module Page.Github.PublicOriginalRepo_ exposing (Data, Model, Msg, page)

import Base64
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Markdown
import OptimizedDecoder
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { publicOriginalRepo : String }


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    Shared.publicOriginalRepos
        |> DataSource.map (List.map RouteParams)


data : RouteParams -> DataSource Data
data routeParams =
    Shared.githubGet ("https://api.github.com/repos/ymtszw/" ++ routeParams.publicOriginalRepo ++ "/contents/README.md")
        (OptimizedDecoder.oneOf
            [ OptimizedDecoder.field "content" OptimizedDecoder.string
                |> OptimizedDecoder.map (String.replace "\n" "")
                |> OptimizedDecoder.andThen (Base64.toString >> Result.fromMaybe "Base64 Error!" >> OptimizedDecoder.fromResult)
            , OptimizedDecoder.field "message" OptimizedDecoder.string
            ]
            |> OptimizedDecoder.andThen Markdown.decoder
        )


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "ymtszw"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = static.routeParams.publicOriginalRepo ++ " | ymtszw's GitHub Repo"
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


type alias Data =
    List (Html.Html Never)


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = static.routeParams.publicOriginalRepo ++ " | ymtszw's GitHub Repo"
    , body = static.data
    }
