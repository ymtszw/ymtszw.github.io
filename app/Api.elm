module Api exposing (routes)

import ApiRoute exposing (ApiRoute)
import BackendTask exposing (BackendTask)
import CmsData
import FatalError exposing (FatalError)
import Html exposing (Html)
import Iso8601
import Pages
import Route exposing (Route(..))
import Route.Articles.ArticleId_
import Rss
import Site
import Sitemap


routes :
    BackendTask FatalError (List Route)
    -> (Maybe { indent : Int, newLines : Bool } -> Html Never -> String)
    -> List (ApiRoute ApiRoute.Response)
routes getStaticRoutes _ =
    [ rss <| BackendTask.map (List.map makeArticleRssItem) builtArticles
    , sitemap <| makeSitemapEntries getStaticRoutes
    ]


rss : BackendTask FatalError (List Rss.Item) -> ApiRoute.ApiRoute ApiRoute.Response
rss itemsSource =
    ApiRoute.succeed
        (itemsSource
            |> BackendTask.map
                (\items ->
                    Rss.generate
                        { title = Site.title
                        , description = Site.tagline
                        , url = Site.config.canonicalUrl ++ "/"
                        , lastBuildTime = Pages.builtAt
                        , generator = Just "elm-pages"
                        , items = items
                        , siteUrl = Site.config.canonicalUrl
                        }
                )
        )
        |> ApiRoute.literal "articles/feed.xml"
        |> ApiRoute.single


type alias BuiltArticle =
    ( Route, CmsData.CmsArticle )


makeArticleRssItem : BuiltArticle -> Rss.Item
makeArticleRssItem ( route, article ) =
    { title = article.meta.title
    , description = article.body.excerpt
    , url = String.join "/" (Route.routeToPath route)
    , categories = []
    , author = "ymtszw (Yu Matsuzawa)"
    , pubDate = Rss.DateTime article.meta.publishedAt
    , content = Nothing
    , contentEncoded = Nothing
    , enclosure = Nothing
    }


builtArticles : BackendTask FatalError (List BuiltArticle)
builtArticles =
    let
        build routeParam =
            Route.Articles.ArticleId_.data routeParam
                |> BackendTask.map .article
                |> BackendTask.map (Tuple.pair (Route.Articles__ArticleId_ routeParam))
    in
    Route.Articles.ArticleId_.pages
        |> BackendTask.map (List.map build)
        |> BackendTask.resolve
        |> BackendTask.map (List.filter (\( _, article ) -> article.meta.published))


sitemap :
    BackendTask FatalError (List Sitemap.Entry)
    -> ApiRoute.ApiRoute ApiRoute.Response
sitemap entriesSource =
    ApiRoute.succeed
        (entriesSource
            |> BackendTask.map
                (\entries ->
                    [ """<?xml version="1.0" encoding="UTF-8"?>"""
                    , Sitemap.build { siteUrl = Site.config.canonicalUrl } entries
                    ]
                        |> String.join "\n"
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
                -- About ->
                --     Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
                -- Articles ->
                --     Shared.cmsArticles
                --         |> BackendTask.andThen
                --             (\articles ->
                --                 articles
                --                     |> List.filter .published
                --                     |> List.head
                --                     |> Maybe.map (.revisedAt >> Iso8601.fromTime)
                --                     |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                --                     |> routeSource
                --             )
                --         |> Just
                -- Articles__Draft ->
                --     Nothing
                Articles__ArticleId_ routeParam ->
                    Route.Articles.ArticleId_.data routeParam
                        |> BackendTask.andThen (\data -> routeSource (Iso8601.fromTime data.article.meta.revisedAt))
                        |> Just

                -- Library ->
                --     -- 書架ページは自分専用で検索に載せないが、書架ページでレビューを投稿すると一般公開記事が生成される仕組み
                --     Nothing
                -- Reviews__Draft ->
                --     Nothing
                -- Twilogs ->
                --     Shared.twilogArchives
                --         |> BackendTask.andThen
                --             (\twilogArchives ->
                --                 twilogArchives
                --                     |> List.head
                --                     |> Maybe.map (\yearMonth -> yearMonth ++ "-01")
                --                     |> Maybe.withDefault (Iso8601.fromTime Pages.builtAt)
                --                     |> routeSource
                --             )
                --         |> Just
                -- Twilogs__YearMonth_ routeParam ->
                --     Just <| routeSource routeParam.yearMonth
                Index ->
                    Just <| routeSource <| Iso8601.fromTime <| Pages.builtAt
    in
    getStaticRoutes
        |> BackendTask.map (List.filterMap build)
        |> BackendTask.resolve
