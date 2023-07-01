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
import Html exposing (a, div, h1, option, select, text)
import Html.Attributes exposing (alt, class, href, selected, src, target, value, width)
import Html.Events exposing (onInput)
import KindleBookTitle
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
    Dict String KindleBook


type alias KindleBook =
    { id : String -- ASIN
    , rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : String
    , authors : List String
    , img : String -- 書影画像URL
    , acquiredDate : Date
    }


data : DataSource Data
data =
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
                                        (OptimizedDecoder.succeed parsed.label)
                                        (OptimizedDecoder.succeed parsed.volume)
                                        (OptimizedDecoder.succeed parsed.seriesName)
                                        (OptimizedDecoder.field "authors" (OptimizedDecoder.list nonEmptyString))
                                        (OptimizedDecoder.field "img" nonEmptyString)
                                        (OptimizedDecoder.field "acquiredDate" japaneseDate)
                                )
                        )
            )


kindleBookTitle =
    OptimizedDecoder.andThen (OptimizedDecoder.fromResult << KindleBookTitle.parse) nonEmptyString


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
    }


type SortKey
    = DATE
    | TITLE


sortKeys =
    [ DATE, TITLE ]


sortKeyToString : SortKey -> String
sortKeyToString sk =
    case sk of
        DATE ->
            "購入日順"

        TITLE ->
            "タイトル順"


stringToSortKey : String -> SortKey
stringToSortKey str =
    case str of
        "購入日順" ->
            DATE

        "タイトル順" ->
            TITLE

        _ ->
            TITLE


init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init _ _ _ =
    ( { sortKey = DATE }, Cmd.none )


type Msg
    = SetSortKey String


update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg )
update _ _ _ _ msg m =
    case msg of
        SetSortKey sk ->
            ( { m | sortKey = stringToSortKey sk }, Cmd.none )


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

- Kindleのコンテンツ一覧ページをスクレイプするTampermonkeyスクリプトを実装
- 上記ページを不定期に手動で開いてスクレイピング→蔵書DBファイルを更新
- サイトビルド時に蔵書DBファイルを読み込み、ページを描画
- **TODO**: Meilisearchで検索機能提供
- **TODO**: 自分限定のレビュー機能をつける
- **TODO**: いい感じに「本棚」「書架」っぽいUIを探求
"""
        , select [ onInput SetSortKey ] <| List.map (\sk -> option [ value <| sortKeyToString sk, selected <| m.sortKey == sk ] [ text <| sortKeyToString sk ]) sortKeys
        , app.data
            |> Dict.toList
            |> doSort m.sortKey
            |> List.map
                (\( asin, book ) ->
                    a [ class "has-image", href <| "https://read.amazon.co.jp/manga/" ++ asin, target "_blank" ] [ View.imgLazy [ src book.img, width 50, alt <| book.rawTitle ++ "の書影" ] [] ]
                )
            |> div []
        ]
    }


doSort sk =
    case sk of
        DATE ->
            List.sortWith compareWithAcquiredDate

        TITLE ->
            List.sortBy (\( _, book ) -> book.rawTitle)


compareWithAcquiredDate : ( String, KindleBook ) -> ( String, KindleBook ) -> Order
compareWithAcquiredDate ( _, book1 ) ( _, book2 ) =
    Date.compare book2.acquiredDate book1.acquiredDate
