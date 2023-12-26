module Page.Articles exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , cmsArticlePreview
    , page
    )

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (div, h1, p, text)
import Html.Attributes
import Page
import Pages.PageUrl
import Route
import Shared exposing (CmsArticleMetadata, seoBase)
import View


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias Data =
    { cmsArticles : List CmsArticleMetadata
    }


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.map Data Shared.cmsArticles


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "記事"
            , description = "（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い"
        }
        |> Seo.website


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ _ app =
    { title = "記事"
    , body =
        [ h1 [] [ text "記事", View.feedLink "/articles/feed.xml" ]
        , p [] [ text "外部の技術記事プラットフォーム以外で書いた、自前CMSなどで管理している（主に）技術記事たち。なんとなく、個人の活動に属する記事がこっちにあることが多い。運用をやめた別ブログの記事やイベントの登壇資料なども良さげなのはサルベージしていく。" ]
        , app.data.cmsArticles
            -- microCMSの記事は、publishされない限りはページビルドされないので、Draftページから見る必要がある。
            -- Markdownの記事は、publishedAt未設定の場合は未来の日付にfallbackするようにしてあるのでここで一覧表示からはfilterされるが、ページビルドはされる。
            |> List.filter .published
            |> List.map cmsArticlePreview
            |> div []
        ]
    }


cmsArticlePreview : Shared.CmsArticleMetadata -> Html.Html msg
cmsArticlePreview meta =
    Route.link (Route.Articles__ArticleId_ { articleId = meta.contentId }) [ Html.Attributes.class "link-preview" ] <|
        [ Html.blockquote [] <|
            [ Html.table [] <|
                [ Html.tr [] <|
                    [ Html.td [] <|
                        [ Html.strong [] [ Html.text meta.title ]
                        , Html.small [] [ Html.text ("[" ++ Shared.posixToYmd meta.publishedAt ++ "]") ]
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
