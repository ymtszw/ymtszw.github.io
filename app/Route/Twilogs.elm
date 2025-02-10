module Route.Twilogs exposing
    ( ActionData
    , Data
    , Model
    , Msg(..)
    , RouteParams
    , aTwilog
    , findTweetsInOrAfterViewport
    , getRecentDays
    , linksByMonths
    , listUrlsForPreviewBulk
    , route
    , scrollToTargetTweet
    , showTwilogsByDailySections
    , subscriptions
    , twilogsOfTheDay
    , update
    )

import BackendTask exposing (BackendTask)
import BackendTask.Glob
import Browser.Dom
import Date
import Debounce exposing (Debounce)
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Head
import Head.Seo as Seo
import Helper exposing (requireEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Json.Decode
import Json.Encode
import LinkPreview
import List.Extra
import Markdown
import PagesMsg exposing (PagesMsg)
import Regex
import Route
import RouteBuilder exposing (App)
import RuntimePorts
import Shared
import Site exposing (seoBase)
import Task
import Tweet
import TwilogData exposing (Media, Quote, RataDie, Reply(..), TcoUrl, Twilog, TwitterStatusId(..))
import TwilogSearch exposing (searchBox)
import UrlPath exposing (UrlPath)
import View exposing (imgLazy, lightboxLink)


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
      --| HACK v3ではclient sideでquery parameterにアクセスしづらくなり、他ページからの遷移時のinitではquery parameterを使った初期化処理が動かない。
      --| （ページを直接訪問したときには動作する）
      --| 代わりにinitMsgを飛ばしてupdateで再度初期化を試みる。
    | RuntimeInit
    | ForceTweetId String


type alias RouteParams =
    {}


type alias Data =
    { twilogsFromOldest : Dict RataDie (List Twilog)
    , searchSecrets : TwilogSearch.Secrets
    , amazonAssociateTag : String
    }


type alias ActionData =
    {}


route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = init
            , update = update
            , subscriptions = subscriptions
            , view = view
            }


init : App Data ActionData routeParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    let
        linksInTwilogs =
            listUrlsForPreviewBulk shared.links app.data.twilogsFromOldest
    in
    ( { twilogSearch = TwilogSearch.init app.data.searchSecrets
      , linksInTwilogs = linksInTwilogs
      , debounce = Debounce.init
      }
    , findTweetsInOrAfterViewport (Dict.keys linksInTwilogs) shared.initialViewport |> Effect.fromCmd
    )


data : BackendTask FatalError Data
data =
    getRecentDays daysToPeek
        |> BackendTask.andThen
            (\dateStrings ->
                TwilogData.dailyTwilogsFromOldest (List.map TwilogData.makeTwilogsJsonPath dateStrings)
                    |> BackendTask.map Data
            )
        |> BackendTask.andMap TwilogSearch.secrets
        |> BackendTask.andMap (requireEnv "AMAZON_ASSOCIATE_TAG")


daysToPeek =
    3


getRecentDays : Int -> BackendTask FatalError (List String)
getRecentDays days =
    BackendTask.Glob.succeed (\year month day -> String.join "-" [ year, month, day ])
        |> BackendTask.Glob.match (BackendTask.Glob.literal "data/")
        |> BackendTask.Glob.capture BackendTask.Glob.wildcard
        |> BackendTask.Glob.match (BackendTask.Glob.literal "/")
        |> BackendTask.Glob.capture BackendTask.Glob.wildcard
        |> BackendTask.Glob.match (BackendTask.Glob.literal "/")
        |> BackendTask.Glob.capture BackendTask.Glob.wildcard
        |> BackendTask.Glob.match (BackendTask.Glob.literal "-twilogs.json")
        |> BackendTask.Glob.toBackendTask
        -- Make newest first
        |> BackendTask.map (List.sort >> List.reverse >> List.take days)


head : App Data ActionData routeParams -> List Head.Tag
head _ =
    { seoBase
        | title = Helper.makeTitle "Twilog"
        , description = "2023年4月から作り始めた自作Twilog。Twitterを日記化している"
    }
        |> Seo.website


