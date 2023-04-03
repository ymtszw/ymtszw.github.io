module Page.Articles.ArticleId_ exposing (Data, Model, Msg, cmsArticleBodyDecoder, page, renderArticle)

import DataSource exposing (DataSource)
import Dict exposing (Dict)
import ExternalHtml
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Iso8601
import LinkPreview
import List.Extra
import Markdown
import OptimizedDecoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Route
import Shared exposing (CmsArticleMetadata, seoBase)
import Time
import View exposing (View)


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
    , body : Markdown.DecodedBody Msg
    , type_ : String
    }


page : Page RouteParams Data
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


cmsArticleBodyDecoder : (Markdown.DecodedBody msg -> String -> a) -> OptimizedDecoder.Decoder a
cmsArticleBodyDecoder cont =
    let
        htmlDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.andThen ExternalHtml.decoder

        markdownDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.map Markdown.renderWithExcerpt
    in
    OptimizedDecoder.oneOf
        [ OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "html" htmlDecoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "html")
        , OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "markdown" markdownDecoder)
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


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle static.data.article.title
            , description = static.data.article.body.excerpt
            , image = Maybe.withDefault seoBase.image (Maybe.map Shared.makeSeoImageFromCmsImage static.data.article.image)
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (Iso8601.fromTime static.data.article.publishedAt)
            , modifiedTime = Just (Iso8601.fromTime static.data.article.revisedAt)
            , expirationTime = Nothing
            }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = static.data.article.title
    , body =
        [ prevNextNavigation static.data
        , Html.header []
            [ Html.small [] <|
                Html.text ("公開: " ++ Shared.formatPosix static.data.article.publishedAt)
                    :: (if static.data.article.revisedAt /= static.data.article.publishedAt then
                            [ Html.text (" (更新: " ++ Shared.formatPosix static.data.article.revisedAt ++ ")") ]

                        else
                            []
                       )
            ]
        , renderArticle { draft = False } static.data.links static.data.article
        , prevNextNavigation static.data
        ]
    }


renderArticle :
    { draft : Bool }
    -> Dict String LinkPreview.Metadata
    ->
        { a
            | title : String
            , image : Maybe Shared.CmsImage
            , body : Markdown.DecodedBody msg
        }
    -> Html.Html msg
renderArticle conf links contents =
    Html.article [] <|
        (case contents.image of
            Just cmsImage ->
                [ Html.figure [] [ View.imgLazy [ Html.Attributes.src cmsImage.url, Html.Attributes.width cmsImage.width, Html.Attributes.height cmsImage.height, Html.Attributes.alt "Article Header Image" ] [] ] ]

            Nothing ->
                []
        )
            ++ Html.h1 [] [ Html.text contents.title ]
            :: (if not conf.draft && Dict.isEmpty links then
                    contents.body.html

                else
                    contents.body.htmlWithLinkPreview conf links
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
