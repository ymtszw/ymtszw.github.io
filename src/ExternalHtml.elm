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
                , htmlWithLinkPreview = transformWithLinkMetadata nodes >> Html.Parser.Util.toVirtualDom
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
                Element "p" [] [ Element "a" (( "href", bareUrl ) :: _) [ Text linkText ] ] ->
                    if bareUrl == linkText then
                        [ bareUrl ]

                    else
                        []

                _ ->
                    []
        )


transformWithLinkMetadata : List Node -> Dict String LinkPreview.Metadata -> List Node
transformWithLinkMetadata nodes links =
    List.concatMap
        (\node ->
            case node of
                Element "p" [] [ Element "a" (( "href", bareUrl ) :: _) [ Text linkText ] ] ->
                    case ( Dict.get bareUrl links, bareUrl == linkText ) of
                        ( Just metadata, True ) ->
                            [ node

                            -- TODO Impl preview block here
                            ]

                        _ ->
                            [ node ]

                _ ->
                    [ node ]
        )
        nodes
