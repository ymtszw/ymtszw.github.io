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

import DataSource exposing (DataSource)
import Dict exposing (Dict)
import ExternalHtml
import Head
import Head.Seo as Seo
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
import Shared exposing (CmsArticleMetadata, seoBase)
import Time
import View


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { articleId : String }


type alias Data =
    { article : CmsArticle
    , links : Dict String LinkPreview.Metadata
    , prevArticleMeta : Maybe CmsArticleMetadata
    , nextArticleMeta : Maybe CmsArticleMetadata
    }


type alias CmsArticle =
    { contentId : String
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
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map (.contentId >> RouteParams)) Shared.publicCmsArticles


data : RouteParams -> DataSource Data
data routeParams =
    Shared.cmsGet ("https://ymtszw.microcms.io/api/v1/articles/" ++ routeParams.articleId)
        (OptimizedDecoder.succeed CmsArticle
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed routeParams.articleId)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "publishedAt" Shared.iso8601Decoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "revisedAt" Shared.iso8601Decoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
            |> OptimizedDecoder.andMap (OptimizedDecoder.maybe (OptimizedDecoder.field "image" Shared.cmsImageDecoder))
            |> OptimizedDecoder.andThen cmsArticleBodyDecoder
        )
        |> DataSource.andThen
            (\currentArticle ->
                currentArticle.body.links
                    |> LinkPreview.collectMetadataOnBuild
                    |> DataSource.andThen
                        (\links ->
                            Shared.publicCmsArticles
                                |> DataSource.map
                                    (\cmsArticles ->
                                        let
                                            ( next, prev ) =
                                                findNextAndPrevArticleMeta currentArticle cmsArticles
                                        in
                                        { article = currentArticle
                                        , links = links
                                        , prevArticleMeta = prev
                                        , nextArticleMeta = next
                                        }
                                    )
                        )
            )


cmsArticleBodyDecoder : (ExternalView -> String -> a) -> OptimizedDecoder.Decoder a
cmsArticleBodyDecoder cont =
    let
        mapFromExternalHtml { parsed, excerpt, links } =
            ExternalView (Html parsed) excerpt links

        mapFromMarkdown { parsed, excerpt, links } =
            ExternalView (Markdown parsed) excerpt links
    in
    OptimizedDecoder.oneOf
        [ OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "html" (OptimizedDecoder.map mapFromExternalHtml ExternalHtml.decoder))
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "html")
        , OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "markdown" (OptimizedDecoder.map mapFromMarkdown Markdown.decoder))
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "markdown")
        ]


findNextAndPrevArticleMeta : CmsArticle -> List CmsArticleMetadata -> ( Maybe CmsArticleMetadata, Maybe CmsArticleMetadata )
findNextAndPrevArticleMeta currentArticle cmsArticlesFromLatest =
    case List.Extra.splitWhen (\a -> a.contentId == currentArticle.contentId) cmsArticlesFromLatest of
        Just ( newer, _ :: older ) ->
            ( List.Extra.last newer, List.head older )

        _ ->
            -- Entry from latest, if query doesn't match'
            ( Nothing, List.head cmsArticlesFromLatest )


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


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data RouteParams -> View.View msg
view _ _ app =
    { title = app.data.article.title
    , body =
        [ prevNextNavigation app.data
        , Html.header []
            [ Html.small [] <|
                Html.text ("公開: " ++ Shared.formatPosix app.data.article.publishedAt)
                    :: (if app.data.article.revisedAt /= app.data.article.publishedAt then
                            [ Html.text (" (更新: " ++ Shared.formatPosix app.data.article.revisedAt ++ ")") ]

                        else
                            []
                       )
            ]
        , renderArticle app.data.links app.data.article
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
