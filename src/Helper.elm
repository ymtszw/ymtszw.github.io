module Helper exposing (initMsg, iso8601Decoder, makeAmazonUrl, makeDisplayUrl, nonEmptyString, waitMsg)

import Iso8601
import OptimizedDecoder
import Process
import QS
import Task
import Time
import Url


iso8601Decoder : OptimizedDecoder.Decoder Time.Posix
iso8601Decoder =
    OptimizedDecoder.andThen (Iso8601.toTime >> Result.mapError (\_ -> "Invalid ISO8601 timestamp") >> OptimizedDecoder.fromResult) OptimizedDecoder.string


nonEmptyString : OptimizedDecoder.Decoder String
nonEmptyString =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\s ->
                if String.isEmpty s then
                    OptimizedDecoder.fail "String is empty"

                else
                    OptimizedDecoder.succeed s
            )


initMsg : msg -> Cmd msg
initMsg =
    Task.perform identity << Task.succeed


waitMsg : Float -> msg -> Cmd msg
waitMsg ms msg =
    Task.perform (\() -> msg) (Process.sleep ms)


makeDisplayUrl : String -> String
makeDisplayUrl =
    removeFragment >> removeQuery >> truncateUrl >> removeRootSlash


removeFragment rawUrl =
    case String.split "#" rawUrl of
        url :: _ ->
            url

        _ ->
            rawUrl


removeQuery rawUrl =
    case String.split "?" rawUrl of
        url :: _ ->
            url

        _ ->
            rawUrl


truncateUrl rawUrl =
    if String.length rawUrl > 40 then
        (rawUrl
            |> String.left 40
            |> String.replace "https://" ""
            |> String.replace "http://" ""
        )
            ++ "..."

    else
        rawUrl
            |> String.replace "https://" ""
            |> String.replace "http://" ""


removeRootSlash rawUrl =
    case String.split "/" rawUrl of
        [ _, "" ] ->
            String.dropRight 1 rawUrl

        _ ->
            rawUrl


makeAmazonUrl : String -> String -> String
makeAmazonUrl amazonAssociateTag rawUrl =
    Url.fromString rawUrl
        |> Maybe.map
            (\url ->
                case ( url.host, String.contains "/dp/" url.path ) of
                    ( "www.amazon.co.jp", True ) ->
                        embedTag amazonAssociateTag url

                    _ ->
                        rawUrl
            )
        |> Maybe.withDefault rawUrl


embedTag : String -> Url.Url -> String
embedTag amazonAssociateTag url =
    url.query
        |> Maybe.withDefault ""
        |> QS.parse QS.config
        |> (\qs ->
                { url
                    | query =
                        QS.setStr "tag" amazonAssociateTag qs
                            |> QS.serialize (QS.config |> QS.addQuestionMark False)
                            |> Just
                }
           )
        |> Url.toString
