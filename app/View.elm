module View exposing
    ( ExternalView
    , HtmlOrMarkdown(..)
    , View
    , feedLink
    , imgLazy
    , map
    , placeholder
    )

import Html exposing (Html)
import Html.Attributes
import Html.Parser
import Markdown.Block


type alias View msg =
    { title : String
    , body : List (Html msg)
    }


type alias ExternalView =
    { parsed : HtmlOrMarkdown
    , excerpt : String
    , links : List String
    }


type HtmlOrMarkdown
    = Html (List Html.Parser.Node)
    | Markdown (List Markdown.Block.Block)


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
