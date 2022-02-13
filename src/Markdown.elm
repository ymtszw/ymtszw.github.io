module Markdown exposing (deadEndsToString, decoder, render)

import Html exposing (Html)
import Html.Attributes
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import OptimizedDecoder
import Parser
import Regex


decoder : String -> OptimizedDecoder.Decoder (List (Html msg))
decoder input =
    OptimizedDecoder.fromResult (render input)


render : String -> Result String (List (Html msg))
render input =
    preprocessMarkdown input
        |> Markdown.Parser.parse
        |> Result.mapError (deadEndsToString >> (++) "Error while parsing Markdown!\n\n")
        |> Result.andThen (Markdown.Renderer.render htmlRenderer)
        |> (\result ->
                case result of
                    Ok ok ->
                        Ok ok

                    Err err ->
                        Ok
                            [ Html.h1 [] [ Html.text "Markdown Error!" ]
                            , Html.pre [] [ Html.text <| "Error while rendering Markdown!\n\n" ++ err ]
                            , Html.br [] []
                            , Html.h1 [] [ Html.text "Here's the source:" ]
                            , Html.pre [] [ Html.text input ]
                            ]
           )


deadEndsToString : List { a | row : Int, col : Int, problem : Parser.Problem } -> String
deadEndsToString =
    List.map deadEndToString >> String.join "\n"


deadEndToString : { a | row : Int, col : Int, problem : Parser.Problem } -> String
deadEndToString deadEnd =
    "Problem at row " ++ String.fromInt deadEnd.row ++ ", col " ++ String.fromInt deadEnd.col ++ "\n" ++ problemToString deadEnd.problem


problemToString : Parser.Problem -> String
problemToString problem =
    case problem of
        Parser.Expecting string ->
            "Expecting " ++ string

        Parser.ExpectingInt ->
            "Expecting int"

        Parser.ExpectingHex ->
            "Expecting hex"

        Parser.ExpectingOctal ->
            "Expecting octal"

        Parser.ExpectingBinary ->
            "Expecting binary"

        Parser.ExpectingFloat ->
            "Expecting float"

        Parser.ExpectingNumber ->
            "Expecting number"

        Parser.ExpectingVariable ->
            "Expecting variable"

        Parser.ExpectingSymbol string ->
            "Expecting symbol " ++ string

        Parser.ExpectingKeyword string ->
            "Expecting keyword " ++ string

        Parser.ExpectingEnd ->
            "Expecting keyword end"

        Parser.UnexpectedChar ->
            "Unexpected char"

        Parser.Problem problemDescription ->
            problemDescription

        Parser.BadRepeat ->
            "Bad repeat"


preprocessMarkdown : String -> String
preprocessMarkdown =
    convertPlainUrlToAngledUrl
        >> convertDollarsToCode


convertPlainUrlToAngledUrl =
    Regex.replace plainUrlPattern <|
        \{ match } -> "<" ++ match ++ ">"


plainUrlPattern =
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|\\s)(?<!\\]:\\s+)https?://\\S+(?=\\s|$)")


convertDollarsToCode =
    Regex.replace dollarsPattern <|
        \{ match } -> "`" ++ String.dropLeft 1 (String.dropRight 1 match) ++ "`"


dollarsPattern =
    Maybe.withDefault Regex.never (Regex.fromString "\\$.+?\\$")


htmlRenderer =
    { defaultHtmlRenderer
        | html =
            let
                -- elm-markdown's custom tags always wrap their children by <p>
                -- such must be considered display: inline
                inline =
                    Html.Attributes.class "inline"
            in
            Markdown.Html.oneOf
                [ Markdown.Html.tag "img"
                    (\src _ ->
                        Html.img [ Html.Attributes.src src ] []
                    )
                    |> Markdown.Html.withAttribute "src"
                , -- src-less anchor
                  Markdown.Html.tag "a"
                    (\name children ->
                        Html.a [ Html.Attributes.name name, inline ] children
                    )
                    |> Markdown.Html.withAttribute "name"
                , Markdown.Html.tag "kbd" <| Html.kbd [ inline ]
                , Markdown.Html.tag "b" <| Html.b [ inline ]
                , Markdown.Html.tag "u" <| Html.u [ inline ]
                , Markdown.Html.tag "small" <| Html.small [ inline ]
                ]
        , link =
            \link content ->
                let
                    titleAttr =
                        link.title |> Maybe.map (\title -> [ Html.Attributes.title title ]) |> Maybe.withDefault []

                    destAttr =
                        if String.startsWith "http://" link.destination || String.startsWith "https://" link.destination then
                            [ Html.Attributes.href link.destination, Html.Attributes.target "_blank" ]

                        else
                            [ Html.Attributes.href link.destination ]
                in
                Html.a (titleAttr ++ destAttr) content
    }
