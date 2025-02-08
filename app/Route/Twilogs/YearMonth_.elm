module Route.Twilogs.YearMonth_ exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import BackendTask.Glob
import Debounce
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Head
import Head.Seo as Seo
import Helper exposing (requireEnv)
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import List.Extra
import PagesMsg exposing (PagesMsg)
import Route
import Route.Twilogs
import RouteBuilder exposing (App)
import Shared
import Site exposing (seoBase)
import TwilogData exposing (RataDie, Twilog)
import TwilogSearch
import View


type alias Model =
    Route.Twilogs.Model


type alias Msg =
    Route.Twilogs.Msg


type alias RouteParams =
    { yearMonth : String }


type alias Data =
    { twilogsFromOldest : Dict RataDie (List Twilog)
    , searchSecrets : TwilogSearch.Secrets
    , amazonAssociateTag : String
    }


type alias ActionData =
    {}


route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = init
            , update = Route.Twilogs.update
            , subscriptions = Route.Twilogs.subscriptions
            , view = view
            }


init : App Data ActionData routeParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    let
        linksInTwilogs =
            Route.Twilogs.listUrlsForPreviewBulk shared.links app.data.twilogsFromOldest
    in
    ( { twilogSearch = TwilogSearch.init app.data.searchSecrets
      , linksInTwilogs = linksInTwilogs
      , debounce = Debounce.init
      }
    , case shared.fragment of
        Just id ->
            -- アーカイブページ独自処理; フラグメント指定されたTweetがあればそのTweetまでスクロール
            Route.Twilogs.scrollToTargetTweet id

        Nothing ->
            -- HACK v3では、別ページからの遷移時、initで最新のURL変更を検知できないので、遅延評価する
            Helper.initMsg Route.Twilogs.RuntimeInit
    )


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.map (List.map RouteParams) TwilogData.twilogArchives


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    getAvailableDays routeParams.yearMonth
        |> BackendTask.andThen
            (\dateStrings ->
                dateStrings
                    -- PERF: ここにList.takeを挟んで処理する日数を減らすと顕著にページあたり処理時間が減少する（ほぼ線形？）
                    -- 逆に、他の共通部分等を効率化しても線形な処理時間削減が見られないので、
                    -- Twilogページのビルド時間への寄与が大きいのはやはりページあたりdecode対象データ量が原因と言えそう。
                    -- elm-pages v3でISR的なアプローチを適用したいとすればここ
                    |> List.map TwilogData.makeTwilogsJsonPath
                    |> TwilogData.dailyTwilogsFromOldest
                    |> BackendTask.map Data
            )
        |> BackendTask.andMap TwilogSearch.secrets
        |> BackendTask.andMap (requireEnv "AMAZON_ASSOCIATE_TAG")


getAvailableDays : String -> BackendTask FatalError (List String)
getAvailableDays yearMonth =
    case String.split "-" yearMonth of
        [ year, month ] ->
            BackendTask.Glob.succeed (\day -> String.join "-" [ year, month, day ])
                |> BackendTask.Glob.match (BackendTask.Glob.literal ("data/" ++ year ++ "/" ++ month ++ "/"))
                |> BackendTask.Glob.capture BackendTask.Glob.wildcard
                |> BackendTask.Glob.match (BackendTask.Glob.literal "-twilogs.json")
                |> BackendTask.Glob.toBackendTask
                -- Make newest first
                |> BackendTask.map (List.sort >> List.reverse)

        _ ->
            BackendTask.fail <| FatalError.fromString <| "Invalid year-month " ++ yearMonth


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    { seoBase
        | title = Helper.makeTitle (app.routeParams.yearMonth ++ "のTwilog")
        , description = app.routeParams.yearMonth ++ "のTwilog"
    }
        |> Seo.article
            { tags = []
            , section = Nothing
            , publishedTime = Nothing
            , modifiedTime = Nothing
            , expirationTime = Nothing
            }


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View.View (PagesMsg Msg)
view app shared m =
    { title = app.routeParams.yearMonth ++ "のTwilog"
    , body =
        -- show navigation links to previous and next days
        prevNextNavigation app.routeParams app.sharedData.twilogArchives
            :: TwilogSearch.searchBox Route.Twilogs.TwilogSearchMsg (Route.Twilogs.aTwilog False Dict.empty) m.twilogSearch
            :: Route.Twilogs.showTwilogsByDailySections shared app.data.twilogsFromOldest
            ++ [ prevNextNavigation app.routeParams app.sharedData.twilogArchives
               , Route.Twilogs.linksByMonths (Just app.routeParams.yearMonth) app.sharedData.twilogArchives
               ]
    }
        |> View.map PagesMsg.fromMsg


prevNextNavigation : RouteParams -> List TwilogArchiveYearMonth -> Html msg
prevNextNavigation { yearMonth } twilogArchives =
    let
        toLink maybeYearMonth child =
            case maybeYearMonth of
                Just yearMonth_ ->
                    Route.Twilogs__YearMonth_ { yearMonth = yearMonth_ } |> Route.link [] [ strong [] [ child ] ]

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
