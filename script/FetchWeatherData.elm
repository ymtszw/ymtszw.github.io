module FetchWeatherData exposing (fetchMissingWeatherData, run)

{-| Open-Meteo Archive API から気象データを取得し、data/weather-db.json に保存するスクリプト。

  - data/residence-periods.json を読み込み居住地マスタを取得
  - data/ ディレクトリの Twilog データファイルから全日付を列挙
  - 未取得の日付のみ差分取得（--date オプション指定時は強制再取得・上書き）
  - 取得結果を data/weather-db.json にマージして保存

オプション:
--date YYYY-MM-DD 特定の日付を指定して気象データを取得（既存データも上書き）

-}

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import BackendTask.File
import BackendTask.Glob as Glob exposing (digits, literal)
import BackendTask.Http
import Cli.Option
import Cli.OptionsParser as OptionsParser
import Cli.Program
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Json.Decode as Decode
import List.Extra
import Pages.Script as Script exposing (Script)
import WeatherData exposing (ResidencePeriod, WeatherDb, WeatherSummary)


run : Script
run =
    Script.withCliOptions config
        (\maybeDate ->
            case maybeDate of
                Just date ->
                    fetchWeatherForSpecificDate date

                Nothing ->
                    fetchMissingWeatherData
        )


config =
    Cli.Program.config
        |> Cli.Program.add
            (OptionsParser.build identity
                |> OptionsParser.with
                    (Cli.Option.optionalKeywordArg "date"
                        |> Cli.Option.withDescription "特定の日付を指定 (YYYY-MM-DD形式)。指定した場合、既存データを上書きして再取得する。"
                    )
            )


fetchWeatherForSpecificDate : String -> BackendTask FatalError ()
fetchWeatherForSpecificDate date =
    do (Script.log ("Fetching weather data for specific date: " ++ date)) <|
        \() ->
            do loadResidencePeriods <|
                \residencePeriods ->
                    do loadExistingWeatherDb <|
                        \existingDb ->
                            do (fetchWeatherForDates residencePeriods [ date ]) <|
                                \newEntries ->
                                    let
                                        mergedDb =
                                            Dict.union newEntries existingDb

                                        encodedBody =
                                            WeatherData.weatherDbToJsonLines mergedDb
                                    in
                                    Script.writeFile
                                        { path = WeatherData.weatherDbFilePath
                                        , body = encodedBody
                                        }
                                        |> BackendTask.allowFatal
                                        |> thenLog ("Saved weather entry for " ++ date ++ " to " ++ WeatherData.weatherDbFilePath)


fetchMissingWeatherData : BackendTask FatalError ()
fetchMissingWeatherData =
    do (Script.log "Fetching weather data...") <|
        \() ->
            do loadResidencePeriods <|
                \residencePeriods ->
                    do listAllTwilogDates <|
                        \allDates ->
                            do loadExistingWeatherDb <|
                                \existingDb ->
                                    let
                                        missingDates =
                                            List.filter (\d -> not (Dict.member d existingDb)) allDates

                                        monthGroups =
                                            missingDates
                                                |> groupByYearMonth
                                                |> Dict.toList
                                    in
                                    if List.isEmpty missingDates then
                                        Script.log "No missing weather data. All up to date."

                                    else
                                        do (Script.log ("Found " ++ String.fromInt (List.length missingDates) ++ " dates with missing weather data.")) <|
                                            \() ->
                                                -- 月ごとに順番に取得・保存（並列だとレート制限に引っかかるため）
                                                fetchAndSaveMonthsSequentially residencePeriods monthGroups existingDb 0


{-| 月グループを1件ずつ順番に取得し、取得のたびに weather-db.json に保存する。
これにより途中で失敗しても保存済み分が保持され、再実行で差分取得できる。
-}
fetchAndSaveMonthsSequentially : List ResidencePeriod -> List ( String, List String ) -> WeatherDb -> Int -> BackendTask FatalError ()
fetchAndSaveMonthsSequentially residencePeriods monthGroups accDb totalSaved =
    case monthGroups of
        [] ->
            Script.log ("Saved " ++ String.fromInt totalSaved ++ " new weather entries to " ++ WeatherData.weatherDbFilePath)

        ( yearMonth, dates ) :: rest ->
            let
                period =
                    findResidencePeriod residencePeriods (List.head dates |> Maybe.withDefault "")
            in
            do (fetchMonthlyWeather period yearMonth dates) <|
                \newEntries ->
                    let
                        mergedDb =
                            Dict.union newEntries accDb

                        encodedBody =
                            WeatherData.weatherDbToJsonLines mergedDb
                    in
                    do (Script.writeFile { path = WeatherData.weatherDbFilePath, body = encodedBody } |> BackendTask.allowFatal) <|
                        \() ->
                            fetchAndSaveMonthsSequentially residencePeriods rest mergedDb (totalSaved + Dict.size newEntries)