update : App Data ActionData routeParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.none, Nothing )

        TwilogSearchMsg twMsg ->
            let
                ( twilogSearch_, cmd ) =
                    TwilogSearch.update twMsg model.twilogSearch
            in
            ( { model | twilogSearch = twilogSearch_ }, Effect.map TwilogSearchMsg cmd, Nothing )

        ReceiveFromJs v ->
            -- Portから送られてくるデータには複数パターンありうるが、今のところスクロールイベントに起因するviewport情報が送られてくる。Debounceして使う
            let
                ( debounce_, cmd ) =
                    Debounce.push debounceConfig v model.debounce
            in
            ( { model | debounce = debounce_ }, Effect.fromCmd cmd, Nothing )

        DebounceMsg dMsg ->
            let
                ( debounce_, cmd ) =
                    -- Debounceによって、最終的にスクロールが停止したときのviewportに対し decodeViewportAndFindTweets を実行することになる
                    Debounce.update debounceConfig (Debounce.takeLast (decodeViewportAndFindTweets (Dict.keys model.linksInTwilogs))) dMsg model.debounce
            in
            ( { model | debounce = debounce_ }, Effect.fromCmd cmd, Nothing )

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
                    ( model, Effect.none, Nothing )

                notFetchedUrls ->
                    ( model, Effect.none, Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag notFetchedUrls)) )

        RuntimeInit ->
            ( model
            , case shared.fragment of
                Just id ->
                    -- v3で、ページ遷移後に遅延してfragmentを読み込んでスクロールするアーカイブページ専用処理。
                    -- update関数共用のために不可避的にこちらに設置
                    scrollToTargetTweet id

                Nothing ->
                    findTweetsInOrAfterViewport (Dict.keys model.linksInTwilogs) shared.initialViewport |> Effect.fromCmd
            , Nothing
            )

        ForceTweetId id ->
            ( model, Effect.none, Just <| Shared.SharedMsg <| Shared.PushFragment id )


debounceConfig =
    { strategy = Debounce.later 200
    , transform = DebounceMsg
    }


listUrlsForPreviewBulk : Dict String LinkPreview.Metadata -> Dict RataDie (List Twilog) -> Dict TwitterStatusIdStr (List String)
listUrlsForPreviewBulk links recentDailyTwilogsFromOldest =
    Dict.values recentDailyTwilogsFromOldest
        |> List.concat
        -- Make it newest first
        |> List.reverse
        |> listUrlsForPreviewImpl links
        |> Dict.fromList


listUrlsForPreviewImpl : Dict String LinkPreview.Metadata -> List Twilog -> List ( TwitterStatusIdStr, List String )
listUrlsForPreviewImpl links =
    List.map
        (\twilog ->
            let
                urlsFromReplies =
                    listUrlsForPreviewFromReplies links twilog.replies
                        |> List.concatMap Tuple.second
                        |> List.Extra.unique

                notLoadedMediaUrls { extendedEntitiesMedia } =
                    extendedEntitiesMedia
                        |> List.filter (\{ sourceUrl } -> String.endsWith "__NOT_LOADED__" sourceUrl)
                        |> List.map .expandedUrl
            in
            (twilog.entitiesTcoUrl ++ (twilog.retweet |> Maybe.map .entitiesTcoUrl |> Maybe.withDefault []))
                |> List.map .expandedUrl
                |> List.append (notLoadedMediaUrls twilog ++ (twilog.retweet |> Maybe.map notLoadedMediaUrls |> Maybe.withDefault []))
                |> List.filterMap
                    (\expandedUrl ->
                        -- list not-yet previewed URLs
                        case Dict.get expandedUrl links of
                            Just _ ->
                                Nothing

                            Nothing ->
                                Just expandedUrl
                    )
                |> List.append urlsFromReplies
                |> List.Extra.unique
                |> Tuple.pair twilog.idStr
        )


listUrlsForPreviewFromReplies links replies =
    listUrlsForPreviewImpl links (List.map (\(Reply twilog) -> twilog) replies)


{-| Debouncerに登録する副作用なので、EffectでなくCmdを返させている
-}
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
                            -- 同じことを上方にやってもいいのだが、画面外のレイアウトシフトのせいで
                            -- viewport内の要素がスクロールと逆方向に押しやられるのは体験が悪いので断念している
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


