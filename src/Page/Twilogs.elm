module Page.Twilogs exposing
    ( Data
    , Model
    , Msg
    , RouteParams
    , aTwilog
    , getRecentDays
    , linksByMonths
    , listUrlsForPreviewBulk
    , listUrlsForPreviewSingle
    , page
    , showTwilogsByDailySections
    , twilogsOfTheDay
    )

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Glob
import Date
import Dict exposing (Dict)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Head
import Head.Seo as Seo
import Helper
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import LinkPreview
import List.Extra
import Markdown
import Page
import Pages.PageUrl
import Path
import Regex
import Route
import Shared exposing (Media, Quote, RataDie, Reply(..), TcoUrl, Twilog, TwitterStatusId(..), seoBase)
import Tweet
import TwilogSearch exposing (searchBox)
import View exposing (imgLazy, lightboxLink)


type alias Model =
    TwilogSearch.Model


type Msg
    = InitiateLinkPreviewPopulation
    | TwilogSearchMsg TwilogSearch.Msg


type alias RouteParams =
    {}


type alias Data =
    { recentDailyTwilogs : Dict RataDie (List Twilog)
    , searchSecrets : TwilogSearch.Secrets
    , amazonAssociateTag : String
    }


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { init = \_ _ app -> ( TwilogSearch.init app.data.searchSecrets, Helper.initMsg InitiateLinkPreviewPopulation )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , view = view
            }


data : DataSource Data
data =
    getRecentDays daysToPeek
        |> DataSource.andThen
            (\dateStrings ->
                Shared.dailyTwilogsFromOldest (List.map Shared.makeTwilogsJsonPath dateStrings)
                    |> DataSource.map Data
            )
        |> DataSource.andMap TwilogSearch.secrets
        |> DataSource.andMap (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")


daysToPeek =
    3


getRecentDays : Int -> DataSource (List String)
getRecentDays days =
    DataSource.Glob.succeed (\year month day -> String.join "-" [ year, month, day ])
        |> DataSource.Glob.match (DataSource.Glob.literal "data/")
        |> DataSource.Glob.capture DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "/")
        |> DataSource.Glob.capture DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "/")
        |> DataSource.Glob.capture DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "-twilogs.json")
        |> DataSource.Glob.toDataSource
        -- Make newest first
        |> DataSource.map (List.sort >> List.reverse >> List.take days)


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "Twilog"
            , description = "2023年4月から作り始めた自作Twilog。Twitterを日記化している"
        }
        |> Seo.website


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared app msg model =
    case msg of
        InitiateLinkPreviewPopulation ->
            ( model
            , Cmd.none
            , listUrlsForPreviewBulk shared app.data.amazonAssociateTag app.data.recentDailyTwilogs
            )

        TwilogSearchMsg twMsg ->
            let
                ( model_, cmd ) =
                    TwilogSearch.update twMsg model
            in
            ( model_
            , Cmd.map TwilogSearchMsg cmd
            , Nothing
            )


listUrlsForPreviewBulk : Shared.Model -> String -> Dict RataDie (List Twilog) -> Maybe Shared.Msg
listUrlsForPreviewBulk { links } amazonAssociateTag recentDailyTwilogs =
    case listUrlsForPreviewBulkHelp links recentDailyTwilogs of
        [] ->
            Nothing

        urls ->
            Just (Shared.SharedMsg (Shared.Req_LinkPreview amazonAssociateTag urls))


listUrlsForPreviewBulkHelp : Dict String LinkPreview.Metadata -> Dict RataDie (List Twilog) -> List String
listUrlsForPreviewBulkHelp links recentDailyTwilogsFromOldest =
    Dict.values recentDailyTwilogsFromOldest
        |> List.concat
        -- Make it newest first
        |> List.reverse
        |> listUrlsForPreviewSingleHelp links
        |> List.Extra.unique


listUrlsForPreviewSingle : Shared.Model -> String -> List Twilog -> Maybe Shared.Msg
listUrlsForPreviewSingle { links } amazonAssociateTag twilogs =
    case listUrlsForPreviewSingleHelp links twilogs of
        [] ->
            Nothing

        urls ->
            Just (Shared.SharedMsg (Shared.Req_LinkPreview amazonAssociateTag urls))


listUrlsForPreviewSingleHelp : Dict String LinkPreview.Metadata -> List Twilog -> List String
listUrlsForPreviewSingleHelp links twilogs =
    twilogs
        |> List.concatMap
            (\twilog ->
                let
                    urlsFromReplies =
                        listUrlsForPreviewFromReplies links twilog.replies
                in
                -- TODO: Also list t.co URLs from twilog.text and twilog.retweet.fullText, if they do not have corresponding expandedUrls
                (twilog.entitiesTcoUrl ++ (twilog.retweet |> Maybe.map .entitiesTcoUrl |> Maybe.withDefault []))
                    |> List.filterMap
                        (\tcoUrl ->
                            -- list not-yet previewed URLs
                            case Dict.get tcoUrl.expandedUrl links of
                                Just _ ->
                                    Nothing

                                Nothing ->
                                    Just tcoUrl.expandedUrl
                        )
                    |> List.append urlsFromReplies
            )
        |> List.Extra.unique


