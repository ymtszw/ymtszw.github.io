module Route.Articles exposing (ActionData, Data, Model, Msg, RouteParams, route)

{-| 
@docs Model, Msg, RouteParams, route, Data, ActionData
-}


import BackendTask
import Effect
import ErrorPage
import FatalError
import Head
import Html
import PagesMsg
import Path
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import View


type alias Model =
    {}


type Msg
    = NoOp


type alias RouteParams =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none )


subscriptions : RouteParams -> Path.Path -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    {}


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Parser (BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage))
data routeParams =
    Server.Request.succeed (BackendTask.succeed (Server.Response.render {}))


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "Articles", body = [ Html.h2 [] [ Html.text "New Page" ] ] }


action :
    RouteParams
    -> Server.Request.Parser (BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage))
action routeParams =
    Server.Request.succeed (BackendTask.succeed (Server.Response.render {}))