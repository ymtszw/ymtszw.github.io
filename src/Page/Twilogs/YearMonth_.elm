module Page.Twilogs.YearMonth_ exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Browser.Dom
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Glob
import Debounce
import Dict exposing (Dict)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Head
import Head.Seo as Seo
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import List.Extra
import Page
import Page.Twilogs exposing (..)
import Pages.PageUrl
import Route
import Shared exposing (RataDie, Twilog, seoBase)
import Task
import TwilogSearch
import View


type alias Model =
    Page.Twilogs.Model


type alias Msg =
    Page.Twilogs.Msg


type alias RouteParams =
    { yearMonth : String }


type alias Data =
    { twilogsFromOldest : Dict RataDie (List Twilog)
    , searchSecrets : TwilogSearch.Secrets
    , amazonAssociateTag : String
    }


page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildWithSharedState
            { init = init
            , update = Page.Twilogs.update
            , subscriptions = Page.Twilogs.subscriptions
            , view = view
            }


init : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data routeParams -> ( Model, Cmd Msg )
init url shared app =
    let
        linksInTwilogs =
            Page.Twilogs.listUrlsForPreviewBulk shared.links app.data.twilogsFromOldest
    in
    ( { twilogSearch = TwilogSearch.init app.data.searchSecrets
      , linksInTwilogs = linksInTwilogs
      , debounce = Debounce.init
      }
    , case Maybe.andThen .fragment url of
        Just id ->
            -- アーカイブページ独自処理; フラグメント指定されたTweetがあればそのTweetまでスクロール
            scrollToTargetTweet id

        Nothing ->
            Page.Twilogs.findTweetsInOrAfterViewport (Dict.keys linksInTwilogs) shared.initialViewport
    )


scrollToTargetTweet id =
    Browser.Dom.getElement id
        -- ヘッダー分を大雑把に差し引いてスクロール（注：yは下方向に向かって値が増える）
        |> Task.andThen (\e -> Browser.Dom.setViewport 0 (e.element.y - 100))
        |> Task.onError (\_ -> Task.succeed ())
        |> Task.perform (\_ -> NoOp)


routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map RouteParams) Shared.twilogArchives


data : RouteParams -> DataSource Data
data routeParams =
    getAvailableDays routeParams.yearMonth
        |> DataSource.andThen
            (\dateStrings ->
                dateStrings
                    -- PERF: ここにList.takeを挟んで処理する日数を減らすと顕著にページあたり処理時間が減少する（ほぼ線形？）
                    -- 逆に、他の共通部分等を効率化しても線形な処理時間削減が見られないので、
                    -- Twilogページのビルド時間への寄与が大きいのはやはりページあたりdecode対象データ量が原因と言えそう。
                    -- elm-pages v3でISR的なアプローチを適用したいとすればここ
                    |> List.map Shared.makeTwilogsJsonPath
                    |> Shared.dailyTwilogsFromOldest
                    |> DataSource.map Data
            )
        |> DataSource.andMap TwilogSearch.secrets
        |> DataSource.andMap (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")


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


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared m app =
    { title = app.routeParams.yearMonth ++ "のTwilog"
    , body =
        -- show navigation links to previous and next days
        prevNextNavigation app.routeParams app.sharedData.twilogArchives
            :: TwilogSearch.searchBox TwilogSearchMsg (Page.Twilogs.aTwilog False Dict.empty) m.twilogSearch
            :: Page.Twilogs.showTwilogsByDailySections shared app.data.twilogsFromOldest
            ++ [ prevNextNavigation app.routeParams app.sharedData.twilogArchives
               , Page.Twilogs.linksByMonths (Just app.routeParams.yearMonth) app.sharedData.twilogArchives
               ]
    }


prevNextNavigation : RouteParams -> List TwilogArchiveYearMonth -> Html msg
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
        [ toLink (findPrevYearMonth yearMonth twilogArchives) <| text "← 前月"
        , toLink (findNextYearMonth yearMonth twilogArchives) <| text "次月 →"
        ]


findNextYearMonth : String -> List TwilogArchiveYearMonth -> Maybe String
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


findPrevYearMonth : String -> List TwilogArchiveYearMonth -> Maybe String
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
