module Site exposing (config, tagline, title)

import DataSource
import Head
import LanguageTag exposing (emptySubtags)
import LanguageTag.Country
import LanguageTag.Language
import MimeType
import Pages.Manifest as Manifest
import Pages.Url
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    {}


config : SiteConfig Data
config =
    { data = DataSource.succeed {}
    , canonicalUrl = canonicalUrl
    , head = head
    , manifest = manifest
    }


head : Data -> List Head.Tag
head _ =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.icon [ ( 100, 100 ) ] MimeType.Png <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=100&h=100"
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=192&h=192"
    , -- ymtszw.github.io 時代のSearch Console認証
      Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")
    , Head.sitemapLink "/sitemap.xml"
    , Head.rssLink "/articles/feed.xml"
    , Head.rootLanguage siteLanguage
    ]


manifest : Data -> Manifest.Config
manifest _ =
    Manifest.init
        { name = title
        , description = tagline
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ { src = Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=144&h=144"
              , sizes = [ ( 144, 144 ) ]
              , mimeType = Just MimeType.Png
              , purposes = [ Manifest.IconPurposeAny ]
              }
            ]
        }
        |> Manifest.withShortName "ymtszw"
        |> Manifest.withLang siteLanguage


siteLanguage =
    LanguageTag.build { emptySubtags | region = Just LanguageTag.Country.jp } LanguageTag.Language.ja


canonicalUrl : String
canonicalUrl =
    "https://ymtszw.cc"


title : String
title =
    "ymtszw's page"


tagline : String
tagline =
    "ymtszwの個人ページ。これまでに書いた記事やTwilogを公開。elm-pages SSGの実験場"