scrollToTargetTweet : String -> Effect Msg
scrollToTargetTweet id =
    Browser.Dom.getElement id
        -- ヘッダー分を大雑把に差し引いてスクロール（注：yは下方向に向かって値が増える）
        |> Task.andThen (\e -> Browser.Dom.setViewport 0 (e.element.y - 100))
        |> Task.onError (\_ -> Task.succeed ())
        |> Task.perform (\_ -> NoOp)
        |> Effect.fromCmd


subscriptions : routeParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    RuntimePorts.fromJs ReceiveFromJs


view : App Data ActionData routeParams -> Shared.Model -> Model -> View.View (PagesMsg Msg)
view app shared m =
    { title = "Twilog"
    , body =
        [ h1 [] [ text "Twilog" ]
        , details []
            [ summary [] [ text "About" ]
            , div [] <| Markdown.parseAndRender Dict.empty """
2023年の各種Twitter騒動のときに遅れ馳せながらTwilogがどういうサービスか知り、Twitterを自動で日記化するという便利さに気づいたので自作し始めたページ。

Zapierを起点としてTweetをGoogle Spreadsheetに蓄積→GitHub Actionsのscheduled workflowで定期的にCSV Endpointからデータを自動取得してwebページ化、という仕組みを実現していたのだが、結局Twitter APIの締め付けは留まるところを知らず、データ取得の維持が大変になったので店じまい。

その後は本家Twilogが再開されたので利用を開始し、不定期にCSVダンプを手動取得→スクリプトでJSONデータに整形してwebページ化する体制になった。

ZapierによるTweet取得以前のデータも、Twitter公式機能で取得したアーカイブから過去データを構成し、webページ化した。

検索SaaSを使って検索機能も提供している。もともとMeilisearchで始めたが、後にfree tierがなくなったのでAlgoliaに移行した。
"""
            ]
        , searchBox TwilogSearchMsg (aTwilog False Dict.empty) m.twilogSearch
        , h3 [ class "twilogs-day-header", id "#onward" ] [ a [ href "https://twilog.togetter.com/gada_twt", target "_blank" ] [ text "最新" ] ]
        ]
            ++ showTwilogsByDailySections shared app.data.twilogsFromOldest
            ++ [ goToLatestMonth app.sharedData.twilogArchives app.data.twilogsFromOldest, linksByMonths Nothing app.sharedData.twilogArchives ]
    }
        |> View.map PagesMsg.fromMsg



-----------------
-- TWILOGS
-----------------


showTwilogsByDailySections : Shared.Model -> Dict RataDie (List Twilog) -> List (Html msg)
showTwilogsByDailySections shared twilogsFromOldest =
    -- foldl to traverse from the oldest
    Dict.foldl (\rataDie twilogs acc -> twilogDailySection shared rataDie twilogs :: acc) [] twilogsFromOldest


twilogDailySection : Shared.Model -> RataDie -> List Twilog -> Html msg
twilogDailySection shared rataDie twilogs =
    let
        date =
            Date.fromRataDie rataDie

        yearMonth =
            String.dropRight 3 (Date.toIsoString date)

        dayId =
            String.padLeft 2 '0' (String.fromInt (Date.day date))

        linkWithDayFragment =
            UrlPath.toAbsolute (Route.toPath (Route.Twilogs__YearMonth_ { yearMonth = yearMonth })) ++ "#" ++ dayId
    in
    section []
        [ h3 [ class "twilogs-day-header", id dayId ] [ a [ href linkWithDayFragment ] [ text (Date.format "yyyy/MM/dd (E)" date) ] ]
        , twilogsOfTheDay shared twilogs
        ]


twilogsOfTheDay : Shared.Model -> List Twilog -> Html msg
twilogsOfTheDay shared twilogs =
    twilogs
        -- Order reversed in index page; newest first
        |> List.reverse
        |> List.map (threadAwareTwilogs shared.links)
        |> Html.Keyed.node "div" []