loadResidencePeriods : BackendTask FatalError (List ResidencePeriod)
loadResidencePeriods =
    BackendTask.File.jsonFile WeatherData.residencePeriodsDecoder "data/residence-periods.json"
        |> BackendTask.allowFatal


listAllTwilogDates : BackendTask FatalError (List String)
listAllTwilogDates =
    Glob.succeed (\year month day -> year ++ "-" ++ month ++ "-" ++ day)
        |> Glob.match (literal "data/")
        |> Glob.capture digits
        |> Glob.match (literal "/")
        |> Glob.capture digits
        |> Glob.match (literal "/")
        |> Glob.capture digits
        |> Glob.match (literal "-twilogs.json")
        |> Glob.toBackendTask
        |> BackendTask.map List.sort


loadExistingWeatherDb : BackendTask FatalError WeatherDb
loadExistingWeatherDb =
    WeatherData.loadWeatherDb


fetchWeatherForDates : List ResidencePeriod -> List String -> BackendTask FatalError WeatherDb
fetchWeatherForDates residencePeriods missingDates =
    -- 月単位でグループ化し、居住地ごとにAPIリクエスト
    missingDates
        |> groupByYearMonth
        |> Dict.toList
        |> List.map
            (\( yearMonth, dates ) ->
                let
                    period =
                        findResidencePeriod residencePeriods (List.head dates |> Maybe.withDefault "")
                in
                fetchMonthlyWeather period yearMonth dates
            )
        |> BackendTask.combine
        |> BackendTask.map (List.foldl Dict.union Dict.empty)


groupByYearMonth : List String -> Dict String (List String)
groupByYearMonth dates =
    List.foldl
        (\date acc ->
            let
                yearMonth =
                    String.left 7 date
            in
            Dict.update yearMonth
                (\maybeList ->
                    case maybeList of
                        Just list ->
                            Just (date :: list)

                        Nothing ->
                            Just [ date ]
                )
                acc
        )
        Dict.empty
        dates


findResidencePeriod : List ResidencePeriod -> String -> ResidencePeriod
findResidencePeriod periods dateStr =
    let
        defaultPeriod =
            { from = "2011-01-01"
            , to = Nothing
            , city = "Tokyo"
            , latitude = 35.6895
            , longitude = 139.6917
            }
    in
    periods
        |> List.filter
            (\period ->
                period.from
                    <= dateStr
                    && (case period.to of
                            Nothing ->
                                True

                            Just toDate ->
                                dateStr <= toDate
                       )
            )
        |> List.head
        |> Maybe.withDefault defaultPeriod


fetchMonthlyWeather : ResidencePeriod -> String -> List String -> BackendTask FatalError WeatherDb
fetchMonthlyWeather period yearMonth dates =
    let
        sortedDates =
            List.sort dates

        startDate =
            List.head sortedDates |> Maybe.withDefault (yearMonth ++ "-01")

        endDate =
            List.Extra.last sortedDates |> Maybe.withDefault (yearMonth ++ "-28")

        url =
            "https://archive-api.open-meteo.com/v1/archive"
                ++ "?latitude="
                ++ String.fromFloat period.latitude
                ++ "&longitude="
                ++ String.fromFloat period.longitude
                ++ "&start_date="
                ++ startDate
                ++ "&end_date="
                ++ endDate
                -- hourly weather_code から時間帯別最頻コードを算出する
                ++ "&hourly=weather_code&daily=temperature_2m_max,temperature_2m_min"
                -- NOTE: タイムゾーンは現状 Asia/Tokyo 固定。
                -- 将来 data/residence-periods.json にタイムゾーン項目を追加することで対応可能。
                ++ "&timezone=Asia%2FTokyo"
    in
    BackendTask.Http.getWithOptions
        { url = url
        , headers = []
        , expect = BackendTask.Http.expectJson (openMeteoDecoder dates period.latitude period.longitude)
        , cachePath = Nothing
        , cacheStrategy = Nothing
        , retries = Just 3
        , timeoutInMs = Just 30000
        }
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\db ->
                Script.log ("Fetched " ++ String.fromInt (Dict.size db) ++ " days for " ++ yearMonth ++ " (" ++ period.city ++ ")")
                    |> BackendTask.andThen (\() -> BackendTask.succeed db)
            )


