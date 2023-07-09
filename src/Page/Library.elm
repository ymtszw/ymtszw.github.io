module Page.Library exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Http
import Date exposing (Date)
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Helper exposing (nonEmptyString)
import Html exposing (Html, a, article, dd, div, dl, dt, figure, h1, h2, h3, h5, header, li, main_, option, p, pre, select, span, strong, text, ul)
import Html.Attributes exposing (alt, attribute, class, hidden, href, id, property, selected, src, target, title, value, width)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Json.Decode
import KindleBookTitle
import List.Extra
import Markdown
import OptimizedDecoder
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets as Secrets
import Shared exposing (seoBase)
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
    , amazonAssociateTag : String
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
    DataSource.map2 Data
        kindleBooks
        (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")


kindleBooks =
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
                                        (OptimizedDecoder.field "authors" (OptimizedDecoder.list (OptimizedDecoder.map j2a nonEmptyString)))
                                        (OptimizedDecoder.field "img" nonEmptyString)
                                        (OptimizedDecoder.field "acquiredDate" japaneseDate)
                                )
                        )
            )
        |> DataSource.map groupBySeriesName


kindleBookTitle =
    OptimizedDecoder.andThen (OptimizedDecoder.fromResult << KindleBookTitle.parse) nonEmptyString


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

                _ ->
                    c
    in
    String.map mapper


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

    -- ハーフモーダルのpopoverが閉じるとき、selectedBookをNothingにしてしまうと
    -- アニメーション中に先行してモーダル内が空になってしまい、スライドアウトがきれいに見えない。
    -- そこで開閉状態と選択状態を分けることで、モーダル内のコンテンツは描画したままに保つ
    , popoverOpened : Bool
    , selectedBook : Maybe ( SeriesName, ASIN )
    }


type SortKey
    = DATE_ASC
    | DATE_DESC
    | AUTHOR
    | TITLE


sortKeys =
    [ DATE_DESC, DATE_ASC, AUTHOR, TITLE ]


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
init _ _ _ =
    ( { sortKey = DATE_DESC, popoverOpened = False, selectedBook = Nothing }, Cmd.none )


type Msg
    = SetSortKey String
    | ToggleKindlePopover (Maybe ( SeriesName, ASIN ))


update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ _ _ msg m =
    case msg of
        SetSortKey sk ->
            ( { m | sortKey = stringToSortKey sk }, Cmd.none )

        ToggleKindlePopover (Just selected) ->
            if m.popoverOpened then
                -- すでにpopoverが開いている場合、内容が切り替わったことをわかりやすくするために一瞬閉じる
                ( { m | popoverOpened = False }, Helper.waitMsg 50 msg )

            else
                ( { m | popoverOpened = True, selectedBook = Just selected }, Cmd.none )

        ToggleKindlePopover Nothing ->
            ( { m | popoverOpened = False }, Cmd.none )


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "書架"
            , description = "Kindle蔵書リスト。基本的には自分用のポータルページだが、将来的にレビュー機能をつけて公開したい"
        }
        |> Seo.website


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
        , div [] <| Markdown.parseAndRender Dict.empty """
Kindle蔵書リスト。前々から自分用に使いやすいKindleのフロントエンドがほしいと思っていたので自作し始めたページ。仕組み：

- Kindleのコンテンツ一覧ページをTampermonkeyスクリプトでスクレイプ
- 上記ページを不定期に手動で開いて蔵書DBファイルを更新
- サイトビルド時に蔵書DBファイルを読み込み、ページを描画
- **TODO**: 検索機能提供
- **TODO**: 自分限定のレビュー機能をつける
- **TODO**: いい感じに「本棚」「書架」っぽいUIを探求
"""
        , select [ onInput SetSortKey ] <| List.map (\sk -> option [ value <| sortKeyToString sk, selected <| m.sortKey == sk ] [ text <| sortKeyToString sk ]) sortKeys
        , let
            item ( label, value ) =
                case value of
                    "" ->
                        []

                    nonEmpty ->
                        [ label ++ ": " ++ nonEmpty ]

            metadata book =
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

            clickBookEvent book =
                Json.Decode.succeed
                    { message = ToggleKindlePopover (Just ( book.seriesName, book.id ))
                    , preventDefault = True
                    , stopPropagation = True
                    }
          in
          app.data.kindleBooks
            |> Dict.toList
            |> doSort m.sortKey
            |> List.concatMap
                (\( _, books ) ->
                    List.map
                        (\book ->
                            a
                                [ class "has-image"
                                , href <| "https://read.amazon.co.jp/manga/" ++ book.id
                                , target "_blank"
                                , title (metadata book)
                                , Html.Events.custom "click" (clickBookEvent book)
                                ]
                                [ View.imgLazy [ src book.img, width 50, alt <| book.rawTitle ++ "の書影" ] [] ]
                                |> Tuple.pair (book.id ++ "-link")
                        )
                        books
                )
            |> Html.Keyed.node "div" []
        , div [ class "kindle-popover", hidden (not m.popoverOpened) ] (kindlePopover app.data m.selectedBook)
        ]
    }


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


kindlePopover : Data -> Maybe ( SeriesName, ASIN ) -> List (Html Msg)
kindlePopover data_ openedBook =
    [ header [ onClick (ToggleKindlePopover Nothing), attribute "role" "button" ] []
    , main_ [] <|
        case getBook data_.kindleBooks openedBook of
            Just book ->
                [ View.imgLazy [ src book.img, width 150, alt <| book.rawTitle ++ "の書影" ] []
                , article []
                    [ h5 [] [ a [ href (Helper.makeAmazonUrl data_.amazonAssociateTag book.id), target "_blank" ] [ text book.rawTitle ] ]
                    , ul [] <|
                        List.filterMap (Maybe.map (\( key, kids ) -> li [] (strong [] [ text key ] :: text " : " :: kids)))
                            [ Just ( "著者", [ text <| String.join ", " book.authors ] )
                            , if book.seriesName == book.rawTitle then
                                Nothing

                              else
                                Just ( "シリーズ", [ text book.seriesName ] )
                            , Maybe.map (\label_ -> ( "レーベル", [ text label_ ] )) book.label
                            , Just ( "購入日", [ text (Date.toIsoString book.acquiredDate) ] )
                            ]
                    ]
                ]

            Nothing ->
                []
    ]


getBook dict openedBook =
    openedBook
        |> Maybe.andThen
            (\( seriesName, asin ) ->
                Dict.get seriesName dict
                    |> Maybe.andThen (\books -> List.Extra.find (\book -> book.id == asin) books)
            )