threadAwareTwilogs : Dict String LinkPreview.Metadata -> Twilog -> ( String, Html msg )
threadAwareTwilogs links twilog =
    Tuple.pair twilog.idStr <|
        case twilog.replies of
            [] ->
                aTwilog True links twilog

            threads ->
                let
                    recursivelyRenderThreadedTwilogs (Reply twilogInThread) =
                        [ div [ class "reply" ] <|
                            case twilogInThread.replies of
                                [] ->
                                    [ aTwilog True links twilogInThread ]

                                more ->
                                    aTwilog True links twilogInThread :: List.concatMap recursivelyRenderThreadedTwilogs more
                        ]
                in
                div [ class "thread" ] <| aTwilog True links twilog :: List.concatMap recursivelyRenderThreadedTwilogs threads


aTwilog : Bool -> Dict String LinkPreview.Metadata -> Twilog -> Html msg
aTwilog isCanonical links twilog =
    div
        [ class "tweet"
        , if isCanonical then
            id ("tweet-" ++ twilog.idStr)

          else
            classList []
        ]
    <|
        List.append
            (if isCanonical then
                twilogData twilog

             else
                []
            )
        <|
            case twilog.retweet of
                Just retweet ->
                    [ a [ class "retweet-label", target "_blank", href (statusLink twilog) ] [ text (twilog.userName ++ " retweeted") ]
                    , header []
                        [ a [ target "_blank", href (statusLink retweet) ]
                            [ imgLazy [ alt ("Avatar of " ++ retweet.userName), src retweet.userProfileImageUrl ] []
                            , strong [] [ text retweet.userName ]
                            ]
                        ]
                    , retweet.fullText
                        |> removeQuoteUrl retweet.quote
                        |> removeMediaUrls retweet.extendedEntitiesMedia
                        |> removeMediaUrls twilog.extendedEntitiesMedia
                        |> removePseudoQuoteUrl retweet.entitiesTcoUrl
                        |> removePseudoQuoteUrl twilog.entitiesTcoUrl
                        |> replaceTcoUrls retweet.entitiesTcoUrl
                        |> replaceTcoUrls twilog.entitiesTcoUrl
                        |> Tweet.render
                        |> (case retweet.extendedEntitiesMedia of
                                [] ->
                                    appendMediaGrid links twilog

                                _ ->
                                    appendMediaGrid links retweet
                           )
                        |> appendQuote retweet.quote
                        -- Prioritize link-previews for retweet here, since twilog.entitiesTcoUrl can have duplicate entitiesTcoUrl
                        |> appendLinkPreviews links
                            (if List.length retweet.entitiesTcoUrl > 0 then
                                retweet.entitiesTcoUrl

                             else
                                -- アーカイブツイートの場合はこちらにRTのentitiesTcoUrlが入っている
                                twilog.entitiesTcoUrl
                            )
                        |> div [ class "body" ]
                    , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Helper.formatPosix twilog.createdAt) ] ]
                    ]

                Nothing ->
                    let
                        ( replyHeader, bodyText ) =
                            case twilog.inReplyTo of
                                -- メモ: ここでは他人へのリプライ（メンション）または日をまたいだセルフリプライのみが対象となる。
                                -- 同日中のセルフリプライツリーはShared.resolveRepliesWithinDayAndSortFromOldestでrepliesに格納し、
                                -- inReplyToをNothingに解決しているので対象とならない。
                                Just inReplyTo ->
                                    case ( String.startsWith "@" twilog.text, String.split " " twilog.text ) of
                                        ( True, mention :: rest ) ->
                                            ( a [ class "reply-label", target "_blank", href (statusLink inReplyTo) ] [ text "Replying to ", strong [ class "link-ish" ] [ text mention ] ]
                                            , String.join " " rest
                                            )

                                        _ ->
                                            ( a [ class "reply-label", target "_blank", href (statusLink inReplyTo) ] [ text (twilog.userName ++ " replied:") ]
                                            , twilog.text
                                            )

                                Nothing ->
                                    ( text "", twilog.text )
                    in
                    [ replyHeader
                    , header []
                        [ a [ target "_blank", href (statusLink twilog) ]
                            [ imgLazy [ alt ("Avatar of " ++ twilog.userName), src twilog.userProfileImageUrl ] []
                            , strong [] [ text twilog.userName ]
                            ]
                        ]
                    , bodyText
                        |> removeQuoteUrl twilog.quote
                        |> removeMediaUrls twilog.extendedEntitiesMedia
                        |> removePseudoQuoteUrl twilog.entitiesTcoUrl
                        |> replaceTcoUrls twilog.entitiesTcoUrl
                        |> Tweet.render
                        |> appendMediaGrid links twilog
                        |> appendQuote twilog.quote
                        |> appendLinkPreviews links twilog.entitiesTcoUrl
                        |> div [ class "body" ]
                    , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Helper.formatPosix twilog.createdAt) ] ]
                    ]


