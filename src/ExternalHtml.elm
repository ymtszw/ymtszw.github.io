module ExternalHtml exposing (decoder, extractInlineTextFromHtml)

import Html.Parser
import Html.Parser.Util
import Markdown
import OptimizedDecoder


decoder : String -> OptimizedDecoder.Decoder (Markdown.DecodedBody msg)
decoder input =
    case Html.Parser.run input of
        Ok nodes ->
            OptimizedDecoder.succeed { html = Html.Parser.Util.toVirtualDom nodes, excerpt = extractInlineTextFromHtml nodes }

        Err e ->
            OptimizedDecoder.fail (Markdown.deadEndsToString e)


extractInlineTextFromHtml : List Html.Parser.Node -> String
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


digHtmlNode : Html.Parser.Node -> String
digHtmlNode node =
    case node of
        Html.Parser.Text text ->
            text

        Html.Parser.Element _ _ nodes ->
            Tuple.first (extractInlineTextHelp nodes "")

        Html.Parser.Comment _ ->
            ""
