module Page.Twilogs.Day_ exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Date
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import List.Extra
import Page exposing (PageWithState, StaticPayload)
import Page.Twilogs
import Pages.PageUrl exposing (PageUrl)
import Route
import Shared exposing (RataDie, Twilog, seoBase)
import Task
import View exposing (View)


type alias Model =
    ()


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    { day : String }


type alias Data =
    { rataDie : RataDie
    , twilogs : List Twilog
    , nextRataDie : Maybe RataDie
    , prevRataDie : Maybe RataDie
    }


page : PageWithState RouteParams Data Model Msg
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildWithSharedState
            { view = view
            , init = \_ _ _ -> ( (), Task.perform (\() -> InitiateLinkPreviewPopulation) (Task.succeed ()) )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            }


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
            (\dailyTwilogsFromOldest ->
                fromRouteString routeParams.day
                    |> DataSource.fromResult
                    |> DataSource.andThen
                        (\rataDie ->
                            case Dict.get rataDie dailyTwilogsFromOldest of
                                Just twilogs ->
                                    DataSource.succeed
                                        { rataDie = rataDie
                                        , twilogs = twilogs
                                        , nextRataDie = findNextRataDie rataDie dailyTwilogsFromOldest
                                        , prevRataDie = findPrevRataDie rataDie dailyTwilogsFromOldest
                                        }

                                Nothing ->
                                    DataSource.fail "No twilogs for this day"
                        )
            )


fromRouteString : String -> Result String RataDie
fromRouteString day =
    -- Convert hyphenated date string to integer rataDie
    Result.map Date.toRataDie (Date.fromIsoString day)


findNextRataDie : RataDie -> Dict RataDie (List Twilog) -> Maybe RataDie
findNextRataDie today dailyTwilogsFromOldest =
    case Dict.keys dailyTwilogsFromOldest of
        (oldestRatadie :: _) as possibleDays ->
            if today < oldestRatadie then
                -- Enter into range from oldest
                Just oldestRatadie

            else
                case List.Extra.dropWhile (\d -> d <= today) possibleDays of
                    nearestNextRatadie :: _ ->
                        Just nearestNextRatadie

                    [] ->
                        -- Today is the latest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing


findPrevRataDie : RataDie -> Dict RataDie (List Twilog) -> Maybe RataDie
findPrevRataDie today dailyTwilogsFromOldest =
    case List.reverse (Dict.keys dailyTwilogsFromOldest) of
        (latestRatadie :: _) as possibleDays ->
            if today > latestRatadie then
                -- Enter into range from latest
                Just latestRatadie

            else
                case List.Extra.dropWhile (\d -> d >= today) possibleDays of
                    nearestPrevRatadie :: _ ->
                        Just nearestPrevRatadie

                    [] ->
                        -- Today is the oldest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared static msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Cmd.none
            , Page.Twilogs.listUrlsForPreviewSingle shared static.data.twilogs
            )


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle (static.routeParams.day ++ "のTwilog")
            , description = static.routeParams.day ++ "のTwilog"
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
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ shared _ static =
    { title = static.routeParams.day ++ "のTwilog"
    , body =
        [ -- show navigation links to previous and next days
          prevNextNavigation static.data
        , Page.Twilogs.twilogDailySection shared static.data.rataDie static.data.twilogs
        , prevNextNavigation static.data
        , Page.Twilogs.linksByMonths (Just (Date.fromRataDie static.data.rataDie)) static.sharedData.dailyTwilogs
        ]
    }


prevNextNavigation : Data -> Html msg
prevNextNavigation data_ =
    let
        toLink maybeRataDie child =
            case maybeRataDie of
                Just rataDie ->
                    Route.link (Route.Twilogs__Day_ { day = Date.toIsoString (Date.fromRataDie rataDie) }) [] [ strong [] [ child ] ]

                Nothing ->
                    child
    in
    nav [ class "prev-next-navigation" ]
        [ toLink data_.prevRataDie <| text "← 前"
        , toLink data_.nextRataDie <| text "次 →"
        ]
