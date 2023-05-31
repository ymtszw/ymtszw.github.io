module Helper exposing (initMsg, iso8601Decoder, nonEmptyString, waitMsg)

import Iso8601
import OptimizedDecoder
import Process
import Task
import Time


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
