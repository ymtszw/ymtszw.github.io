module ImportTwilogCsvAndBuildSearchIndex exposing (run)

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import BackendTask.File exposing (FileReadError(..))
import BackendTask.Glob exposing (defaultOptions, digits, literal)
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
import Json.Encode
import LinkPreview
import List.Extra
import Pages.Script as Script exposing (Script)
import Regex
import TwilogData exposing (Media, Retweet, TcoUrl, Twilog)
import TwilogSearch
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
                            do (BackendTask.Glob.fromString (home ++ "/Downloads/gada_twt-*.csv")) <|
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
                                        |> removeDuplicatesByStatusId
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


{-| HACK: 2025/06頃のTwilogのCSVエクスポート機能で、同一statusIdのtweetが複数行に重複している不具合があったので、ユーザー側で重複除去する対応。
-}
removeDuplicatesByStatusId : List RawTwilogInCsv -> List RawTwilogInCsv
removeDuplicatesByStatusId twilogs =
    List.Extra.uniqueBy .statusId twilogs


type alias RawTwilogInCsv =
    { statusId : String, url : String, createdAt : String, text : String }


importRecentTwilogs : String -> List RawTwilogInCsv -> BackendTask FatalError ()
importRecentTwilogs previousIdCursor twilogs =
    let
        ( writeTwilogJsonFileTasks, updatedCursor ) =
            twilogs
                |> groupedByYearMonthDay
                |> Dict.foldl importRecentTwilogsByYearMonthDay ( [], previousIdCursor )
    in
    if List.isEmpty writeTwilogJsonFileTasks && updatedCursor == previousIdCursor then
        Script.log "No new Twilogs to import"

    else
        writeTwilogJsonFileTasks
            |> BackendTask.combine
            |> BackendTask.map List.concat
            |> BackendTask.andThen
                (\newTwilogs ->
                    Script.log ("Imported " ++ String.fromInt (List.length newTwilogs) ++ " Twilogs")
                        |> Script.doThen (TwilogSearch.batchAddObjectsOnBuild newTwilogs)
                        |> thenLog ("Indexed " ++ String.fromInt (List.length newTwilogs) ++ " Twilogs")
                )
            |> Script.doThen (Script.writeFile { path = cursorFilePath, body = updatedCursor } |> BackendTask.allowFatal)
            |> thenLog ("Updated cursor to " ++ updatedCursor ++ " in " ++ cursorFilePath)
            |> Script.doThen generateTwilogArchives


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


importRecentTwilogsByYearMonthDay : YearMonthDay -> List RawTwilogInCsv -> ( List (BackendTask FatalError (List Twilog)), Cursor ) -> ( List (BackendTask FatalError (List Twilog)), Cursor )
importRecentTwilogsByYearMonthDay ymd twilogs ( writeTwilogJsonFileTasks, previousIdCursor ) =
    let
        newIdCursor =
            twilogs
                |> List.Extra.maximumBy .statusId
                |> Maybe.map .statusId
                |> Maybe.withDefault previousIdCursor
    in
    ( mergeOrCreateNewTwilogsJsonByYearMonthDay (TwilogData.makeTwilogsJsonPath ymd) twilogs :: writeTwilogJsonFileTasks, newIdCursor )


mergeOrCreateNewTwilogsJsonByYearMonthDay : String -> List RawTwilogInCsv -> BackendTask FatalError (List Twilog)
mergeOrCreateNewTwilogsJsonByYearMonthDay outFilePath twilogs =
    let
        newTwilogsWithScreenName =
            List.map sanitizeTwilog twilogs
    in
    do (collectUserInfo newTwilogsWithScreenName) <|
        \userInfoCache ->
            let
                newTwilogsWithUserInfo =
                    List.map (injectUserInfo userInfoCache) newTwilogsWithScreenName
            in
            BackendTask.File.rawFile outFilePath
                |> BackendTask.allowFatal
                |> BackendTask.andThen (\existingJson -> mergeWithExistingTwilogsJson outFilePath existingJson newTwilogsWithUserInfo)
                |> BackendTask.onError (\_ -> createNewTwilogsJson outFilePath newTwilogsWithUserInfo)
                |> Script.doThen (BackendTask.succeed newTwilogsWithUserInfo)


type alias UserInfo =
    { userName : String, userProfileImageUrl : String }


