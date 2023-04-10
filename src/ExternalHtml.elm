module ExternalHtml exposing
    ( decoder
    , extractInlineTextFromHtml
    , render
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Parser exposing (Node(..))
import Html.Parser.Util
import LinkPreview
import Markdown
import OptimizedDecoder


type alias DecodedHtml =
    { parsed : List Html.Parser.Node
    , excerpt : String
    , links : List String
    }


decoder : OptimizedDecoder.Decoder DecodedHtml
decoder =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\input ->
                case Html.Parser.run input of
                    Ok nodes ->
                        OptimizedDecoder.succeed
                            { parsed = nodes
                            , excerpt = extractInlineTextFromHtml nodes
                            , links = enumerateLinks nodes
                            }

                    Err e ->
                        OptimizedDecoder.fail (Markdown.deadEndsToString e)
            )


extractInlineTextFromHtml : List Node -> String
extractInlineTextFromHtml nodes =
    case extractInlineTextHelp nodes "" of
        ( acc, True ) ->
            acc

        ( acc, False ) ->
            String.left 100 acc ++ "..."


extractInlineTextHelp nodes acc =
    case ( nodes, String.length acc > 100 ) of
        ( [], _ ) ->
            ( acc, True )

        ( _, True ) ->
            ( acc, False )

        ( h :: t, False ) ->
            let
                new =
                    digHtmlNode h
            in
            extractInlineTextHelp t (acc ++ " " ++ new)


digHtmlNode : Node -> String
digHtmlNode node =
    case node of
        Text text ->
            text

        Element _ _ nodes ->
            Tuple.first (extractInlineTextHelp nodes "")

        Comment _ ->
            ""


enumerateLinks : List Node -> List String
enumerateLinks =
    List.concatMap
        (\node ->
            case node of
                Element "p" _ pChildren ->
                    pChildren
                        |> List.foldl splitParagraphByBr []
                        |> List.concatMap
                            (\lineInParagraph ->
                                case lineInParagraph of
                                    [ Element "a" (( "href", bareUrl ) :: _) [ Text linkText ] ] ->
                                        if bareUrl == linkText then
                                            [ bareUrl ]

                                        else
                                            []

                                    _ ->
                                        []
                            )

                _ ->
                    []
        )


splitParagraphByBr pElem acc =
    case ( pElem, acc ) of
        ( Element "br" _ _, _ ) ->
            [] :: acc

        ( notBr, accHead :: accTail ) ->
            (notBr :: accHead) :: accTail

        ( notBr, [] ) ->
            [ [ notBr ] ]


render : Dict String LinkPreview.Metadata -> List Node -> List (Html msg)
render links nodes =
    nodes
        |> transformWithLinkMetadata links
        |> Html.Parser.Util.toVirtualDom


transformWithLinkMetadata : Dict String LinkPreview.Metadata -> List Node -> List Node
transformWithLinkMetadata links nodes =
    List.map
        (\node ->
            case node of
                Element "p" pAttrs pChildren ->
                    pChildren
                        |> List.foldr splitParagraphByBr []
                        |> List.map
                            (\lineInParagraph ->
                                case lineInParagraph of
                                    [ Element "a" ((( "href", bareUrl ) :: _) as linkAttrs) [ Text linkText ] ] ->
                                        case ( bareUrl == linkText, Dict.get bareUrl links ) of
                                            ( True, Just metadata ) ->
                                                [ Element "a" (( "class", "link-preview" ) :: linkAttrs) [ linkPreview metadata ]
                                                ]

                                            _ ->
                                                lineInParagraph

                                    _ ->
                                        lineInParagraph
                            )
                        |> List.intersperse [ Element "br" [] [] ]
                        |> List.concat
                        |> Element "p" pAttrs

                _ ->
                    recursivelyLazifyImg node
        )
        nodes


linkPreview : LinkPreview.Metadata -> Node
linkPreview meta =
    Element "blockquote" [] <|
        [ Element "table" [] <|
            [ Element "tr" [] <|
                [ Element "td" [] <|
                    [ Element "strong" [] [ Text meta.title ]
                    , case meta.description of
                        Just desc ->
                            Element "p" [] [ Text desc ]

                        Nothing ->
                            Text ""
                    , Element "small" [] [ Text meta.canonicalUrl ]
                    ]
                , case meta.imageUrl of
                    Just imageUrl ->
                        Element "td" [] [ Element "img" [ ( "src", imageUrl ), ( "loading", "lazy" ) ] [] ]

                    Nothing ->
                        Text ""
                ]
            ]
        ]


recursivelyLazifyImg : Node -> Node
recursivelyLazifyImg node =
    case node of
        Element "img" (( "src", src ) :: attrs) children ->
            Element "img" (( "src", src ) :: ( "loading", "lazy" ) :: attrs) children

        Element tag attrs children ->
            Element tag attrs (List.map recursivelyLazifyImg children)

        _ ->
            node
