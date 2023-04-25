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
import Regex exposing (Regex)
import Route
import Shared exposing (Media, Quote, RataDie, Reply(..), TcoUrl, Twilog, TwitterStatusId(..), seoBase)
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
    , searchApiKey : String
    }


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { init = \_ _ app -> ( TwilogSearch.init app.data.searchApiKey, Helper.initMsg InitiateLinkPreviewPopulation )
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
        |> DataSource.andMap TwilogSearch.apiKey


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
            , listUrlsForPreviewBulk shared app.data.recentDailyTwilogs
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


listUrlsForPreviewBulk : Shared.Model -> Dict RataDie (List Twilog) -> Maybe Shared.Msg
listUrlsForPreviewBulk { links } recentDailyTwilogs =
    case listUrlsForPreviewBulkHelp links recentDailyTwilogs of
        [] ->
            Nothing

        urls ->
            Just (Shared.SharedMsg (Shared.Req_LinkPreview urls))


listUrlsForPreviewBulkHelp : Dict String LinkPreview.Metadata -> Dict RataDie (List Twilog) -> List String
listUrlsForPreviewBulkHelp links recentDailyTwilogsFromOldest =
    Dict.values recentDailyTwilogsFromOldest
        |> List.concat
        -- Make it newest first
        |> List.reverse
        |> listUrlsForPreviewSingleHelp links
        |> List.Extra.unique


listUrlsForPreviewSingle : Shared.Model -> List Twilog -> Maybe Shared.Msg
listUrlsForPreviewSingle { links } twilogs =
    case listUrlsForPreviewSingleHelp links twilogs of
        [] ->
            Nothing

        urls ->
            Just (Shared.SharedMsg (Shared.Req_LinkPreview urls))


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
2023年に、Twitter APIの大幅値上げ（無料枠縮小）で[Twilogが新規データを記録できなくなる](https://twitter.com/ropross/status/1641353674046992385)ようなのだが、
そのタイミングで遅ればせながらTwilogがどういうサービスか知り、Twitterを自動で日記化するという便利さに気づいたので自作し始めたページ。仕組み：

- Zapierを起点としてうまいことTweetを継続的に蓄積
- それを自前でTwilogっぽくwebページ化（サイトはデイリービルド）
- Twitter公式機能で取得したアーカイブから過去ページも追って作成（完成）
- Meilisearchで検索機能提供
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
                        |> autoLinkedMarkdown
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
                        |> autoLinkedMarkdown
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
            if Regex.contains tcoUrlInTweetRegex expandedUrl then
                -- NoOp, since if the url is expanded to another t.co URL, it will be caught again in autoLinkedMarkdown.
                acc

            else
                String.replace url ("[" ++ makeDisplayUrl expandedUrl ++ "](" ++ expandedUrl ++ ")") acc
        )
        rawText
        tcoUrls


makeDisplayUrl : String -> String
makeDisplayUrl rawUrl =
    if String.length rawUrl > 40 then
        (rawUrl
            |> String.left 40
            |> String.replace "https://" ""
            |> String.replace "http://" ""
        )
            ++ "..."

    else
        rawUrl
            |> String.replace "https://" ""
            |> String.replace "http://" ""


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
                            , div [ class "body" ] (autoLinkedMarkdown quote.fullText)
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
                                        |> autoLinkedMarkdown
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


autoLinkedMarkdown : String -> List (Html msg)
autoLinkedMarkdown rawText =
    rawText
        -- Shorten remaining t.co URLs. Another URLs, if any, will be autolinked by Markdown.render
        |> Regex.replace tcoUrlInTweetRegex (\{ match } -> "[" ++ makeDisplayUrl match ++ "](" ++ match ++ ")")
        |> Regex.replace mentionRegex (\{ match } -> "[@" ++ String.dropLeft 1 match ++ "](https://twitter.com/" ++ String.dropLeft 1 match ++ ")")
        |> replaceHashtags ""
        -- 最終的に、各種処理されたtweet由来のテキストをMarkdownとして解釈している。
        -- Markdownリンクとして加工された文中のURLやハッシュタグをサクッとHtmlリンクにできる。
        -- 副作用として、本来Markdownと意識されていないTweetがMarkdownとして描画されてしまう。
        -- ここで`links : Dict String LinkPreview.Metadata`を引いてくればruntime link-previewもできるが、
        -- Tweet表示ではinlineで表示するよりappendLinkPreviewsの方に含めたほうがいい。
        -- TODO: そのうち「リンクだけをHTML化するrenderer」を用意して使い分けたほうがよりTweetらしくなるかも
        |> Markdown.parseAndRender Dict.empty


replaceHashtags : String -> String -> String
replaceHashtags acc input =
    -- `#tokyoex #tokyoex_livestream`のように、前方一致するhashtagが同時存在している場合、まとめて変換されないようにしたい。
    -- 再帰関数で前方から順に処理していく。
    case input of
        "" ->
            acc

        rest ->
            case Regex.findAtMost 1 hashtagRegex rest of
                [ { match, index } ] ->
                    let
                        -- hashtagっぽいmatchが、Markdownリンクの内部にないことを確認する
                        -- これがないと、`[#foo](https://example.com)`や`[foo](https://example.com#foo)`のようなすでにここまでで整形されたテキストに含まれるhashtagらしき文字列が、
                        -- `[[#foo](https://example.com)](https://twitter.com/hashtag/foo)`と二重にリンク化されてしまう
                        hashInMarkdownLinkPattern =
                            Maybe.withDefault Regex.never (Regex.fromString ("(\\[[^\\]]*?" ++ match ++ "[^\\]]*?\\]\\(|\\]\\([^\\]]*?" ++ match ++ "[^\\]]*?\\))"))

                        doReplace _ =
                            let
                                skipped =
                                    String.left index rest

                                replaced =
                                    "[#" ++ String.dropLeft 1 match ++ "](https://twitter.com/hashtag/" ++ String.dropLeft 1 match ++ ")"

                                rest_ =
                                    String.dropLeft (String.length skipped + String.length match) rest
                            in
                            replaceHashtags (acc ++ skipped ++ replaced) rest_
                    in
                    case Regex.findAtMost 1 hashInMarkdownLinkPattern rest of
                        [ innerMatch ] ->
                            if innerMatch.index <= index then
                                -- 見つかったのはMarkdownリンク内部のhashtagっぽいマッチだった。該当部分スキップ
                                let
                                    skipped =
                                        String.left (index + String.length innerMatch.match) rest
                                in
                                replaceHashtags (acc ++ skipped) (String.dropLeft (String.length skipped) rest)

                            else
                                -- Markdownリンクが見つかったが、より後方にあった。とりあえず今のmatchについてはリンク化実行
                                doReplace ()

                        _ ->
                            -- Markdownリンクは見つからず、裸のhashtagだけがあった。リンク化実行
                            doReplace ()

                _ ->
                    -- findAtMostによって2件以上マッチはしないので、ここに来るのは0件のみ。即時終了
                    acc ++ rest


tcoUrlInTweetRegex : Regex
tcoUrlInTweetRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://t.co/[a-zA-Z0-9]+")


mentionRegex : Regex
mentionRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...,@mention`のようなURLがあると誤認識する。が、制限事項とする
    -- 少なくともauthority partに@を含む認証可能URL（URL内に@を含むパターンとして第一にありがちなやつ）などはカンマが先行しないはず
    -- また、開きカッコなどの識別用意な記号に続くものも可能な限り対応。
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|[\\s,\\.\\(（、。])@[a-zA-Z0-9_]+")


hashtagRegex : Regex
hashtagRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...?foo,bar,#hashtag`のようなURLがあると誤認識する。が、制限事項とする
    -- このRegexはdeny-list方式で、hashtagに使用できない文字列をひたすら列挙している。ASCII記号としては`_`以外すべての記号を除外。
    -- その他、Unicodeの記号系文字列も可能な範囲で弾いている。TODO: 「数字のみからなるもの」も除外対象だが、一つのRegexだと表現しづらい
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|[\\s,\\.\\(（、。])(#|＃)[^\\s!-/:-@\\[-\\^`{-~＠＃「」（）…]+")


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

        ( maybeOpenedYear, maybeOpenedMonth ) =
            case maybeOpenedYearMonth of
                Just yearMonth ->
                    case String.split "-" yearMonth of
                        [ year, month ] ->
                            ( Just year, Just month )

                        _ ->
                            ( Nothing, Nothing )

                Nothing ->
                    ( Nothing, Nothing )
    in
    yearMonthsFromNewest
        |> List.map
            (\( year, months ) ->
                details
                    [ if Just year == maybeOpenedYear then
                        attribute "open" ""

                      else
                        classList []
                    ]
                    [ summary [] [ text (year ++ "年") ]
                    , List.map
                        (\month ->
                            if ( Just year, Just month ) == ( maybeOpenedYear, maybeOpenedMonth ) then
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
