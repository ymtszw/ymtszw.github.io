module Page.Index exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Browser.Navigation
import DataSource exposing (DataSource)
import Dict
import Head
import Head.Seo as Seo
import Helper
import Html
import Html.Attributes
import OptimizedDecoder
import Page
import Page.Articles
import Page.Twilogs
import Pages.PageUrl
import Route
import Shared exposing (CmsArticleMetadata, RataDie, Twilog, iso8601Decoder, publicCmsArticles, seoBase)
import Time
import View


type alias Model =
    ()


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    {}


type alias Data =
    { repos : List String
    , cmsArticles : List CmsArticleMetadata
    , zennArticles : List ZennArticleMetadata
    , qiitaArticles : List QiitaArticleMetadata
    , rataDie : RataDie
    , twilogs : List Twilog
    }


type alias ZennArticleMetadata =
    { url : String
    , bodyUpdatedAt : Time.Posix
    , publishedAt : Time.Posix
    , title : String
    , likedCount : Int
    , articleType : String
    }


type alias QiitaArticleMetadata =
    { url : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , title : String
    , likesCount : Int
    , tags : List String
    }


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { init = \_ _ _ -> ( (), Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , view = view
            }


data : DataSource Data
data =
    DataSource.map4 Data
        publicOriginalRepos
        publicCmsArticles
        publicZennArticles
        publicQiitaArticles
        |> DataSource.andThen
            (\cont ->
                Page.Twilogs.getRecentDays 1
                    |> DataSource.andThen
                        (\latestArchive ->
                            case latestArchive of
                                latestArchive_ :: _ ->
                                    Shared.dailyTwilogsFromOldest [ Shared.makeTwilogsJsonPath latestArchive_ ]
                                        |> DataSource.map
                                            (\dailyTwilogs ->
                                                -- In this page dailyTwilogs contain only one day
                                                case Dict.toList dailyTwilogs of
                                                    [ ( rataDie, twilogs ) ] ->
                                                        cont rataDie twilogs

                                                    _ ->
                                                        -- Should not happen
                                                        cont 1 []
                                            )

                                [] ->
                                    DataSource.fail "No twilogs; Should not happen"
                        )
            )


publicOriginalRepos =
    Shared.githubGet "https://api.github.com/users/ymtszw/repos?per_page=100&direction=desc&sort=pushed"
        (OptimizedDecoder.list
            (OptimizedDecoder.map2 Tuple.pair
                (OptimizedDecoder.field "fork" (OptimizedDecoder.map not OptimizedDecoder.bool))
                (OptimizedDecoder.field "name" OptimizedDecoder.string)
            )
            |> OptimizedDecoder.map
                (List.filterMap
                    (\( notFork, name ) ->
                        if notFork then
                            Just name

                        else
                            Nothing
                    )
                )
        )


publicZennArticles =
    let
        baseUrl =
            "https://zenn.dev/ymtszw/articles/"

        articleMetadataDecoder =
            OptimizedDecoder.succeed ZennArticleMetadata
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "slug" (OptimizedDecoder.map ((++) baseUrl) OptimizedDecoder.string))
                |> OptimizedDecoder.andMap
                    (OptimizedDecoder.oneOf
                        [ OptimizedDecoder.field "body_updated_at" iso8601Decoder
                        , OptimizedDecoder.field "published_at" iso8601Decoder
                        ]
                    )
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "published_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "liked_count" OptimizedDecoder.int)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "article_type" OptimizedDecoder.string)
    in
    Shared.miscGet "https://zenn.dev/api/articles?username=ymtszw&count=500&order=latest"
        (OptimizedDecoder.field "articles" (OptimizedDecoder.list articleMetadataDecoder))


publicQiitaArticles =
    let
        articleMetadataDecoder =
            OptimizedDecoder.succeed QiitaArticleMetadata
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "url" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "created_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "updated_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "likes_count" OptimizedDecoder.int)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "tags" (OptimizedDecoder.list (OptimizedDecoder.field "name" OptimizedDecoder.string)))
    in
    Shared.miscGet "https://qiita.com/api/v2/users/ymtszw/items?per_page=100"
        (OptimizedDecoder.list articleMetadataDecoder)


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared app msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Cmd.none
            , Page.Twilogs.listUrlsForPreviewSingle shared app.data.twilogs
            )


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared _ app =
    { title = ""
    , body =
        [ Html.h1 []
            [ View.imgLazy [ Html.Attributes.src <| Shared.ogpHeaderImageUrl ++ "?w=750&h=250", Html.Attributes.width 750, Html.Attributes.height 250, Html.Attributes.alt "Mt. Asama Header Image" ] []
            , Html.text "ymtszw's page"
            ]
        , Html.h2 [] [ Route.link Route.Twilogs [] [ Html.text "Twilog" ] ]
        , app.data.twilogs
            |> Page.Twilogs.twilogsOfTheDay shared
            |> showless "latest-twilogs"
        , Html.h2 [] [ Route.link Route.Articles [] [ Html.text "記事" ], View.feedLink "/articles/feed.xml" ]
        , app.data.cmsArticles
            |> List.take 5
            |> List.map Page.Articles.cmsArticlePreview
            |> Html.div []
            |> showless "cms-articles"
        , Html.h2 [] [ Html.text "Zenn記事", View.feedLink "https://zenn.dev/ymtszw/feed" ]
        , app.data.zennArticles
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
        , app.data.qiitaArticles
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
        , app.data.repos
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
