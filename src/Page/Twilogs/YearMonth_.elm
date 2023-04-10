module Page.Twilogs.YearMonth_ exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Glob
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Helper
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import List.Extra
import Page
import Page.Twilogs
import Pages.PageUrl
import Route
import Shared exposing (RataDie, Twilog, seoBase)
import View


type alias Model =
    ()


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    { yearMonth : String }


type alias Data =
    { dailyTwilogsFromOldest : Dict RataDie (List Twilog)
    }


page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildWithSharedState
            { init = \_ _ _ -> ( (), Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , view = view
            }


routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map RouteParams) Shared.twilogArchives


data : RouteParams -> DataSource Data
data routeParams =
    getAvailableDays routeParams.yearMonth
        |> DataSource.andThen
            (\dateStrings ->
                Shared.dailyTwilogsFromOldest (List.map Shared.makeTwilogsJsonPath dateStrings)
                    |> DataSource.map Data
            )


getAvailableDays : String -> DataSource (List String)
getAvailableDays yearMonth =
    case String.split "-" yearMonth of
        [ year, month ] ->
            DataSource.Glob.succeed (\day -> String.join "-" [ year, month, day ])
                |> DataSource.Glob.match (DataSource.Glob.literal ("data/" ++ year ++ "/" ++ month ++ "/"))
                |> DataSource.Glob.capture DataSource.Glob.wildcard
                |> DataSource.Glob.match (DataSource.Glob.literal "-twilogs.json")
                |> DataSource.Glob.toDataSource
                -- Make newest first
                |> DataSource.map (List.sort >> List.reverse)

        _ ->
            DataSource.fail ("Invalid year-month " ++ yearMonth)


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head app =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle (app.routeParams.yearMonth ++ "のTwilog")
            , description = app.routeParams.yearMonth ++ "のTwilog"
        }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared app msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Cmd.none
            , Page.Twilogs.listUrlsForPreviewBulk shared app.data.dailyTwilogsFromOldest
            )


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared _ app =
    { title = app.routeParams.yearMonth ++ "のTwilog"
    , body =
        -- show navigation links to previous and next days
        prevNextNavigation app.routeParams app.sharedData.twilogArchives
            :: Page.Twilogs.showTwilogsByDailySections shared app.data.dailyTwilogsFromOldest
            ++ [ prevNextNavigation app.routeParams app.sharedData.twilogArchives
               , Page.Twilogs.linksByMonths Nothing app.sharedData.twilogArchives
               ]
    }


prevNextNavigation : RouteParams -> List Shared.TwilogArchiveYearMonth -> Html msg
prevNextNavigation { yearMonth } twilogArchives =
    let
        toLink maybeYearMonth child =
            case maybeYearMonth of
                Just yearMonth_ ->
                    Route.link (Route.Twilogs__YearMonth_ { yearMonth = yearMonth_ }) [] [ strong [] [ child ] ]

                Nothing ->
                    child
    in
    nav [ class "prev-next-navigation" ]
        [ toLink (findPrevYearMonth yearMonth twilogArchives) <| text "← 前"
        , toLink (findNextYearMonth yearMonth twilogArchives) <| text "次 →"
        ]


findNextYearMonth : String -> List Shared.TwilogArchiveYearMonth -> Maybe String
findNextYearMonth yearMonth twilogArchives =
    case List.reverse twilogArchives of
        (oldestYearMonth :: _) as reversedArchives ->
            if yearMonth < oldestYearMonth then
                -- Enter into range from oldest
                Just oldestYearMonth

            else
                case List.Extra.dropWhile (\a -> a <= yearMonth) reversedArchives of
                    nearestNextYearMonth :: _ ->
                        Just nearestNextYearMonth

                    [] ->
                        -- This yearMonth is the latest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing


findPrevYearMonth : String -> List Shared.TwilogArchiveYearMonth -> Maybe String
findPrevYearMonth yearMonth twilogArchives =
    case twilogArchives of
        latestYearMonth :: _ ->
            if yearMonth > latestYearMonth then
                -- Enter into range from latest
                Just latestYearMonth

            else
                case List.Extra.dropWhile (\a -> a >= yearMonth) twilogArchives of
                    nearestPrevYearMonth :: _ ->
                        Just nearestPrevYearMonth

                    [] ->
                        -- Today is the oldest
                        Nothing

        [] ->
            -- Usually won't happen
            Nothing
