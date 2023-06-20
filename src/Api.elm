module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import DataSource exposing (DataSource)
import Html exposing (Html)
import Iso8601
import Page.Articles.ArticleId_
import Pages
import Route exposing (Route(..))
import Rss
import Shared
import Site
import Sitemap
import Time


routes :
    DataSource (List Route)
    -> (Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes _ =
    [ rss
        { siteTagline = Site.tagline
        , siteUrl = Site.config.canonicalUrl
        , title = Site.title
        , builtAt = Pages.builtAt
        , indexPage = []
        }
        (DataSource.map (List.map makeArticleRssItem) builtArticles)
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
    -> DataSource (List Rss.Item)
    -> ApiRoute.ApiRoute ApiRoute.Response
rss options itemsSource =
    ApiRoute.succeed
        (itemsSource
            |> DataSource.map
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
                        |> ApiRoute.Response
                )
        )
        |> ApiRoute.literal "articles/feed.xml"
        |> ApiRoute.single


type alias BuiltArticle =
    ( Route, Page.Articles.ArticleId_.CmsArticle )


makeArticleRssItem : BuiltArticle -> Rss.Item
makeArticleRssItem ( route, article ) =
    { title = article.title
    , description = article.body.excerpt
    , url = String.join "/" (Route.routeToPath route)
    , categories = []
    , author = "ymtszw (Yu Matsuzawa)"
    , pubDate = Rss.DateTime article.publishedAt
    , content = Nothing
    , contentEncoded = Nothing
    , enclosure = Nothing
    }


builtArticles : DataSource (List BuiltArticle)
builtArticles =
    let
        build routeParam =
            Page.Articles.ArticleId_.data routeParam
                |> DataSource.map .article
                |> DataSource.map (Tuple.pair (Route.Articles__ArticleId_ routeParam))
    in
    Page.Articles.ArticleId_.routes
        |> DataSource.map (List.map build)
        |> DataSource.resolve
        |> DataSource.map (List.filter (\( _, article ) -> article.published))


sitemap :
    DataSource (List Sitemap.Entry)
    -> ApiRoute.ApiRoute ApiRoute.Response
sitemap entriesSource =
    ApiRoute.succeed
        (entriesSource
            |> DataSource.map
                (\entries ->
                    ApiRoute.Response <| """<?xml version="1.0" encoding="UTF-8"?>
""" ++ Sitemap.build { siteUrl = Site.config.canonicalUrl } entries
                )
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single


makeSitemapEntries : DataSource (List Route) -> DataSource (List Sitemap.Entry)
makeSitemapEntries getStaticRoutes =
    let
        build route =
            let
                routeSource lastMod =
                    DataSource.succeed
                        { path = String.join "/" (Route.routeToPath route)
                        , lastMod = Just lastMod
                        }
            in
            case route of
                About ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt

                Articles ->
                    Shared.cmsArticles
                        |> DataSource.andThen
                            (\articles ->
                                articles
                                    |> List.filter .published
                                    |> List.head
                                    |> Maybe.map (.revisedAt >> Iso8601.fromTime)
                                    |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                                    |> routeSource
                            )
                        |> Just

                Articles__Draft ->
                    Nothing

                Articles__ArticleId_ routeParam ->
                    Page.Articles.ArticleId_.data routeParam
                        |> DataSource.andThen (\data -> routeSource (Iso8601.fromTime data.article.revisedAt))
                        |> Just

                Library ->
                    Nothing

                Twilogs ->
                    Shared.twilogArchives
                        |> DataSource.andThen
                            (\twilogArchives ->
                                twilogArchives
                                    |> List.head
                                    |> Maybe.map (\yearMonth -> yearMonth ++ "-01")
                                    |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                                    |> routeSource
                            )
                        |> Just

                Twilogs__YearMonth_ routeParam ->
                    Just <| routeSource routeParam.yearMonth

                Index ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
    in
    getStaticRoutes
        |> DataSource.map (List.filterMap build)
        |> DataSource.resolve