collectUserInfo : List ( Twilog, ScreenName ) -> BackendTask FatalError (Dict ScreenName UserInfo)
collectUserInfo newTwilogsWithScreenName =
    let
        screenNames =
            newTwilogsWithScreenName
                |> List.map Tuple.second
                |> List.filter ((/=) "gada_twt")
                |> List.Extra.unique
    in
    screenNames
        |> List.map fetchUserInfo
        |> BackendTask.combine
        |> BackendTask.map Dict.fromList


fetchUserInfo : ScreenName -> BackendTask FatalError ( ScreenName, UserInfo )
fetchUserInfo screenName =
    LinkPreview.getMetadataOnBuild ("https://x.com/" ++ screenName)
        |> BackendTask.map
            (\metadata ->
                let
                    reconstructed =
                        LinkPreview.reconstructTwitterUserName metadata.title
                in
                if reconstructed == metadata.title then
                    -- ユーザ名の構成に失敗しているので、おそらくプロフィール画像も正しく取得できていない。ユーザーによってはこのようなケースがある
                    ( screenName, { userName = screenName, userProfileImageUrl = placeholderAvatarUrl } )

                else
                    ( screenName
                    , { userName = reconstructed, userProfileImageUrl = Maybe.withDefault placeholderAvatarUrl metadata.imageUrl }
                    )
            )
        |> BackendTask.onError (\_ -> BackendTask.succeed ( screenName, { userName = screenName, userProfileImageUrl = placeholderAvatarUrl } ))


injectUserInfo : Dict ScreenName UserInfo -> ( Twilog, ScreenName ) -> Twilog
injectUserInfo userInfoCache ( twilog, screenName ) =
    case ( Dict.get screenName userInfoCache, twilog.retweet ) of
        ( Just userInfo, Just retweet ) ->
            -- UserInfoは基本的にRetweetにのみ適用する。Retweetでない場合screenNameはgada_twtであるはず
            { twilog | retweet = Just { retweet | userName = userInfo.userName, userProfileImageUrl = userInfo.userProfileImageUrl } }

        _ ->
            twilog


mergeWithExistingTwilogsJson : String -> String -> List Twilog -> BackendTask FatalError ()
mergeWithExistingTwilogsJson outFilePath existingJson newTwilogs =
    case Decode.decodeString (Decode.list TwilogData.twilogDecoder) existingJson of
        Ok existingTwilogs ->
            let
                -- Merge順序に注意。newで上書きしている
                existingTwilogDict =
                    List.foldl (\twilog acc -> Dict.insert twilog.idStr twilog acc) Dict.empty existingTwilogs

                twilogDict =
                    List.foldl smartlyMergeTwilog existingTwilogDict newTwilogs

                data =
                    Dict.values twilogDict
                        |> List.sortBy .idStr
                        |> List.map (TwilogData.serializeToOnelineTwilogJson False >> Json.Encode.encode 0)
                        |> String.join "\n,\n"
            in
            Script.writeFile
                { path = outFilePath
                , body = "[\n" ++ data ++ "\n]\n"
                }
                |> BackendTask.allowFatal
                |> thenLog ("Merged " ++ outFilePath ++ " (" ++ String.fromInt (List.length existingTwilogs) ++ " existing Twilogs, " ++ String.fromInt (List.length newTwilogs) ++ " new Twilogs)")

        Err error ->
            BackendTask.fail <| FatalError.fromString <| "Failed to decode existing Twilogs JSON: " ++ Debug.toString error


{-| Use New entities EXCEPT profile images if they are placeholders.

The link-preview service and twitter servers sometimes fail to fetch the latest information.

-}
smartlyMergeTwilog : Twilog -> Dict String Twilog -> Dict String Twilog
smartlyMergeTwilog newTwilog existingTwilogs =
    case Dict.get newTwilog.idStr existingTwilogs of
        Just existingTwilog ->
            let
                newTwilogWithReconciledProfileImageUrls =
                    if newTwilog.userProfileImageUrl /= existingTwilog.userProfileImageUrl && newTwilog.userProfileImageUrl == placeholderAvatarUrl then
                        { newTwilog | userProfileImageUrl = existingTwilog.userProfileImageUrl }

                    else
                        newTwilog
            in
            Dict.insert newTwilog.idStr newTwilogWithReconciledProfileImageUrls existingTwilogs

        Nothing ->
            Dict.insert newTwilog.idStr newTwilog existingTwilogs


