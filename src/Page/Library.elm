module Page.Library exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Http
import Date exposing (Date)
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Helper exposing (nonEmptyString)
import Html exposing (a, div, h1, img, text)
import Html.Attributes exposing (alt, class, href, src, target, width)
import Markdown
import OptimizedDecoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets as Secrets
import Shared exposing (seoBase)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    Dict String KindleBook


type alias KindleBook =
    { id : String -- ASIN
    , title : String
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
                        OptimizedDecoder.map5 KindleBook
                            (OptimizedDecoder.field "id" nonEmptyString)
                            (OptimizedDecoder.field "title" nonEmptyString)
                            (OptimizedDecoder.field "authors" (OptimizedDecoder.list nonEmptyString))
                            (OptimizedDecoder.field "img" nonEmptyString)
                            (OptimizedDecoder.field "acquiredDate" japaneseDate)
            )


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
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ app =
    { title = "書架"
    , body =
        [ h1 [] [ text "書架" ]
        , div [] <| Markdown.parseAndRender Dict.empty """
Kindle蔵書リスト。前々から自分用に使いやすいKindleのフロントエンドがほしいと思っていたので自作し始めたページ。仕組み：

- Kindleのコンテンツ一覧ページをスクレイプするTampermonkeyスクリプトを実装
- 上記ページを不定期に手動で開いてスクレイピング→蔵書DBファイルを更新
- **TODO**: サイトビルド時に蔵書DBファイルを読み込み、ページを描画
- **TODO**: Meilisearchで検索機能提供
- **TODO**: 自分限定のレビュー機能をつける
- **TODO**: いい感じに「本棚」「書架」っぽいUIを探求
"""
        , app.data
            |> Dict.toList
            |> List.take 1000
            |> List.map
                (\( asin, book ) ->
                    a [ class "has-image", href <| "https://read.amazon.co.jp/manga/" ++ asin, target "_blank" ] [ img [ src book.img, width 150, alt <| book.title ++ "の書影" ] [] ]
                )
            |> div []
        ]
    }
