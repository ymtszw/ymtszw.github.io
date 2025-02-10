module Route.Index exposing (ActionData, Data, Model, Msg, RouteParams, route)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import CmsData exposing (CmsArticleMetadata)
import Effect exposing (Effect)
import ExternalHtml
import FatalError exposing (FatalError)
import GitHubData
import Head
import Head.Seo as Seo
import Helper
import Html
import Html.Attributes
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import PagesMsg exposing (PagesMsg)
import Route
import Route.Articles
import RouteBuilder exposing (App)
import Shared
import Site
import Time
import Url
import View


type alias Model =
    {}


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    {}


type alias ActionData =
    {}


type alias Data =
    { repos : List String
    , cmsArticles : List CmsArticleMetadata
    , zennArticles : List ZennArticleMetadata
    , qiitaArticles : List QiitaArticleMetadata
    , sizumeArticles : List SizumeArticleMetadata
    , amazonAssociateTag : String
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


type alias SizumeArticleMetadata =
    { url : String
    , bodyUpdatedAt : Time.Posix
    , publishedAt : Time.Posix
    , title : String
    , excerptHtml : ExternalHtml.DecodedHtml
    }


route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = \_ _ -> ( {}, Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


data : BackendTask FatalError Data
data =
    BackendTask.map6 Data
        publicOriginalRepos
        CmsData.allMetadata
        publicZennArticles
        publicQiitaArticles
        publicSizumeArticles
        (Helper.requireEnv "AMAZON_ASSOCIATE_TAG")


publicOriginalRepos =
    GitHubData.githubGet "https://api.github.com/users/ymtszw/repos?per_page=100&direction=desc&sort=pushed"
        (Decode.list
            (Decode.map2 Tuple.pair
                (Decode.field "fork" (Decode.map not Decode.bool))
                (Decode.field "name" Decode.string)
            )
            |> Decode.map
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
            Decode.succeed ZennArticleMetadata
                |> Decode.andMap (Decode.field "slug" (Decode.map ((++) baseUrl) Decode.string))
                |> Decode.andMap
                    (Decode.oneOf
                        [ Decode.field "body_updated_at" Iso8601.decoder
                        , Decode.field "published_at" Iso8601.decoder
                        ]
                    )
                |> Decode.andMap (Decode.field "published_at" Iso8601.decoder)
                |> Decode.andMap (Decode.field "title" Decode.string)
                |> Decode.andMap (Decode.field "liked_count" Decode.int)
                |> Decode.andMap (Decode.field "article_type" Decode.string)
    in
    miscGet "https://zenn.dev/api/articles?username=ymtszw&count=500&order=latest"
        (Decode.field "articles" (Decode.list articleMetadataDecoder))


miscGet : String -> Decode.Decoder a -> BackendTask FatalError a
miscGet url decoder =
    BackendTask.Http.getJson url decoder
        |> BackendTask.allowFatal


publicQiitaArticles =
    let
        articleMetadataDecoder =
            Decode.succeed QiitaArticleMetadata
                |> Decode.andMap (Decode.field "url" Decode.string)
                |> Decode.andMap (Decode.field "created_at" Iso8601.decoder)
                |> Decode.andMap (Decode.field "updated_at" Iso8601.decoder)
                |> Decode.andMap (Decode.field "title" Decode.string)
                |> Decode.andMap (Decode.field "likes_count" Decode.int)
                |> Decode.andMap (Decode.field "tags" (Decode.list (Decode.field "name" Decode.string)))
    in
    miscGet "https://qiita.com/api/v2/users/ymtszw/items?per_page=100"
        (Decode.list articleMetadataDecoder)


publicSizumeArticles =
    let
        baseUrl =
            "https://sizu.me/ymtszw/posts/"

        articleMetadataDecoder =
            Decode.succeed SizumeArticleMetadata
                |> Decode.andMap (Decode.field "slug" (Decode.map ((++) baseUrl) Decode.string))
                |> Decode.andMap
                    (Decode.oneOf
                        [ Decode.at [ "bodyUpdatedAt", "iso" ] Iso8601.decoder
                        , Decode.at [ "firstPublishedAt", "iso" ] Iso8601.decoder
                        ]
                    )
                |> Decode.andMap (Decode.at [ "firstPublishedAt", "iso" ] Iso8601.decoder)
                |> Decode.andMap (Decode.field "title" Decode.string)
                |> Decode.andMap (Decode.field "excerptHtml" ExternalHtml.decoder)

        input =
            Url.percentEncode """{"0":{"userId":2707,"pageNumber":1}}"""
    in
    miscGet ("https://sizu.me/api/trpc/postList.index?batch=1&input=" ++ input)
        (Decode.index 0 (Decode.at [ "result", "data", "posts" ] (Decode.list articleMetadataDecoder)))


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Site.seoBase
        |> Seo.website


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update _ _ msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Effect.none
            , Nothing
            )


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View.View (PagesMsg Msg)
view app _ _ =
    { title = ""
    , body =
        [ Html.h1 []
            [ View.imgLazy [ Html.Attributes.src <| Site.ogpHeaderImageUrl ++ "?w=684&h=228", Html.Attributes.width 684, Html.Attributes.height 228, Html.Attributes.alt "Mt. Asama Header Image" ] []
            , Html.text "ymtszw's page"
            ]
        , Html.h2 [] [ Html.text "しずかなインターネット", View.feedLink "https://sizu.me/ymtszw/rss" ]
        , app.data.sizumeArticles
            |> List.take 5
            |> List.map
                (\metadata ->
                    Html.a
                        [ Html.Attributes.href metadata.url
                        , Html.Attributes.target "_blank"
                        , Html.Attributes.class "link-preview"
                        ]
                        [ Html.blockquote [] <|
                            [ Html.table [] <|
                                [ Html.tr [] <|
                                    [ Html.td [] <|
                                        [ Html.strong [] [ Html.text metadata.title ]
                                        , Html.p [] [ Html.text metadata.excerptHtml.excerpt ]
                                        , Html.small [] [ Html.text (" [" ++ Helper.posixToYmd metadata.publishedAt ++ "]") ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                )
            |> Html.div []
            |> showless "sizume-articles"
        , Html.h2 [] [ Route.Articles |> Route.link [] [ Html.text "記事" ], View.feedLink "/articles/feed.xml" ]
        , app.data.cmsArticles
            |> List.filter .published
            |> List.take 5
            |> List.map Route.Articles.cmsArticlePreview
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
                            , Html.text (Helper.posixToYmd metadata.publishedAt)
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
                            , Html.text (Helper.posixToYmd metadata.createdAt)
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
