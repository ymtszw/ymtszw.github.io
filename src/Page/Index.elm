module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
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
                |> DataSource.andThen (Markdown.render >> DataSource.fromResult)

        bio =
            DataSource.map2 (++)
                (DataSource.fromResult (Markdown.render """## Bio [(source)](https://github.com/ymtszw/ymtszw)

> この節は[public profile repository](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/about-your-profile)をサイトビルド時に読み込んでHTML化しています。"""))
                (Shared.getGitHubRepoReadme "ymtszw")
    in
    DataSource.map2 Data readme bio


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "ymtszw's page"
        , image =
            { url = Pages.Url.external <| ogpHeaderImageUrl ++ "?w=900&h=300"
            , alt = "Mt. Asama Header Image"
            , dimensions = Just { width = 900, height = 300 }
            , mimeType = Just "image/jpeg"
            }
        , description = "ymtszw's personal biography page"
        , locale = Just "ja_JP"
        , title = "ymtszw's page"
        }
        |> Seo.website


ogpHeaderImageUrl =
    "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg"


type alias Data =
    { readme : List (Html.Html Never)
    , bio : List (Html.Html Never)
    }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "ymtszw's page"
    , body =
        Html.img [ Html.Attributes.src <| ogpHeaderImageUrl ++ "?w=750&h=250", Html.Attributes.width 750, Html.Attributes.height 250, Html.Attributes.alt "Mt. Asama Header Image" ] []
            :: static.data.readme
            ++ static.data.bio
            ++ [ Html.h2 [] [ Html.text "GitHub Public Repo" ]
               , Html.blockquote [] [ Html.text "このリストはサイトビルド時にGitHub REST APIをHeadless CMSのように見立ててデータを取得し、事前構築しています。作成が新しい順です" ]
               , static.sharedData.repos
                    |> List.map
                        (\publicOriginalRepo ->
                            Html.strong []
                                [ Html.text "["
                                , Html.a [ Html.Attributes.href ("https://github.com/ymtszw/" ++ publicOriginalRepo), Html.Attributes.target "_blank" ] [ Html.text publicOriginalRepo ]
                                , Html.text "]"
                                ]
                        )
                    |> List.intersperse (Html.text " ")
                    |> Html.p []
               ]
    }
