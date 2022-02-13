module Page.Articles.ArticleId_ exposing (Data, Model, Msg, page, renderArticle)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
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
    DataSource.succeed []


data : RouteParams -> DataSource Data
data routeParams =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary seoBase
        |> Seo.website


type alias Data =
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    View.placeholder "Articles.ArticleId_"


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
