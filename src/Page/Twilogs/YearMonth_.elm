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
import Html exposing (Html, nav, strong, text)
import Html.Attributes exposing (class)
import Json.Decode
import Json.Encode
import List.Extra
import Page
import Page.Twilogs
import Pages.PageUrl
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
    = NoOp
    | TwilogSearchMsg TwilogSearch.Msg
    | ReceiveFromJs Json.Encode.Value
    | DebounceMsg Debounce.Msg
    | RequestLinkPreview TwitterStatusIdStr


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


init : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init url shared app =
    let
        linksInTwilogs =
            Page.Twilogs.listUrlsForPreviewBulk shared.links app.data.dailyTwilogsFromOldest
    in
    ( { twilogSearch = TwilogSearch.init app.data.searchSecrets
      , linksInTwilogs = linksInTwilogs
      , debounce = Debounce.init
      }
    , case Maybe.andThen .fragment url of
        Just id ->
            scrollToTargetTweet id

        Nothing ->
            findTweetsInOrAfterViewport (Dict.keys linksInTwilogs) shared.initialViewport
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


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared app msg model =
    case msg of
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
                    Debounce.update debounceConfig (Debounce.takeLast (decodeViewportAndFindTweets (Dict.keys model.linksInTwilogs))) dMsg model.debounce
            in
            ( { model | debounce = debounce_ }, cmd, Nothing )

        RequestLinkPreview tweetId ->
            let
                isNotFetched url_ =
                    case Dict.get url_ shared.links of
                        Just _ ->
                            False

                        Nothing ->
                            True
            in
            case Dict.get tweetId model.linksInTwilogs |> Maybe.withDefault [] |> List.filter isNotFetched of
                [] ->
                    ( model, Cmd.none, Nothing )

                notFetchedUrls ->
                    ( model, Cmd.none, Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag notFetchedUrls)) )


debounceConfig =
    { strategy = Debounce.later 200
    , transform = DebounceMsg
    }


decodeViewportAndFindTweets : List String -> Json.Encode.Value -> Cmd Msg
decodeViewportAndFindTweets tweetIds v =
    case Json.Decode.decodeValue Shared.viewportDecoder v of
        Ok viewport ->
            findTweetsInOrAfterViewport tweetIds viewport

        Err _ ->
            Cmd.none


findTweetsInOrAfterViewport : List String -> Shared.Viewport -> Cmd Msg
findTweetsInOrAfterViewport tweetIds viewport =
    let
        retrieveTweetIdInViewport tweetId =
            Browser.Dom.getElement ("tweet-" ++ tweetId)
                |> Task.andThen
                    (\found ->
                        let
                            -- 注：screen topに原点があるので、下方向に向かって値が増える
                            foundElementTop =
                                found.element.y

                            foundElementBottom =
                                found.element.y + found.element.height

                            -- ある程度下方のTweetも先読み対象とするために、viewportを仮想的に１画面分、下方に拡張
                            virtualViewportBottom =
                                viewport.bottom + viewport.height
                        in
                        if (viewport.top <= foundElementBottom) && (foundElementTop <= virtualViewportBottom) then
                            Task.succeed (RequestLinkPreview tweetId)

                        else
                            Task.succeed NoOp
                    )
                |> Task.onError (\_ -> Task.succeed NoOp)
                |> Task.perform identity
    in
    tweetIds
        |> List.map retrieveTweetIdInViewport
        |> Cmd.batch


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
