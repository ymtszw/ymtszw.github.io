module Page.Library exposing (Data, Model, Msg, page)

import Browser.Dom
import Browser.Navigation
import Color
import DataSource exposing (DataSource)
import DataSource.Env
import Date
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Helper exposing (dataSourceWith, onChange)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Identicon
import Json.Decode
import Json.Encode
import KindleBook exposing (ASIN, KindleBook, SeriesName, kindleBooks)
import List.Extra
import Markdown
import Murmur3
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Route
import RuntimePorts
import Set exposing (Set)
import Shared exposing (seoBase)
import Table
import Task
import Url.Builder
import View exposing (View)


type alias RouteParams =
    {}


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithLocalState
            { init = init
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


type alias Data =
    { kindleBooks : Dict SeriesName (List KindleBook)
    , numberOfBooks : Int
    , authors : Dict String Int
    , labels : Dict String Int
    , amazonAssociateTag : String
    , libraryKeySeedHash : ( Int, Int )
    , secrets : KindleBook.Secrets
    }


data : DataSource Data
data =
    dataSourceWith libraryKeySeedHash <|
        \lksh ->
            -- TODO lkshを元にderivedKeyを作り、鍵として蔵書DBの中身を対称暗号化しておけば、
            -- index.htmlを読み込んだ時点では真に保護されたページを実現できる
            kindleBooks
                |> DataSource.map
                    (\booksByAsin ->
                        let
                            ( authors, labels ) =
                                countByAuthorsAndLabels booksByAsin
                        in
                        Data (groupBySeriesName booksByAsin) (Dict.size booksByAsin) authors labels
                    )
                |> DataSource.andMap (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")
                |> DataSource.andMap (DataSource.succeed lksh)
                |> DataSource.andMap KindleBook.secrets


libraryKeySeedHash : DataSource ( Int, Int )
libraryKeySeedHash =
    dataSourceWith (DataSource.Env.load "LIBRARY_KEY_SEED_HASH") <|
        \s ->
            case String.split "." s |> List.filterMap String.toInt of
                [ seed, hash ] ->
                    DataSource.succeed ( seed, hash )

                _ ->
                    DataSource.fail "LIBRARY_KEY_SEED_HASH is invalid"


countByAuthorsAndLabels : Dict ASIN KindleBook -> ( Dict String Int, Dict String Int )
countByAuthorsAndLabels =
    Dict.foldl
        (\_ book ( accAuthors, accLabels ) ->
            ( List.foldl increment accAuthors book.authors
            , book.label |> Maybe.map (\label -> increment label accLabels) |> Maybe.withDefault accLabels
            )
        )
        ( Dict.empty, Dict.empty )


increment : comparable -> Dict comparable Int -> Dict comparable Int
increment key dict =
    Dict.update key
        (\count ->
            case count of
                Just count_ ->
                    Just (count_ + 1)

                Nothing ->
                    Just 1
        )
        dict


groupBySeriesName : Dict String KindleBook -> Dict SeriesName (List KindleBook)
groupBySeriesName =
    Dict.foldl
        (\_ book acc ->
            Dict.update book.seriesName
                (\books ->
                    case books of
                        Just books_ ->
                            Just (List.sortBy .volume (book :: books_))

                        Nothing ->
                            Just [ book ]
                )
                acc
        )
        Dict.empty


type alias Model =
    { sortKey : SortKey
    , filter : Filter

    -- ハーフモーダルのpopoverが閉じるとき、selectedBookをNothingにしてしまうと
    -- アニメーション中に先行してモーダル内が空になってしまい、スライドアウトがきれいに見えない。
    -- そこで開閉状態と選択状態を分けることで、モーダル内のコンテンツは描画したままに保つ
    , popoverOpened : Bool
    , selectedBook : Maybe ( SeriesName, ASIN )
    , editingBook : Maybe KindleBook

    -- Libraryページをパスワード保護している
    -- 1) 初期状態ではFalseで、書架部分は非表示
    -- 2) localStorage経由でshared.storedLibraryKeyを取得し、unlockできればTrueになり、書架部分を表示
    -- 3) 非表示な書架部分には代わりにパスワードフォームを表示し、unlockできればTrueになり、書架部分を表示
    --    その際、成功したパスワードはlocalStorageに保存してその端末での再入力を不要にする
    , unlocked : Bool
    , -- TODO data.kindleBooksが暗号化されるようになったら、unlockしたときにデータを復号し、初めてこのDictが実体化する。
      -- こちらのデータはruntimeにAlgoliaからオンデマンドに取得した最新データを持っている。
      decryptedKindleBooks : Dict SeriesName (List KindleBook)

    -- kindle-dataセクションのテーブルはelm-sortable-tableで可動式にしている
    , seriesTableState : Table.State
    , authorsTableState : Table.State
    , labelsTableState : Table.State
    }


