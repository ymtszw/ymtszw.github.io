module Route.Index exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import PagesMsg exposing (PagesMsg)
import Route
import Route.Articles.ArticleId_ as ArticleId_
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { message : String
    , articleIds : List String
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    BackendTask.succeed Data
        |> BackendTask.andMap (BackendTask.succeed "Hello!")
        |> BackendTask.andMap (ArticleId_.publishedPages |> BackendTask.map (List.map .articleId))


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head _ =
    Site.seoBase
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    { title = Site.title
    , body =
        [ Html.h1 [] [ Html.text "elm-pages is up and running!" ]
        , Html.p []
            [ Html.text <| "The message is: " ++ app.data.message
            ]
        , app.data.articleIds
            |> List.map
                (\articleId ->
                    Html.li []
                        [ Route.Articles__ArticleId_ { articleId = articleId }
                            |> Route.link [] [ Html.text articleId ]
                        ]
                )
            |> Html.ul []
        ]
    }
