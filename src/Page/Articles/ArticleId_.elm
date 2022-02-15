module Page.Articles.ArticleId_ exposing (Body, Data, Model, Msg, cmsArticleBodyDecoder, page, renderArticle)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Html.Parser
import Html.Parser.Util
import Iso8601
import Markdown
import OptimizedDecoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Shared exposing (seoBase)
import Time
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { articleId : String }


type alias Data =
    CmsArticle


type alias CmsArticle =
    { contentId : String
    , publishedAt : Time.Posix
    , revisedAt : Time.Posix
    , title : String
    , image : Maybe Shared.CmsImage
    , body : Body Msg
    , type_ : String
    }


type alias Body msg =
    { html : List (Html.Html msg)
    , excerpt : String
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


cmsArticleBodyDecoder : (Body msg -> String -> a) -> OptimizedDecoder.Decoder a
cmsArticleBodyDecoder cont =
    let
        htmlDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.andThen
                    (\input ->
                        case Html.Parser.run input of
                            Ok nodes ->
                                OptimizedDecoder.succeed (Body (Html.Parser.Util.toVirtualDom nodes) (extractInlineTextFromHtml nodes))

                            Err e ->
                                OptimizedDecoder.fail (Markdown.deadEndsToString e)
                    )

        markdownDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.andThen
                    (\input ->
                        case Markdown.renderWithExcerpt input of
                            Ok ( html, excerpt ) ->
                                OptimizedDecoder.succeed (Body html excerpt)

                            Err e ->
                                OptimizedDecoder.fail e
                    )
    in
    OptimizedDecoder.oneOf
        [ OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "html" htmlDecoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "html")
        , OptimizedDecoder.succeed cont
            |> OptimizedDecoder.andMap (OptimizedDecoder.field "markdown" markdownDecoder)
            |> OptimizedDecoder.andMap (OptimizedDecoder.succeed "markdown")
        ]


extractInlineTextFromHtml : List Html.Parser.Node -> String
extractInlineTextFromHtml nodes =
    case extractInlineTextHelp nodes "" of
        ( acc, True ) ->
            acc

        ( acc, False ) ->
            String.left 100 acc ++ "..."


extractInlineTextHelp nodes acc =
    case ( nodes, String.length acc > 100 ) of
        ( [], _ ) ->
            ( acc, True )

        ( _, True ) ->
            ( acc, False )

        ( h :: t, False ) ->
            let
                new =
                    digHtmlNode h
            in
            extractInlineTextHelp t (acc ++ " " ++ new)


digHtmlNode : Html.Parser.Node -> String
digHtmlNode node =
    case node of
        Html.Parser.Text text ->
            text

        Html.Parser.Element _ _ nodes ->
            Tuple.first (extractInlineTextHelp nodes "")

        Html.Parser.Comment _ ->
            ""


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle static.data.title
            , description = static.data.body.excerpt
            , image = Maybe.withDefault seoBase.image (Maybe.map Shared.makeSeoImageFromCmsImage static.data.image)
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Just (Iso8601.fromTime static.data.publishedAt)
            , modifiedTime = Just (Iso8601.fromTime static.data.revisedAt)
            , expirationTime = Nothing
            }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = static.data.title
    , body =
        [ Html.table []
            [ Html.tbody [] <|
                Html.tr [] [ Html.th [] [ Html.text "公開" ], Html.td [] [ Html.text (Shared.formatPosix static.data.publishedAt) ] ]
                    :: (if static.data.revisedAt /= static.data.publishedAt then
                            [ Html.tr [] [ Html.th [] [ Html.text "更新" ], Html.td [] [ Html.text (Shared.formatPosix static.data.revisedAt) ] ] ]

                        else
                            []
                       )
            ]
        , Html.hr [] []
        , renderArticle static.data
        ]
    }


renderArticle :
    { a
        | title : String
        , image : Maybe Shared.CmsImage
        , body : Body msg
    }
    -> Html.Html msg
renderArticle contents =
    Html.article [] <|
        (case contents.image of
            Just cmsImage ->
                [ Html.img [ Html.Attributes.src cmsImage.url, Html.Attributes.width cmsImage.width, Html.Attributes.height cmsImage.height, Html.Attributes.alt "Article Header Image" ] [] ]

            Nothing ->
                []
        )
            ++ Html.h1 [] [ Html.text contents.title ]
            :: contents.body.html
