module Site exposing (cacheBuster, canonicalUrl, config, locale, manifest, ogpHeaderImageUrl, seoBase, tagline, title)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo
import LanguageTag exposing (emptySubtags)
import LanguageTag.Language
import LanguageTag.Region
import MimeType
import Pages
import Pages.Manifest as Manifest
import Pages.Url
import Route
import SiteConfig exposing (SiteConfig)
import Time


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
        Pages.Url.external <|
            "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=100&h=100&"
                ++ cacheBuster
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external <|
            "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=192&h=192&"
                ++ cacheBuster
    , -- ymtszw.github.io 時代のSearch Console認証
      Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")

    -- manifest.jsonのみ、Api.elmでApiRouteとして定義されていれば、自動的にlinkタグが挿入される。
    , Head.sitemapLink "/sitemap.xml"
    , Head.rssLink "/articles/feed.xml"
    , Head.rootLanguage language
    ]
        |> BackendTask.succeed


manifest : Manifest.Config
manifest =
    Manifest.init
        { name = title
        , description = tagline
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ { src = Pages.Url.external <| "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4bbee72905cf4e5fa4a55d9de0d9593b/icon-square.png?w=144&h=144&" ++ cacheBuster
              , sizes = [ ( 144, 144 ) ]
              , mimeType = Just MimeType.Png
              , purposes = [ Manifest.IconPurposeAny ]
              }
            ]
        }
        |> Manifest.withShortName "ymtszw"
        |> Manifest.withLang siteLanguage


siteLanguage =
    LanguageTag.build { emptySubtags | region = Just LanguageTag.Region.jp } LanguageTag.Language.ja


type alias Locale =
    ( LanguageTag.Language.Language, LanguageTag.Region.Region )


seoBase :
    { canonicalUrlOverride : Maybe String
    , siteName : String
    , image : Head.Seo.Image
    , description : String
    , title : String
    , locale : Maybe Locale
    }
seoBase =
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
    "Gada / ymtszwの個人ページ。これまでに書いた記事やTwilogを公開中。elm-pages SSGで作っており、その実験場を兼ねる"


language =
    LanguageTag.build { emptySubtags | region = Just LanguageTag.Region.jp } LanguageTag.Language.ja


locale : Locale
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
    "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?" ++ cacheBuster


cacheBuster : String
cacheBuster =
    "v=" ++ String.fromInt (Time.posixToMillis Pages.builtAt)
