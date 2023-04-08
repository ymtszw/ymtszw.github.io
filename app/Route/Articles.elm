module Route.Articles exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , cmsArticlePreview
    , route
    )

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, p, text)
import Html.Attributes
import PagesMsg
import Route
import RouteBuilder
import Shared exposing (CmsArticleMetadata, seoBase)
import View


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { cmsArticles : List CmsArticleMetadata
    }


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.map Data Shared.publicCmsArticles


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "記事"
            , description = "（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い"
        }
        |> Seo.website


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ =
    { title = "記事"
    , body =
        [ h1 [] [ text "記事", View.feedLink "/articles/feed.xml" ]
        , p [] [ text "外部の技術記事プラットフォーム以外で書いた、自前CMSなどで管理している（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い。運用をやめた別ブログの記事やイベントの登壇資料なども良さげなのはサルベージしていく。" ]
        , app.data.cmsArticles
            |> List.map cmsArticlePreview
            |> div []
        ]
    }


cmsArticlePreview : Shared.CmsArticleMetadata -> Html.Html msg
cmsArticlePreview meta =
    Route.Articles__ArticleId_ { articleId = meta.contentId }
        |> Route.link [ Html.Attributes.class "link-preview" ]
            [ Html.blockquote [] <|
                [ Html.table [] <|
                    [ Html.tr [] <|
                        [ Html.td [] <|
                            [ Html.strong [] [ Html.text meta.title ]
                            , Html.p [] [ Html.text ("[" ++ Shared.posixToYmd meta.publishedAt ++ "]") ]
                            ]
                        , case meta.image of
                            Just cmsImage ->
                                Html.td [] [ View.imgLazy [ Html.Attributes.src (cmsImage.url ++ "?h=150"), Html.Attributes.alt "Article Header Image", Html.Attributes.height 150 ] [] ]

                            Nothing ->
                                Html.text ""
                        ]
                    ]
                ]
            ]
