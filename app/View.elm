module View exposing
    ( LightboxMedia
    , View
    , formatPosix
    , imgLazy
    , lightboxLink
    , map
    , parseLightboxFragment
    , posixToYmd
    )

import Html exposing (Html)
import Html.Attributes
import Time exposing (Month(..))
import UrlPath exposing (UrlPath)


{-| -}
type alias View msg =
    { title : String
    , body : List (Html msg)
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }


imgLazy : List (Html.Attribute msg) -> List (Html msg) -> Html msg
imgLazy attrs kids =
    Html.img (Html.Attributes.attribute "loading" "lazy" :: attrs) kids


type alias LightboxMedia =
    { href : String
    , src : String
    , type_ : String
    , originReq : { path : UrlPath, query : Maybe String, fragment : Maybe String }
    }


lightboxLink : { href : String, src : String, type_ : String } -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
lightboxLink opts attrs kids =
    Html.a (Html.Attributes.href ("#lightbox:src(" ++ opts.src ++ "):href(" ++ opts.href ++ "):type(" ++ opts.type_ ++ ")") :: attrs) kids


parseLightboxFragment : { path : UrlPath, query : Maybe String, fragment : Maybe String } -> String -> Maybe LightboxMedia
parseLightboxFragment originReq fr =
    if String.startsWith "lightbox:src(" fr then
        case String.split "):href(" (String.dropLeft 13 fr) of
            [ src, rest ] ->
                case String.split "):type(" (String.dropRight 1 rest) of
                    [ href, type_ ] ->
                        Just { href = href, src = src, type_ = type_, originReq = originReq }

                    _ ->
                        Nothing

            _ ->
                Nothing

    else
        Nothing


posixToYmd : Time.Posix -> String
posixToYmd posix =
    String.fromInt (Time.toYear jst posix)
        ++ "年"
        ++ (case Time.toMonth jst posix of
                Jan ->
                    "1月"

                Feb ->
                    "2月"

                Mar ->
                    "3月"

                Apr ->
                    "4月"

                May ->
                    "5月"

                Jun ->
                    "6月"

                Jul ->
                    "7月"

                Aug ->
                    "8月"

                Sep ->
                    "9月"

                Oct ->
                    "10月"

                Nov ->
                    "11月"

                Dec ->
                    "12月"
           )
        ++ String.fromInt (Time.toDay jst posix)
        ++ "日"


formatPosix : Time.Posix -> String
formatPosix posix =
    posixToYmd posix
        ++ " "
        ++ String.padLeft 2 '0' (String.fromInt (Time.toHour jst posix))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (Time.toMinute jst posix))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (Time.toSecond jst posix))
        ++ " JST"


jst =
    Time.customZone (9 * 60) []