type SortKey
    = DATE_ASC
    | DATE_DESC
    | AUTHOR
    | TITLE


sortKeys =
    [ DATE_DESC, DATE_ASC, AUTHOR, TITLE ]


type alias Filter =
    { authors : Set String
    , labels : Set String
    }


noFilter =
    { authors = Set.empty, labels = Set.empty }


sortKeyToString : SortKey -> String
sortKeyToString sk =
    case sk of
        DATE_ASC ->
            "昔に買った順"

        DATE_DESC ->
            "最近買った順"

        AUTHOR ->
            "著者名順"

        TITLE ->
            "タイトル順"


stringToSortKey : String -> SortKey
stringToSortKey str =
    case str of
        "昔に買った順" ->
            DATE_ASC

        "最近買った順" ->
            DATE_DESC

        "著者名順" ->
            AUTHOR

        "タイトル順" ->
            TITLE

        _ ->
            TITLE


init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init _ shared app =
    ( { sortKey = DATE_DESC
      , filter = noFilter
      , popoverOpened = False
      , selectedBook = Nothing
      , editingBook = Nothing
      , unlocked = Maybe.withDefault False (Maybe.map (unlockLibrary app.data.libraryKeySeedHash) shared.storedLibraryKey)
      , -- TODO app.data.kindleBooksが暗号化されるようになったら、当初はempty dictから初めて復号成功時にデータを入れる。
        decryptedKindleBooks = app.data.kindleBooks
      , seriesTableState = Table.initialSort ""
      , authorsTableState = Table.initialSort ""
      , labelsTableState = Table.initialSort ""
      }
    , Cmd.none
    )


type alias Password =
    String


unlockLibrary : ( Int, Int ) -> Password -> Bool
unlockLibrary ( seed, hash ) pw =
    Murmur3.hashString seed pw == hash


type Msg
    = SetSortKey String
    | ToggleAuthorFilter Bool String
    | ToggleLabelFilter Bool String
    | ToggleKindlePopover (Maybe ( SeriesName, ASIN ))
    | EditKindleBook (Maybe KindleBook)
    | UnlockLibrary Password
    | LockLibrary
    | SeriesTableMsg Table.State
    | AuthorsTableMsg Table.State
    | LabelsTableMsg Table.State
    | Res_refreshKindleBookOnDemand (Result String KindleBook)


