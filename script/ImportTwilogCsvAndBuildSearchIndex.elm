module ImportTwilogCsvAndBuildSearchIndex exposing (run)

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import BackendTask.File exposing (FileReadError(..))
import BackendTask.Glob as Glob
import Cli.Option
import Cli.OptionsParser as OptionsParser
import Cli.Program
import Csv.Decode as Csv
import Date
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Helper exposing (requireEnv)
import Iso8601
import Json.Decode as Decode
import List.Extra
import Pages.Script as Script exposing (Script)
import TwilogData exposing (Media, Retweet, TcoUrl, Twilog)
import Url


run : Script
run =
    Script.withCliOptions config
        (\maybeArchiveFilePath ->
            case maybeArchiveFilePath of
                Just archiveFilePath ->
                    importTwilogs archiveFilePath

                Nothing ->
                    do (requireEnv "HOME") <|
                        \home ->
                            do (Glob.fromString (home ++ "/Downloads/gada_twt-*.csv")) <|
                                \archiveFilePaths ->
                                    case List.reverse (List.sort archiveFilePaths) of
                                        [] ->
                                            BackendTask.fail <| FatalError.fromString <| "No Twilog CSV files found in " ++ home ++ "/Downloads/"

                                        latestArchiveFilePath :: _ ->
                                            importTwilogs latestArchiveFilePath
        )


config =
    Cli.Program.config
        |> Cli.Program.add
            (OptionsParser.build identity
                |> OptionsParser.withOptionalPositionalArg (Cli.Option.optionalPositionalArg "archiveFilePath")
            )


importTwilogs : String -> BackendTask FatalError ()
importTwilogs archiveFilePath =
    do (Script.log ("Importing Twilog CSV: " ++ archiveFilePath ++ "\n")) <|
        \() ->
            do (BackendTask.File.rawFile cursorFilePath |> BackendTask.onError (\_ -> BackendTask.succeed lastIdFromZapierTwilogs)) <|
                \previousIdCursor ->
                    do (BackendTask.File.rawFile archiveFilePath |> BackendTask.allowFatal) <|
                        \csvContent ->
                            case
                                Csv.decodeCustom { fieldSeparator = ',' }
                                    (Csv.CustomFieldNames [ "statusId", "url", "createdAt", "text" ])
                                    twilogDecoder
                                    csvContent
                            of
                                Ok tweets ->
                                    tweets
                                        |> List.filter (\twilog -> twilog.statusId > previousIdCursor)
                                        |> importRecentTwilogs previousIdCursor

                                Err error ->
                                    BackendTask.fail <| FatalError.fromString <| "Failed to decode Twilog CSV: " ++ Csv.errorToString error


twilogDecoder =
    Csv.succeed (\statusId url createdAt text -> { statusId = statusId, url = url, createdAt = createdAt, text = text })
        |> Csv.pipeline (Csv.field "statusId" Csv.string)
        |> Csv.pipeline (Csv.field "url" Csv.string)
        |> Csv.pipeline (Csv.field "createdAt" Csv.string)
        |> Csv.pipeline (Csv.field "text" (Csv.string |> Csv.map (String.replace "\u{000D}\n" "\n")))


cursorFilePath =
    "data/TWILOGS_CSV_ID_CURSOR"


type alias Cursor =
    String


lastIdFromZapierTwilogs : Cursor
lastIdFromZapierTwilogs =
    "1701931660152041841"


type alias RawTwilogInCsv =
    { statusId : String, url : String, createdAt : String, text : String }


importRecentTwilogs : String -> List RawTwilogInCsv -> BackendTask FatalError ()
importRecentTwilogs previousIdCursor twilogs =
    case
        twilogs
            |> groupedByYearMonthDay
            |> Dict.foldl importRecentTwilogsByYearMonthDay ( [], previousIdCursor )
    of
        ( writeTwilogJsonFileTasks, updatedCursor ) ->
            writeTwilogJsonFileTasks
                |> BackendTask.combine
                |> BackendTask.do
                |> Script.doThen
                    -- TODO Update cursor here after all implementations are done
                    (Script.log ("Updated cursor to " ++ updatedCursor ++ " in " ++ cursorFilePath))
                |> Script.doThen (Script.log ("Imported " ++ String.fromInt (List.length twilogs) ++ " Twilogs"))


type alias YearMonthDay =
    String


groupedByYearMonthDay : List RawTwilogInCsv -> Dict YearMonthDay (List RawTwilogInCsv)
groupedByYearMonthDay twilogs =
    List.foldl
        (\twilog acc -> Dict.update (makeYearMonthDay twilog.createdAt) (\maybeList -> maybeList |> Maybe.map ((::) twilog) |> Maybe.withDefault [ twilog ] |> Just) acc)
        Dict.empty
        twilogs


makeYearMonthDay : String -> YearMonthDay
makeYearMonthDay createdAtInTwilogCsv =
    createdAtInTwilogCsv
        |> String.slice 0 10


importRecentTwilogsByYearMonthDay : YearMonthDay -> List RawTwilogInCsv -> ( List (BackendTask FatalError ()), Cursor ) -> ( List (BackendTask FatalError ()), Cursor )
importRecentTwilogsByYearMonthDay ymd twilogs ( writeTwilogJsonFileTasks, previousIdCursor ) =
    let
        newIdCursor =
            twilogs
                |> List.Extra.maximumBy .statusId
                |> Maybe.map .statusId
                |> Maybe.withDefault previousIdCursor
    in
    ( mergeOrCreateNewTwilogsJsonByYearMonthDay (TwilogData.makeTwilogsJsonPath ymd) twilogs :: writeTwilogJsonFileTasks, newIdCursor )


