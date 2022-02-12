module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Route
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
    DataSource.succeed ()


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
    ()


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "ymtszw's page"
    , body =
        [ Html.h1 [] [ Html.text "ymtszw's page" ]
        , Html.h2 [] [ Html.text "GitHub Public Repo" ]
        , Html.blockquote [] [ Html.text "作成が新しい順です" ]
        , static.sharedData.repos
            |> List.map
                (\publicOriginalRepo ->
                    strong []
                        [ text "["
                        , Route.link (Route.Github__PublicOriginalRepo_ { publicOriginalRepo = publicOriginalRepo }) [] [ text publicOriginalRepo ]
                        , text "]"
                        ]
                )
            |> List.intersperse (Html.text " ")
            |> p []
        ]
    }
