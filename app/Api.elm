module Api exposing (manifest, routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Html exposing (Html)
import Iso8601
import MimeType
import Pages
import Pages.Manifest as Manifest
import Pages.Url
import Route exposing (Route(..))
import Route.Articles.ArticleId_
import Rss
import Site
import Sitemap
import Time


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes htmlToString =
    [ rss
        { siteTagline = Site.tagline
        , siteUrl = Site.config.canonicalUrl
        , title = Site.title
        , builtAt = Pages.builtAt
        , indexPage = []
        }
        (BackendTask.map (List.map makeArticleRssItem) builtArticles)
    , sitemap <|
        makeSitemapEntries <|
            getStaticRoutes
    ]


rss :
    { siteTagline : String
    , siteUrl : String
    , title : String
    , builtAt : Time.Posix
    , indexPage : List String
    }
    -> BackendTask FatalError (List Rss.Item)
    -> ApiRoute.ApiRoute ApiRoute.Response
rss options itemsSource =
    ApiRoute.succeed
        (itemsSource
            |> BackendTask.map
                (\items ->
                    Rss.generate
                        { title = options.title
                        , description = options.siteTagline
                        , url = options.siteUrl ++ "/" ++ String.join "/" options.indexPage
                        , lastBuildTime = options.builtAt
                        , generator = Just "elm-pages"
                        , items = items
                        , siteUrl = options.siteUrl
                        }
                )
        )
        |> ApiRoute.literal "articles/feed.xml"
        |> ApiRoute.single


type alias BuiltArticle =
    ( Route, Route.Articles.ArticleId_.Data )


makeArticleRssItem : BuiltArticle -> Rss.Item
makeArticleRssItem ( route, data ) =
    -- TODO: Fix this
    -- { title = data.article.title
    -- , description = data.article.body.excerpt
    { title = ""
    , description = ""
    , url =
        route
            |> Route.routeToPath
            |> String.join "/"
    , categories = []
    , author = "ymtszw (Yu Matsuzawa)"

    -- , pubDate = Rss.DateTime data.article.publishedAt
    , pubDate = Rss.DateTime Pages.builtAt
    , content = Nothing
    , contentEncoded = Nothing
    , enclosure = Nothing
    }


builtArticles : BackendTask FatalError (List BuiltArticle)
builtArticles =
    let
        build routeParam =
            -- TODO: Fix this
            -- Route.Articles.ArticleId_.route.data routeParam
            BackendTask.succeed {}
                |> BackendTask.map (Tuple.pair (Route.Articles__ArticleId_ routeParam))
    in
    Route.Articles.ArticleId_.route.staticRoutes
        |> BackendTask.map (List.map build)
        |> BackendTask.resolve


sitemap :
    BackendTask FatalError (List Sitemap.Entry)
    -> ApiRoute.ApiRoute ApiRoute.Response
sitemap entriesSource =
    ApiRoute.succeed
        (entriesSource
            |> BackendTask.map
                (\entries ->
                    """<?xml version="1.0" encoding="UTF-8"?>
""" ++ Sitemap.build { siteUrl = Site.config.canonicalUrl } entries
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single


makeSitemapEntries : BackendTask FatalError (List Route) -> BackendTask FatalError (List Sitemap.Entry)
makeSitemapEntries getStaticRoutes =
    let
        build route =
            let
                routeSource lastMod =
                    BackendTask.succeed
                        { path = String.join "/" (Route.routeToPath route)
                        , lastMod = Just lastMod
                        }
            in
            case route of
                About ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt

                Articles ->
                    -- TODO: Fix this
                    -- Shared.publicCmsArticles
                    --     |> BackendTask.andThen
                    --         (\articles ->
                    --             articles
                    --                 |> List.head
                    --                 |> Maybe.map (.revisedAt >> Iso8601.fromTime)
                    --                 |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                    --                 |> routeSource
                    --         )
                    --     |> Just
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt

                Articles__Draft ->
                    Nothing

                Articles__ArticleId_ routeParam ->
                    -- TODO: Fix this
                    -- Route.Articles.ArticleId_.route.data routeParam
                    --     |> BackendTask.andThen (\data -> routeSource (Iso8601.fromTime data.article.revisedAt))
                    Nothing

                Twilogs ->
                    -- TODO: Fix this
                    -- Shared.twilogArchives
                    --     |> BackendTask.andThen
                    --         (\twilogArchives ->
                    --             twilogArchives
                    --                 |> List.head
                    --                 |> Maybe.map .isoDate
                    --                 |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                    --                 |> routeSource
                    --         )
                    --     |> Just
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt

                Twilogs__Day_ routeParam ->
                    Just <| routeSource routeParam.day

                Index ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
    in
    getStaticRoutes
        |> BackendTask.map (List.filterMap build)
        |> BackendTask.resolve


manifest : Manifest.Config
manifest =
    Manifest.init
        { name = Site.title
        , description = Site.tagline
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ { src = Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=200&w=200"
              , sizes = [ ( 200, 200 ) ]
              , mimeType = Just MimeType.Jpeg
              , purposes = [ Manifest.IconPurposeAny ]
              }
            ]
        }
