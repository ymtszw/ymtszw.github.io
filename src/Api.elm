module Api exposing (routes)

import ApiRoute
import DataSource exposing (DataSource)
import Html exposing (Html)
import Page.Articles.ArticleId_
import Pages
import Route exposing (Route(..))
import Rss
import Site
import Time


routes :
    DataSource (List Route)
    -> (Html Never -> String)
    -> List (ApiRoute.ApiRoute ApiRoute.Response)
routes _ _ =
    [ builtArticles
        |> DataSource.map (List.map makeArticleRssItem)
        |> rss
            { siteTagline = Site.tagline
            , siteUrl = Site.config.canonicalUrl
            , title = Site.title
            , builtAt = Pages.builtAt
            , indexPage = []
            }
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
rss options itemsRequest =
    ApiRoute.succeed
        (itemsRequest
            |> DataSource.map
                (\items ->
                    { body =
                        Rss.generate
                            { title = options.title
                            , description = options.siteTagline
                            , url = options.siteUrl ++ "/" ++ String.join "/" options.indexPage
                            , lastBuildTime = options.builtAt
                            , generator = Just "elm-pages"
                            , items = items
                            , siteUrl = options.siteUrl
                            }
                    }
                )
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