mergeOrCreateNewTwilogsJsonByYearMonthDay : String -> List RawTwilogInCsv -> BackendTask FatalError ()
mergeOrCreateNewTwilogsJsonByYearMonthDay outFilePath twilogs =
    BackendTask.File.rawFile outFilePath
        |> BackendTask.allowFatal
        |> BackendTask.andThen (\existingJson -> mergeWithExistingTwilogsJson outFilePath existingJson twilogs)
        |> BackendTask.onError (\_ -> createNewTwilogsJson outFilePath twilogs)


mergeWithExistingTwilogsJson : String -> String -> List RawTwilogInCsv -> BackendTask FatalError ()
mergeWithExistingTwilogsJson outFilePath existingJson twilogs =
    case Decode.decodeString (Decode.list (TwilogData.twilogDecoder Nothing)) existingJson of
        Ok existingTwilogs ->
            let
                newTwilogs =
                    List.map sanitizeTwilog twilogs

                -- Merge順序に注意。newで上書きしている
                existingTwilogDict =
                    List.foldl (\twilog acc -> Dict.insert twilog.idStr twilog acc) Dict.empty existingTwilogs

                twilogDict =
                    List.foldl (\twilog acc -> Dict.insert twilog.idStr twilog acc) existingTwilogDict newTwilogs

                data =
                    Dict.values twilogDict
                        |> List.sortBy .idStr
                        |> List.map TwilogData.serializeToOnelineTwilogJson
                        |> String.join "\n,\n"
            in
            Script.writeFile
                { path = outFilePath
                , body = "[\n" ++ data ++ "\n]\n"
                }
                |> BackendTask.allowFatal
                |> Script.doThen (Script.log ("Merged " ++ outFilePath ++ " (" ++ String.fromInt (List.length existingTwilogs) ++ " existing Twilogs, " ++ String.fromInt (List.length newTwilogs) ++ " new Twilogs)"))

        Err error ->
            BackendTask.fail <| FatalError.fromString <| "Failed to decode existing Twilogs JSON: " ++ Debug.toString error


createNewTwilogsJson : String -> List RawTwilogInCsv -> BackendTask FatalError ()
createNewTwilogsJson outFilePath twilogs =
    let
        data =
            twilogs
                |> List.map sanitizeTwilog
                |> List.sortBy .idStr
                |> List.map TwilogData.serializeToOnelineTwilogJson
                |> String.join "\n,\n"
    in
    Script.writeFile
        { path = outFilePath
        , body = "[\n" ++ data ++ "\n]\n"
        }
        |> BackendTask.allowFatal
        |> Script.doThen (Script.log ("Created " ++ outFilePath ++ " (" ++ String.fromInt (List.length twilogs) ++ " Twilogs)"))


sanitizeTwilog : RawTwilogInCsv -> Twilog
sanitizeTwilog rawTwilog =
    let
        ( screenName, statusId ) =
            case Url.fromString rawTwilog.url |> Maybe.map (.path >> String.split "/") of
                Just [ "", screenName_, "status", statusId_ ] ->
                    ( screenName_, statusId_ )

                _ ->
                    ( "gada_twt", lastIdFromZapierTwilogs )

        isRetweet =
            screenName /= "gada_twt"

        text =
            String.replace "\u{000D}\n" "\n" rawTwilog.text

        createdAtPosix =
            rawTwilog.createdAt
                |> String.replace " " "T"
                |> (\s -> s ++ "+09:00")
                |> Iso8601.toTime
                |> Result.withDefault Helper.unixOrigin

        ( retweetDetails, entitiesTcoUrl, extendedEntitiesMedia ) =
            extractEmbeddedProperties isRetweet rawTwilog
    in
    { createdAt = createdAtPosix
    , touchedAt = createdAtPosix
    , createdDate = Date.fromPosix Helper.jst createdAtPosix
    , text = text
    , id = TwilogData.TwitterStatusId statusId
    , idStr = statusId
    , userName = "Gada / ymtszw"
    , userProfileImageUrl = myAvatarUrl20230405
    , retweet = retweetDetails
    , entitiesTcoUrl = entitiesTcoUrl
    , extendedEntitiesMedia = extendedEntitiesMedia

    -- Unused when imported from Twilog CSVs
    , inReplyTo = Nothing
    , replies = []
    , quote = Nothing
    }


extractEmbeddedProperties : Bool -> RawTwilogInCsv -> ( Maybe Retweet, List TcoUrl, List Media )
extractEmbeddedProperties isRetweet rawTwilog =
    if isRetweet then
        -- TODO: Implement the logic to extract retweet details
        ( Nothing, [], [] )

    else
        let
            entitiesTcoUrl =
                -- Extract entitiesTcoUrl from rawTwilog
                []

            extendedEntitiesMedia =
                -- Extract extendedEntitiesMedia from rawTwilog
                []
        in
        ( Nothing, entitiesTcoUrl, extendedEntitiesMedia )


myAvatarUrl20230405 =
    "https://pbs.twimg.com/profile_images/1520432647868391430/4b2AUYjC_normal.jpg"


placeholderAvatarUrl =
    "https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png"
