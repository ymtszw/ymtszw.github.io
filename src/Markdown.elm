module Markdown exposing (decoder)

import Html exposing (Html)
import Html.Attributes
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import OptimizedDecoder
import Regex


decoder : String -> OptimizedDecoder.Decoder (List (Html Never))
decoder input =
    preprocessMarkdown input
        |> Markdown.Parser.parse
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


preprocessMarkdown =
    Regex.replace plainUrlPattern <|
        \{ match } -> "<" ++ match ++ ">"


plainUrlPattern =
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|\\s)https?://\\S+(?=\\s|$)")


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
