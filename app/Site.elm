module Site exposing (config, tagline, title)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = "https://ymtszw.github.io"
    , head = head
    }


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.icon [ ( 100, 100 ) ] MimeType.Jpeg <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=100&w=100"
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=192&w=192"
    , Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")
    , Head.sitemapLink "/sitemap.xml"
    , Head.rssLink "/articles/feed.xml"
    ]
        |> BackendTask.succeed


title : String
title =
    "ymtszw's page"


tagline : String
tagline =
    "ymtszw's personal page"
