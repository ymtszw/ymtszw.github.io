module Route.Index exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import Dict
import Effect
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Attributes
import PagesMsg
import Route
import Route.Articles
import Route.Twilogs
import RouteBuilder
import Shared exposing (RataDie, Twilog, seoBase)
import View


type alias Model =
    {}


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    {}


type alias Data =
    { rataDie : RataDie
    , twilogs : List Twilog
    }


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = \_ _ -> ( {}, Effect.init InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


data : BackendTask FatalError Data
data =
    Shared.twilogArchives
        |> BackendTask.andThen
            (\twilogArchives ->
                case twilogArchives of
                    latestArchive :: _ ->
                        Shared.dailyTwilogsFromOldest [ latestArchive.path ]
                            |> BackendTask.map
                                (\dailyTwilogs ->
                                    -- In this page dailyTwilogs contain only one day
                                    Dict.get latestArchive.rataDie dailyTwilogs
                                        |> Maybe.withDefault []
                                        |> Data latestArchive.rataDie
                                )

                    [] ->
                        BackendTask.fail (FatalError.fromString "No twilogs; Should not happen")
            )


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Effect.none
            , Route.Twilogs.listUrlsForPreviewSingle shared app.data.twilogs
            )


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared _ =
    { title = ""
    , body =
        [ Html.h1 []
            [ View.imgLazy [ Html.Attributes.src <| Shared.ogpHeaderImageUrl ++ "?w=750&h=250", Html.Attributes.width 750, Html.Attributes.height 250, Html.Attributes.alt "Mt. Asama Header Image" ] []
            , Html.text "ymtszw's page"
            ]
        , Html.h2 [] [ Route.link [] [ Html.text "Twilog" ] Route.Twilogs ]
        , app.data.twilogs
            |> Route.Twilogs.twilogsOfTheDay shared
            |> showless "latest-twilogs"
        , Html.h2 [] [ Route.link [] [ Html.text "記事" ] Route.Articles, View.feedLink "/articles/feed.xml" ]
        , app.sharedData.cmsArticles
            |> List.take 5
            |> List.map Route.Articles.cmsArticlePreview
            |> Html.div []
            |> showless "cms-articles"
        , Html.h2 [] [ Html.text "Zenn記事", View.feedLink "https://zenn.dev/ymtszw/feed" ]
        , app.sharedData.zennArticles
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
        , app.sharedData.qiitaArticles
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
        , app.sharedData.repos
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
