module Page.Articles.ArticleId_ exposing
    ( CmsArticle
    , Data
    , ExternalView
    , HtmlOrMarkdown(..)
    , Model
    , Msg
    , RouteParams
    , cmsArticleBodyDecoder
    , data
    , page
    , renderArticle
    , routes
    )

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.File
import Dict exposing (Dict)
import ExternalHtml
import Head
import Head.Seo as Seo
import Helper exposing (iso8601Decoder)
import Html
import Html.Attributes
import Html.Parser
import Iso8601
import LinkPreview
import List.Extra
import Markdown
import Markdown.Block
import OptimizedDecoder
import Page
import Pages.PageUrl
import Route
import Shared exposing (CmsArticleMetadata, markdownArticles, seoBase)
import Time
import View


type alias Model =
    ()


type alias RouteParams =
    { articleId : String }


type alias Data =
    { article : CmsArticle
    , prevArticleMeta : Maybe CmsArticleMetadata
    , nextArticleMeta : Maybe CmsArticleMetadata
    , amazonAssociateTag : String
    }


type alias CmsArticle =
    { contentId : String
    , published : Bool
    , publishedAt : Time.Posix
    , revisedAt : Time.Posix
    , title : String
    , image : Maybe Shared.CmsImage
    , body : ExternalView
    , type_ : String
    }


type alias ExternalView =
    { parsed : HtmlOrMarkdown
    , excerpt : String
    , links : List String
    }


type HtmlOrMarkdown
    = Html (List Html.Parser.Node)
    | Markdown (List Markdown.Block.Block)


page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildWithSharedState
            { init = \_ _ _ -> ( (), Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , view = view
            }


routes : DataSource (List RouteParams)
routes =
    Shared.cmsArticles
        |> DataSource.map (List.map (.contentId >> RouteParams))


data : RouteParams -> DataSource Data
data routeParams =
    -- XXX: ここでmarkdownの記事リストに依存しているのは若干効率が悪いが、あまり他にいい方法がなかった
    Shared.markdownArticles
        |> DataSource.andThen
            (\markdownArticles ->
                case List.Extra.find (\meta -> meta.contentId == routeParams.articleId) markdownArticles of
                    Just matchedMeta ->
                        markdownArticleData matchedMeta

                    Nothing ->
                        publicCmsArticleData routeParams
            )


markdownArticleData : Shared.CmsArticleMetadata -> DataSource Data
markdownArticleData meta =
    let
        cmsArticleDecoder markdownBody =
            OptimizedDecoder.map8 CmsArticle
                (OptimizedDecoder.succeed meta.contentId)
                (OptimizedDecoder.succeed meta.published)
                (OptimizedDecoder.succeed meta.publishedAt)
                (OptimizedDecoder.succeed meta.revisedAt)
                (OptimizedDecoder.succeed meta.title)
                (OptimizedDecoder.succeed meta.image)
                (markdownBody
                    |> Markdown.decoderInternal
                    |> OptimizedDecoder.map mapFromMarkdown
                )
                (OptimizedDecoder.succeed "markdown")
    in
    DataSource.File.bodyWithFrontmatter cmsArticleDecoder ("articles/" ++ meta.contentId ++ ".md")
        |> DataSource.andThen buildPageData


publicCmsArticleData : RouteParams -> DataSource Data
publicCmsArticleData routeParams =
    Shared.cmsGet ("https://ymtszw.microcms.io/api/v1/articles/" ++ routeParams.articleId)
        (OptimizedDecoder.succeed CmsArticle
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed routeParams.articleId)
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed True)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "publishedAt" iso8601Decoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "revisedAt" iso8601Decoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
            |> OptimizedDecoder.andMap (OptimizedDecoder.maybe (OptimizedDecoder.field "image" Shared.cmsImageDecoder))
            |> OptimizedDecoder.andThen cmsArticleBodyDecoder
        )
        |> DataSource.andThen buildPageData


