module Page.Twilogs exposing (Data, Model, Msg, page, showTwilogsUpToDays, twilogDailyExcerpt, twilogsOfTheDay)

import DataSource exposing (DataSource)
import Date
import Dict exposing (Dict)
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (alt, class, href, src, target)
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Regex exposing (Regex)
import Route
import Shared exposing (Media, Quote, RataDie, Reply(..), Twilog, TwitterStatusId(..), seoBase)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


type alias Data =
    ()


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summaryLarge seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ static =
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
            ++ showTwilogsUpToDays 31 static.sharedData.dailyTwilogs
    }


showTwilogsUpToDays : Int -> Dict RataDie (List Twilog) -> List (Html msg)
showTwilogsUpToDays days dailyTwilogs =
    dailyTwilogs
        |> Dict.foldr
            (\rataDie twilogs acc ->
                if List.length acc < days then
                    twilogDailyExcerpt rataDie twilogs :: acc

                else
                    acc
            )
            []
        |> List.reverse


twilogDailyExcerpt : RataDie -> List Twilog -> Html msg
twilogDailyExcerpt rataDie twilogs =
    let
        date =
            Date.fromRataDie rataDie
    in
    section []
        [ h3 [] [ Route.link (Route.Twilogs__Day_ { day = Date.toIsoString date }) [] [ text (Date.format "yyyy/MM/dd (E)" date) ] ]
        , twilogsOfTheDay twilogs
        ]


twilogsOfTheDay : List Twilog -> Html msg
twilogsOfTheDay twilogs =
    twilogs
        -- Order reversed in index page; newest first
        |> List.reverse
        |> List.map threadAwareTwilogs
        |> div []


threadAwareTwilogs : Twilog -> Html msg
threadAwareTwilogs twilog =
    case twilog.replies of
        [] ->
            aTwilog twilog

        threads ->
            let
                recursivelyRenderThreadedTwilogs (Reply twilogInThread) =
                    [ div [ class "reply" ] <|
                        case twilogInThread.replies of
                            [] ->
                                [ aTwilog twilogInThread ]

                            more ->
                                aTwilog twilogInThread :: List.concatMap recursivelyRenderThreadedTwilogs more
                    ]
            in
            div [ class "thread" ] <| aTwilog twilog :: List.concatMap recursivelyRenderThreadedTwilogs threads


aTwilog : Twilog -> Html msg
aTwilog twilog =
    div [ class "tweet" ] <|
        case twilog.retweet of
            Just retweet ->
                [ a [ class "retweet-label", target "_blank", href (statusLink twilog) ] [ text (twilog.userName ++ " retweeted") ]
                , a [ target "_blank", href (statusLink retweet) ]
                    [ header []
                        [ img [ alt ("Avatar of " ++ retweet.userName), src retweet.userProfileImageUrl ] []
                        , strong [] [ text retweet.userName ]
                        ]
                    ]
                , retweet.fullText
                    |> removeQuoteUrl retweet.quote
                    |> removeMediaUrls retweet.extendedEntitiesMedia
                    |> removeMediaUrls twilog.extendedEntitiesMedia
                    |> autoLinkedMarkdown
                    |> appendQuote retweet.quote
                    |> div [ class "body" ]
                , case retweet.extendedEntitiesMedia of
                    [] ->
                        mediaGrid twilog

                    _ ->
                        mediaGrid retweet
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
                        [ img [ alt ("Avatar of " ++ twilog.userName), src twilog.userProfileImageUrl ] []
                        , strong [] [ text twilog.userName ]
                        ]
                    ]
                , twilog.text
                    |> removeQuoteUrl twilog.quote
                    |> removeMediaUrls twilog.extendedEntitiesMedia
                    |> autoLinkedMarkdown
                    |> appendQuote twilog.quote
                    |> div [ class "body" ]
                , mediaGrid twilog
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


appendQuote : Maybe Quote -> List (Html msg) -> List (Html msg)
appendQuote maybeQuote htmls =
    case maybeQuote of
        Just quote ->
            htmls
                ++ [ div [ class "tweet" ]
                        [ a [ target "_blank", href (statusLink quote) ]
                            [ header []
                                [ img [ alt ("Avatar of " ++ quote.userName), src quote.userProfileImageUrl ] []
                                , strong [] [ text quote.userName ]
                                ]
                            ]
                        , div [ class "body" ] (autoLinkedMarkdown quote.fullText)
                        ]
                   ]

        Nothing ->
            htmls


autoLinkedMarkdown : String -> List (Html msg)
autoLinkedMarkdown rawText =
    rawText
        |> Regex.replace urlInTweetRegex (\{ match } -> "<" ++ match ++ ">")
        |> Regex.replace mentionRegex (\{ match } -> "[@" ++ String.dropLeft 1 match ++ "](https://twitter.com/" ++ String.dropLeft 1 match ++ ")")
        |> Regex.replace hashtagRegex (\{ match } -> "[#" ++ String.dropLeft 1 match ++ "](https://twitter.com/hashtag/" ++ String.dropLeft 1 match ++ ")")
        |> Markdown.render


urlInTweetRegex : Regex
urlInTweetRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://t.co/[a-zA-Z0-9]+")


mentionRegex : Regex
mentionRegex =
    Maybe.withDefault Regex.never (Regex.fromString "(@|＠)[a-zA-Z0-9_]+")


hashtagRegex : Regex
hashtagRegex =
    Maybe.withDefault Regex.never (Regex.fromString "(#|＃)[^- ]+")


mediaGrid : { a | id : TwitterStatusId, extendedEntitiesMedia : List Media } -> Html msg
mediaGrid status =
    case status.extendedEntitiesMedia of
        [] ->
            text ""

        nonEmpty ->
            let
                -- Show media based on type: "photo" | "video" | "animated_gif"
                aMedia media =
                    case media.type_ of
                        "photo" ->
                            a [ target "_blank", href media.expandedUrl ] [ img [ src media.sourceUrl ] [] ]

                        "video" ->
                            -- Looks like expanded_url is a thumbnail in simple Media object
                            a [ target "_blank", href media.expandedUrl ] [ figure [ class "video-thumbnail" ] [ img [ src media.sourceUrl ] [] ] ]

                        "animated_gif" ->
                            a [ target "_blank", href media.expandedUrl ] [ img [ src media.sourceUrl ] [] ]

                        _ ->
                            text ""
            in
            div [ class "media-grid" ] <| List.map aMedia nonEmpty
