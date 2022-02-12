module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
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


data : DataSource Data
data =
    let
        readme =
            DataSource.File.bodyWithoutFrontmatter "README.md"
                |> DataSource.andThen (Markdown.render >> DataSource.fromResult)

        bio =
            DataSource.map2 (++)
                (DataSource.fromResult (Markdown.render "## Bio [(source)](https://github.com/ymtszw/ymtszw)"))
                (Shared.getGitHubRepoReadme "ymtszw")
    in
    DataSource.map2 Data readme bio


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "ymtszw"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "ymtszw's page"
        }
        |> Seo.website


type alias Data =
    { readme : List (Html.Html Never)
    , bio : List (Html.Html Never)
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "ymtszw's page"
    , body =
        static.data.readme
            ++ static.data.bio
            ++ [ Html.h2 [] [ Html.text "GitHub Public Repo" ]
               , Html.blockquote [] [ Html.text "作成が新しい順です" ]
               , static.sharedData.repos
                    |> List.map
                        (\publicOriginalRepo ->
                            Html.strong []
                                [ Html.text "["
                                , Html.a [ Html.Attributes.href ("https://github.com/ymtszw/" ++ publicOriginalRepo), Html.Attributes.target "_blank" ] [ Html.text publicOriginalRepo ]
                                , Html.text "]"
                                ]
                        )
                    |> List.intersperse (Html.text " ")
                    |> Html.p []
               ]
    }
