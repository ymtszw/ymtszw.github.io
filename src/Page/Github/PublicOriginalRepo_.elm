module Page.Github.PublicOriginalRepo_ exposing (Data, Model, Msg, page)

import Base64
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import OptimizedDecoder
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
    { publicOriginalRepo : String }


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
    Shared.publicOriginalRepos
        |> DataSource.map (List.map RouteParams)


data : RouteParams -> DataSource Data
data routeParams =
    Shared.githubGet ("https://api.github.com/repos/ymtszw/" ++ routeParams.publicOriginalRepo ++ "/contents/README.md")
        (OptimizedDecoder.oneOf
            [ OptimizedDecoder.field "content" OptimizedDecoder.string
                |> OptimizedDecoder.map (String.replace "\n" "")
                |> OptimizedDecoder.andThen (Base64.toString >> Result.fromMaybe "Base64 Error!" >> OptimizedDecoder.fromResult)
            , OptimizedDecoder.succeed "# Missing README.md"
            ]
            |> OptimizedDecoder.andThen markdownDecoder
        )


markdownDecoder input =
    Markdown.Parser.parse input
        |> Result.mapError (List.map Markdown.Parser.deadEndToString >> String.join "\n")
        |> Result.andThen (Markdown.Renderer.render htmlRenderer)
        |> (\result ->
                case result of
                    Ok ok ->
                        OptimizedDecoder.succeed ok

                    Err err ->
                        OptimizedDecoder.succeed <|
                            [ Html.h1 [] [ Html.text "Markdown Error!" ]
                            , Html.pre [] [ Html.text err ]
                            , Html.br [] []
                            , Html.h1 [] [ Html.text "Here's the source:" ]
                            , Html.pre [] [ Html.text input ]
                            ]
           )


htmlRenderer =
    { defaultHtmlRenderer
        | html =
            Markdown.Html.oneOf
                [ Markdown.Html.tag "img"
                    (\src children ->
                        Html.img [ Html.Attributes.src src ] children
                    )
                    |> Markdown.Html.withAttribute "src"
                , -- src-less anchor
                  Markdown.Html.tag "a"
                    (\name children ->
                        Html.a [ Html.Attributes.name name ] children
                    )
                    |> Markdown.Html.withAttribute "name"
                , Markdown.Html.tag "kbd" <| Html.kbd []
                , Markdown.Html.tag "b" <| Html.b []
                ]
    }


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
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
        , title = static.routeParams.publicOriginalRepo ++ " | ymtszw's GitHub Repo"
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


type alias Data =
    List (Html.Html Never)


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = static.routeParams.publicOriginalRepo ++ " | ymtszw's GitHub Repo"
    , body = static.data
    }
