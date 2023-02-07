module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Html exposing (Html)
import Iso8601
import Page.Articles.ArticleId_
import Pages
import Route exposing (Route(..))
import Rss
import Site
import Sitemap
import Time


routes :
    DataSource (List Route)
    -> (Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes allRoutesSource _ =
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
            allRoutesSource
    ]


rss :
    { siteTagline : String
    , siteUrl : String
    , title : String
    , builtAt : Time.Posix
    , indexPage : List String
    }
    -> DataSource.DataSource (List Rss.Item)
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
                )
            |> DataSource.map ApiRoute.Response
        )
        |> ApiRoute.literal "articles/feed.xml"
        |> ApiRoute.single


type alias BuiltArticle =
    ( Route, Page.Articles.ArticleId_.Data )


makeArticleRssItem : BuiltArticle -> Rss.Item
makeArticleRssItem ( route, data ) =
    { title = data.article.title
    , description = data.article.body.excerpt
    , url =
        route
            |> Route.routeToPath
            |> String.join "/"
    , categories = []
    , author = "ymtszw (Yu Matsuzawa)"
    , pubDate = Rss.DateTime data.article.publishedAt
    , content = Nothing
    , contentEncoded = Nothing
    , enclosure = Nothing
    }


builtArticles : DataSource (List BuiltArticle)
builtArticles =
    let
        build routeParam =
            Page.Articles.ArticleId_.page.data routeParam
                |> DataSource.map (Tuple.pair (Route.Articles__ArticleId_ routeParam))
    in
    Page.Articles.ArticleId_.page.staticRoutes
        |> DataSource.map (List.map build)
        |> DataSource.resolve


sitemap :
    DataSource.DataSource (List Sitemap.Entry)
    -> ApiRoute.ApiRoute ApiRoute.Response
sitemap entriesSource =
    ApiRoute.succeed
        (entriesSource
            |> DataSource.map (Sitemap.build { siteUrl = Site.config.canonicalUrl })
            |> DataSource.map ApiRoute.Response
        )
        |> ApiRoute.literal "sitemap.xml"
        |> ApiRoute.single


makeSitemapEntries : DataSource (List Route) -> DataSource (List Sitemap.Entry)
makeSitemapEntries allRoutesSource =
    let
        build route =
            case route of
                Articles__Draft ->
                    Nothing

                Articles__ArticleId_ routeParam ->
                    Page.Articles.ArticleId_.page.data routeParam
                        |> DataSource.map
                            (\data ->
                                { path = Route.routeToPath route |> String.join "/"
                                , lastMod = Just <| Iso8601.fromTime <| data.article.revisedAt
                                }
                            )
                        |> Just

                Index ->
                    DataSource.succeed { path = "", lastMod = Just <| Iso8601.fromTime <| Pages.builtAt }
                        |> Just
    in
    allRoutesSource
        |> DataSource.map (List.filterMap build)
        |> DataSource.resolve