update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ _ app msg ({ filter } as m) =
    case msg of
        SetSortKey sk ->
            ( { m | sortKey = stringToSortKey sk }, Cmd.none )

        ToggleAuthorFilter switch author ->
            ( { m | filter = { filter | authors = toggle switch author filter.authors } }, Cmd.none )

        ToggleLabelFilter switch author ->
            ( { m | filter = { filter | labels = toggle switch author filter.labels } }, Cmd.none )

        ToggleKindlePopover (Just selected) ->
            if m.popoverOpened then
                -- すでにpopoverが開いている場合:
                ( { m | popoverOpened = False, editingBook = Nothing }
                , if m.selectedBook == Just selected then
                    -- 同じ本を選択した場合、単に閉じて終了
                    Cmd.none

                  else
                    -- 違う本を選択した場合、内容が切り替わったことをわかりやすくするために一瞬閉じるだけで、次の枝ですぐ開く
                    Helper.waitMsg 50 msg
                )

            else
                ( { m | popoverOpened = True, selectedBook = Just selected }
                , -- 人力注釈やレビューでKindleBookはruntimeに更新されている可能性がある
                  -- しばらく時間が経てばstatic buildにも反映されるが、それまではオンデマンドで取得しないとstaleデータが見え続ける
                  -- このページではPopoverを開いたタイミングで更新する
                  KindleBook.getOnDemand Res_refreshKindleBookOnDemand app.data.secrets (Tuple.second selected)
                )

        ToggleKindlePopover Nothing ->
            ( { m | popoverOpened = False, editingBook = Nothing }, Cmd.none )

        EditKindleBook editingBook ->
            case ( m.selectedBook, m.editingBook, editingBook ) of
                ( Just ( previousSeriesName, _ ), Just editing, Nothing ) ->
                    -- 明示的な編集終了動作を確定とみなして保存する
                    -- このとき初めての保存動作であれば、何も編集していなかったとしても、
                    -- editingの中身がGist由来の元の書籍タイトルをparseした結果であるため、
                    -- それがAlgoliaに保存されて若干情報量が増える。
                    -- ２回目以降の保存動作であれば、実際に内容に変更がないと挙動に変化がない。
                    ( if previousSeriesName == editing.seriesName then
                        { m | editingBook = editingBook }

                      else
                        -- シリーズ名が変わった場合
                        -- NOTE: この処理はRes_refreshKindleBookOnDemand側の枝で行ったほうが汎用性が高まり、
                        -- static buildが行われるまでの間に別のセッションで更新されたbookを読み込んだときに辞書を更新できる。
                        -- が、この枝で実装したほうがpreviousSeriesNameと自然に比較できるので面倒が少ない。
                        let
                            updater previousSeries =
                                case List.filter (\book -> book.id /= editing.id) previousSeries of
                                    [] ->
                                        Nothing

                                    updated ->
                                        Just updated
                        in
                        { m
                            | editingBook = editingBook
                            , selectedBook = Just ( editing.seriesName, editing.id )
                            , decryptedKindleBooks = Dict.update previousSeriesName (Maybe.andThen updater) m.decryptedKindleBooks
                        }
                    , KindleBook.putOnDemand Res_refreshKindleBookOnDemand app.data.secrets editing
                    )

                _ ->
                    ( { m | editingBook = editingBook }, Cmd.none )

        UnlockLibrary pw ->
            if unlockLibrary app.data.libraryKeySeedHash pw then
                ( { m | unlocked = True }
                , RuntimePorts.toJs <|
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "StoreLibraryKey" )
                        , ( "value", Json.Encode.string pw )
                        ]
                )

            else
                ( m, Cmd.none )

        LockLibrary ->
            ( { m | unlocked = False }
            , Cmd.batch
                [ RuntimePorts.toJs <|
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "StoreLibraryKey" )
                        , ( "value", Json.Encode.string "" )
                        ]
                , Browser.Dom.setViewport 0 0 |> Task.perform (\_ -> ToggleKindlePopover Nothing)
                ]
            )

        SeriesTableMsg state ->
            ( { m | seriesTableState = state }, Cmd.none )

        AuthorsTableMsg state ->
            ( { m | authorsTableState = state }, Cmd.none )

        LabelsTableMsg state ->
            ( { m | labelsTableState = state }, Cmd.none )

        Res_refreshKindleBookOnDemand (Ok book) ->
            let
                updater currentSeries =
                    case currentSeries of
                        Just books ->
                            -- groupBySeriesNameのsort挙動に従う
                            Just <|
                                List.sortBy .volume <|
                                    case List.Extra.findIndex (\before -> before.id == book.id) books of
                                        Just foundIndex ->
                                            -- 既存シリーズの本のシリーズ名以外を編集した場合
                                            List.Extra.setAt foundIndex book books

                                        Nothing ->
                                            -- 別のシリーズから移動した場合
                                            book :: books

                        Nothing ->
                            -- 人力注釈でシリーズ名を編集した後にread after writeすると新規シリーズが生まれることがある
                            Just [ book ]
            in
            ( { m | decryptedKindleBooks = Dict.update book.seriesName updater m.decryptedKindleBooks }, Cmd.none )

        Res_refreshKindleBookOnDemand (Err _) ->
            ( m, Cmd.none )