createNewTwilogsJson : String -> List Twilog -> BackendTask FatalError ()
createNewTwilogsJson outFilePath newTwilogs =
    let
        data =
            newTwilogs
                |> List.sortBy .idStr
                |> List.map (TwilogData.serializeToOnelineTwilogJson False >> Json.Encode.encode 0)
                |> String.join "\n,\n"
    in
    Script.writeFile
        { path = outFilePath
        , body = "[\n" ++ data ++ "\n]\n"
        }
        |> BackendTask.allowFatal
        |> thenLog ("Created " ++ outFilePath ++ " (" ++ String.fromInt (List.length newTwilogs) ++ " Twilogs)")


type alias ScreenName =
    String


sanitizeTwilog : RawTwilogInCsv -> ( Twilog, ScreenName )
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
            extractEmbeddedProperties { isRetweet = isRetweet, screenName = screenName, rawTwilog = rawTwilog }
    in
    ( { createdAt = createdAtPosix
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

      -- Unused when importing from Twilog CSVs
      , inReplyTo = Nothing
      , replies = []
      , quote = Nothing
      }
    , screenName
    )


extractEmbeddedProperties : { isRetweet : Bool, screenName : String, rawTwilog : RawTwilogInCsv } -> ( Maybe Retweet, List TcoUrl, List Media )
extractEmbeddedProperties { isRetweet, screenName, rawTwilog } =
    let
        urlRegex =
            Maybe.withDefault Regex.never (Regex.fromString "https?://[\\w/:%#\\$&\\?\\(\\)~\\.=\\+\\-]+")

        foundUrls =
            rawTwilog.text |> Regex.find urlRegex |> List.map .match

        extendedEntitiesMedia =
            foundUrls
                |> List.filter (\url -> String.contains "://x.com" url || String.contains "://twitter.com" url)
                |> List.filter (\url -> String.contains "/photo/" url || String.contains "/video/" url)
                |> List.map
                    (\url ->
                        if String.contains "/photo/" url then
                            { url = url
                            , sourceUrl = "https://pbs.twimg.com/media/__NOT_LOADED__"
                            , type_ = "photo"
                            , expandedUrl = url
                            }

                        else
                            { url = url
                            , sourceUrl = "https://pbs.twimg.com/amplify_video_thumb/__NOT_LOADED__"
                            , type_ = "video"
                            , expandedUrl = url
                            }
                    )

        entitiesTcoUrl =
            foundUrls
                |> List.filter (\url -> not (List.any (\media -> media.url == url) extendedEntitiesMedia))
                |> List.map (\url -> TcoUrl url url)
    in
    if isRetweet then
        let
            retweet =
                { fullText = rawTwilog.text
                , id = TwilogData.TwitterStatusId rawTwilog.statusId
                , userName = screenName
                , userProfileImageUrl = placeholderAvatarUrl
                , quote = Nothing
                , entitiesTcoUrl = entitiesTcoUrl
                , extendedEntitiesMedia = extendedEntitiesMedia
                }
        in
        ( Just retweet, [], [] )

    else
        ( Nothing, entitiesTcoUrl, extendedEntitiesMedia )


myAvatarUrl20230405 =
    "https://pbs.twimg.com/profile_images/1520432647868391430/4b2AUYjC_normal.jpg"


placeholderAvatarUrl =
    "https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png"


generateTwilogArchives : BackendTask FatalError ()
generateTwilogArchives =
    BackendTask.Glob.succeed (\year month -> year ++ "-" ++ month)
        |> BackendTask.Glob.match (literal "data/")
        |> BackendTask.Glob.capture digits
        |> BackendTask.Glob.match (literal "/")
        |> BackendTask.Glob.capture digits
        |> BackendTask.Glob.toBackendTaskWithOptions { defaultOptions | include = BackendTask.Glob.OnlyFolders }
        |> BackendTask.map (List.sort >> List.reverse)
        |> BackendTask.andThen
            (\yearMonthsFromNewest ->
                Script.writeFile
                    { path = "src/Generated/TwilogArchives.elm"
                    , body = """module Generated.TwilogArchives exposing (TwilogArchiveYearMonth, list)


type alias TwilogArchiveYearMonth =
    String


list : List TwilogArchiveYearMonth
list =
    [ """ ++ (yearMonthsFromNewest |> List.map (\ym -> "\"" ++ ym ++ "\"") |> String.join "\n    , ") ++ """
    ]
"""
                    }
                    |> BackendTask.allowFatal
            )


thenLog : String -> BackendTask a () -> BackendTask a ()
thenLog message =
    Script.doThen (Script.log message)
