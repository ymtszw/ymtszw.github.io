module Markdown exposing
    ( deadEndToString
    , deadEndsToString
    , decoder
    , parse
    , parseAndRender
    , render
    )

import Dict exposing (Dict)
import Html
import Html.Attributes
import Json.Decode
import Json.Decode.Extra
import LinkPreview
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)
import Parser
import Regex
import View exposing (HtmlOrMarkdown(..))


decoder : Json.Decode.Decoder View.ExternalView
decoder =
    Json.Decode.string
        |> Json.Decode.andThen (parse >> Json.Decode.Extra.fromResult)
        |> Json.Decode.map (\nodes -> { parsed = Markdown nodes, excerpt = excerpt nodes, links = enumerateLinks nodes })


parse : String -> Result String (List Markdown.Block.Block)
parse input =
    preprocessMarkdown input
        |> Markdown.Parser.parse
        |> Result.map (List.map (Markdown.Block.walkInlines postprocessInline))
        |> Result.mapError (deadEndsToString >> (++) "Error while parsing Markdown!\n\n")


parseAndRender : Dict String LinkPreview.Metadata -> String -> List (Html.Html msg)
parseAndRender links input =
    parse input
        |> Result.map (render links)
        |> defaultToErrorView input


render : Dict String LinkPreview.Metadata -> List Markdown.Block.Block -> List (Html.Html msg)
render links nodes =
    -- Markdowns can fail on parse but actually never fail on render.
    nodes
        |> transformWithLinkMetadata links
        |> Markdown.Renderer.render htmlRenderer
        |> Result.withDefault []


defaultToErrorView : String -> Result String (List (Html.Html msg)) -> List (Html.Html msg)
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


postprocessInline : Markdown.Block.Inline -> Markdown.Block.Inline
postprocessInline inline =
    case inline of
        Markdown.Block.Link url _ ([ Markdown.Block.Image _ _ _ ] as children) ->
            -- Discard maybeTitle and use it for has-image identifier
            Markdown.Block.Link url (Just "__has_image__") children

        _ ->
            inline


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
                        View.imgLazy [ Html.Attributes.src src ] []
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
                        case link.title of
                            Just "__has_image__" ->
                                [ Html.Attributes.class "has-image" ]

                            Just otherwise ->
                                [ Html.Attributes.alt otherwise ]

                            Nothing ->
                                []
                in
                Html.a (titleAttr ++ destAttr link.destination) content
    }


destAttr : String -> List (Html.Attribute msg)
destAttr destination =
    if not (String.startsWith "https://ymtszw.github.io/" destination) && (String.startsWith "http://" destination || String.startsWith "https://" destination) then
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



-----------------
-- LinkPreview Transform
-----------------


transformWithLinkMetadata : Dict String LinkPreview.Metadata -> List Markdown.Block.Block -> List Markdown.Block.Block
transformWithLinkMetadata links nodes =
    List.map
        (\block ->
            case block of
                Markdown.Block.Paragraph [ Markdown.Block.Link bareUrl _ _ ] ->
                    case Dict.get bareUrl links of
                        Just metadata ->
                            Markdown.Block.HtmlBlock <| Markdown.Block.HtmlElement "a" [ { name = "class", value = "link-preview" }, { name = "href", value = bareUrl } ] [ linkPreview metadata ]

                        Nothing ->
                            block

                _ ->
                    block
        )
        nodes


linkPreview : LinkPreview.Metadata -> Markdown.Block.Block
linkPreview meta =
    Markdown.Block.BlockQuote
        [ Markdown.Block.Table [] <|
            [ [ [ Markdown.Block.Strong [ Markdown.Block.Text meta.title ]
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