statusLink : { a | id : TwitterStatusId } -> String
statusLink { id } =
    let
        (TwitterStatusId idStr) =
            id
    in
    "https://twitter.com/_/status/" ++ idStr


removeQuoteUrl : Maybe Quote -> String -> String
removeQuoteUrl maybeQuote rawText =
    case maybeQuote of
        Just quote ->
            String.replace quote.permalinkUrl "" rawText

        Nothing ->
            rawText


removeMediaUrls : List Media -> String -> String
removeMediaUrls media rawText =
    List.foldl (\{ url } -> String.replace url "") rawText media


removePseudoQuoteUrl : List TcoUrl -> String -> String
removePseudoQuoteUrl tcoUrls rawText =
    List.foldl
        (\{ url, expandedUrl } acc ->
            if Regex.contains tweetPermalinkRegex expandedUrl then
                -- 展開するとTweet permalinkになるtcoUrlは、アーカイブツイートにおけるQuoteとみなし、
                -- appendLinkPreviewsで擬似Quoteとして表示する。該当する展開前URLがrawTextの末尾にある場合、削除する。
                -- 末尾でなく文中に含まれる場合は原文の雰囲気を残すために削除しない。
                if String.endsWith url acc then
                    acc |> String.replace url "" |> String.trimRight

                else
                    acc

            else
                acc
        )
        rawText
        tcoUrls


replaceTcoUrls : List TcoUrl -> String -> String
replaceTcoUrls tcoUrls rawText =
    List.foldl
        (\{ url, expandedUrl } acc ->
            if Tweet.isTcoUrl expandedUrl then
                -- NoOp, since if the url is expanded to another t.co URL, it will be caught again in autoLinkedMarkdown.
                acc

            else
                String.replace url ("[" ++ Helper.makeDisplayUrl expandedUrl ++ "](" ++ expandedUrl ++ ")") acc
        )
        rawText
        tcoUrls


appendQuote : Maybe Quote -> List (Html msg) -> List (Html msg)
appendQuote maybeQuote htmls =
    case maybeQuote of
        Just quote ->
            htmls
                ++ [ a [ target "_blank", href (statusLink quote) ]
                        [ div [ class "tweet" ]
                            [ header []
                                [ a [ target "_blank", href (statusLink quote) ]
                                    [ imgLazy [ alt ("Avatar of " ++ quote.userName), src quote.userProfileImageUrl ] []
                                    , strong [] [ text quote.userName ]
                                    ]
                                ]
                            , div [ class "body" ] (Tweet.render quote.fullText)
                            ]
                        ]
                   ]

        Nothing ->
            htmls


