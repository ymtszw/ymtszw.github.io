module FetchWeatherData exposing (fetchMissingWeatherData, run)

{-| Open-Meteo Archive API から気象データを取得し、data/weather-db.json に保存するスクリプト。

  - data/residence-periods.json を読み込み居住地マスタを取得
  - data/ ディレクトリの Twilog データファイルから全日付を列挙
  - 未取得の日付のみ差分取得
  - 取得結果を data/weather-db.json にマージして保存

-}

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import BackendTask.File
import BackendTask.Glob as Glob exposing (digits, literal)
import BackendTask.Http
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra
import Pages.Script as Script exposing (Script)
import WeatherData exposing (ResidencePeriod, WeatherDb, WeatherSummary)


run : Script
run =
    fetchMissingWeatherData
        |> Script.withoutCliOptions


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
                                    in
                                    if List.isEmpty missingDates then
                                        Script.log "No missing weather data. All up to date."

                                    else
                                        do (Script.log ("Found " ++ String.fromInt (List.length missingDates) ++ " dates with missing weather data.")) <|
                                            \() ->
                                                do (fetchWeatherForDates residencePeriods missingDates) <|
                                                    \newEntries ->
                                                        let
                                                            mergedDb =
                                                                Dict.union newEntries existingDb

                                                            encodedBody =
                                                                Encode.encode 0 (WeatherData.weatherDbEncoder mergedDb)
                                                        in
                                                        Script.writeFile
                                                            { path = WeatherData.weatherDbFilePath
                                                            , body = encodedBody
                                                            }
                                                            |> BackendTask.allowFatal
                                                            |> thenLog ("Saved " ++ String.fromInt (Dict.size newEntries) ++ " new weather entries to " ++ WeatherData.weatherDbFilePath)


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
                ++ "&daily=temperature_2m_max,temperature_2m_min,weathercode"
                -- NOTE: タイムゾーンは現状 Asia/Tokyo 固定。
                -- 将来 data/residence-periods.json にタイムゾーン項目を追加することで対応可能。
                ++ "&timezone=Asia%2FTokyo"
    in
    BackendTask.Http.getWithOptions
        { url = url
        , headers = []
        , expect = BackendTask.Http.expectJson (openMeteoDecoder dates)
        , cachePath = Nothing
        , cacheStrategy = Nothing
        , retries = Just 3
        , timeoutInMs = Just 30000
        }
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\db ->
                thenLog ("Fetched " ++ String.fromInt (Dict.size db) ++ " days for " ++ yearMonth ++ " (" ++ period.city ++ ")")
                    (BackendTask.succeed db)
            )


openMeteoDecoder : List String -> Decode.Decoder WeatherDb
openMeteoDecoder requestedDates =
    -- NOTE: API のフィールド名は "weathercode"（小文字）だが、
    -- 内部の WeatherSummary / weather-db.json では "weatherCode"（キャメルケース）を使用する。
    Decode.field "daily"
        (Decode.map3
            (\times maxTemps minTemps ->
                ( times, maxTemps, minTemps )
            )
            (Decode.field "time" (Decode.list Decode.string))
            (Decode.field "temperature_2m_max" (Decode.list (Decode.nullable Decode.float)))
            (Decode.field "temperature_2m_min" (Decode.list (Decode.nullable Decode.float)))
            |> Decode.andThen
                (\( times, maxTemps, minTemps ) ->
                    Decode.field "weathercode" (Decode.list (Decode.nullable Decode.int))
                        |> Decode.map
                            (\weatherCodes ->
                                List.map4
                                    (\time maxTemp minTemp weatherCode ->
                                        case ( maxTemp, minTemp, weatherCode ) of
                                            ( Just max, Just min, Just code ) ->
                                                if List.member time requestedDates then
                                                    Just ( time, WeatherSummary max min code )

                                                else
                                                    Nothing

                                            _ ->
                                                Nothing
                                    )
                                    times
                                    maxTemps
                                    minTemps
                                    weatherCodes
                                    |> List.filterMap identity
                                    |> Dict.fromList
                            )
                )
        )


thenLog : String -> BackendTask a () -> BackendTask a ()
thenLog message =
    Script.doThen (Script.log message)
