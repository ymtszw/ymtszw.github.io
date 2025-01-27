module Helper exposing
    ( dataSourceWith
    , deadEndToString
    , deadEndsToString
    , decodeWith
    , initMsg
    , iso8601Decoder
    , japaneseDateDecoder
    , makeAmazonUrl
    , makeDisplayUrl
    , makeReq
    , nonEmptyString
    , onChange
    , preprocessMarkdown
    , toJapaneseDate
    , twitterProfileImageUrl
    , waitMsg
    )

import DataSource exposing (DataSource)
import Date exposing (Date)
import Html
import Html.Events
import Iso8601
import Json.Decode
import OptimizedDecoder
import Pages.Secrets
import Parser
import Process
import QS
import Regex
import Task
import Time
import Url
import Url.Builder exposing (string)


dataSourceWith : DataSource a -> (a -> DataSource b) -> DataSource b
dataSourceWith a b =
    DataSource.andThen b a


{-| elm-pages v2のPages.Secrets APIがあまり素性が良くないので、v3アップグレードまでの間グルーする関数をこのmoduleから提供しておく

基本的に、`Pages.Secrets.with`を使わず`DataSource.Env.load`を使うと、この関数と組み合わせながらきれいに移行できるはず

-}
makeReq : req -> Pages.Secrets.Value req
makeReq =
    Pages.Secrets.succeed


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


twitterProfileImageUrl : String -> String
twitterProfileImageUrl screenName =
    Url.Builder.crossOrigin "http://link-preview.ymtszw.workers.dev" [] [ string "tw-profile-icon" screenName ]


onChange : (String -> msg) -> Html.Attribute msg
onChange handler =
    Html.Events.stopPropagationOn "change" (Json.Decode.map (\a -> ( a, True )) (Json.Decode.map handler Html.Events.targetValue))


deadEndsToString : List { a | row : Int, col : Int, problem : Parser.Problem } -> String
deadEndsToString =
    List.map deadEndToString >> String.join "\n"


deadEndToString : { a | row : Int, col : Int, problem : Parser.Problem } -> String
deadEndToString deadEnd =
    "Problem at row " ++ String.fromInt deadEnd.row ++ ", col " ++ String.fromInt deadEnd.col ++ "\n" ++ problemToString deadEnd.problem


problemToString : Parser.Problem -> String
problemToString problem =
    case problem of
        Parser.Expecting string ->
            "Expecting " ++ string

        Parser.ExpectingInt ->
            "Expecting int"

        Parser.ExpectingHex ->
            "Expecting hex"

        Parser.ExpectingOctal ->
            "Expecting octal"

        Parser.ExpectingBinary ->
            "Expecting binary"

        Parser.ExpectingFloat ->
            "Expecting float"

        Parser.ExpectingNumber ->
            "Expecting number"

        Parser.ExpectingVariable ->
            "Expecting variable"

        Parser.ExpectingSymbol string ->
            "Expecting symbol " ++ string

        Parser.ExpectingKeyword string ->
            "Expecting keyword " ++ string

        Parser.ExpectingEnd ->
            "Expecting keyword end"

        Parser.UnexpectedChar ->
            "Unexpected char"

        Parser.Problem problemDescription ->
            problemDescription

        Parser.BadRepeat ->
            "Bad repeat"


preprocessMarkdown : String -> String
preprocessMarkdown =
    convertPlainUrlToAngledUrl


convertPlainUrlToAngledUrl : String -> String
convertPlainUrlToAngledUrl =
    Regex.replace plainUrlPattern <|
        \{ match } -> "[" ++ makeDisplayUrl match ++ "](" ++ match ++ ")"


plainUrlPattern =
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|\\s|。)(?<!\\]:\\s+)https?://\\S+(?=\\s|$)")
