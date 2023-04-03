module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Dict
import Html exposing (Html)
import Iso8601
import Page.Articles.ArticleId_
import Page.Twilogs.Day_
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
                    Shared.publicCmsArticles
                        |> DataSource.andThen
                            (\articles ->
                                articles
                                    |> List.head
                                    |> Maybe.map (.revisedAt >> Iso8601.fromTime)
                                    |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                                    |> routeSource
                            )
                        |> Just

                Articles__Draft ->
                    Nothing

                Articles__ArticleId_ routeParam ->
                    Page.Articles.ArticleId_.page.data routeParam
                        |> DataSource.andThen (\data -> routeSource (Iso8601.fromTime data.article.revisedAt))
                        |> Just

                Twilogs ->
                    Shared.dailyTwilogsFromOldest
                        |> DataSource.andThen
                            (\dailyTwilogsFromOldest ->
                                dailyTwilogsFromOldest
                                    |> Dict.values
                                    |> List.reverse
                                    |> List.head
                                    |> Maybe.andThen List.head
                                    |> Maybe.map (\latestTwilog -> Iso8601.fromTime latestTwilog.createdAt)
                                    |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                                    |> routeSource
                            )
                        |> Just

                Twilogs__Day_ routeParam ->
                    Page.Twilogs.Day_.page.data routeParam
                        |> DataSource.andThen
                            (\data ->
                                data.twilogs
                                    |> List.head
                                    |> Maybe.map (\latestTwilog -> Iso8601.fromTime latestTwilog.createdAt)
                                    |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                                    |> routeSource
                            )
                        |> Just

                Index ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
    in
    allRoutesSource
        |> DataSource.map (List.filterMap build)
        |> DataSource.resolve
