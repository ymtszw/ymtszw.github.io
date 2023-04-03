module Page.Index exposing (Data, Model, Msg, cmsArticlePreview, page)

import DataSource exposing (DataSource)
import Dict
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import Page exposing (Page, StaticPayload)
import Page.Twilogs
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


type alias Data =
    ()


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ shared static =
    { title = "Index"
    , body =
        [ Html.h1 []
            [ Html.img [ Html.Attributes.src <| Shared.ogpHeaderImageUrl ++ "?w=750&h=250", Html.Attributes.width 750, Html.Attributes.height 250, Html.Attributes.alt "Mt. Asama Header Image" ] []
            , Html.text "ymtszw's page"
            ]
        , Html.h2 [] [ Route.link Route.Twilogs [] [ Html.text "Twilog" ] ]
        , -- get latest day's twilogs from static.sharedData.dailyTwilogs
          case List.reverse (Dict.values static.sharedData.dailyTwilogs) of
            latestTwilogs :: _ ->
                latestTwilogs
                    |> Page.Twilogs.twilogsOfTheDay shared
                    |> showless "latest-twilogs"

            [] ->
                Html.text ""
        , Html.h2 [] [ Route.link Route.Articles [] [ Html.text "記事" ], View.feedLink "/articles/feed.xml" ]
        , static.sharedData.cmsArticles
            |> List.take 5
            |> List.map cmsArticlePreview
            |> Html.div []
            |> showless "cms-articles"
        , Html.h2 [] [ Html.text "Zenn記事", View.feedLink "https://zenn.dev/ymtszw/feed" ]
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
                            , Html.code [] [ Html.text metadata.articleType ]
                            , Html.text " ["
                            , Html.text (Shared.posixToYmd metadata.publishedAt)
                            , Html.text "]"
                            ]
                        ]
                )
            |> Html.ul []
            |> showless "zenn-articles"
        , Html.h2 [] [ Html.text "Qiita記事", View.feedLink "https://qiita.com/ymtszw/feed" ]
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


cmsArticlePreview : Shared.CmsArticleMetadata -> Html.Html Msg
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