openMeteoDecoder : List String -> Float -> Float -> Decode.Decoder WeatherDb
openMeteoDecoder requestedDates latitude longitude =
    Decode.map2
        (\hourlyByDate dailyTemps ->
            requestedDates
                |> List.filterMap
                    (\date ->
                        case Dict.get date dailyTemps of
                            Nothing ->
                                Nothing

                            Just ( maxTemp, minTemp ) ->
                                let
                                    codes =
                                        Dict.get date hourlyByDate
                                            |> Maybe.withDefault []
                                            |> computeSlotCodes
                                in
                                if List.isEmpty codes then
                                    Nothing

                                else
                                    Just ( date, WeatherSummary maxTemp minTemp codes latitude longitude )
                    )
                |> Dict.fromList
        )
        hourlyWeatherByDateDecoder
        dailyTempsDecoder


{-| hourly.time と hourly.weather\_code を date -> [(hour, code)] の Dict に変換する
-}
hourlyWeatherByDateDecoder : Decode.Decoder (Dict String (List ( Int, Int )))
hourlyWeatherByDateDecoder =
    Decode.field "hourly"
        (Decode.map2
            (\times codes ->
                List.map2
                    (\timeStr maybeCode ->
                        Maybe.map
                            (\code ->
                                let
                                    date =
                                        String.left 10 timeStr

                                    hour =
                                        String.slice 11 13 timeStr
                                            |> String.toInt
                                            |> Maybe.withDefault -1
                                in
                                ( date, hour, code )
                            )
                            maybeCode
                    )
                    times
                    codes
                    |> List.filterMap identity
                    |> List.foldl
                        (\( date, hour, code ) acc ->
                            Dict.update date
                                (\maybeList -> Just (( hour, code ) :: Maybe.withDefault [] maybeList))
                                acc
                        )
                        Dict.empty
            )
            (Decode.field "time" (Decode.list Decode.string))
            (Decode.field "weather_code" (Decode.list (Decode.nullable Decode.int)))
        )


{-| daily から date -> (maxTemp, minTemp) の Dict を作る
-}
dailyTempsDecoder : Decode.Decoder (Dict String ( Float, Float ))
dailyTempsDecoder =
    Decode.field "daily"
        (Decode.map3
            (\dates maxTemps minTemps ->
                List.map3
                    (\date maybeMax maybeMin ->
                        case ( maybeMax, maybeMin ) of
                            ( Just max, Just min ) ->
                                Just ( date, ( max, min ) )

                            _ ->
                                Nothing
                    )
                    dates
                    maxTemps
                    minTemps
                    |> List.filterMap identity
                    |> Dict.fromList
            )
            (Decode.field "time" (Decode.list Decode.string))
            (Decode.field "temperature_2m_max" (Decode.list (Decode.nullable Decode.float)))
            (Decode.field "temperature_2m_min" (Decode.list (Decode.nullable Decode.float)))
        )


{-| 6-11時、12-17時、18-23時のスロット別最頻天気コードを返す（各スロットが空なら省略）
-}
computeSlotCodes : List ( Int, Int ) -> List Int
computeSlotCodes hourAndCodePairs =
    [ ( 6, 11 ), ( 12, 17 ), ( 18, 23 ) ]
        |> List.filterMap
            (\( slotStart, slotEnd ) ->
                hourAndCodePairs
                    |> List.filterMap
                        (\( hour, code ) ->
                            if hour >= slotStart && hour <= slotEnd then
                                Just code

                            else
                                Nothing
                        )
                    |> computeMode
            )


{-| リスト中で最も出現回数が多い値を返す（同数の場合は辞書順で最小）
-}
computeMode : List Int -> Maybe Int
computeMode codes =
    case codes of
        [] ->
            Nothing

        _ ->
            codes
                |> List.foldl
                    (\code acc ->
                        Dict.update code
                            (\maybeCount -> Just (1 + Maybe.withDefault 0 maybeCount))
                            acc
                    )
                    Dict.empty
                |> Dict.toList
                |> List.sortBy (\( _, count ) -> -count)
                |> List.head
                |> Maybe.map Tuple.first


thenLog : String -> BackendTask a () -> BackendTask a ()
thenLog message =
    Script.doThen (Script.log message)