listUrlsForPreviewFromReplies links replies =
    listUrlsForPreviewSingleHelp links (List.map (\(Reply twilog) -> twilog) replies)


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared m app =
    { title = "Twilog"
    , body =
        [ h1 [] [ text "Twilog" ]
        , div [] <| Markdown.parseAndRender Dict.empty """
2023年に、Twitter APIの大幅値上げ（無料枠縮小）で[Twilogが新規データを記録できなくなる](https://twitter.com/ropross/status/1641353674046992385)~~ようなのだが~~という懸念があったが （のちに[Togetter社がサービスを買収して復旧した](https://prtimes.jp/main/html/rd/p/000000008.000012337.html)）、
そのタイミングで遅ればせながらTwilogがどういうサービスか知り、Twitterを自動で日記化するという便利さに気づいたので自作し始めたページ。

以下のような仕組みで実現できていたのだが、結局Twitter APIの締め付けは留まるところを知らず、データが取得できなくなったので店じまい。

- Zapierを起点としてうまいことTweetを継続的に蓄積
- それを自前でTwilogっぽくwebページ化（サイトはデイリービルド）
- Twitter公式機能で取得したアーカイブから過去ページも追って作成（完成）
- 検索SaaSを使って検索機能提供

その後は[Twilog本家に任せることにした](https://twilog.togetter.com/gada_twt)。
"""
        , searchBox TwilogSearchMsg (aTwilog False Dict.empty) m
        ]
            ++ showTwilogsByDailySections shared app.data.recentDailyTwilogs
            ++ [ goToLatestMonth app.sharedData.twilogArchives, linksByMonths Nothing app.sharedData.twilogArchives ]
    }



-----------------
-- TWILOGS
-----------------


showTwilogsByDailySections : Shared.Model -> Dict RataDie (List Twilog) -> List (Html msg)
showTwilogsByDailySections shared recentDailyTwilogs =
    -- foldl to traverse from the oldest
    Dict.foldl (\rataDie twilogs acc -> twilogDailySection shared rataDie twilogs :: acc) [] recentDailyTwilogs


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
            Path.toAbsolute (Route.toPath (Route.Twilogs__YearMonth_ { yearMonth = yearMonth })) ++ "#" ++ dayId
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
                                    appendMediaGrid twilog

                                _ ->
                                    appendMediaGrid retweet
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
                    , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Shared.formatPosix twilog.createdAt) ] ]
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
                        |> appendMediaGrid twilog
                        |> appendQuote twilog.quote
                        |> appendLinkPreviews links twilog.entitiesTcoUrl
                        |> div [ class "body" ]
                    , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Shared.formatPosix twilog.createdAt) ] ]
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
                                    String.replace "さんはTwitterを使っています" "" pseudoQuote.title

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
                                        -- LinkPreviewではtweet descriptionに本文が入っているが、ダブルクォートされているので解除
                                        |> String.dropLeft 1
                                        |> String.dropRight 1
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
    Maybe.withDefault Regex.never (Regex.fromString "https?://twitter\\.com/[^/]+/status/.+")


appendMediaGrid : { a | id : TwitterStatusId, extendedEntitiesMedia : List Media } -> List (Html msg) -> List (Html msg)
appendMediaGrid status htmls =
    case status.extendedEntitiesMedia of
        [] ->
            htmls

        nonEmpty ->
            let
                (TwitterStatusId idStr) =
                    status.id

                -- Show media based on type: "photo" | "video" | "animated_gif"
                aMedia media =
                    case media.type_ of
                        "photo" ->
                            lightboxLink { href = media.expandedUrl, src = media.sourceUrl, type_ = media.type_ } [] [ imgLazy [ src media.sourceUrl, alt ("Attached photo of status id: " ++ idStr) ] [] ]

                        "video" ->
                            -- Looks like expanded_url is a thumbnail in simple Media object
                            lightboxLink { href = media.expandedUrl, src = media.sourceUrl, type_ = media.type_ } [] [ figure [ class "video-thumbnail" ] [ imgLazy [ src media.sourceUrl, alt ("Thumbnail of attached video of status id: " ++ idStr) ] [] ] ]

                        "animated_gif" ->
                            lightboxLink { href = media.expandedUrl, src = media.sourceUrl, type_ = media.type_ } [] [ figure [ class "video-thumbnail" ] [ imgLazy [ src media.sourceUrl, alt ("Animated GIF attached to status id: " ++ idStr) ] [] ] ]

                        _ ->
                            text ""
            in
            htmls ++ [ div [ class "media-grid" ] <| List.map aMedia nonEmpty ]



-----------------
-- ARCHIVE NAVIGATION
-----------------


goToLatestMonth : List TwilogArchiveYearMonth -> Html msg
goToLatestMonth twilogArchives =
    case twilogArchives of
        [] ->
            -- Should not happen
            text ""

        latestYearMonth :: _ ->
            -- Similar to Page.Twilogs.YearMonth_.prevNextNavigation
            nav [ class "prev-next-navigation" ]
                [ Route.link (Route.Twilogs__YearMonth_ { yearMonth = latestYearMonth }) [] [ strong [] [ text "← 最新月" ] ]
                ]


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
                                li [] [ Route.link (Route.Twilogs__YearMonth_ { yearMonth = year ++ "-" ++ month }) [] [ text (year ++ "/" ++ month) ] ]
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
    , pre [ class "twilog-data" ] [ text (Shared.dumpTwilog twilog) ]
    ]
