module Route.ServerTest exposing (ActionData, Data, Model, Msg, route)

{-| Server-render routeのテストページ

このrouteはCloudflare Pages Functionsでサーバーサイドレンダリングされます。
リクエストごとに動的に生成されるため、現在時刻などのリアルタイムデータを表示できます。

-}

import BackendTask exposing (BackendTask)
import Dict
import ErrorPage
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes as Attr
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Server.Request exposing (Request)
import Server.Response
import Shared
import Site
import Time
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { requestTime : Time.Posix
    , method : String
    , path : String
    , headers : List ( String, String )
    }


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        , action = \_ _ -> BackendTask.fail (FatalError.fromString "No action defined")
        }
        |> RouteBuilder.buildNoState { view = view }


data : RouteParams -> Request -> BackendTask FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data _ request =
    let
        allHeaders =
            Server.Request.headers request
                |> Dict.toList

        requestData =
            { requestTime = Server.Request.requestTime request
            , method = Server.Request.method request |> methodToString
            , path = Server.Request.rawUrl request
            , headers = allHeaders
            }
    in
    BackendTask.succeed (Server.Response.render requestData)


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

        Server.Request.NonStandard methodName ->
            methodName


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = Site.title
        , image = Site.seoBase.image
        , description = "Server-render test page for Cloudflare Pages Functions adapter"
        , locale = Just Site.locale
        , title = "Server Render Test"
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    let
        cloudflareHeader =
            app.data.headers
                |> List.filter (\( key, _ ) -> String.toLower key == "x-elm-pages-cloudflare")
                |> List.head

        isCloudflare =
            cloudflareHeader /= Nothing

        runtimeInfo =
            if isCloudflare then
                "✅ Running on Cloudflare Pages Functions (or wrangler dev)"

            else
                "⚠️ Running on elm-pages dev server (adapter not active)"

        cloudflareHeaderDebug =
            case cloudflareHeader of
                Just ( key, value ) ->
                    "Found: " ++ key ++ " = " ++ value

                Nothing ->
                    "NOT FOUND (checked " ++ String.fromInt (List.length app.data.headers) ++ " headers)"
    in
    { title = "Server Render Test"
    , body =
        [ Html.h1 [] [ Html.text "🚀 Server-Render Test" ]
        , Html.p []
            [ Html.text runtimeInfo ]
        , Html.p [ Attr.style "font-size" "small" ]
            [ Html.text ("Debug: x-elm-pages-cloudflare header " ++ cloudflareHeaderDebug) ]
        , Html.h2 [] [ Html.text "Request Information" ]
        , Html.dl []
            [ Html.dt [] [ Html.text "Request Time:" ]
            , Html.dd [] [ Html.text (String.fromInt (Time.posixToMillis app.data.requestTime) ++ " ms") ]
            , Html.dt [] [ Html.text "Method:" ]
            , Html.dd [] [ Html.text app.data.method ]
            , Html.dt [] [ Html.text "Path:" ]
            , Html.dd [] [ Html.text app.data.path ]
            , Html.dt [] [ Html.text ("All Headers (" ++ String.fromInt (List.length app.data.headers) ++ "):") ]
            , Html.dd []
                [ Html.ul []
                    (List.map
                        (\( name, value ) ->
                            Html.li []
                                [ Html.strong [] [ Html.text (name ++ ": ") ]
                                , Html.text value
                                ]
                        )
                        app.data.headers
                    )
                ]
            ]
        , Html.h2 [] [ Html.text "Test Results" ]
        , Html.ul []
            [ Html.li [ Attr.style "color" "green" ] [ Html.text "✅ Server-side rendering is working" ]
            , Html.li [ Attr.style "color" "green" ] [ Html.text "✅ Request object is accessible" ]
            , if isCloudflare then
                Html.li [ Attr.style "color" "green" ] [ Html.text "✅ Cloudflare Pages Functions adapter is operational" ]

              else
                Html.li [ Attr.style "color" "orange" ] [ Html.text "⚠️ elm-pages dev server (no adapter)" ]
            ]
        ]
    }
