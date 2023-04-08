module Route.About exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import BackendTask.File
import Base64
import Dict
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (href, target)
import Json.Decode
import Json.Decode.Extra
import Markdown
import Markdown.Block
import PagesMsg
import RouteBuilder
import Shared exposing (seoBase)
import View


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    { readme : List Markdown.Block.Block
    , bio : List Markdown.Block.Block
    }


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    let
        readme =
            BackendTask.File.bodyWithoutFrontmatter "README.md"
                |> BackendTask.allowFatal
                |> BackendTask.andThen
                    (Markdown.parse
                        >> BackendTask.fromResult
                        >> BackendTask.mapError FatalError.fromString
                    )

        bio =
            Shared.githubGet "https://api.github.com/repos/ymtszw/ymtszw/contents/README.md"
                (Json.Decode.oneOf
                    [ Json.Decode.field "message" (Json.Decode.map .parsed Markdown.decoder)
                    , Json.Decode.field "content" Json.Decode.string
                        |> Json.Decode.map (String.replace "\n" "")
                        |> Json.Decode.andThen
                            (Base64.toString
                                >> Result.fromMaybe "Base64 Error!"
                                >> Result.andThen Markdown.parse
                                >> Json.Decode.Extra.fromResult
                            )
                    ]
                )
    in
    BackendTask.map2 Data readme bio


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "このサイトについて"
            , description = "Gada / ymtszwの個人ページ。これまでに書いたものなどをリンクしていく予定。elm-pagesで作っている。"
        }
        |> Seo.website


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app _ =
    { title = "このサイトについて"
    , body =
        [ div [] <| Markdown.render Dict.empty app.data.readme
        , h2 [] [ Html.text "自己紹介 ", Html.a [ href "https://github.com/ymtszw/ymtszw", target "_blank" ] [ text "(source)" ] ]
        , div [] <| Markdown.render Dict.empty app.data.bio
        ]
    }
