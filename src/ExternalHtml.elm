module ExternalHtml exposing (decoder, extractInlineTextFromHtml)

import Dict exposing (Dict)
import Html.Parser exposing (Node(..))
import Html.Parser.Util
import LinkPreview
import Markdown
import OptimizedDecoder


decoder : String -> OptimizedDecoder.Decoder (Markdown.DecodedBody msg)
decoder input =
    case Html.Parser.run input of
        Ok nodes ->
            OptimizedDecoder.succeed
                { html = Html.Parser.Util.toVirtualDom nodes
                , excerpt = extractInlineTextFromHtml nodes
                , links = enumerateLinks nodes
                , htmlWithLinkPreview = \conf links -> transformWithLinkMetadata conf nodes links |> Html.Parser.Util.toVirtualDom
                }

        Err e ->
            OptimizedDecoder.fail (Markdown.deadEndsToString e)


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


transformWithLinkMetadata : { draft : Bool } -> List Node -> Dict String LinkPreview.Metadata -> List Node
transformWithLinkMetadata { draft } nodes links =
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
                                        case ( bareUrl == linkText, Dict.get bareUrl links, draft ) of
                                            ( True, Just metadata, _ ) ->
                                                [ Element "br" [] [] -- Vertical balancing newline
                                                , Element "a" (( "class", "link-preview" ) :: linkAttrs) [ linkPreview metadata ]
                                                ]

                                            ( True, Nothing, True ) ->
                                                [ Element "br" [] [] -- Vertical balancing newline
                                                , Element "a" (( "class", "link-preview" ) :: linkAttrs) [ linkPreview (LinkPreview.previewMetadata bareUrl) ]
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
                    node
        )
        nodes


linkPreview : LinkPreview.Metadata -> Node
linkPreview meta =
    Element "blockquote" [] <|
        [ Element "table" [] <|
            [ Element "tr" [] <|
                [ Element "td" [] <|
                    [ case meta.title of
                        Just title ->
                            Element "strong" [] <|
                                [ case meta.iconUrl of
                                    Just iconUrl ->
                                        Element "img" [ ( "src", iconUrl ) ] []

                                    Nothing ->
                                        Text ""
                                , Text title
                                ]

                        Nothing ->
                            Text ""
                    , case meta.description of
                        Just desc ->
                            Element "p" [] [ Text desc ]

                        Nothing ->
                            Text ""
                    , Element "small" [] [ Text meta.canonicalUrl ]
                    ]
                , case meta.imageUrl of
                    Just imageUrl ->
                        Element "td" [] [ Element "img" [ ( "src", imageUrl ) ] [] ]

                    Nothing ->
                        Text ""
                ]
            ]
        ]
