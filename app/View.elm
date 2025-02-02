module View exposing
    ( LightboxMedia
    , View
    , feedLink
    , formatPosix
    , imgLazy
    , lightboxLink
    , map
    , markdownEditor
    , parseLightboxFragment
    , placeholder
    , posixToYmd
    , toggleSwitch
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
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


placeholder : String -> View msg
placeholder moduleName =
    { title = "Placeholder - " ++ moduleName
    , body = [ Html.text moduleName ]
    }


feedLink : String -> Html msg
feedLink linkTo =
    Html.a
        [ Html.Attributes.href linkTo
        , Html.Attributes.target "_blank"
        , Html.Attributes.class "has-image"
        ]
        [ imgLazy
            [ Html.Attributes.src "/feed.png"
            , Html.Attributes.alt "feed icon"
            , Html.Attributes.class "feed"
            ]
            []
        ]


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


markdownEditor : (String -> msg) -> String -> Html msg
markdownEditor tagger val =
    -- https://qiita.com/tsmd/items/fce7bf1f65f03239eef0
    div
        [ class "markdown-editor" ]
        [ div [ class "background", attribute "aria-hidden" "true" ] [ text (val ++ "\u{200B}") ]
        , textarea
            [ onInput tagger
            , value val
            ]
            []
        ]


toggleSwitch : List (Attribute msg) -> List (Html msg) -> Html msg
toggleSwitch attrs _ =
    label [ class "switch" ] [ input (type_ "checkbox" :: attrs) [], span [ class "slider" ] [] ]


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
