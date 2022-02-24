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
    in
    DataSource.map2 Data readme (Shared.getGitHubRepoReadme "ymtszw")


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
            ++ [ Html.h2 [] [ Html.text "記事" ]
               , static.sharedData.cmsArticles
                    |> List.map cmsArticlePreview
                    |> Html.div []
               , Html.h2 [] [ Html.text "Zenn記事" ]
               , static.sharedData.zennArticles
                    |> List.sortBy (.likedCount >> negate)
                    |> List.map
                        (\metadata ->
                            Html.li []
                                [ Html.strong [] [ externalLink metadata.url metadata.title ]
                                , Html.br [] []
                                , Html.small []
                                    [ Html.strong [] [ Html.text (String.fromInt metadata.likedCount) ]
                                    , Html.text " 💚"
                                    , Html.code [] (List.map Html.text (List.intersperse ", " metadata.topics))
                                    , Html.text " ["
                                    , Html.text (Shared.posixToYmd metadata.publishedAt)
                                    , Html.text "]"
                                    ]
                                ]
                        )
                    |> Html.ul []
                    |> showless "zenn-articles"
               , Html.h2 [] [ Html.text "Qiita記事" ]
               , static.sharedData.qiitaArticles
                    |> List.sortBy (.likesCount >> negate)
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
                    |> showless "qiita-articles"
               , Html.h2 [] [ Html.text "GitHub Public Repo" ]
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
                    |> showless "repos"
               , Html.h2 [] [ Html.text "自己紹介 ", Html.a [ Html.Attributes.href "https://github.com/ymtszw/ymtszw", Html.Attributes.target "_blank" ] [ Html.text "(source)" ] ]
               , Html.div [] static.data.bio
                    |> showless "bio"
               ]
    }


showless id inner =
    Html.div []
        [ Html.input [ Html.Attributes.id id, Html.Attributes.type_ "checkbox", Html.Attributes.class "showless-toggle" ] []
        , inner
        , Html.label [ Html.Attributes.for id, Html.Attributes.class "showless-button" ] []
        ]


externalLink url text_ =
    Html.a [ Html.Attributes.href url, Html.Attributes.target "_blank" ] [ Html.text text_ ]


cmsArticlePreview meta =
    Route.link (Route.Articles__ArticleId_ { articleId = meta.contentId }) [ Html.Attributes.class "link-preview" ] <|
        [ Html.blockquote [] <|
            [ Html.table [] <|
                [ Html.tr [] <|
                    [ Html.td [] <|
                        [ Html.strong [] [ Html.text meta.title ]
                        , Html.p [] [ Html.text ("[" ++ Shared.posixToYmd meta.publishedAt ++ "]") ]
                        ]
                    , case meta.image of
                        Just cmsImage ->
                            Html.td [] [ Html.img [ Html.Attributes.src (cmsImage.url ++ "?h=150"), Html.Attributes.alt "Article Header Image", Html.Attributes.height 150 ] [] ]

                        Nothing ->
                            Html.text ""
                    ]
                ]
            ]
        ]
