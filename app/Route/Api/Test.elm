module Route.Api.Test exposing (ActionData, Data, Model, Msg, route)

{-| JSONを返すAPI routeのテストエンドポイント

このrouteはCloudflare Pages FunctionsでサーバーサイドレンダリングされるAPIです。
リクエストごとに動的に生成されるJSONレスポンスを返します。

-}

import BackendTask exposing (BackendTask)
import Dict
import ErrorPage
import FatalError exposing (FatalError)
import Json.Encode as Encode
import RouteBuilder
import Server.Request exposing (Request)
import Server.Response
import Time


type alias Data =
    {}


type alias Model =
    {}


type alias Msg =
    ()


type alias ActionData =
    {}


type alias RouteParams =
    {}


route : RouteBuilder.StatelessRoute RouteParams Data action
route =
    RouteBuilder.serverRender
        { head = \_ -> []
        , data = data
        , action = \_ _ -> BackendTask.fail (FatalError.fromString "No action defined")
        }
        |> RouteBuilder.buildNoState { view = \_ _ -> { title = "", body = [] } }


data : RouteParams -> Request -> BackendTask FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data _ request =
    let
        requestTime =
            Server.Request.requestTime request

        method =
            Server.Request.method request
                |> methodToString

        path =
            Server.Request.rawUrl request

        allHeaders =
            Server.Request.headers request
                |> Dict.toList

        cloudflareHeader =
            allHeaders
                |> List.filter (\( key, _ ) -> String.toLower key == "x-elm-pages-cloudflare")
                |> List.head

        isCloudflare =
            cloudflareHeader /= Nothing

        runtimeInfo =
            if isCloudflare then
                "Running on Cloudflare Pages Functions (or wrangler dev)"

            else
                "Running on elm-pages dev server (adapter not active)"

        jsonResponse =
            Encode.object
                [ ( "success", Encode.bool True )
                , ( "message", Encode.string "This is a JSON API response from Cloudflare Pages Functions" )
                , ( "runtime"
                  , Encode.object
                        [ ( "adapter", Encode.string "cloudflare-pages" )
                        , ( "isCloudflare", Encode.bool isCloudflare )
                        , ( "info", Encode.string runtimeInfo )
                        ]
                  )
                , ( "request"
                  , Encode.object
                        [ ( "timestamp", Encode.int (Time.posixToMillis requestTime) )
                        , ( "method", Encode.string method )
                        , ( "path", Encode.string path )
                        , ( "headers"
                          , Encode.object
                                (List.map
                                    (\( key, value ) -> ( key, Encode.string value ))
                                    allHeaders
                                )
                          )
                        ]
                  )
                ]
    in
    BackendTask.succeed (Server.Response.json jsonResponse)


methodToString : Server.Request.Method -> String
methodToString method =
    case method of
        Server.Request.Get ->
            "GET"

        Server.Request.Post ->
            "POST"

        Server.Request.Put ->
            "PUT"

        Server.Request.Patch ->
            "PATCH"

        Server.Request.Delete ->
            "DELETE"

        Server.Request.Head ->
            "HEAD"

        Server.Request.Options ->
            "OPTIONS"

        Server.Request.Trace ->
            "TRACE"

        Server.Request.Connect ->
            "CONNECT"

        Server.Request.NonStandard methodString ->
            methodString
