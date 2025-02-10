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
import CmsData exposing (CmsArticleMetadata)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Helper exposing (posixToYmd)
import Html exposing (details, div, h1, p, summary, text)
import Html.Attributes
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site exposing (seoBase)
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


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.map Data CmsData.allMetadata


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    { seoBase
        | title = Helper.makeTitle "記事"
        , description = "（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い"
    }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View.View (PagesMsg Msg)
view app _ =
    { title = "記事"
    , body =
        [ h1 [] [ text "記事", View.feedLink "/articles/feed.xml" ]
        , details []
            [ summary [] [ text "About" ]
            , p [] [ text "外部の技術記事プラットフォーム以外で書いた、自前CMSなどで管理している（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い。運用をやめた別ブログの記事やイベントの登壇資料なども良さげなのはサルベージしていく。" ]
            ]
        , app.data.cmsArticles
            -- microCMSの記事は、publishされない限りはページビルドされないので、Draftページから見る必要がある。
            -- Markdownの記事は、publishedAt未設定の場合は未来の日付にfallbackするようにしてあるのでここで一覧表示からはfilterされるが、ページビルドはされる。
            |> List.filter .published
            |> List.map cmsArticlePreview
            |> div []
        ]
    }


cmsArticlePreview : CmsArticleMetadata -> Html.Html msg
cmsArticlePreview meta =
    Route.Articles__ArticleId_ { articleId = meta.contentId }
        |> Route.link [ Html.Attributes.class "link-preview" ]
            [ Html.blockquote [] <|
                [ Html.table [] <|
                    [ Html.tr [] <|
                        [ Html.td [] <|
                            [ Html.strong [] [ Html.text meta.title ]
                            , Html.small [] [ Html.text ("[" ++ posixToYmd meta.publishedAt ++ "]") ]
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
