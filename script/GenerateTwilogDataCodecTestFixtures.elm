module GenerateTwilogDataCodecTestFixtures exposing (run)

{-| Script to generate the Ephemeral.TwilogDataCodecTestFixtures module for testing
-}

import BackendTask
import BackendTask.Do exposing (do)
import BackendTask.File
import BackendTask.Glob
import BackendTask.Random
import List.Extra
import Pages.Script as Script exposing (Script)


run : Script
run =
    -- Twilogから取得したJSONファイルを使うようになったのは2024年後半からなので、2025年のデータをfixtureとして使う
    -- それ以前のデータはTwitter v2 APIをZapier経由で利用して取得したものだったので、ReplyやQuoteなどより多くの情報を含んでいるが、
    -- TwilogData.serializeToOnelineTwilogJsonはそれらに対応しておらず、する予定もない
    Script.withoutCliOptions <|
        do (BackendTask.Glob.fromString "data/2025/**/*-twilogs.json") <|
            \twilogJsonFiles ->
                do (BackendTask.sequence (List.repeat 30 BackendTask.Random.int32)) <|
                    \randomInts ->
                        let
                            numOfFiles =
                                List.length twilogJsonFiles

                            selectRandomTwilogJsonFilesUpTo30 =
                                randomInts
                                    |> List.map (remainderBy numOfFiles)
                                    |> List.Extra.unique
                                    |> List.filterMap (\randomIndex -> List.Extra.getAt randomIndex twilogJsonFiles)
                                    |> List.sort
                                    |> List.map (BackendTask.File.rawFile >> BackendTask.allowFatal)
                                    |> BackendTask.sequence
                        in
                        do selectRandomTwilogJsonFilesUpTo30 <|
                            \selectedTwilogJsons ->
                                let
                                    fixtureFilePath =
                                        "tests/Ephemeral/TwilogDataCodecTestFixtures.elm"

                                    rawLines =
                                        List.concatMap stripBracketsAndCommas selectedTwilogJsons
                                in
                                Script.writeFile
                                    { path = fixtureFilePath
                                    , body = makeBody rawLines
                                    }
                                    |> BackendTask.allowFatal
                                    |> Script.doThen (Script.log ("Generated " ++ fixtureFilePath ++ " from " ++ String.fromInt (List.length selectedTwilogJsons) ++ " data files (" ++ String.fromInt (List.length rawLines) ++ " total lines)"))


makeBody : List String -> String
makeBody rawLines =
    let
        lines =
            rawLines
                |> List.map escapeJsonReservedChars
                |> List.map wrapWithHereStringBoundary
    in
    """module Ephemeral.TwilogDataCodecTestFixtures exposing (fixtures)


fixtures : List String
fixtures =
    [ """ ++ String.join "\n    , " lines ++ """
    ]
"""


stripBracketsAndCommas : String -> List String
stripBracketsAndCommas json =
    -- Input JSON:
    -- [
    -- { ... }
    -- ,
    -- { ... }
    -- ,
    -- { ... }
    -- ]
    String.lines json
        |> List.indexedMap
            (\index line ->
                if remainderBy 2 index == 0 then
                    []

                else if String.length line > 2 then
                    -- 少なくとも`{}`でないとJSONとして読めない、不正な行と言える
                    [ line ]

                else
                    []
            )
        |> List.concat


escapeJsonReservedChars : String -> String
escapeJsonReservedChars str =
    str
        |> String.replace "\\n" "\\\\n"
        |> String.replace "\\\"" "\\\\\""


wrapWithHereStringBoundary : String -> String
wrapWithHereStringBoundary str =
    "\"\"\"" ++ str ++ "\"\"\""
