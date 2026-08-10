module WeatherData exposing
    ( ResidencePeriod
    , WeatherDb
    , WeatherSummary
    , cityForDate
    , decoder
    , emptyDb
    , loadResidencePeriods
    , loadWeatherDb
    , residencePeriodsDecoder
    , weatherCodeToEmoji
    , weatherCodeToLabel
    , weatherCodesDisplay
    , weatherCodesToLabel
    , weatherDbFilePath
    , weatherDbToJsonLines
    , weatherSummaryForDate
    )

import BackendTask exposing (BackendTask)
import BackendTask.File
import Date exposing (Date)
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Json.Decode as Decode
import Json.Encode as Encode


weatherDbFilePath : String
weatherDbFilePath =
    "data/weather-db.json"


residencePeriodsFilePath : String
residencePeriodsFilePath =
    "data/residence-periods.json"


type alias WeatherSummary =
    { maxTemp : Float
    , minTemp : Float
    , weatherCodes : List Int -- [6-12時スロット, 12-18時スロット, 18-24時スロット] の最頻コード
    , latitude : Float
    , longitude : Float
    }


{-| キーは ISO 日付文字列 "YYYY-MM-DD"
-}
type alias WeatherDb =
    Dict String WeatherSummary


type alias ResidencePeriod =
    { from : String
    , to : Maybe String
    , city : String
    , latitude : Float
    , longitude : Float
    }


emptyDb : WeatherDb
emptyDb =
    Dict.empty


loadWeatherDb : BackendTask FatalError WeatherDb
loadWeatherDb =
    BackendTask.File.jsonFile decoder weatherDbFilePath
        |> BackendTask.onError (\_ -> BackendTask.succeed emptyDb)


loadResidencePeriods : BackendTask FatalError (List ResidencePeriod)
loadResidencePeriods =
    BackendTask.File.jsonFile residencePeriodsDecoder residencePeriodsFilePath
        |> BackendTask.allowFatal


weatherSummaryForDate : Date -> WeatherDb -> Maybe WeatherSummary
weatherSummaryForDate date db =
    Dict.get (Date.toIsoString date) db


cityForDate : Date -> List ResidencePeriod -> String
cityForDate date periods =
    currentResidencePeriodForDate date periods
        |> Maybe.map .city
        |> Maybe.withDefault "Tokyo"


currentResidencePeriodForDate : Date -> List ResidencePeriod -> Maybe ResidencePeriod
currentResidencePeriodForDate date periods =
    let
        dateStr =
            Date.toIsoString date
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


decoder : Decode.Decoder WeatherDb
decoder =
    Decode.list
        (Decode.map6
            (\date maxTemp minTemp weatherCodes latitude longitude ->
                ( date, WeatherSummary maxTemp minTemp weatherCodes latitude longitude )
            )
            (Decode.field "date" Decode.string)
            (Decode.field "maxTemp" Decode.float)
            (Decode.field "minTemp" Decode.float)
            -- 旧フォーマット(weatherCode: Int)と新フォーマット(weatherCodes: List Int)の両方に対応
            (Decode.oneOf
                [ Decode.field "weatherCodes" (Decode.list Decode.int)
                , Decode.field "weatherCode" Decode.int |> Decode.map List.singleton
                , Decode.succeed []
                ]
            )
            (Decode.oneOf [ Decode.field "latitude" Decode.float, Decode.succeed 0.0 ])
            (Decode.oneOf [ Decode.field "longitude" Decode.float, Decode.succeed 0.0 ])
        )
        |> Decode.map Dict.fromList


{-| WeatherDb を「1行1日付」のJSONLines形式の文字列にシリアライズする。
日付昇順でソートされ、実行のたびに行順が一定になる。

形式:
[
{"date":"YYYY-MM-DD","maxTemp":X.X,"minTemp":X.X,"weatherCode":N},
...
]

-}
weatherDbToJsonLines : WeatherDb -> String
weatherDbToJsonLines db =
    let
        lines =
            db
                |> Dict.toList
                |> List.sortBy Tuple.first
                |> List.map
                    (\( date, ws ) ->
                        Encode.encode 0
                            (Encode.object
                                [ ( "date", Encode.string date )
                                , ( "maxTemp", Encode.float ws.maxTemp )
                                , ( "minTemp", Encode.float ws.minTemp )
                                , ( "weatherCodes", Encode.list Encode.int ws.weatherCodes )
                                , ( "latitude", Encode.float ws.latitude )
                                , ( "longitude", Encode.float ws.longitude )
                                ]
                            )
                    )
    in
    "[\n" ++ String.join ",\n" lines ++ "\n]"


residencePeriodsDecoder : Decode.Decoder (List ResidencePeriod)
residencePeriodsDecoder =
    Decode.list residencePeriodDecoder


residencePeriodDecoder : Decode.Decoder ResidencePeriod
residencePeriodDecoder =
    Decode.map5 ResidencePeriod
        (Decode.field "from" Decode.string)
        (Decode.field "to" (Decode.nullable Decode.string))
        (Decode.field "city" Decode.string)
        (Decode.field "latitude" Decode.float)
        (Decode.field "longitude" Decode.float)


{-| 隣接する同値を除去する（スロット表示の重複マージに使用）
-}
deduplicateAdjacent : List a -> List a
deduplicateAdjacent xs =
    List.foldr
        (\x acc ->
            case acc of
                [] ->
                    [ x ]

                head :: _ ->
                    if head == x then
                        acc

                    else
                        x :: acc
        )
        []
        xs


{-| 複数スロットの天気コードをマージしてスラッシュ区切りの絵文字で返す
-}
weatherCodesDisplay : List Int -> String
weatherCodesDisplay codes =
    codes
        |> List.map weatherCodeToEmoji
        |> deduplicateAdjacent
        |> String.join "/"


{-| 複数スロットの天気コードをマージしてスラッシュ区切りの日本語ラベルで返す
-}
weatherCodesToLabel : List Int -> String
weatherCodesToLabel codes =
    codes
        |> List.map weatherCodeToLabel
        |> String.join "/"


{-| WMO Weather interpretation codes to emoji

Reference: <https://open-meteo.com/en/docs>

-}
weatherCodeToEmoji : Int -> String
weatherCodeToEmoji code =
    if code == 0 then
        -- Clear sky
        "☀"

    else if code == 1 then
        -- Mainly clear
        "☀"

    else if code <= 3 then
        -- Partly cloudy, overcast
        "☁"

    else if code <= 49 then
        -- Fog and depositing rime fog
        "〰"

    else if code <= 57 then
        -- Drizzle (霧雨は曇り扱い)
        "☁"

    else if code <= 67 then
        -- Rain
        "☔"

    else if code <= 77 then
        -- Snow fall, Snow grains
        "⛄"

    else if code <= 82 then
        -- Rain showers
        "☂"

    else if code <= 86 then
        -- Snow showers
        "☃"

    else
        -- Thunderstorm
        "☈"


{-| WMO Weather interpretation codes to Japanese label
-}
weatherCodeToLabel : Int -> String
weatherCodeToLabel code =
    if code == 0 then
        "快晴"

    else if code == 1 then
        "概ね晴れ"

    else if code == 2 then
        "晴れ時々曇り"

    else if code == 3 then
        "曇り"

    else if code <= 49 then
        "霧"

    else if code <= 57 then
        "霧雨"

    else if code <= 67 then
        "雨"

    else if code <= 77 then
        "雪"

    else if code <= 82 then
        "にわか雨"

    else if code <= 86 then
        "にわか雪"

    else
        "雷雨"
