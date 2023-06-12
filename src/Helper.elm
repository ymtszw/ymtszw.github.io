module Helper exposing (initMsg, iso8601Decoder, makeAmazonUrl, nonEmptyString, waitMsg)

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
                            |> QS.serialize QS.config
                            |> Just
                }
           )
        |> Url.toString
