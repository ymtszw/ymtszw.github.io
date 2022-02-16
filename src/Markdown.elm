module Markdown exposing (deadEndsToString, decoder, parse, render, renderWithExcerpt)

import Html
import Html.Attributes
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import OptimizedDecoder
import Parser
import Regex


decoder : String -> OptimizedDecoder.Decoder (List (Html.Html msg))
decoder input =
    OptimizedDecoder.succeed (render input)


parse : String -> Result String (List Markdown.Block.Block)
parse input =
    preprocessMarkdown input
        |> Markdown.Parser.parse
        |> Result.mapError (deadEndsToString >> (++) "Error while parsing Markdown!\n\n")


render : String -> List (Html.Html msg)
render input =
    parse input
        |> Result.andThen render_
        |> renderWithFallback input


render_ nodes =
    Markdown.Renderer.render htmlRenderer nodes
        |> Result.mapError ((++) "Error while rendering Markdown!\n\n")


renderWithFallback input result =
    case result of
        Ok renderred ->
            renderred

        Err err ->
            renderFallback input err


renderFallback input err =
    [ Html.h1 [] [ Html.text "Markdown Error!" ]
    , Html.pre [] [ Html.text err ]
    , Html.br [] []
    , Html.h1 [] [ Html.text "Here's the source:" ]
    , Html.pre [] [ Html.text input ]
    ]


renderWithExcerpt : String -> ( List (Html.Html msg), String )
renderWithExcerpt input =
    case parse input of
        Ok nodes ->
            ( renderWithFallback input (render_ nodes), excerpt nodes )

        Err err ->
            ( renderFallback input err, String.left 100 input ++ "..." )


excerpt : List Markdown.Block.Block -> String
excerpt blocks =
    let
        reducer block ( acc, _ ) =
            if String.length acc > 100 then
                ( acc, False )

            else
                ( acc ++ extractInlineBlockText block, True )
    in
    case List.foldl reducer ( "", True ) blocks of
        ( acc, True ) ->
            acc

        ( acc, False ) ->
            String.left 100 acc ++ "..."


{-| Copied from Markdown.Block in order to avoid repeated walk over inline nodes.
-}
extractInlineBlockText block =
    case block of
        Markdown.Block.Paragraph inlines ->
            Markdown.Block.extractInlineText inlines

        Markdown.Block.HtmlBlock html ->
            case html of
                Markdown.Block.HtmlElement _ _ blocks ->
                    Markdown.Block.foldl
                        (\nestedBlock soFar ->
                            soFar ++ extractInlineBlockText nestedBlock
                        )
                        ""
                        blocks

                _ ->
                    ""

        Markdown.Block.UnorderedList _ items ->
            items
                |> List.map
                    (\(Markdown.Block.ListItem _ blocks) ->
                        blocks
                            |> List.map extractInlineBlockText
                            |> String.join "\n"
                    )
                |> String.join "\n"

        Markdown.Block.OrderedList _ _ items ->
            items
                |> List.map
                    (\blocks ->
                        blocks
                            |> List.map extractInlineBlockText
                            |> String.join "\n"
                    )
                |> String.join "\n"

        Markdown.Block.BlockQuote blocks ->
            blocks
                |> List.map extractInlineBlockText
                |> String.join "\n"

        Markdown.Block.Heading _ inlines ->
            Markdown.Block.extractInlineText inlines

        Markdown.Block.Table header rows ->
            [ header
                |> List.map .label
                |> List.map Markdown.Block.extractInlineText
            , rows
                |> List.map (List.map Markdown.Block.extractInlineText)
                |> List.concat
            ]
                |> List.concat
                |> String.join "\n"

        Markdown.Block.CodeBlock { body } ->
            body

        Markdown.Block.ThematicBreak ->
            ""


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
