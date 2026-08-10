module WeatherData exposing
    ( ResidencePeriod
    , WeatherDb
    , WeatherSummary
    , decoder
    , emptyDb
    , loadWeatherDb
    , residencePeriodsDecoder
    , weatherCodeToEmoji
    , weatherCodeToLabel
    , weatherDbEncoder
    , weatherDbFilePath
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
    , weatherCode : Int
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


weatherSummaryForDate : Date -> WeatherDb -> Maybe WeatherSummary
weatherSummaryForDate date db =
    Dict.get (Date.toIsoString date) db


decoder : Decode.Decoder WeatherDb
decoder =
    Decode.dict weatherSummaryDecoder


weatherSummaryDecoder : Decode.Decoder WeatherSummary
weatherSummaryDecoder =
    Decode.map3 WeatherSummary
        (Decode.field "maxTemp" Decode.float)
        (Decode.field "minTemp" Decode.float)
        (Decode.field "weatherCode" Decode.int)


weatherDbEncoder : WeatherDb -> Encode.Value
weatherDbEncoder db =
    Encode.dict identity weatherSummaryEncoder db


weatherSummaryEncoder : WeatherSummary -> Encode.Value
weatherSummaryEncoder ws =
    Encode.object
        [ ( "maxTemp", Encode.float ws.maxTemp )
        , ( "minTemp", Encode.float ws.minTemp )
        , ( "weatherCode", Encode.int ws.weatherCode )
        ]


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


{-| WMO Weather interpretation codes to emoji

Reference: <https://open-meteo.com/en/docs>

-}
weatherCodeToEmoji : Int -> String
weatherCodeToEmoji code =
    if code == 0 then
        -- Clear sky
        "☀️"

    else if code <= 3 then
        -- Mainly clear, partly cloudy, overcast
        "⛅"

    else if code <= 49 then
        -- Fog and depositing rime fog
        "🌫️"

    else if code <= 67 then
        -- Drizzle, Rain
        "🌧️"

    else if code <= 77 then
        -- Snow fall, Snow grains
        "❄️"

    else if code <= 82 then
        -- Rain showers
        "🌦️"

    else if code <= 86 then
        -- Snow showers
        "🌨️"

    else
        -- Thunderstorm
        "⛈️"


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
