module Page.Library exposing (Data, Model, Msg, page)

import Browser.Dom
import Browser.Navigation
import Color
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Http
import Date exposing (Date)
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Helper exposing (nonEmptyString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Identicon
import Json.Decode
import Json.Encode
import KindleBookTitle
import List.Extra
import Markdown
import Murmur3
import OptimizedDecoder
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets as Secrets
import Regex
import RuntimePorts
import Set exposing (Set)
import Shared exposing (seoBase)
import Table
import Task
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
    }


type alias KindleBook =
    { id : ASIN
    , rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : SeriesName
    , authors : List String
    , img : String -- 書影画像URL
    , acquiredDate : Date
    }


type alias ASIN =
    String


type alias SeriesName =
    String


data : DataSource Data
data =
    libraryKeySeedHash
        |> DataSource.andThen
            (\lksh ->
                kindleBooks lksh
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
            )


libraryKeySeedHash : DataSource ( Int, Int )
libraryKeySeedHash =
    DataSource.Env.load "LIBRARY_KEY_SEED_HASH"
        |> DataSource.andThen
            (\s ->
                case String.split "." s |> List.filterMap String.toInt of
                    [ seed, hash ] ->
                        DataSource.succeed ( seed, hash )

                    _ ->
                        DataSource.fail "LIBRARY_KEY_SEED_HASH is invalid"
            )


kindleBooks ( _, derivedKey ) =
    -- TODO derivedKeyを鍵として蔵書DBの中身を対象暗号化しておけば、真に保護されたページを実現できる
    DataSource.Env.load "BOOKS_JSON_URL"
        |> DataSource.andThen
            (\booksJsonUrl ->
                DataSource.Http.get (Secrets.succeed booksJsonUrl) <|
                    OptimizedDecoder.dict <|
                        (OptimizedDecoder.field "title" kindleBookTitle
                            |> OptimizedDecoder.andThen
                                (\parsed ->
                                    OptimizedDecoder.map8 KindleBook
                                        (OptimizedDecoder.field "id" nonEmptyString)
                                        (OptimizedDecoder.succeed parsed.rawTitle)
                                        (OptimizedDecoder.succeed (Maybe.map j2a parsed.label))
                                        (OptimizedDecoder.succeed parsed.volume)
                                        (OptimizedDecoder.succeed parsed.seriesName |> OptimizedDecoder.map j2a)
                                        (OptimizedDecoder.field "authors" (OptimizedDecoder.list (OptimizedDecoder.map (j2a >> normalizeAuthor) nonEmptyString) |> OptimizedDecoder.map (List.filter notStopWords)))
                                        (OptimizedDecoder.field "img" nonEmptyString)
                                        (OptimizedDecoder.field "acquiredDate" japaneseDate)
                                )
                        )
            )


kindleBookTitle =
    OptimizedDecoder.andThen (OptimizedDecoder.fromResult << KindleBookTitle.parse) nonEmptyString


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


j2a : String -> String
j2a =
    let
        mapper c =
            case c of
                '０' ->
                    '0'

                '１' ->
                    '1'

                '２' ->
                    '2'

                '３' ->
                    '3'

                '４' ->
                    '4'

                '５' ->
                    '5'

                '６' ->
                    '6'

                '７' ->
                    '7'

                '８' ->
                    '8'

                '９' ->
                    '9'

                'Ａ' ->
                    'A'

                'Ｂ' ->
                    'B'

                'Ｃ' ->
                    'C'

                'Ｄ' ->
                    'D'

                'Ｅ' ->
                    'E'

                'Ｆ' ->
                    'F'

                'Ｇ' ->
                    'G'

                'Ｈ' ->
                    'H'

                'Ｉ' ->
                    'I'

                'Ｊ' ->
                    'J'

                'Ｋ' ->
                    'K'

                'Ｌ' ->
                    'L'

                'Ｍ' ->
                    'M'

                'Ｎ' ->
                    'N'

                'Ｏ' ->
                    'O'

                'Ｐ' ->
                    'P'

                'Ｑ' ->
                    'Q'

                'Ｒ' ->
                    'R'

                'Ｓ' ->
                    'S'

                'Ｔ' ->
                    'T'

                'Ｕ' ->
                    'U'

                'Ｖ' ->
                    'V'

                'Ｗ' ->
                    'W'

                'Ｘ' ->
                    'X'

                'Ｙ' ->
                    'Y'

                'Ｚ' ->
                    'Z'

                'ａ' ->
                    'a'

                'ｂ' ->
                    'b'

                'ｃ' ->
                    'c'

                'ｄ' ->
                    'd'

                'ｅ' ->
                    'e'

                'ｆ' ->
                    'f'

                'ｇ' ->
                    'g'

                'ｈ' ->
                    'h'

                'ｉ' ->
                    'i'

                'ｊ' ->
                    'j'

                'ｋ' ->
                    'k'

                'ｌ' ->
                    'l'

                'ｍ' ->
                    'm'

                'ｎ' ->
                    'n'

                'ｏ' ->
                    'o'

                'ｐ' ->
                    'p'

                'ｑ' ->
                    'q'

                'ｒ' ->
                    'r'

                'ｓ' ->
                    's'

                'ｔ' ->
                    't'

                'ｕ' ->
                    'u'

                'ｖ' ->
                    'v'

                'ｗ' ->
                    'w'

                'ｘ' ->
                    'x'

                'ｙ' ->
                    'y'

                'ｚ' ->
                    'z'

                '\u{3000}' ->
                    ' '

                '（' ->
                    '('

                '）' ->
                    ')'

                _ ->
                    c
    in
    String.map mapper


