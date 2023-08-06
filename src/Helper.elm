module Helper exposing (dataSourceWith, decodeWith, initMsg, iso8601Decoder, japaneseDateDecoder, makeAmazonUrl, makeDisplayUrl, nonEmptyString, onChange, toJapaneseDate, waitMsg)

import DataSource exposing (DataSource)
import Date exposing (Date)
import Html
import Html.Events
import Iso8601
import Json.Decode
import OptimizedDecoder
import Process
import QS
import Task
import Time
import Url


dataSourceWith : DataSource a -> (a -> DataSource b) -> DataSource b
dataSourceWith a b =
    DataSource.andThen b a


decodeWith : OptimizedDecoder.Decoder a -> (a -> OptimizedDecoder.Decoder b) -> OptimizedDecoder.Decoder b
decodeWith a b =
    OptimizedDecoder.andThen b a


iso8601Decoder : OptimizedDecoder.Decoder Time.Posix
iso8601Decoder =
    OptimizedDecoder.andThen (Iso8601.toTime >> Result.mapError (\_ -> "Invalid ISO8601 timestamp") >> OptimizedDecoder.fromResult) OptimizedDecoder.string


japaneseDateDecoder : OptimizedDecoder.Decoder Date
japaneseDateDecoder =
    decodeWith nonEmptyString <|
        OptimizedDecoder.fromResult
            << fromJapaneseDate


fromJapaneseDate : String -> Result String Date
fromJapaneseDate str =
    case String.split "年" str of
        [ year, monthDay ] ->
            case String.split "月" monthDay of
                [ month, day ] ->
                    Date.fromIsoString <| String.join "-" <| [ year, String.padLeft 2 '0' month, String.padLeft 2 '0' <| String.dropRight 1 day ]

                _ ->
                    Err <| "Invalid Date: " ++ str

        _ ->
            Err <| "Invalid Date: " ++ str


toJapaneseDate : Date -> String
toJapaneseDate date =
    String.fromInt (Date.year date)
        ++ "年"
        ++ String.fromInt (Date.monthNumber date)
        ++ "月"
        ++ String.fromInt (Date.day date)
        ++ "日"


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


makeDisplayUrl : String -> String
makeDisplayUrl =
    removeFragment >> removeQuery >> truncateUrl >> removeRootSlash


removeFragment rawUrl =
    case String.split "#" rawUrl of
        url :: _ ->
            url

        _ ->
            rawUrl


removeQuery rawUrl =
    case String.split "?" rawUrl of
        url :: _ ->
            url

        _ ->
            rawUrl


truncateUrl rawUrl =
    if String.length rawUrl > 40 then
        (rawUrl
            |> String.left 40
            |> String.replace "https://" ""
            |> String.replace "http://" ""
        )
            ++ "..."

    else
        rawUrl
            |> String.replace "https://" ""
            |> String.replace "http://" ""


removeRootSlash rawUrl =
    case String.split "/" rawUrl of
        [ _, "" ] ->
            String.dropRight 1 rawUrl

        _ ->
            rawUrl


makeAmazonUrl : String -> String -> String
makeAmazonUrl amazonAssociateTag rawUrlOrAsin =
    Url.fromString rawUrlOrAsin
        |> Maybe.map
            (\url ->
                case ( url.host, String.contains "/dp/" url.path ) of
                    ( "www.amazon.co.jp", True ) ->
                        embedTag amazonAssociateTag url

                    _ ->
                        Url.toString url
            )
        |> Maybe.withDefault (dpUrlWithTag amazonAssociateTag rawUrlOrAsin)


dpUrlWithTag amazonAssociateTag asin =
    "https://www.amazon.co.jp/dp/" ++ asin ++ "?tag=" ++ amazonAssociateTag


embedTag : String -> Url.Url -> String
embedTag amazonAssociateTag url =
    url.query
        |> Maybe.withDefault ""
        |> QS.parse QS.config
        |> (\qs ->
                { url
                    | query =
                        QS.setStr "tag" amazonAssociateTag qs
                            |> QS.serialize (QS.config |> QS.addQuestionMark False)
                            |> Just
                }
           )
        |> Url.toString


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    Html.Events.stopPropagationOn "change" (Json.Decode.map (\a -> ( a, True )) (Json.Decode.map handler Html.Events.targetValue))