appendLinkPreviews : Dict String LinkPreview.Metadata -> List TcoUrl -> List (Html msg) -> List (Html msg)
appendLinkPreviews links entitiesTcoUrl htmls_ =
    let
        ( pseudoQuotes, linkPreviews ) =
            entitiesTcoUrl
                |> List.Extra.uniqueBy .expandedUrl
                -- Remove rich Tweet permalink from the list
                |> List.filter (\{ expandedUrl } -> not (String.startsWith "https://twitter.com/i/web/status/" expandedUrl))
                |> List.filterMap (\{ expandedUrl } -> Dict.get expandedUrl links)
                |> List.partition (\{ canonicalUrl } -> Regex.contains tweetPermalinkRegex canonicalUrl)

        htmls =
            if List.isEmpty pseudoQuotes then
                htmls_

            else
                htmls_
                    ++ List.map
                        (\pseudoQuote ->
                            -- LinkPreviewから得られる情報を元に、アーカイブツイートのQuoteを擬似的に再現している。
                            let
                                userName =
                                    LinkPreview.reconstructTwitterUserName pseudoQuote.title

                                iconUrl =
                                    Maybe.withDefault placeholderAvatarUrl pseudoQuote.imageUrl

                                placeholderAvatarUrl =
                                    "https://abs.twimg.com/sticky/default_profile_images/default_profile_200x200.png"
                            in
                            a [ target "_blank", href pseudoQuote.canonicalUrl ]
                                [ div [ class "tweet" ]
                                    [ header []
                                        [ a [ target "_blank", href pseudoQuote.canonicalUrl ]
                                            [ imgLazy [ alt ("Avatar of " ++ userName), src iconUrl ] []
                                            , strong [] [ text userName ]
                                            ]
                                        ]
                                    , pseudoQuote.description
                                        |> Maybe.withDefault ""
                                        |> Tweet.render
                                        |> div [ class "body" ]
                                    ]
                                ]
                        )
                        pseudoQuotes
    in
    if List.isEmpty linkPreviews then
        htmls

    else
        htmls
            ++ List.map
                (\{ title, description, imageUrl, canonicalUrl } ->
                    a [ target "_blank", href canonicalUrl ]
                        [ div [ class "link-preview" ]
                            [ case imageUrl of
                                Just imageUrl_ ->
                                    imgLazy [ src imageUrl_, alt "Preview image of the website" ] []

                                Nothing ->
                                    text ""
                            , div []
                                [ header [] [ strong [] [ text title ] ]
                                , case description of
                                    Just description_ ->
                                        p [] [ text description_ ]

                                    Nothing ->
                                        text ""
                                ]
                            ]
                        ]
                )
                linkPreviews


tweetPermalinkRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://twitter\\.com/[^/]+/status/[^/]+(?!/)")


appendMediaGrid : Dict String LinkPreview.Metadata -> { a | id : TwitterStatusId, extendedEntitiesMedia : List Media } -> List (Html msg) -> List (Html msg)
appendMediaGrid links status htmls =
    case status.extendedEntitiesMedia of
        [] ->
            htmls

        nonEmptyMedia ->
            let
                (TwitterStatusId idStr) =
                    status.id

                -- Show media based on type: "photo" | "video" | "animated_gif"
                aMedia media =
                    let
                        maybeSourceUrl =
                            if String.endsWith "__NOT_LOADED__" media.sourceUrl then
                                Dict.get media.expandedUrl links
                                    |> Maybe.andThen .imageUrl
                                    |> Maybe.andThen
                                        (\actualSourceUrl ->
                                            -- LinkPreview did not resolve in media file, rather than profile image of the retweeted user. Discard.
                                            if String.contains "/profile_images/" actualSourceUrl then
                                                Nothing

                                            else
                                                Just actualSourceUrl
                                        )

                            else
                                Just media.sourceUrl
                    in
                    case ( media.type_, maybeSourceUrl ) of
                        ( "photo", Just sourceUrl ) ->
                            [ lightboxLink { href = media.expandedUrl, src = sourceUrl, type_ = media.type_ } [] [ imgLazy [ src sourceUrl, alt ("Attached photo of status id: " ++ idStr) ] [] ] ]

                        ( "video", Just sourceUrl ) ->
                            -- Looks like expanded_url is a thumbnail in simple Media object
                            [ lightboxLink { href = media.expandedUrl, src = sourceUrl, type_ = media.type_ } [] [ figure [ class "video-thumbnail" ] [ imgLazy [ src sourceUrl, alt ("Thumbnail of attached video of status id: " ++ idStr) ] [] ] ] ]

                        ( "animated_gif", Just sourceUrl ) ->
                            [ lightboxLink { href = media.expandedUrl, src = sourceUrl, type_ = media.type_ } [] [ figure [ class "video-thumbnail" ] [ imgLazy [ src sourceUrl, alt ("Animated GIF attached to status id: " ++ idStr) ] [] ] ] ]

                        _ ->
                            []
            in
            case List.concatMap aMedia nonEmptyMedia of
                [] ->
                    htmls

                nonEmptyRenderedImages ->
                    htmls ++ [ div [ class "media-grid" ] nonEmptyRenderedImages ]



