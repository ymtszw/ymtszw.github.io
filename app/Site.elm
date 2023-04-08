module Site exposing (canonicalUrl, config, tagline, title)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = canonicalUrl
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.icon [ ( 100, 100 ) ] MimeType.Png <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=100&h=100"
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=192&h=192"
    , Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")
    , Head.sitemapLink "/sitemap.xml"
    , Head.rssLink "/articles/feed.xml"
    , Head.manifestLink "/manifest.json"
    ]
        |> BackendTask.succeed


canonicalUrl : String
canonicalUrl =
    "https://ymtszw.github.io"


title : String
title =
    "ymtszw's page"


tagline : String
tagline =
    "ymtszwの個人ページ。これまでに書いた記事やTwilogを公開。elm-pages SSGの実験場"
