module Page.Articles exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, p, text)
import Page exposing (Page, StaticPayload)
import Page.Index
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
            | title = Shared.makeTitle "記事"
            , description = "（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "記事"
    , body =
        [ h1 [] [ text "記事", View.feedLink "/articles/feed.xml" ]
        , p [] [ text "外部の技術記事プラットフォーム以外で書いた、自前CMSなどで管理している（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い。運用をやめた別ブログの記事やイベントの登壇資料なども良さげなのはサルベージしていく。" ]
        , static.sharedData.cmsArticles
            |> List.map Page.Index.cmsArticlePreview
            |> div []
        ]
    }