-----------------
-- ARCHIVE NAVIGATION
-----------------


goToLatestMonth : List TwilogArchiveYearMonth -> Dict RataDie (List Twilog) -> Html Msg
goToLatestMonth twilogArchives twilogsFromOldest =
    case ( twilogArchives, Dict.toList twilogsFromOldest ) of
        ( latestYearMonth :: _, ( _, oldestTwilog :: _ ) :: _ ) ->
            -- Similar to Page.Twilogs.YearMonth_.prevNextNavigation
            -- ただしここでは最新月へのリンクのみがページ下部（twilogsFromOldestを最後までスクロールした先）にあるので、
            -- 遷移先はoldestTwilogのidを指定することで自然な位置を保つ
            let
                pathToLatestMonth =
                    UrlPath.toAbsolute (Route.toPath (Route.Twilogs__YearMonth_ { yearMonth = latestYearMonth }))

                id =
                    "tweet-" ++ oldestTwilog.idStr
            in
            nav [ class "prev-next-navigation" ]
                [ a [ href <| pathToLatestMonth ++ "#" ++ id, onClick (ForceTweetId id) ] [ strong [] [ text "← 最新月" ] ]
                ]

        ( _, _ ) ->
            -- Should not happen
            text ""


linksByMonths : Maybe String -> List TwilogArchiveYearMonth -> Html msg
linksByMonths maybeOpenedYearMonth twilogArchives =
    let
        yearMonthsFromNewest =
            twilogArchives
                -- Traverse from oldest
                |> List.foldr
                    (\yearMonth acc ->
                        case String.split "-" yearMonth of
                            [ year, month ] ->
                                Dict.update year
                                    (\maybeMonths ->
                                        case maybeMonths of
                                            Nothing ->
                                                Just [ month ]

                                            Just months ->
                                                -- Eventually newest-first list
                                                Just (month :: months)
                                    )
                                    acc

                            _ ->
                                -- Usually not happen
                                acc
                    )
                    Dict.empty
                -- Here Dict -> List conversion makes the resulting list oldest-first; reverse it
                |> Dict.toList
                |> List.reverse

        ( openedYear, maybeOpenedMonth ) =
            case maybeOpenedYearMonth of
                Just yearMonth ->
                    case String.split "-" yearMonth of
                        [ year, month ] ->
                            ( year, Just month )

                        _ ->
                            fallbackYearMonth

                Nothing ->
                    fallbackYearMonth

        fallbackYearMonth =
            case twilogArchives of
                yearMonth :: _ ->
                    case String.split "-" yearMonth of
                        [ year, _ ] ->
                            ( year, Nothing )

                        _ ->
                            ( "2023", Nothing )

                [] ->
                    ( "2023", Nothing )
    in
    yearMonthsFromNewest
        |> List.map
            (\( year, months ) ->
                details
                    [ if year == openedYear then
                        attribute "open" ""

                      else
                        classList []
                    ]
                    [ summary [] [ text (year ++ "年") ]
                    , List.map
                        (\month ->
                            if ( year, Just month ) == ( openedYear, maybeOpenedMonth ) then
                                li [ class "selected" ] [ text (year ++ "/" ++ month) ]

                            else
                                li [] [ Route.Twilogs__YearMonth_ { yearMonth = year ++ "-" ++ month } |> Route.link [] [ text (year ++ "/" ++ month) ] ]
                        )
                        months
                        |> ul []
                    ]
            )
        |> nav [ class "twilog-archive-navigation" ]



-----------------
-- TWILOG RAW DATA
-----------------


twilogData : Twilog -> List (Html msg)
twilogData twilog =
    let
        checkboxId =
            "twilog-data-checkbox-" ++ twilog.idStr
    in
    [ input [ type_ "checkbox", id checkboxId ] []
    , label [ for checkboxId ] [ text "Twilog raw JSON" ]
    , pre [ class "twilog-data" ] [ text (TwilogData.dumpTwilog twilog) ]
    ]
