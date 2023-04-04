module Page.Twilogs exposing (Data, Model, Msg, listUrlsForPreviewBulk, listUrlsForPreviewSingle, page, showTwilogsUpToDays, twilogDailySection, twilogsOfTheDay)

import Browser.Navigation
import DataSource exposing (DataSource)
import Date
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (alt, class, href, src, target)
import LinkPreview
import List.Extra
import Markdown
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Regex exposing (Regex)
import Route
import Shared exposing (Media, Quote, RataDie, Reply(..), TcoUrl, Twilog, TwitterStatusId(..), seoBase)
import Task
import View exposing (View, imgLazy)


type alias Model =
    ()


type Msg
    = InitiateLinkPreviewPopulation


type alias RouteParams =
    {}


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { view = view
            , init = \_ _ _ -> ( (), Task.perform (\() -> InitiateLinkPreviewPopulation) (Task.succeed ()) )
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            }


type alias Data =
    ()


data : DataSource Data
data =
    DataSource.succeed ()


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
            , static.sharedData.dailyTwilogs
                |> Dict.keys
                |> List.reverse
                |> List.take daysToPeek
                |> listUrlsForPreviewBulk shared static
            )


listUrlsForPreviewBulk : Shared.Model -> StaticPayload templateData routeParams -> List RataDie -> Maybe Shared.Msg
listUrlsForPreviewBulk { links } { sharedData } rataDiesToPeek =
    case listUrlsForPreviewBulkHelp links rataDiesToPeek sharedData.dailyTwilogs of
        [] ->
            Nothing

        urls ->
            Just (Shared.SharedMsg (Shared.Req_LinkPreview urls))


listUrlsForPreviewBulkHelp : Dict String LinkPreview.Metadata -> List RataDie -> Dict RataDie (List Twilog) -> List String
listUrlsForPreviewBulkHelp links rataDies dailyTwilogsFromOldest =
    rataDies
        |> List.concatMap
            (\rataDie ->
                Dict.get rataDie dailyTwilogsFromOldest
                    |> Maybe.withDefault []
                    |> listUrlsForPreviewSingleHelp links
            )
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
                (twilog.entitiesTcoUrl ++ (twilog.retweet |> Maybe.map .entitiesTcoUrl |> Maybe.withDefault []))
                    |> List.filterMap
                        (\tcoUrl ->
                            -- list not-yet previewed URLs
                            case Dict.get tcoUrl.expandedUrl links of
                                Just _ ->
                                    Nothing

                                Nothing ->
                                    -- Do not list twitter-internal URLs since they are likely quote/reply permalinks
                                    if String.startsWith "https://twitter.com" tcoUrl.expandedUrl then
                                        Nothing

                                    else
                                        Just tcoUrl.expandedUrl
                        )
                    |> List.append urlsFromReplies
            )
        |> List.Extra.unique


listUrlsForPreviewFromReplies links replies =
    listUrlsForPreviewSingleHelp links (List.map (\(Reply twilog) -> twilog) replies)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge
        { seoBase
            | title = Shared.makeTitle "Twilog"
            , description = "2023年4月から作り始めた自作Twilog。Twitterを日記化している"
        }
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ shared _ static =
    { title = "Twilog"
    , body =
        [ h1 [] [ text "Twilog" ]
        , div [] <| Markdown.render """
2023年に、Twitter APIの大幅値上げ（無料枠縮小）で[Twilogが新規データを記録できなくなる](https://twitter.com/ropross/status/1641353674046992385)ようなのだが、
そのタイミングで遅ればせながらTwilogがどういうサービスか知り、Twitterを自動で日記化するという便利さに気づいたので自作し始めたページ。仕組み：

- Zapierを起点としてうまいことTweetを継続的に蓄積
- それを自前でTwilogっぽくwebページ化（サイトはデイリービルド）
- Twitter公式機能で取得したアーカイブから過去ページも追って作成（予定）
"""
        ]
            ++ showTwilogsUpToDays daysToPeek shared static.sharedData.dailyTwilogs
    }


daysToPeek =
    10


showTwilogsUpToDays : Int -> Shared.Model -> Dict RataDie (List Twilog) -> List (Html msg)
showTwilogsUpToDays days shared dailyTwilogs =
    dailyTwilogs
        |> Dict.foldr
            (\rataDie twilogs acc ->
                if List.length acc < days then
                    twilogDailySection shared rataDie twilogs :: acc

                else
                    -- TODO Link to old dates
                    acc
            )
            []
        |> List.reverse


