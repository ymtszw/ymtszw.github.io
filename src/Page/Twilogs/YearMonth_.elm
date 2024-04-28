module Page.Twilogs.YearMonth_ exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Browser.Dom
import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Glob
import Debounce exposing (Debounce)
import Dict exposing (Dict)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Head
import Head.Seo as Seo
import Helper
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import Json.Decode
import Json.Encode
import List.Extra
import Page
import Page.Twilogs
import Pages.PageUrl
import Process
import Route
import RuntimePorts
import Shared exposing (RataDie, Twilog, seoBase)
import Task
import TwilogSearch
import View


type alias Model =
    { twilogSearch : TwilogSearch.Model
    , linksInTwilogs : Dict TwitterStatusIdStr (List String)
    , debounce : Debounce Json.Encode.Value
    }


type alias TwitterStatusIdStr =
    String


type Msg
    = InitiateLinkPreviewPopulation
    | NoOp
    | TwilogSearchMsg TwilogSearch.Msg
    | ReceiveFromJs Json.Encode.Value
    | DebounceMsg Debounce.Msg


type alias RouteParams =
    { yearMonth : String }


type alias Data =
    { dailyTwilogsFromOldest : Dict RataDie (List Twilog)
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
            , update = update
            , subscriptions = \_ _ _ _ _ -> RuntimePorts.fromJs ReceiveFromJs
            , view = view
            }


init : x -> y -> Page.StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init _ _ app =
    ( { twilogSearch = TwilogSearch.init app.data.searchSecrets
      , linksInTwilogs = Dict.empty
      , debounce = Debounce.init
      }
    , Helper.initMsg InitiateLinkPreviewPopulation
    )


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


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update url _ shared app msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( { model | linksInTwilogs = Page.Twilogs.listUrlsForPreviewBulk shared.links app.data.dailyTwilogsFromOldest }
            , case url.fragment of
                Just id ->
                    -- LinkPreviewの読み込みなどでlayout shiftが少しあるので、雑にちょっと待つ
                    Process.sleep 500
                        |> Task.andThen (\() -> Browser.Dom.getElement id)
                        -- ヘッダー分を大雑把に加えてスクロール
                        |> Task.andThen (\e -> Browser.Dom.setViewport 0 (e.element.y + 50))
                        |> Task.onError (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> NoOp)

                _ ->
                    Cmd.none
            , Nothing
            )

        NoOp ->
            ( model, Cmd.none, Nothing )

        TwilogSearchMsg twMsg ->
            let
                ( twilogSearch_, cmd ) =
                    TwilogSearch.update twMsg model.twilogSearch
            in
            ( { model | twilogSearch = twilogSearch_ }, Cmd.map TwilogSearchMsg cmd, Nothing )

        ReceiveFromJs v ->
            let
                ( debounce_, cmd ) =
                    Debounce.push debounceConfig v model.debounce
            in
            ( { model | debounce = debounce_ }, cmd, Nothing )

        DebounceMsg dMsg ->
            let
                ( debounce_, cmd ) =
                    Debounce.update debounceConfig (Debounce.takeLast findTweetsInViewport) dMsg model.debounce
            in
            ( { model | debounce = debounce_ }, cmd, Nothing )


debounceConfig =
    { strategy = Debounce.later 200
    , transform = DebounceMsg
    }


type alias Viewport =
    { height : Float, top : Float, bottom : Float }


findTweetsInViewport : Json.Encode.Value -> Cmd Msg
findTweetsInViewport v =
    case Json.Decode.decodeValue viewportDecoder v of
        Ok viewport ->
            let
                _ =
                    Debug.log "viewport" viewport
            in
            Cmd.none

        Err _ ->
            Cmd.none


viewportDecoder =
    Json.Decode.map3 Viewport
        (Json.Decode.field "viewportHeight" Json.Decode.float)
        (Json.Decode.field "viewportTop" Json.Decode.float)
        (Json.Decode.field "viewportBottom" Json.Decode.float)


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared m app =
    { title = app.routeParams.yearMonth ++ "のTwilog"
    , body =
        -- show navigation links to previous and next days
        prevNextNavigation app.routeParams app.sharedData.twilogArchives
            :: TwilogSearch.searchBox TwilogSearchMsg (Page.Twilogs.aTwilog False Dict.empty) m.twilogSearch
            :: Page.Twilogs.showTwilogsByDailySections shared app.data.dailyTwilogsFromOldest
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
