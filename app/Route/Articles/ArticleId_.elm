module Route.Articles.ArticleId_ exposing
    ( ActionData
    , CmsArticle
    , Data
    , ExternalView
    , HtmlOrMarkdown(..)
    , Model
    , Msg
    , RouteParams
    , cmsArticleBodyDecoder
    , data
    , pages
    , renderArticle
    , route
    )

import BackendTask exposing (BackendTask)
import DateOrDateTime
import Dict exposing (Dict)
import ExternalHtml
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Html.Parser
import Json.Decode
import Json.Decode.Extra
import LinkPreview
import List.Extra
import Markdown
import Markdown.Block
import PagesMsg
import Route
import RouteBuilder
import Shared exposing (CmsArticleMetadata, seoBase)
import Time
import View


type alias Model =
    {}


type alias Msg =
    ()


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


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.map (List.map (.contentId >> RouteParams)) Shared.publicCmsArticles


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    Shared.cmsGet ("https://ymtszw.microcms.io/api/v1/articles/" ++ routeParams.articleId)
        (Json.Decode.succeed CmsArticle
            |> Json.Decode.Extra.andMap (Json.Decode.succeed routeParams.articleId)
            |> Json.Decode.Extra.andMap (Json.Decode.field "publishedAt" Shared.iso8601Decoder)
            |> Json.Decode.Extra.andMap (Json.Decode.field "revisedAt" Shared.iso8601Decoder)
            |> Json.Decode.Extra.andMap (Json.Decode.field "title" Json.Decode.string)
            |> Json.Decode.Extra.andMap (Json.Decode.maybe (Json.Decode.field "image" Shared.cmsImageDecoder))
            |> Json.Decode.andThen cmsArticleBodyDecoder
        )
        |> BackendTask.andThen
            (\currentArticle ->
                currentArticle.body.links
                    |> LinkPreview.collectMetadataOnBuild
                    |> BackendTask.andThen
                        (\links ->
                            Shared.publicCmsArticles
                                |> BackendTask.map
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


cmsArticleBodyDecoder : (ExternalView -> String -> a) -> Json.Decode.Decoder a
cmsArticleBodyDecoder cont =
    let
        mapFromExternalHtml { parsed, excerpt, links } =
            ExternalView (Html parsed) excerpt links

        mapFromMarkdown { parsed, excerpt, links } =
            ExternalView (Markdown parsed) excerpt links
    in
    Json.Decode.oneOf
        [ Json.Decode.succeed cont
            |> Json.Decode.Extra.andMap (Json.Decode.field "html" (Json.Decode.map mapFromExternalHtml ExternalHtml.decoder))
            |> Json.Decode.Extra.andMap (Json.Decode.succeed "html")
        , Json.Decode.succeed cont
            |> Json.Decode.Extra.andMap (Json.Decode.field "markdown" (Json.Decode.map mapFromMarkdown Markdown.decoder))
            |> Json.Decode.Extra.andMap (Json.Decode.succeed "markdown")
        ]


findNextAndPrevArticleMeta : CmsArticle -> List CmsArticleMetadata -> ( Maybe CmsArticleMetadata, Maybe CmsArticleMetadata )
findNextAndPrevArticleMeta currentArticle cmsArticlesFromLatest =
    case List.Extra.splitWhen (\a -> a.contentId == currentArticle.contentId) cmsArticlesFromLatest of
        Just ( newer, _ :: older ) ->
            ( List.Extra.last newer, List.head older )

        _ ->
            -- Entry from latest, if query doesn't match'
            ( Nothing, List.head cmsArticlesFromLatest )


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
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
            , publishedTime = Just (DateOrDateTime.DateTime app.data.article.publishedAt)
            , modifiedTime = Just (DateOrDateTime.DateTime app.data.article.revisedAt)
            , expirationTime = Nothing
            }


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ =
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
    -> Html.Html (PagesMsg.PagesMsg msg)
renderArticle links contents =
    Html.map PagesMsg.fromMsg <|
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
                    Route.link [] [ Html.strong [] [ child ] ] <| Route.Articles__ArticleId_ { articleId = articleMeta.contentId }

                Nothing ->
                    child
    in
    Html.nav [ Html.Attributes.class "prev-next-navigation" ]
        [ toLink data_.prevArticleMeta <| Html.text "← 前"
        , toLink data_.nextArticleMeta <| Html.text "次 →"
        ]
