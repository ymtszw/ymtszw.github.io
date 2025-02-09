module Route.Articles.ArticleId_ exposing (ActionData, Data, Model, Msg, cmsArticleBodyDecoder, data, pages, publishedPages, renderArticle, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import CmsData exposing (CmsArticle, CmsArticleMetadata, CmsImage, CmsSource(..), ExternalView, HtmlOrMarkdown(..), allMetadata)
import DateOrDateTime exposing (DateOrDateTime(..))
import Dict exposing (Dict)
import Effect exposing (Effect)
import ExternalHtml
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Helper exposing (dataSourceWith, formatPosix, requireEnv)
import Html
import Html.Attributes
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import LinkPreview
import List.Extra
import Markdown
import PagesMsg exposing (PagesMsg)
import Route
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Site exposing (seoBase)
import View exposing (View)


type alias Model =
    {}


type alias RouteParams =
    { articleId : String }


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = \_ _ -> ( {}, Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


pages : BackendTask FatalError (List RouteParams)
pages =
    CmsData.allMetadata
        |> BackendTask.map (List.map (.contentId >> RouteParams))


publishedPages : BackendTask FatalError (List RouteParams)
publishedPages =
    CmsData.allMetadata
        |> BackendTask.map (List.filter .published >> List.map (.contentId >> RouteParams))


type alias Data =
    { article : CmsArticle
    , prevArticleMeta : Maybe CmsArticleMetadata
    , nextArticleMeta : Maybe CmsArticleMetadata
    , amazonAssociateTag : String
    }


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data { articleId } =
    dataSourceWith (requireEnv "AMAZON_ASSOCIATE_TAG") <|
        \amazonAssociateTag ->
            dataSourceWith CmsData.allMetadata <|
                \allMetadata ->
                    case List.Extra.find (\meta -> meta.contentId == articleId) allMetadata of
                        Just matchedMeta ->
                            let
                                buildArticleData article =
                                    let
                                        ( next, prev ) =
                                            findNextAndPrevArticleMeta article allMetadata
                                    in
                                    { article = article
                                    , prevArticleMeta = prev
                                    , nextArticleMeta = next
                                    , amazonAssociateTag = amazonAssociateTag
                                    }
                            in
                            BackendTask.map buildArticleData <|
                                case matchedMeta.source of
                                    MicroCms ->
                                        microCmsArticleData matchedMeta

                                    MarkdownFile ->
                                        markdownArticleData matchedMeta

                        Nothing ->
                            BackendTask.fail (FatalError.build { title = "Not found", body = "Article not found: " ++ articleId })


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
        |> BackendTask.allowFatal


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


type Msg
    = InitiateLinkPreviewPopulation


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app _ msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Effect.none
            , Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag app.data.article.body.links))
            )


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    { seoBase
        | title = Helper.makeTitle app.data.article.meta.title
        , description = app.data.article.body.excerpt
        , image = Maybe.withDefault seoBase.image (Maybe.map CmsData.makeSeoImageFromCmsImage app.data.article.meta.image)
    }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (DateTime app.data.article.meta.publishedAt)
            , modifiedTime = Just (DateTime app.data.article.meta.revisedAt)
            , expirationTime = Nothing
            }


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app shared _ =
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
        , renderArticle shared.links app.data.article
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
