module Site exposing (config, tagline, title)

import DataSource
import Head
import MimeType
import Pages.Manifest as Manifest
import Pages.Url
import Route
import SiteConfig exposing (SiteConfig)


type alias Data =
    ()


config : SiteConfig Data
config =
    { data = data
    , canonicalUrl = "https://ymtszw.github.io"
    , head = head
    , manifest = manifest
    }


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


head : Data -> List Head.Tag
head _ =
    [ Head.icon [ ( 100, 100 ) ] MimeType.Jpeg <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=100&w=100"
    , Head.appleTouchIcon (Just 192) <|
        Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=192&w=192"
    , Head.metaName "google-site-verification" (Head.raw "Bby4JbWa2r4u77WnDC7sWGQbmIWji1Z5cQwCTAXr0Sg")
    ]


manifest : Data -> Manifest.Config
manifest _ =
    Manifest.init
        { name = title
        , description = tagline
        , startUrl = Route.Index |> Route.toPath
        , icons =
            [ { src = Pages.Url.external "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg?fit=crop&h=200&w=200"
              , sizes = [ ( 200, 200 ) ]
              , mimeType = Just MimeType.Jpeg
              , purposes = [ Manifest.IconPurposeAny ]
              }
            ]
        }


title : String
title =
    "ymtszw's page"


tagline : String
tagline =
    "ymtszw's personal page"
