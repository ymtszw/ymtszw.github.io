module GenerateHtmlEntities exposing (run)

import BackendTask
import BackendTask.Http
import Hex
import Json.Decode as Decode
import Pages.Script as Script exposing (Script)
import String.Graphemes


run : Script
run =
    BackendTask.Http.getJson "https://html.spec.whatwg.org/entities.json" htmlEntitiesDecoder
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\decoded ->
                Script.writeFile
                    { path = "src/Generated/HtmlEntities.elm"
                    , body = makeBody decoded
                    }
                    |> BackendTask.allowFatal
            )
        |> Script.withoutCliOptions


{-| Decode WHATWG official HTML entities JSON.

Example:

    {
        "&AElig": { "codepoints": [198], "characters": "\u00C6" },
        "&AElig;": { "codepoints": [198], "characters": "\u00C6" },
        "&AMP": { "codepoints": [38], "characters": "\u0026" },
        "&AMP;": { "codepoints": [38], "characters": "\u0026" },
        ...
    }

-}
htmlEntitiesDecoder : Decode.Decoder (List { label : String, unicode : List String })
htmlEntitiesDecoder =
    let
        valueDecoder =
            Decode.field "characters" Decode.string
                |> Decode.map convertToElmUnicode
    in
    Decode.keyValuePairs valueDecoder
        |> Decode.map
            (\keyValuePairs ->
                keyValuePairs
                    |> List.filter (\( label, _ ) -> String.endsWith ";" label)
                    |> List.map (\( label, unicode ) -> { label = label |> String.dropLeft 1 |> String.dropRight 1, unicode = unicode })
            )


{-| Convert complex unicodes into codepoints.
-}
convertToElmUnicode : String -> List String
convertToElmUnicode unicode =
    unicode
        |> String.Graphemes.toList
        |> List.concatMap String.toList
        |> List.map (Char.toCode >> Hex.toString >> String.padLeft 4 '0')


makeBody decoded =
    """module Generated.HtmlEntities exposing (dict)

import Dict exposing (Dict)


dict : Dict String String
dict =
    [ """
        ++ String.join "\n    , " (List.map (\{ label, unicode } -> "( \"" ++ label ++ "\", \"\\u{" ++ String.join "}\\u{" unicode ++ "}\" )") decoded)
        ++ """
    ]
        |> Dict.fromList
"""