buildPageData : CmsArticle -> DataSource Data
buildPageData currentArticle =
    DataSource.Env.load "AMAZON_ASSOCIATE_TAG"
        |> DataSource.andThen
            (\aat ->
                Shared.cmsArticles
                    |> DataSource.map
                        (\cmsArticles ->
                            let
                                ( next, prev ) =
                                    findNextAndPrevArticleMeta currentArticle cmsArticles
                            in
                            { article = currentArticle
                            , prevArticleMeta = prev
                            , nextArticleMeta = next
                            , amazonAssociateTag = aat
                            }
                        )
            )


cmsArticleBodyDecoder : (ExternalView -> String -> a) -> OptimizedDecoder.Decoder a
cmsArticleBodyDecoder cont =
    let
        mapFromExternalHtml { parsed, excerpt, links } =
            ExternalView (Html parsed) excerpt links
    in
    OptimizedDecoder.oneOf
        [ OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "html" (OptimizedDecoder.map mapFromExternalHtml ExternalHtml.decoder))
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "html")
        , OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "markdown" (OptimizedDecoder.map mapFromMarkdown Markdown.decoder))
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "markdown")
        ]


mapFromMarkdown { parsed, excerpt, links } =
    ExternalView (Markdown parsed) excerpt links


findNextAndPrevArticleMeta : CmsArticle -> List CmsArticleMetadata -> ( Maybe CmsArticleMetadata, Maybe CmsArticleMetadata )
findNextAndPrevArticleMeta currentArticle cmsArticlesFromLatest =
    let
        publishedArticles =
            List.filter .published cmsArticlesFromLatest
    in
    case List.Extra.splitWhen (\a -> a.contentId == currentArticle.contentId) publishedArticles of
        Just ( newer, _ :: older ) ->
            ( List.Extra.last newer, List.head older )

        _ ->
            -- Entry from latest, if query doesn't match'
            ( Nothing, List.head publishedArticles )


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head app =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle app.data.article.title
            , description = app.data.article.body.excerpt
            , image = Maybe.withDefault seoBase.image (Maybe.map Shared.makeSeoImageFromCmsImage app.data.article.image)
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (Iso8601.fromTime app.data.article.publishedAt)
            , modifiedTime = Just (Iso8601.fromTime app.data.article.revisedAt)
            , expirationTime = Nothing
            }


type Msg
    = InitiateLinkPreviewPopulation


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ _ app msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Cmd.none
            , Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag app.data.article.body.links))
            )


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View msg
view _ shared _ app =
    { title = app.data.article.title
    , body =
        let
            timestamp =
                Html.small [] <|
                    if app.data.article.published then
                        Html.text ("公開: " ++ Shared.formatPosix app.data.article.publishedAt)
                            :: (if app.data.article.revisedAt /= app.data.article.publishedAt then
                                    [ Html.text (" (更新: " ++ Shared.formatPosix app.data.article.revisedAt ++ ")") ]

                                else
                                    []
                               )

                    else
                        [ Html.text <| "未公開 (articles/" ++ app.data.article.contentId ++ ".md)" ]
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
            | title : String
            , image : Maybe Shared.CmsImage
            , body : ExternalView
        }
    -> Html.Html msg
renderArticle links contents =
    Html.article [] <|
        (case contents.image of
            Just cmsImage ->
                [ Html.figure [] [ View.imgLazy [ Html.Attributes.src cmsImage.url, Html.Attributes.width cmsImage.width, Html.Attributes.height cmsImage.height, Html.Attributes.alt "Article Header Image" ] [] ] ]

            Nothing ->
                []
        )
            ++ Html.h1 [] [ Html.text contents.title ]
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
                    Route.link (Route.Articles__ArticleId_ { articleId = articleMeta.contentId }) [] [ Html.strong [] [ child ] ]

                Nothing ->
                    child
    in
    Html.nav [ Html.Attributes.class "prev-next-navigation" ]
        [ toLink data_.prevArticleMeta <| Html.text "← 前"
        , toLink data_.nextArticleMeta <| Html.text "次 →"
        ]