twilogDailySection : Shared.Model -> RataDie -> List Twilog -> Html msg
twilogDailySection shared rataDie twilogs =
    let
        date =
            Date.fromRataDie rataDie
    in
    section []
        [ h3 [] [ Route.link (Route.Twilogs__Day_ { day = Date.toIsoString date }) [] [ text (Date.format "yyyy/MM/dd (E)" date) ] ]
        , twilogsOfTheDay shared twilogs
        ]


twilogsOfTheDay : Shared.Model -> List Twilog -> Html msg
twilogsOfTheDay shared twilogs =
    twilogs
        -- Order reversed in index page; newest first
        |> List.reverse
        |> List.map (threadAwareTwilogs shared.links)
        |> div []


threadAwareTwilogs : Dict String LinkPreview.Metadata -> Twilog -> Html msg
threadAwareTwilogs links twilog =
    case twilog.replies of
        [] ->
            aTwilog links twilog

        threads ->
            let
                recursivelyRenderThreadedTwilogs (Reply twilogInThread) =
                    [ div [ class "reply" ] <|
                        case twilogInThread.replies of
                            [] ->
                                [ aTwilog links twilogInThread ]

                            more ->
                                aTwilog links twilogInThread :: List.concatMap recursivelyRenderThreadedTwilogs more
                    ]
            in
            div [ class "thread" ] <| aTwilog links twilog :: List.concatMap recursivelyRenderThreadedTwilogs threads


