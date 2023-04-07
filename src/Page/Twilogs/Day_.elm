module Page.Twilogs.Day_ exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Date
import Dict
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
    DataSource.map (List.map (.isoDate >> RouteParams)) Shared.twilogArchives


data : RouteParams -> DataSource Data
data routeParams =
    Date.fromIsoString routeParams.day
        |> DataSource.fromResult
        |> DataSource.andThen
            (\date ->
                Shared.dailyTwilogsFromOldest [ Shared.makeTwilogsJsonPath date ]
                    |> DataSource.map
                        (\dailyTwilogs ->
                            -- In this page dailyTwilogs contain only one day
                            Dict.get (Date.toRataDie date) dailyTwilogs
                                |> Maybe.withDefault []
                                |> Data (Date.toRataDie date)
                        )
            )


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
          prevNextNavigation static.data static.sharedData.twilogArchives
        , Page.Twilogs.twilogDailySection shared static.data.rataDie static.data.twilogs
        , prevNextNavigation static.data static.sharedData.twilogArchives
        , Page.Twilogs.linksByMonths (Just (Date.fromRataDie static.data.rataDie)) static.sharedData.twilogArchives
        ]
    }


prevNextNavigation : Data -> List Shared.TwilogArchiveMetadata -> Html msg
prevNextNavigation { rataDie } twilogArchives =
    let
        toLink maybeRataDie child =
            case maybeRataDie of
                Just rataDie_ ->
                    Route.link (Route.Twilogs__Day_ { day = Date.toIsoString (Date.fromRataDie rataDie_) }) [] [ strong [] [ child ] ]

                Nothing ->
                    child
    in
    nav [ class "prev-next-navigation" ]
        [ toLink (findPrevRataDie rataDie twilogArchives) <| text "← 前"
        , toLink (findNextRataDie rataDie twilogArchives) <| text "次 →"
        ]


findNextRataDie : RataDie -> List Shared.TwilogArchiveMetadata -> Maybe RataDie
findNextRataDie today twilogArchives =
    case List.reverse twilogArchives of
        (oldestArchive :: _) as reversedArchives ->
            if today < oldestArchive.rataDie then
                -- Enter into range from oldest
                Just oldestArchive.rataDie

            else
                case List.Extra.dropWhile (\a -> a.rataDie <= today) reversedArchives of
                    nearestNextArchive :: _ ->
                        Just nearestNextArchive.rataDie

                    [] ->
                        -- Today is the latest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing


findPrevRataDie : RataDie -> List Shared.TwilogArchiveMetadata -> Maybe RataDie
findPrevRataDie today twilogArchives =
    case twilogArchives of
        latestArchive :: _ ->
            if today > latestArchive.rataDie then
                -- Enter into range from latest
                Just latestArchive.rataDie

            else
                case List.Extra.dropWhile (\a -> a.rataDie >= today) twilogArchives of
                    nearestPrevArchive :: _ ->
                        Just nearestPrevArchive.rataDie

                    [] ->
                        -- Today is the oldest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing
