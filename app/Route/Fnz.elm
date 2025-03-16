module Route.Fnz exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import Date exposing (Date)
import Dict exposing (Dict)
import ErrorPage exposing (ErrorPage)
import FatalError exposing (FatalError)
import Head
import Helper exposing (jst, requireEnv)
import Html exposing (..)
import Pages
import PagesMsg exposing (PagesMsg)
import RouteBuilder
import Server.Request as Request
import Server.Response as Response
import Server.Session as Session
import Server.SetCookie as SetCookie
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


dummyBooks =
    Dict.fromList
        [ ( "1234ABCD"
          , { id = "1234ABCD"
            , purchaseDate = Date.fromPosix jst Pages.builtAt
            , releaseDate = Date.fromPosix jst Pages.builtAt
            , title = "Dummy Book"
            , typeTags = [ "dummy" ]
            , thumbnailUrl = "https://example.com/dummy.jpg"
            , storeUrl = "https://example.com/dummy"
            , circleId = "abcdefgh"
            , circleName = "Dummy Circle"
            , circleUrl = "https://example.com/dummy-circle"
            , firstFileUrl = Just "https://example.com/dummy.pdf"
            }
          )
        ]


data : RouteParams -> Request.Request -> BackendTask FatalError (Response.Response Data ErrorPage)
data _ req =
    do (requireEnv "FNZ_KEY") <|
        \fnzKey ->
            req
                |> Session.withSession
                    { name = "fnz-session"
                    , secrets = signingSecrets
                    , options =
                        Just
                            (SetCookie.options
                                |> SetCookie.withImmediateExpiration
                                |> SetCookie.withSameSite SetCookie.Lax
                            )
                    }
                    (\session ->
                        if (session |> Session.get "key" |> Maybe.withDefault "") == fnzKey then
                            BackendTask.succeed ( session, Response.render { fnzBooks = dummyBooks } )

                        else
                            BackendTask.succeed ( Session.empty, Response.render { fnzBooks = Dict.empty } )
                    )


signingSecrets : BackendTask FatalError (List String)
signingSecrets =
    BackendTask.combine
        -- Add a new secret at the top when rotating; all the existing ones are used for un-signing old sessions
        [ requireEnv "SESSION_SIGNING_SECRET_V1"
        ]


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
view app _ =
    { title = "Fnz"
    , body =
        case Dict.toList app.data.fnzBooks of
            [] ->
                [ text "Access denied." ]

            ( _, book ) :: _ ->
                [ text "Server responded!"
                , ul []
                    [ li [] [ strong [] [ text book.title ] ]
                    , li [] [ text <| "Release Date: " ++ Helper.toJapaneseDate book.releaseDate ]
                    , li [] [ text <| "Purchase Date: " ++ Helper.toJapaneseDate book.purchaseDate ]
                    , li [] [ text <| "Circle Name: " ++ book.circleName ]
                    ]
                ]
    }
