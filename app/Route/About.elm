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
import GitHubData
import Head
import Head.Seo as Seo
import Helper exposing (decodeFromResult)
import Html exposing (..)
import Html.Attributes exposing (href, target)
import Json.Decode as Decode
import Markdown
import Markdown.Block
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Site exposing (seoBase)
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


route : StatelessRoute RouteParams Data ActionData
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
                |> BackendTask.andThen (Markdown.parse >> Result.mapError FatalError.fromString >> BackendTask.fromResult)

        bio =
            GitHubData.githubGet "https://api.github.com/repos/ymtszw/ymtszw/contents/README.md"
                (Decode.oneOf
                    [ Decode.field "message" (Decode.map .parsed Markdown.decoder)
                    , Decode.field "content" Decode.string
                        |> Decode.map (String.replace "\n" "")
                        |> Decode.andThen
                            (Base64.toString
                                >> Result.fromMaybe "Base64 Error!"
                                >> Result.andThen Markdown.parse
                                >> decodeFromResult
                            )
                    ]
                )
    in
    BackendTask.map2 Data readme bio


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    { seoBase
        | title = Helper.makeTitle "このサイトについて"
    }
        |> Seo.summaryLarge
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View.View (PagesMsg Msg)
view app _ =
    { title = "このサイトについて"
    , body =
        [ div [] <| Markdown.render Dict.empty app.data.readme
        , h2 [] [ Html.text "自己紹介 ", Html.a [ href "https://github.com/ymtszw/ymtszw", target "_blank" ] [ text "(source)" ] ]
        , div [] <| Markdown.render Dict.empty app.data.bio
        ]
    }
