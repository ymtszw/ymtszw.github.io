module View exposing
    ( LightboxMedia
    , View
    , feedLink
    , imgLazy
    , lightboxLink
    , map
    , parseLightboxFragment
    , placeholder
    )

import Html exposing (Html)
import Html.Attributes


type alias View msg =
    { title : String
    , body : List (Html msg)
    }


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
    }


lightboxLink : LightboxMedia -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
lightboxLink opts attrs kids =
    Html.a (Html.Attributes.href ("#lightbox:src(" ++ opts.src ++ "):href(" ++ opts.href ++ "):type(" ++ opts.type_ ++ ")") :: attrs) kids


parseLightboxFragment : String -> Maybe LightboxMedia
parseLightboxFragment fr =
    if String.startsWith "lightbox:src(" fr then
        case String.split "):href(" (String.dropLeft 13 fr) of
            [ src, rest ] ->
                case String.split "):type(" (String.dropRight 1 rest) of
                    [ href, type_ ] ->
                        Just { href = href, src = src, type_ = type_ }

                    _ ->
                        Nothing

            _ ->
                Nothing

    else
        Nothing
