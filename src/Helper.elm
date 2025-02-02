module Helper exposing
    ( dataSourceWith
    , deadEndToString
    , deadEndsToString
    , decodeWith
    , initMsg
    , japaneseDateDecoder
    , makeAmazonUrl
    , makeDisplayUrl
    , makeTitle
    , nonEmptyString
    , onChange
    , preprocessMarkdown
    , requireEnv
    , toJapaneseDate
    , twitterProfileImageUrl
    , waitMsg
    )

import BackendTask exposing (BackendTask)
import BackendTask.Env
import Date exposing (Date)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html
import Html.Events
import Json.Decode as Decode
import Parser
import Process
import QS
import Regex
import Site exposing (seoBase)
import Task
import Url
import Url.Builder exposing (string)


dataSourceWith : BackendTask FatalError a -> (a -> BackendTask FatalError b) -> BackendTask FatalError b
dataSourceWith a b =
    BackendTask.andThen b a


{-| v3の`BackendTask.Env.expect`は以前自前実装していた`DataSource.Env`を置き換えられて便利だが、
最初から`FatalError`を返すAPIが提供されなかったので結局自前で補う。
-}
requireEnv : String -> BackendTask FatalError String
requireEnv key =
    BackendTask.Env.expect key
        |> BackendTask.allowFatal


decodeWith : Decode.Decoder a -> (a -> Decode.Decoder b) -> Decode.Decoder b
decodeWith a b =
    Decode.andThen b a


japaneseDateDecoder : Decode.Decoder Date
japaneseDateDecoder =
    decodeWith nonEmptyString <|
        \str ->
            case fromJapaneseDate str of
                Ok date ->
                    Decode.succeed date

                Err err ->
                    Decode.fail err


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


nonEmptyString : Decode.Decoder String
nonEmptyString =
    Decode.string
        |> Decode.andThen
            (\s ->
                if String.isEmpty s then
                    Decode.fail "String is empty"

                else
                    Decode.succeed s
            )


initMsg : msg -> Effect msg
initMsg =
    Task.succeed >> Task.perform identity >> Effect.fromCmd


waitMsg : Float -> msg -> Effect msg
waitMsg ms msg =
    Task.perform (\() -> msg) (Process.sleep ms) |> Effect.fromCmd


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
    Html.Events.stopPropagationOn "change" (Decode.map (\a -> ( a, True )) (Decode.map handler Html.Events.targetValue))


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


makeTitle : String -> String
makeTitle pageTitle =
    case pageTitle of
        "" ->
            seoBase.siteName

        nonEmpty ->
            nonEmpty ++ " | " ++ seoBase.siteName
