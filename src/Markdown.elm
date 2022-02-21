module Markdown exposing (DecodedBody, deadEndToString, deadEndsToString, decoder, parse, render, renderWithExcerpt)

import Dict exposing (Dict)
import Html
import Html.Attributes
import LinkPreview exposing (Metadata)
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
        |> defaultToErrorView input


render_ nodes =
    Markdown.Renderer.render htmlRenderer nodes
        |> Result.mapError ((++) "Error while rendering Markdown!\n\n")


defaultToErrorView input result =
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


type alias DecodedBody msg =
    { html : List (Html.Html msg)
    , excerpt : String
    , links : List String
    , htmlWithLinkPreview : { draft : Bool } -> Dict String Metadata -> List (Html.Html msg)
    }


renderWithExcerpt : String -> DecodedBody msg
renderWithExcerpt input =
    case parse input of
        Ok nodes ->
            { html = defaultToErrorView input (render_ nodes)
            , excerpt = excerpt nodes
            , links = enumerateLinks nodes
            , htmlWithLinkPreview = \conf links -> transformWithLinkMetadata conf nodes links |> render_ |> defaultToErrorView input
            }

        Err err ->
            let
                renderred =
                    renderFallback input err
            in
            { html = renderred
            , excerpt = String.left 100 input ++ "..."
            , links = []
            , htmlWithLinkPreview = \_ _ -> renderred
            }


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
                , Markdown.Html.tag "a"
                    (\href class children ->
                        Html.a (Html.Attributes.class class :: destAttr href) children
                    )
                    |> Markdown.Html.withAttribute "href"
                    |> Markdown.Html.withAttribute "class"
                , Markdown.Html.tag "kbd" <| Html.kbd [ inline ]
                , Markdown.Html.tag "b" <| Html.b [ inline ]
                , Markdown.Html.tag "u" <| Html.u [ inline ]
                , Markdown.Html.tag "small" <| Html.small [ inline ]
                , Markdown.Html.tag "div" <| Html.div []
                ]
        , link =
            \link content ->
                let
                    titleAttr =
                        link.title |> Maybe.map (\title -> [ Html.Attributes.title title ]) |> Maybe.withDefault []
                in
                Html.a (titleAttr ++ destAttr link.destination) content
    }


destAttr : String -> List (Html.Attribute msg)
destAttr destination =
    if String.startsWith "http://" destination || String.startsWith "https://" destination then
        [ Html.Attributes.href destination, Html.Attributes.target "_blank" ]

    else
        [ Html.Attributes.href destination ]


enumerateLinks : List Markdown.Block.Block -> List String
enumerateLinks =
    List.concatMap
        (\block ->
            case block of
                Markdown.Block.Paragraph [ Markdown.Block.Link bareUrl _ _ ] ->
                    [ bareUrl ]

                _ ->
                    []
        )


transformWithLinkMetadata : { draft : Bool } -> List Markdown.Block.Block -> Dict String LinkPreview.Metadata -> List Markdown.Block.Block
transformWithLinkMetadata { draft } nodes links =
    List.concatMap
        (\block ->
            case block of
                Markdown.Block.Paragraph [ Markdown.Block.Link bareUrl _ _ ] ->
                    case ( Dict.get bareUrl links, draft ) of
                        ( Just metadata, _ ) ->
                            [ Markdown.Block.HtmlBlock <| Markdown.Block.HtmlElement "a" [ { name = "class", value = "link-preview" }, { name = "href", value = bareUrl } ] [ linkPreview metadata ] ]

                        ( Nothing, True ) ->
                            [ Markdown.Block.HtmlBlock <| Markdown.Block.HtmlElement "a" [ { name = "class", value = "link-preview" }, { name = "href", value = bareUrl } ] [ linkPreview (LinkPreview.previewMetadata bareUrl) ] ]

                        ( Nothing, False ) ->
                            [ block ]

                _ ->
                    [ block ]
        )
        nodes


linkPreview : LinkPreview.Metadata -> Markdown.Block.Block
linkPreview meta =
    Markdown.Block.BlockQuote
        [ Markdown.Block.Table [] <|
            [ [ [ case meta.title of
                    Just title ->
                        Markdown.Block.Strong <|
                            [ case meta.iconUrl of
                                Just iconUrl ->
                                    Markdown.Block.Image iconUrl Nothing []

                                Nothing ->
                                    Markdown.Block.Text ""
                            , Markdown.Block.Text title
                            ]

                    Nothing ->
                        Markdown.Block.Text ""
                , Markdown.Block.HtmlInline <|
                    Markdown.Block.HtmlElement "div" [] <|
                        case meta.description of
                            Just desc ->
                                [ Markdown.Block.Paragraph [ Markdown.Block.Text desc ] ]

                            Nothing ->
                                []
                , Markdown.Block.HtmlInline <|
                    Markdown.Block.HtmlElement "small" [] [ Markdown.Block.Paragraph [ Markdown.Block.Text meta.canonicalUrl ] ]
                ]
              , case meta.imageUrl of
                    Just imageUrl ->
                        [ Markdown.Block.Image imageUrl Nothing [] ]

                    Nothing ->
                        []
              ]
            ]
        ]