toggle : Bool -> comparable -> Set comparable -> Set comparable
toggle switch e set =
    if switch then
        Set.insert e set

    else
        Set.remove e set


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    (Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "書架"
            , description = "Kindle蔵書リスト。基本的には自分用のページで検索にも載せないが、レビュー機能を持ち、レビューを投稿するとシリーズ単位で一般公開記事化される仕組み"
        }
        |> Seo.website
    )
        ++ [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ m app =
    { title = "書架"
    , body =
        [ h1 [] [ text "書架" ]
        , div [] <|
            Markdown.parseAndRender Dict.empty <|
                """
Kindle蔵書リスト。前々から自分用に使いやすいKindleのフロントエンドがほしいと思っていたので自作し始めたページ。仕組み：

- [Kindleのコンテンツ一覧ページ](https://www.amazon.co.jp/hz/mycd/digital-console/contentlist/booksAll/dateDsc/)をTampermonkeyスクリプトでスクレイプ
- 上記ページを不定期に手動で開いて蔵書DBを更新
- サイトビルド時に蔵書DBを読み込み、ページを描画
- ただし書架は検索に載せない自分専用、事前共有鍵でロック
- データの正規化（人力注釈）機能
- **TODO**: レビュー機能＆レビュー自動記事化
- **TODO**: DataSourceを暗号化→ロック解除時に復号
"""
        , kindleData m app
        , div [ class "kindle-control", classList [ ( "locked", not m.unlocked ) ] ] <|
            (select [ onInput SetSortKey ] <| List.map (\sk -> option [ value <| sortKeyToString sk, selected <| m.sortKey == sk ] [ text <| sortKeyToString sk ]) sortKeys)
                :: (List.map (filterableTag ToggleAuthorFilter m.filter.authors) <| Set.toList m.filter.authors)
                ++ List.map (filterableTag ToggleLabelFilter m.filter.labels) (Set.toList m.filter.labels)
        , kindleBookshelf m app
        , lockKindleLibrary
        , div [ class "kindle-popover", hidden (not m.popoverOpened) ] (kindlePopover app.data.amazonAssociateTag m.decryptedKindleBooks m.filter m.selectedBook m.editingBook)
        , div [ class "kindle-popover", hidden m.unlocked ] kindleLibraryLock
        ]
    }


kindleBookshelf : Model -> StaticPayload Data RouteParams -> Html Msg
kindleBookshelf m app =
    let
        clickBookEvent book =
            Json.Decode.succeed
                { message = ToggleKindlePopover (Just ( book.seriesName, book.id ))
                , preventDefault = True
                , stopPropagation = True
                }

        seriesColor sn =
            Color.toCssString (Identicon.defaultColor sn)

        seriesBookmark books =
            case books of
                [] ->
                    -- 人力注釈でシリーズにあった本がすべて別シリーズに修正されるとemptyになる
                    []

                first :: _ ->
                    [ Tuple.pair (first.id ++ "-series-bookmark") <|
                        span [ class "series-bookmark", attribute "data-count" (String.fromInt (List.length books)) ]
                            [ text <|
                                if m.unlocked then
                                    first.seriesName

                                else
                                    String.map (\_ -> 'X') first.seriesName
                            ]
                    ]
    in
    (if m.unlocked then
        m.decryptedKindleBooks

     else
        app.data.kindleBooks
    )
        |> doFilter m.filter
        |> Dict.toList
        |> doSort m.sortKey
        |> List.concatMap
            (\( seriesName, books ) ->
                List.map
                    (\book ->
                        Tuple.pair (book.id ++ "-link") <|
                            if m.unlocked then
                                a
                                    [ class "has-image"
                                    , href <| "https://read.amazon.co.jp/manga/" ++ book.id
                                    , target "_blank"
                                    , title (bookMetadata book)
                                    , style "border-top" <| "5px solid " ++ seriesColor seriesName
                                    , Html.Events.custom "click" (clickBookEvent book)
                                    ]
                                    [ View.imgLazy [ class "kindle-bookshelf-image", src book.img, width 50, alt <| book.rawTitle ++ "の書影" ] [] ]

                            else
                                a
                                    [ class "has-image"
                                    , href "https://read.amazon.co.jp/"
                                    , target "_blank"
                                    , style "border-top" <| "5px solid " ++ seriesColor seriesName
                                    ]
                                    [ div [ class "kindle-bookshelf-image", style "background-color" <| seriesColor seriesName ] [] ]
                    )
                    -- booksはDataSourceの時点でvolumeでソートされている前提
                    books
                    ++ seriesBookmark books
            )
        |> Html.Keyed.node "div" [ class "kindle-bookshelf", classList [ ( "locked", not m.unlocked ) ] ]


kindleData : Model -> StaticPayload Data RouteParams -> Html Msg
kindleData m app =
    details [ class "kindle-data", classList [ ( "locked", not m.unlocked ) ] ]
        [ summary [] [ text <| "蔵書数: " ++ String.fromInt app.data.numberOfBooks ]
        , details []
            [ summary [] [ text <| "シリーズ数: " ++ String.fromInt (Dict.size app.data.kindleBooks) ++ " （１冊しか存在・購入していないものも含む）" ]
            , p []
                [ text "※KindleBookTitleパーサが対応できない形式のタイトル表記については、人力注釈が必要。"
                , br [] []
                , text "例えば現状、サブタイトルがある形式に対応していない。"
                ]
            , Table.view
                (Table.config
                    { toId = \( seriesName, _ ) -> seriesName
                    , toMsg = SeriesTableMsg
                    , columns =
                        [ Table.stringColumn "シリーズ名" (\( seriesName, _ ) -> seriesName)
                        , Table.intColumn "冊数" (\( _, books ) -> List.length books)
                        ]
                    }
                )
                m.seriesTableState
                (if m.unlocked then
                    Dict.toList m.decryptedKindleBooks

                 else
                    []
                )
            ]
        , details []
            [ summary [] [ text <| "著者数: " ++ String.fromInt (Dict.size app.data.authors) ]
            , Table.view
                (Table.config
                    { toId = \( author, _ ) -> author
                    , toMsg = AuthorsTableMsg
                    , columns =
                        [ Table.veryCustomColumn
                            { name = "著者名"
                            , sorter = Table.decreasingOrIncreasingBy <| \( author, _ ) -> author
                            , viewData = \( author, _ ) -> Table.HtmlDetails [] [ filterableTag ToggleAuthorFilter m.filter.authors author ]
                            }
                        , Table.intColumn "冊数" (\( _, count ) -> count)
                        ]
                    }
                )
                m.authorsTableState
                (if m.unlocked then
                    -- 統計テーブルの方はstaticデータの更新までstaleデータを元にする
                    Dict.toList app.data.authors

                 else
                    []
                )
            ]
        , details []
            [ summary [] [ text <| "レーベル数: " ++ String.fromInt (Dict.size app.data.labels) ]
            , Table.view
                (Table.config
                    { toId = \( label, _ ) -> label
                    , toMsg = LabelsTableMsg
                    , columns =
                        [ Table.veryCustomColumn
                            { name = "レーベル名"
                            , sorter = Table.decreasingOrIncreasingBy <| \( label, _ ) -> label
                            , viewData = \( label, _ ) -> Table.HtmlDetails [] [ filterableTag ToggleLabelFilter m.filter.labels label ]
                            }
                        , Table.intColumn "冊数" (\( _, count ) -> count)
                        ]
                    }
                )
                m.labelsTableState
                (if m.unlocked then
                    -- 統計テーブルの方はstaticデータの更新までstaleデータを元にする
                    Dict.toList app.data.labels

                 else
                    []
                )
            ]
        ]


doFilter : Filter -> Dict SeriesName (List KindleBook) -> Dict SeriesName (List KindleBook)
doFilter f =
    let
        filterByAuthors authors books =
            List.any (\author -> List.any (\book -> List.member author book.authors) books) authors

        filterByLabels labels books =
            List.any (\label_ -> List.any (\book -> Maybe.withDefault "" book.label == label_) books) labels
    in
    -- 基本的にシリーズ単位でList.anyで探索するため、シリーズ途中で著者やレーベルが変わった場合もシリーズ全巻がマッチする
    case ( Set.toList f.authors, Set.toList f.labels ) of
        ( [], [] ) ->
            identity

        ( nonEmptyAuthors, [] ) ->
            Dict.filter (\_ books -> filterByAuthors nonEmptyAuthors books)

        ( [], nonEmptyLabels ) ->
            Dict.filter (\_ books -> filterByLabels nonEmptyLabels books)

        ( nonEmptyAuthors, nonEmptyLabels ) ->
            Dict.filter (\_ books -> filterByAuthors nonEmptyAuthors books || filterByLabels nonEmptyLabels books)


doSort : SortKey -> List ( SeriesName, List KindleBook ) -> List ( SeriesName, List KindleBook )
doSort sk =
    case sk of
        DATE_ASC ->
            List.sortWith (compareWithAcquiredDate True)

        DATE_DESC ->
            List.sortWith (compareWithAcquiredDate False)

        AUTHOR ->
            List.sortWith compareWithFirstAuthor

        TITLE ->
            List.sortBy Tuple.first


compareWithAcquiredDate : Bool -> ( SeriesName, List KindleBook ) -> ( SeriesName, List KindleBook ) -> Order
compareWithAcquiredDate isAsc ( _, books1 ) ( _, books2 ) =
    case ( List.reverse books1, List.reverse books2 ) of
        ( latest1 :: _, latest2 :: _ ) ->
            if isAsc then
                Date.compare latest1.acquiredDate latest2.acquiredDate

            else
                Date.compare latest2.acquiredDate latest1.acquiredDate

        ( _, _ ) ->
            EQ


compareWithFirstAuthor : ( SeriesName, List KindleBook ) -> ( SeriesName, List KindleBook ) -> Order
compareWithFirstAuthor ( _, books1 ) ( _, books2 ) =
    case ( books1, books2 ) of
        ( book1 :: _, book2 :: _ ) ->
            case ( book1.authors, book2.authors ) of
                ( author1 :: _, author2 :: _ ) ->
                    Basics.compare author1 author2

                _ ->
                    EQ

        _ ->
            EQ


bookMetadata : KindleBook -> String
bookMetadata book =
    let
        item ( label, value ) =
            case value of
                "" ->
                    []

                nonEmpty ->
                    [ label ++ ": " ++ nonEmpty ]
    in
    [ ( "タイトル", book.rawTitle )
    , ( "ASIN", book.id )
    , ( "巻数", String.fromInt book.volume )
    , ( "シリーズ", book.seriesName )
    , ( "著者", String.join ", " book.authors )
    , ( "レーベル", Maybe.withDefault "" book.label )
    , ( "購入日", Helper.toJapaneseDate book.acquiredDate )
    ]
        |> List.concatMap item
        |> String.join "\n"


filterableTag : (Bool -> String -> Msg) -> Set String -> String -> Html Msg
filterableTag event filter word =
    let
        attrs =
            if Set.member word filter then
                [ class "active", onClick (event False word) ]

            else
                [ onClick (event True word) ]
    in
    button (class "kindle-filterable-tag" :: attrs) [ text word ]


kindleLibraryLock : List (Html Msg)
kindleLibraryLock =
    [ main_ []
        [ article [ class "kindle-library-lock" ]
            [ Html.form [] [ input [ type_ "password", autofocus True, onInput UnlockLibrary ] [] ]
            ]
        ]
    ]


lockKindleLibrary : Html Msg
lockKindleLibrary =
    button [ onClick LockLibrary ] [ text "再度ロックする（テスト用）" ]


kindlePopover : String -> Dict SeriesName (List KindleBook) -> Filter -> Maybe ( SeriesName, ASIN ) -> Maybe KindleBook -> List (Html Msg)
kindlePopover amazonAssociateTag decryptedKindleBooks f openedBook maybeEditingBook =
    [ header [ onClick (ToggleKindlePopover Nothing), attribute "role" "button" ] []
    , main_ [] <|
        case getBook decryptedKindleBooks openedBook of
            Just ( maybePrev, book, maybeNext ) ->
                [ prevVolume maybePrev
                , article []
                    [ View.imgLazy [ src book.img, width 150, alt <| book.rawTitle ++ "の書影" ] []
                    , div [] <|
                        let
                            editablePart =
                                case maybeEditingBook of
                                    Nothing ->
                                        [ button [ class "kindle-book-edit-button", onClick (EditKindleBook (Just book)) ] []
                                        , ul [] <|
                                            List.filterMap (Maybe.map (\( key, kids ) -> li [] (strong [] [ text key ] :: text " : " :: kids)))
                                                [ Just ( "著者", List.map (filterableTag ToggleAuthorFilter f.authors) book.authors )
                                                , if book.seriesName == book.rawTitle then
                                                    Nothing

                                                  else
                                                    Just ( "シリーズ", [ text book.seriesName ] )
                                                , Maybe.map (\label_ -> ( "レーベル", [ filterableTag ToggleLabelFilter f.labels label_ ] )) book.label
                                                , Just ( "購入日", [ text (Helper.toJapaneseDate book.acquiredDate) ] )
                                                , Just ( "レビュー", [ a [ href reviewUrl ] [ text "書く" ] ] )
                                                ]
                                        ]

                                    Just editingBook ->
                                        [ button [ class "kindle-book-edit-button active", onClick (EditKindleBook Nothing) ] []
                                        , ul [] <|
                                            List.map (\( key, kid ) -> li [] [ strong [] [ text key ], text " : ", kid ]) <|
                                                let
                                                    edit handler currentValue =
                                                        input [ class "kindle-book-edit-input", type_ "text", value currentValue, onChange (EditKindleBook << Just << handler) ] []
                                                in
                                                [ ( "著者", edit (\s -> { editingBook | authors = String.split "," s |> List.map String.trim }) (String.join "," editingBook.authors) )
                                                , ( "シリーズ", edit (\s -> { editingBook | seriesName = s }) editingBook.seriesName )
                                                , ( "巻数", edit (\s -> String.toInt s |> Maybe.map (\i -> { editingBook | volume = i }) |> Maybe.withDefault editingBook) (String.fromInt editingBook.volume) )
                                                , ( "レーベル", edit (\s -> { editingBook | label = Just s }) (Maybe.withDefault "" editingBook.label) )
                                                , ( "購入日", text (Helper.toJapaneseDate editingBook.acquiredDate) )
                                                , ( "レビュー", a [ href reviewUrl ] [ text "書く" ] )
                                                ]
                                        ]

                            reviewUrl =
                                -- 執筆したいときは書架ページからの遷移を必須とすることで自分しか書けないようにしたい
                                Url.Builder.absolute (Route.routeToPath Route.Reviews__Draft) [ Url.Builder.string "id" book.id ]
                        in
                        [ h5 [] [ a [ href (Helper.makeAmazonUrl amazonAssociateTag book.id), target "_blank" ] [ text book.rawTitle ] ]
                        , a [ class "cloud-reader-link", href ("https://read.amazon.co.jp/manga/" ++ book.id), target "_blank" ] [ text "Kindleビューアで読む" ]
                        ]
                            ++ editablePart
                    ]
                , nextVolume maybeNext
                ]

            Nothing ->
                []
    ]


getBook dict openedBook =
    openedBook
        |> Maybe.andThen
            (\( seriesName, asin ) ->
                Dict.get seriesName dict
                    |> Maybe.andThen
                        (\books ->
                            books
                                |> List.Extra.selectSplit
                                |> List.Extra.find (\( _, book, _ ) -> book.id == asin)
                                |> Maybe.map
                                    (\( prev, selected, next ) ->
                                        ( List.head <| List.reverse prev
                                        , selected
                                        , List.head next
                                        )
                                    )
                        )
            )


prevVolume maybePrev =
    case maybePrev of
        Just prev ->
            div [ class "prev-volume active", title (bookMetadata prev), onClick (ToggleKindlePopover (Just ( prev.seriesName, prev.id ))) ]
                [ View.imgLazy [ src prev.img, width 34, alt <| prev.rawTitle ++ "の書影" ] [] ]

        Nothing ->
            div [ class "prev-volume" ] []


nextVolume maybeNext =
    case maybeNext of
        Just next ->
            div [ class "next-volume active", title (bookMetadata next), onClick (ToggleKindlePopover (Just ( next.seriesName, next.id ))) ]
                [ View.imgLazy [ src next.img, width 34, alt <| next.rawTitle ++ "の書影" ] [] ]

        Nothing ->
            div [ class "prev-volume" ] []
