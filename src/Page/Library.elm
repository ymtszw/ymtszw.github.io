module Page.Library exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Dict
import Head
import Head.Seo as Seo
import Html exposing (div, h1, text)
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
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
    ()


data : DataSource Data
data =
    DataSource.succeed ()


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
view _ _ _ =
    { title = "書架"
    , body =
        [ h1 [] [ text "書架" ]
        , div [] <| Markdown.parseAndRender Dict.empty """
Kindle蔵書リスト。前々からKindleの自分用に使いやすいフロントエンドページがほしいと思っていたので自作し始めたもの。仕組み：

- Kindleのコンテンツ一覧ページをスクレイプするTampermonkeyスクリプトを実装
- 上記ページを不定期に手動で開いてスクレイピング→蔵書DBファイルを更新
- **TODO**: サイトビルド時に蔵書DBファイルを読み込み、ページを描画
- **TODO**: Meilisearchで検索機能提供
- **TODO**: 自分限定のレビュー機能をつける
- **TODO**: いい感じに「本棚」「書架」っぽいUIを探求
"""
        ]
    }
