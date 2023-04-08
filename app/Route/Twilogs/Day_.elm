module Route.Twilogs.Day_ exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import Date
import Dict
import Effect
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import List.Extra
import PagesMsg
import Route
import Route.Twilogs
import RouteBuilder
import Shared exposing (RataDie, Twilog, seoBase)
import View


type alias Model =
    {}


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    { day : String }


type alias Data =
    { rataDie : RataDie
    , twilogs : List Twilog
    }


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = \_ _ -> ( {}, Effect.init InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.map (List.map (.isoDate >> RouteParams)) Shared.twilogArchives


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    Date.fromIsoString routeParams.day
        |> BackendTask.fromResult
        |> BackendTask.mapError FatalError.fromString
        |> BackendTask.andThen
            (\date ->
                Shared.dailyTwilogsFromOldest [ Shared.makeTwilogsJsonPath date ]
                    |> BackendTask.map
                        (\dailyTwilogs ->
                            -- In this page dailyTwilogs contain only one day
                            Dict.get (Date.toRataDie date) dailyTwilogs
                                |> Maybe.withDefault []
                                |> Data (Date.toRataDie date)
                        )
            )


head :
    RouteBuilder.App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle (app.routeParams.day ++ "のTwilog")
            , description = app.routeParams.day ++ "のTwilog"
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Effect.none
            , Route.Twilogs.listUrlsForPreviewSingle shared app.data.twilogs
            )


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared _ =
    { title = app.routeParams.day ++ "のTwilog"
    , body =
        [ -- show navigation links to previous and next days
          prevNextNavigation app.data app.sharedData.twilogArchives
        , Route.Twilogs.twilogDailySection shared app.data.rataDie app.data.twilogs
        , prevNextNavigation app.data app.sharedData.twilogArchives
        , Route.Twilogs.linksByMonths (Just (Date.fromRataDie app.data.rataDie)) app.sharedData.twilogArchives
        ]
    }


prevNextNavigation : Data -> List Shared.TwilogArchiveMetadata -> Html msg
prevNextNavigation { rataDie } twilogArchives =
    let
        toLink maybeRataDie child =
            case maybeRataDie of
                Just rataDie_ ->
                    Route.link [] [ strong [] [ child ] ] <| Route.Twilogs__Day_ { day = Date.toIsoString (Date.fromRataDie rataDie_) }

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
