module Page.Articles.ArticleId_ exposing (Data, Model, Msg, cmsArticleBodyDecoder, page, renderArticle)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Html.Parser
import Html.Parser.Util
import Markdown
import OptimizedDecoder
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
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
    , body : List (Html.Html Msg)
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


cmsArticleBodyDecoder : (List (Html.Html msg) -> String -> a) -> OptimizedDecoder.Decoder a
cmsArticleBodyDecoder cont =
    let
        htmlDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.andThen
                    (\input ->
                        case Html.Parser.run input of
                            Ok nodes ->
                                OptimizedDecoder.succeed (Html.Parser.Util.toVirtualDom nodes)

                            Err e ->
                                OptimizedDecoder.fail (Markdown.deadEndsToString e)
                    )

        markdownDecoder =
            OptimizedDecoder.string
                |> OptimizedDecoder.andThen
                    (\input ->
                        case Markdown.render input of
                            Ok html ->
                                OptimizedDecoder.succeed html

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


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = static.data.title
    , body =
        [ Html.table []
            [ Html.tbody []
                [ Html.tr [] [ Html.th [] [ Html.text "公開" ], Html.td [] [ Html.text (Shared.formatPosix static.data.publishedAt) ] ]
                , Html.tr [] [ Html.th [] [ Html.text "更新" ], Html.td [] [ Html.text (Shared.formatPosix static.data.revisedAt) ] ]
                ]
            ]
        , Html.hr [] []
        , renderArticle static.data
        ]
    }


renderArticle :
    { a
        | title : String
        , image : Maybe Shared.CmsImage
        , body : List (Html.Html msg)
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
            :: contents.body
