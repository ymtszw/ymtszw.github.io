module Page.About exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Base64
import DataSource exposing (DataSource)
import DataSource.File
import Dict
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (href, target)
import Markdown
import Markdown.Block
import OptimizedDecoder
import Page
import Pages.PageUrl
import Shared exposing (seoBase)
import View


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


type alias Data =
    { readme : List Markdown.Block.Block
    , bio : List Markdown.Block.Block
    }


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    let
        readme =
            DataSource.File.bodyWithoutFrontmatter "README.md"
                |> DataSource.andThen (Markdown.parse >> DataSource.fromResult)

        bio =
            Shared.githubGet "https://api.github.com/repos/ymtszw/ymtszw/contents/README.md"
                (OptimizedDecoder.oneOf
                    [ OptimizedDecoder.field "message" (OptimizedDecoder.map .parsed Markdown.decoder)
                    , OptimizedDecoder.field "content" OptimizedDecoder.string
                        |> OptimizedDecoder.map (String.replace "\n" "")
                        |> OptimizedDecoder.andThen
                            (Base64.toString
                                >> Result.fromMaybe "Base64 Error!"
                                >> Result.andThen Markdown.parse
                                >> OptimizedDecoder.fromResult
                            )
                    ]
                )
    in
    DataSource.map2 Data readme bio


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "このサイトについて"
            , description = "Gada / ymtszwの個人ページ。これまでに書いたものなどをリンクしていく予定。elm-pagesで作っている。"
        }
        |> Seo.website


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ _ app =
    { title = "このサイトについて"
    , body =
        [ div [] <| Markdown.render Dict.empty app.data.readme
        , h2 [] [ Html.text "自己紹介 ", Html.a [ href "https://github.com/ymtszw/ymtszw", target "_blank" ] [ text "(source)" ] ]
        , div [] <| Markdown.render Dict.empty app.data.bio
        ]
    }