aTwilog : Dict String LinkPreview.Metadata -> Twilog -> Html msg
aTwilog links twilog =
    -- TODO: show link-previews when links are populated at runtime
    div [ class "tweet" ] <|
        case twilog.retweet of
            Just retweet ->
                [ a [ class "retweet-label", target "_blank", href (statusLink twilog) ] [ text (twilog.userName ++ " retweeted") ]
                , a [ target "_blank", href (statusLink retweet) ]
                    [ header []
                        [ imgLazy [ alt ("Avatar of " ++ retweet.userName), src retweet.userProfileImageUrl ] []
                        , strong [] [ text retweet.userName ]
                        ]
                    ]
                , retweet.fullText
                    |> removeQuoteUrl retweet.quote
                    |> removeMediaUrls retweet.extendedEntitiesMedia
                    |> removeMediaUrls twilog.extendedEntitiesMedia
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
                    -- Only show link-previews for retweet here, since twilog.entitiesTcoUrl can have duplicate entitiesTcoUrl
                    |> appendLinkPreviews links retweet.entitiesTcoUrl
                    |> div [ class "body" ]
                , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Shared.formatPosix twilog.createdAt) ] ]
                ]

            Nothing ->
                [ case twilog.inReplyTo of
                    Just inReplyTo ->
                        a [ class "reply-label", target "_blank", href (statusLink inReplyTo) ] [ text (twilog.userName ++ " replied:") ]

                    Nothing ->
                        text ""
                , a [ target "_blank", href (statusLink twilog) ]
                    [ header []
                        [ imgLazy [ alt ("Avatar of " ++ twilog.userName), src twilog.userProfileImageUrl ] []
                        , strong [] [ text twilog.userName ]
                        ]
                    ]
                , twilog.text
                    |> removeQuoteUrl twilog.quote
                    |> removeMediaUrls twilog.extendedEntitiesMedia
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
                ++ [ div [ class "tweet" ]
                        [ a [ target "_blank", href (statusLink quote) ]
                            [ header []
                                [ imgLazy [ alt ("Avatar of " ++ quote.userName), src quote.userProfileImageUrl ] []
                                , strong [] [ text quote.userName ]
                                ]
                            ]
                        , div [ class "body" ] (autoLinkedMarkdown quote.fullText)
                        ]
                   ]

        Nothing ->
            htmls


appendLinkPreviews : Dict String LinkPreview.Metadata -> List TcoUrl -> List (Html msg) -> List (Html msg)
appendLinkPreviews links entitiesTcoUrl htmls =
    let
        linkPreviews =
            entitiesTcoUrl
                |> List.Extra.uniqueBy .expandedUrl
                |> List.filterMap (\{ expandedUrl } -> Dict.get expandedUrl links)
    in
    if List.isEmpty linkPreviews then
        htmls

    else
        htmls
            ++ [ div [ class "link-previews" ]
                    (List.map
                        (\{ title, description, imageUrl, canonicalUrl } ->
                            a [ target "_blank", href canonicalUrl ]
                                [ div [ class "link-preview" ]
                                    [ case imageUrl of
                                        Just imageUrl_ ->
                                            imgLazy [ src imageUrl_ ] []

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
                    )
               ]


autoLinkedMarkdown : String -> List (Html msg)
autoLinkedMarkdown rawText =
    rawText
        -- Shorten remaining t.co URLs. Another URLs, if any, will be autolinked by Markdown.render
        |> Regex.replace tcoUrlInTweetRegex (\{ match } -> "[" ++ String.dropLeft 8 match ++ "](" ++ match ++ ")")
        |> Regex.replace mentionRegex (\{ match } -> "[@" ++ String.dropLeft 1 match ++ "](https://twitter.com/" ++ String.dropLeft 1 match ++ ")")
        |> (\tcoUrlsExpandedText ->
                Regex.find hashtagRegex tcoUrlsExpandedText
                    |> List.foldl
                        (\{ match } accText ->
                            let
                                -- hashtagっぽいmatchが、Markdownリンクの内部にないことを確認する
                                -- これがないと、`[#foo](https://example.com)`や`[foo](https://example.com#foo)`のようなすでにここまでで整形されたテキストに含まれるhashtagらしき文字列が、
                                -- `[[#foo](https://example.com)](https://twitter.com/hashtag/foo)`と二重にリンク化されてしまう
                                hashInMarkdownLinkPattern =
                                    Maybe.withDefault Regex.never (Regex.fromString ("(\\[[^\\]]*?" ++ match ++ "[^\\]]*?\\]\\(|\\]\\([^\\]]*?" ++ match ++ "[^\\]]*?\\))"))
                            in
                            -- 同じhashtagが複数Regex.findでマッチし、foldで同じ内容の`match`がマッチした分繰り返し評価されるパターンについてもここでスルーできる
                            -- String.replaceは最初の評価時に一発でaccText内の同じmatchをすべて置換してしまうため、結果として求める形が得られる
                            if Regex.contains hashInMarkdownLinkPattern accText then
                                accText

                            else
                                String.replace match ("[#" ++ String.dropLeft 1 match ++ "](https://twitter.com/hashtag/" ++ String.dropLeft 1 match ++ ")") accText
                        )
                        tcoUrlsExpandedText
           )
        |> Markdown.render


tcoUrlInTweetRegex : Regex
tcoUrlInTweetRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://t.co/[a-zA-Z0-9]+")


mentionRegex : Regex
mentionRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...,@mention`のようなURLがあると誤認識する。が、制限事項とする
    -- 少なくともauthority partに@を含む認証可能URL（URL内に@を含むパターンとして第一にありがちなやつ）などはカンマが先行しないはず
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|\\s|,)@[a-zA-Z0-9_]+")


hashtagRegex : Regex
hashtagRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...?foo,bar,#hashtag`のようなURLがあると誤認識する。が、制限事項とする
    -- このRegexはdeny-list方式で、hashtagに使用できない文字列をひたすら列挙している。ASCII記号としては`_`以外すべての記号を除外。
    -- その他、Unicodeの記号系文字列も可能な範囲で弾いている
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|\\s|,)(#|＃)[^\\s!-/:-@\\[-\\^`{-~＠＃「」（）…]+")


appendMediaGrid : { a | id : TwitterStatusId, extendedEntitiesMedia : List Media } -> List (Html msg) -> List (Html msg)
appendMediaGrid status htmls =
    case status.extendedEntitiesMedia of
        [] ->
            htmls

        nonEmpty ->
            let
                -- Show media based on type: "photo" | "video" | "animated_gif"
                aMedia media =
                    case media.type_ of
                        "photo" ->
                            a [ target "_blank", href media.expandedUrl ] [ imgLazy [ src media.sourceUrl ] [] ]

                        "video" ->
                            -- Looks like expanded_url is a thumbnail in simple Media object
                            a [ target "_blank", href media.expandedUrl ] [ figure [ class "video-thumbnail" ] [ imgLazy [ src media.sourceUrl ] [] ] ]

                        "animated_gif" ->
                            a [ target "_blank", href media.expandedUrl ] [ imgLazy [ src media.sourceUrl ] [] ]

                        _ ->
                            text ""
            in
            htmls ++ [ div [ class "media-grid" ] <| List.map aMedia nonEmpty ]
