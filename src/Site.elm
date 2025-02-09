module Site exposing (config, locale, ogpHeaderImageUrl, seoBase, tagline, title)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import LanguageTag exposing (emptySubtags)
import LanguageTag.Language
import LanguageTag.Region
import MimeType
import Pages.Url
import SiteConfig exposing (SiteConfig)


config : SiteConfig
config =
    { canonicalUrl = canonicalUrl
    , head = head
    }


canonicalUrl : String
canonicalUrl =
    "https://ymtszw.cc"


head : BackendTask FatalError (List Head.Tag)
head =
    [ Head.metaName "viewport" (Head.raw "width=device-width,initial-scale=1")
    , Head.icon [ ( 100, 100 ) ] MimeType.Png <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=100&h=100"
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=192&h=192"
    , -- ymtszw.github.io 時代のSearch Console認証
      Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")
    , Head.sitemapLink "/sitemap.xml"
    , Head.rssLink "/articles/feed.xml"
    , Head.rootLanguage language
    ]
        |> BackendTask.succeed


seoBase : Head.Seo.Common
seoBase =
    Head.Seo.summaryLarge
        { canonicalUrlOverride = Nothing
        , siteName = title
        , image = ogpImage
        , description = tagline
        , locale = Just locale
        , title = title
        }


title : String
title =
    "ymtszw's page"


tagline : String
tagline =
    "ymtszwの個人ページ。これまでに書いた記事やTwilogを公開。elm-pages SSGの実験場"


language =
    LanguageTag.build { emptySubtags | region = Just LanguageTag.Region.jp } LanguageTag.Language.ja


locale : ( LanguageTag.Language.Language, LanguageTag.Region.Region )
locale =
    ( LanguageTag.Language.ja, LanguageTag.Region.jp )


ogpImage : Head.Seo.Image
ogpImage =
    { url = Pages.Url.external <| ogpHeaderImageUrl ++ "?w=900&h=300"
    , alt = "Image of Mt.Asama"
    , dimensions = Just { width = 900, height = 300 }
    , mimeType = Just (MimeType.Image MimeType.Png)
    }


ogpHeaderImageUrl : String
ogpHeaderImageUrl =
    "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg"