normalizeAuthor : String -> String
normalizeAuthor raw =
    if String.all (\c -> Char.toCode c < 256) raw then
        -- Extended ASCIIまでは英字氏名とみなし、スペースを除去しない
        raw

    else
        -- 日本語表記の著者名は、姓名間のスペースを除去して正規化
        -- また、"()"で囲まれた装飾が後置されていることがあるので削除する
        -- ただし、著者名表記はほかにも表記揺れが多く、この正規化処理はおまけ程度
        raw
            |> String.replace " " ""
            |> Regex.replace redundantAuthorSuffixPattern (\_ -> "")


redundantAuthorSuffixPattern =
    Regex.fromString "(\\(.*\\))$" |> Maybe.withDefault Regex.never


notStopWords raw =
    case raw of
        "ほか" ->
            False

        _ ->
            True


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


japaneseDate =
    nonEmptyString
        |> OptimizedDecoder.andThen
            (\str ->
                OptimizedDecoder.fromResult <|
                    case String.split "年" str of
                        [ year, monthDay ] ->
                            case String.split "月" monthDay of
                                [ month, day ] ->
                                    Date.fromIsoString <| String.join "-" <| [ year, String.padLeft 2 '0' month, String.padLeft 2 '0' <| String.dropRight 1 day ]

                                _ ->
                                    Err <| "Invalid Date: " ++ str

                        _ ->
                            Err <| "Invalid Date: " ++ str
            )


type alias Model =
    { sortKey : SortKey
    , filter : Filter

    -- ハーフモーダルのpopoverが閉じるとき、selectedBookをNothingにしてしまうと
    -- アニメーション中に先行してモーダル内が空になってしまい、スライドアウトがきれいに見えない。
    -- そこで開閉状態と選択状態を分けることで、モーダル内のコンテンツは描画したままに保つ
    , popoverOpened : Bool
    , selectedBook : Maybe ( SeriesName, ASIN )

    -- Libraryページをパスワード保護している
    -- 1) 初期状態ではFalseで、書架部分は非表示
    -- 2) localStorage経由でshared.storedLibraryKeyを取得し、unlockできればTrueになり、書架部分を表示
    -- 3) 非表示な書架部分には代わりにパスワードフォームを表示し、unlockできればTrueになり、書架部分を表示
    --    その際、成功したパスワードはlocalStorageに保存してその端末での再入力を不要にする
    , unlocked : Bool

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
      , unlocked = Maybe.withDefault False (Maybe.map (unlockLibrary app.data.libraryKeySeedHash) shared.storedLibraryKey)
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
    | UnlockLibrary Password
    | LockLibrary
    | SeriesTableMsg Table.State
    | AuthorsTableMsg Table.State
    | LabelsTableMsg Table.State


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
                ( { m | popoverOpened = False }
                , if m.selectedBook == Just selected then
                    -- 同じ本を選択した場合、単に閉じて終了
                    Cmd.none

                  else
                    -- 違う本を選択した場合、内容が切り替わったことをわかりやすくするために一瞬閉じるだけで、次の枝ですぐ開く
                    Helper.waitMsg 50 msg
                )

            else
                ( { m | popoverOpened = True, selectedBook = Just selected }, Cmd.none )

        ToggleKindlePopover Nothing ->
            ( { m | popoverOpened = False }, Cmd.none )

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
- **TODO**: 人力データ修正機能
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
        , div [ class "kindle-popover", hidden (not m.popoverOpened) ] (kindlePopover app.data m.filter m.selectedBook)
        , div [ class "kindle-popover", hidden m.unlocked ] kindleLibraryLock
        ]
    }


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
                    -- MNH
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
    app.data.kindleBooks
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
                    books
                    ++ seriesBookmark books
            )
        |> Html.Keyed.node "div" [ class "kindle-bookshelf", classList [ ( "locked", not m.unlocked ) ] ]


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
                    Dict.toList app.data.kindleBooks

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
                            , viewData = \( label, _ ) -> Table.HtmlDetails [] [ filterableTag ToggleAuthorFilter m.filter.labels label ]
                            }
                        , Table.intColumn "冊数" (\( _, count ) -> count)
                        ]
                    }
                )
                m.labelsTableState
                (if m.unlocked then
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
    , ( "購入日", Date.toIsoString book.acquiredDate )
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


kindlePopover : Data -> Filter -> Maybe ( SeriesName, ASIN ) -> List (Html Msg)
kindlePopover data_ f openedBook =
    [ header [ onClick (ToggleKindlePopover Nothing), attribute "role" "button" ] []
    , main_ [] <|
        case getBook data_.kindleBooks openedBook of
            Just ( maybePrev, book, maybeNext ) ->
                [ prevVolume maybePrev
                , article []
                    [ View.imgLazy [ src book.img, width 150, alt <| book.rawTitle ++ "の書影" ] []
                    , div []
                        [ h5 [] [ a [ href (Helper.makeAmazonUrl data_.amazonAssociateTag book.id), target "_blank" ] [ text book.rawTitle ] ]
                        , a [ class "cloud-reader-link", href ("https://read.amazon.co.jp/manga/" ++ book.id), target "_blank" ] [ text "Kindleビューアで読む" ]
                        , ul [] <|
                            List.filterMap (Maybe.map (\( key, kids ) -> li [] (strong [] [ text key ] :: text " : " :: kids)))
                                [ Just ( "著者", List.map (filterableTag ToggleAuthorFilter f.authors) book.authors )
                                , if book.seriesName == book.rawTitle then
                                    Nothing

                                  else
                                    Just ( "シリーズ", [ text book.seriesName ] )
                                , Maybe.map (\label_ -> ( "レーベル", [ filterableTag ToggleLabelFilter f.labels label_ ] )) book.label
                                , Just ( "購入日", [ text (Date.toIsoString book.acquiredDate) ] )
                                ]
                        ]
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
