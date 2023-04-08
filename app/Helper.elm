module Helper exposing (nonEmptyString)

import Json.Decode


nonEmptyString : Json.Decode.Decoder String
nonEmptyString =
    Json.Decode.string
        |> Json.Decode.andThen
            (\s ->
                if String.isEmpty s then
                    Json.Decode.fail "String is empty"

                else
                    Json.Decode.succeed s
            )
