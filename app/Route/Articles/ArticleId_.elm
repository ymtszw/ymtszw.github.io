module Route.Articles.ArticleId_ exposing (ActionData, Data, Model, Msg, pages, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import CmsData exposing (CmsArticle, CmsArticleMetadata, CmsImage, CmsSource(..), ExternalView, HtmlOrMarkdown(..), allMetadata)
import DateOrDateTime exposing (DateOrDateTime(..))
import Dict exposing (Dict)
import ExternalHtml
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import LinkPreview
import List.Extra
import Markdown
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site
import View exposing (View, formatPosix)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { articleId : String }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    CmsData.allMetadata
        |> BackendTask.map (List.map (.contentId >> RouteParams))


type alias Data =
    { article : CmsArticle
    , prevArticleMeta : Maybe CmsArticleMetadata
    , nextArticleMeta : Maybe CmsArticleMetadata
    }


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data { articleId } =
    CmsData.allMetadata
        |> BackendTask.andThen
            (\allMetadata ->
                case List.Extra.find (\meta -> meta.contentId == articleId) allMetadata of
                    Just matchedMeta ->
                        (case matchedMeta.source of
                            MicroCms ->
                                microCmsArticleData matchedMeta

                            MarkdownFile ->
                                markdownArticleData matchedMeta
                                    |> BackendTask.allowFatal
                        )
                            |> BackendTask.map
                                (\article ->
                                    let
                                        ( prevArticleMeta, nextArticleMeta ) =
                                            findNextAndPrevArticleMeta article allMetadata
                                    in
                                    { article = article
                                    , prevArticleMeta = prevArticleMeta
                                    , nextArticleMeta = nextArticleMeta
                                    }
                                )

                    Nothing ->
                        BackendTask.fail (FatalError.build { title = "Not found", body = "Article not found: " ++ articleId })
            )


microCmsArticleData meta =
    CmsData.cmsGet ("https://ymtszw.microcms.io/api/v1/articles/" ++ meta.contentId)
        (cmsArticleBodyDecoder (CmsArticle meta))


cmsArticleBodyDecoder : (ExternalView -> String -> CmsArticle) -> Decode.Decoder CmsArticle
cmsArticleBodyDecoder cont =
    let
        mapFromExternalHtml { parsed, excerpt, links } =
            ExternalView (Html parsed) excerpt links
    in
    Decode.oneOf
        [ Decode.succeed cont
            |> Decode.andMap (Decode.field "html" (Decode.map mapFromExternalHtml ExternalHtml.decoder))
            |> Decode.andMap (Decode.succeed "html")
        , Decode.succeed cont
            |> Decode.andMap (Decode.field "markdown" (Decode.map mapFromMarkdown Markdown.decoder))
            |> Decode.andMap (Decode.succeed "markdown")
        ]


mapFromMarkdown { parsed, excerpt, links } =
    ExternalView (Markdown parsed) excerpt links


markdownArticleData meta =
    let
        cmsArticleDecoder markdownBody =
            markdownBody
                |> Markdown.decoderInternal
                |> Decode.map mapFromMarkdown
                |> Decode.andThen
                    (\decodedBody ->
                        Decode.succeed
                            { meta = meta
                            , body = decodedBody
                            , type_ = "markdown"
                            }
                    )
    in
    BackendTask.File.bodyWithFrontmatter cmsArticleDecoder ("articles/" ++ meta.contentId ++ ".md")


findNextAndPrevArticleMeta : CmsArticle -> List CmsArticleMetadata -> ( Maybe CmsArticleMetadata, Maybe CmsArticleMetadata )
findNextAndPrevArticleMeta currentArticle cmsArticlesFromLatest =
    let
        publishedArticles =
            List.filter .published cmsArticlesFromLatest
    in
    case List.Extra.splitWhen (\a -> a.contentId == currentArticle.meta.contentId) publishedArticles of
        Just ( newer, _ :: older ) ->
            ( List.Extra.last newer, List.head older )

        _ ->
            -- Entry from latest, if query doesn't match'
            ( Nothing, List.head publishedArticles )


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Site.seoBase
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (DateTime app.data.article.meta.publishedAt)
            , modifiedTime = Just (DateTime app.data.article.meta.revisedAt)
            , expirationTime = Nothing
            }


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app _ =
    { title = app.data.article.meta.title
    , body =
        let
            timestamp =
                Html.small [] <|
                    if app.data.article.meta.published then
                        Html.text ("公開: " ++ formatPosix app.data.article.meta.publishedAt)
                            :: (if app.data.article.meta.revisedAt /= app.data.article.meta.publishedAt then
                                    [ Html.text (" (更新: " ++ formatPosix app.data.article.meta.revisedAt ++ ")") ]

                                else
                                    []
                               )

                    else
                        [ Html.text <| "未公開 (articles/" ++ app.data.article.meta.contentId ++ ".md)" ]
        in
        [ prevNextNavigation app.data
        , Html.header [] [ timestamp ]

        -- , renderArticle shared.links app.data.article
        , renderArticle Dict.empty app.data.article
        , Html.div [] [ timestamp ]
        , prevNextNavigation app.data
        ]
    }


renderArticle :
    Dict String LinkPreview.Metadata
    ->
        { a
            | meta :
                { meta
                    | title : String
                    , image : Maybe CmsImage
                }
            , body : ExternalView
        }
    -> Html.Html msg
renderArticle links contents =
    Html.article [] <|
        (case contents.meta.image of
            Just cmsImage ->
                [ Html.figure [] [ View.imgLazy [ Html.Attributes.src cmsImage.url, Html.Attributes.width cmsImage.width, Html.Attributes.height cmsImage.height, Html.Attributes.alt "Article Header Image" ] [] ] ]

            Nothing ->
                []
        )
            ++ Html.h1 [] [ Html.text contents.meta.title ]
            :: (case contents.body.parsed of
                    Html parsed ->
                        ExternalHtml.render links parsed

                    Markdown parsed ->
                        Markdown.render links parsed
               )


prevNextNavigation : Data -> Html.Html msg
prevNextNavigation data_ =
    let
        toLink maybeArticleMeta child =
            case maybeArticleMeta of
                Just articleMeta ->
                    Route.Articles__ArticleId_ { articleId = articleMeta.contentId } |> Route.link [] [ Html.strong [] [ child ] ]

                Nothing ->
                    child
    in
    Html.nav [ Html.Attributes.class "prev-next-navigation" ]
        [ toLink data_.prevArticleMeta <| Html.text "← 前"
        , toLink data_.nextArticleMeta <| Html.text "次 →"
        ]
