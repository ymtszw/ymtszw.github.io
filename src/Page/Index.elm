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
import Route
import Shared exposing (seoBase)
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
                |> DataSource.map Markdown.render

        bio =
            DataSource.map2 (++)
                (DataSource.succeed (Markdown.render "> この節は[public profile repository](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-github-profile/customizing-your-profile/about-your-profile)をサイトビルド時に読み込んでHTML化しています。"))
                (Shared.getGitHubRepoReadme "ymtszw")
    in
    DataSource.map2 Data readme bio


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


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
    { title = "Index"
    , body =
        Html.img [ Html.Attributes.src <| Shared.ogpHeaderImageUrl ++ "?w=750&h=250", Html.Attributes.width 750, Html.Attributes.height 250, Html.Attributes.alt "Mt. Asama Header Image" ] []
            :: static.data.readme
            ++ [ Html.h2 [] [ Html.text "自己紹介 ", Html.a [ Html.Attributes.href "https://github.com/ymtszw/ymtszw", Html.Attributes.target "_blank" ] [ Html.text "(source)" ] ]
               , Html.details [] <| Html.summary [] [ Html.text "開く" ] :: static.data.bio
               , Html.h2 [] [ Html.text "記事" ]
               , Html.blockquote [] [ Html.text "このリストはサイトビルド時にmicroCMSからデータを取得し、事前構築しています。公開が新しい順です" ]
               , static.sharedData.cmsArticles
                    |> List.map
                        (\metadata ->
                            Html.li []
                                [ Route.link (Route.Articles__ArticleId_ { articleId = metadata.contentId }) [] <|
                                    [ Html.article []
                                        [ Html.header []
                                            [ Html.h3 []
                                                [ Html.text metadata.title
                                                , Html.small [] [ Html.text " [", Html.text (Shared.posixToYmd metadata.publishedAt), Html.text "]" ]
                                                ]
                                            ]
                                        , case metadata.image of
                                            Just cmsImage ->
                                                Html.div [] [ Html.img [ Html.Attributes.src (cmsImage.url ++ "?h=150"), Html.Attributes.alt "Article Header Image", Html.Attributes.height 150 ] [] ]

                                            Nothing ->
                                                Html.div [] []
                                        ]
                                    ]
                                ]
                        )
                    |> Html.ul []
               , Html.h2 [] [ Html.text "Qiita記事" ]
               , Html.blockquote [] [ Html.text "このリストはサイトビルド時にQiitaから（ｒｙ" ]
               , static.sharedData.qiitaArticles
                    |> List.map
                        (\metadata ->
                            Html.li []
                                [ Html.strong [] [ externalLink metadata.url metadata.title ]
                                , Html.br [] []
                                , Html.small []
                                    [ Html.strong [] [ Html.text (String.fromInt metadata.likesCount) ]
                                    , Html.text " ✅"
                                    , Html.code [] (List.map Html.text (List.intersperse ", " metadata.tags))
                                    , Html.text " ["
                                    , Html.text (Shared.posixToYmd metadata.createdAt)
                                    , Html.text "]"
                                    ]
                                ]
                        )
                    |> Html.ul []
               , Html.h2 [] [ Html.text "GitHub Public Repo" ]
               , Html.blockquote [] [ Html.text "このリストはサイトビルド時にGitHub REST APIをHeadless CMSのように見立ててデータを取得し、事前構築しています。作成が新しい順です" ]
               , static.sharedData.repos
                    |> List.map
                        (\publicOriginalRepo ->
                            Html.strong []
                                [ Html.text "["
                                , externalLink ("https://github.com/ymtszw/" ++ publicOriginalRepo) publicOriginalRepo
                                , Html.text "]"
                                ]
                        )
                    |> List.intersperse (Html.text " ")
                    |> Html.p []
               ]
    }


externalLink url text_ =
    Html.a [ Html.Attributes.href url, Html.Attributes.target "_blank" ] [ Html.text text_ ]
