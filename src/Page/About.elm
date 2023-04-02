module Page.About exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (href, target)
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Shared exposing (seoBase)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    { readme : List (Html Never)
    , bio : List (Html Never)
    }


data : DataSource Data
data =
    let
        readme =
            DataSource.File.bodyWithoutFrontmatter "README.md"
                |> DataSource.map Markdown.render
    in
    DataSource.map2 Data readme (Shared.getGitHubRepoReadme "ymtszw")


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "このサイトについて"
    , body =
        [ div [] static.data.readme
        , h2 [] [ Html.text "自己紹介 ", Html.a [ href "https://github.com/ymtszw/ymtszw", target "_blank" ] [ text "(source)" ] ]
        , div [] static.data.bio
        ]
    }
