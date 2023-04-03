module Page.Twilogs.Day_ exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Date
import Dict
import Head
import Head.Seo as Seo
import Page exposing (Page, StaticPayload)
import Page.Twilogs
import Pages.PageUrl exposing (PageUrl)
import Shared exposing (RataDie, Twilog, seoBase)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { day : String }


type alias Data =
    { rataDie : RataDie, twilogs : List Twilog }


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
    DataSource.map (Dict.keys >> List.map (toRouteString >> RouteParams)) Shared.dailyTwilogsFromOldest


toRouteString rataDie =
    -- Convert integer rataDie to hyphenated date string
    Date.toIsoString (Date.fromRataDie rataDie)


data : RouteParams -> DataSource Data
data routeParams =
    Shared.dailyTwilogsFromOldest
        |> DataSource.andThen
            (\dailyTwilogs ->
                fromRouteString routeParams.day
                    |> DataSource.fromResult
                    |> DataSource.andThen
                        (\rataDie ->
                            case Dict.get rataDie dailyTwilogs of
                                Just twilogs ->
                                    DataSource.succeed (Data rataDie twilogs)

                                Nothing ->
                                    DataSource.fail "No twilogs for this day"
                        )
            )


fromRouteString : String -> Result String RataDie
fromRouteString day =
    -- Convert hyphenated date string to integer rataDie
    Result.map Date.toRataDie (Date.fromIsoString day)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle ("Twilogs of " ++ static.routeParams.day)
            , description = "Twilogs of " ++ static.routeParams.day
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
    { title = "Twilogs of " ++ static.routeParams.day
    , body =
        -- TODO: show navigation links to previous and next days
        [ Page.Twilogs.twilogDailySection static.data.rataDie static.data.twilogs
        ]
    }
