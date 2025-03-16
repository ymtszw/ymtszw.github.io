module Route.Fnz exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import Date exposing (Date)
import Dict exposing (Dict)
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import RouteBuilder
import Server.Request as Request
import Server.Response as Response
import Shared
import View exposing (View)


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender
        { data = data
        , action = action
        , head = head
        }
        |> RouteBuilder.buildNoState { view = view }


type alias RouteParams =
    {}


type alias Data =
    { fnzBooks : Dict FnzBookId FnzBook
    }


type alias FnzBookId =
    String


type alias FnzBook =
    { id : FnzBookId
    , purchaseDate : Date
    , releaseDate : Date
    , title : String
    , typeTags : List String
    , thumbnailUrl : String
    , storeUrl : String
    , circleId : FnzCircleId
    , circleName : String
    , circleUrl : String
    , firstFileUrl : Maybe String
    }


type alias FnzCircleId =
    String


data : RouteParams -> Request.Request -> BackendTask FatalError (Response.Response Data ErrorPage)
data _ _ =
    BackendTask.succeed (Response.render { fnzBooks = Dict.empty })


type alias ActionData =
    {}


action : RouteParams -> Request.Request -> BackendTask FatalError (Response.Response ActionData ErrorPage)
action _ _ =
    BackendTask.succeed (Response.render {})


type alias Model =
    {}


type alias Msg =
    ()


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view : RouteBuilder.App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    { body = []
    , title = "Fnz"
    }
