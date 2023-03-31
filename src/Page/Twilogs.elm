module Page.Twilogs exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Date
import Dict
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes exposing (alt, class, href, src, target)
import Markdown
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Regex exposing (Regex)
import Shared exposing (RataDie, Twilog, TwitterStatusId(..), seoBase)
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
        static.sharedData.dailyTwilogs
            |> Dict.foldr
                (\rataDie twilogs acc ->
                    if List.length acc < 31 then
                        twilogDailyExcerpt rataDie twilogs :: acc

                    else
                        acc
                )
                []
            |> List.reverse
    }


twilogDailyExcerpt : RataDie -> List Twilog -> Html msg
twilogDailyExcerpt rataDie twilogs =
    section []
        [ h3 [] [ text (Date.format "yyyy/MM/dd (E)" (Date.fromRataDie rataDie)) ]
        , twilogs
            -- Order reversed in index page
            |> List.reverse
            |> List.map
                (\twilog ->
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
                                , div [] (autoLinkedMarkdown retweet.fullText)
                                , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Shared.formatPosix twilog.createdAt) ] ]
                                ]

                            Nothing ->
                                [ a [ target "_blank", href (statusLink twilog) ]
                                    [ header []
                                        [ img [ alt ("Avatar of " ++ twilog.userName), src twilog.userProfileImageUrl ] []
                                        , strong [] [ text twilog.userName ]
                                        ]
                                    ]
                                , div [] (autoLinkedMarkdown twilog.text)
                                , a [ target "_blank", href (statusLink twilog) ] [ time [] [ text (Shared.formatPosix twilog.createdAt) ] ]
                                ]
                )
            |> div []
        ]


statusLink : { a | id : TwitterStatusId } -> String
statusLink { id } =
    let
        (TwitterStatusId idStr) =
            id
    in
    "https://twitter.com/_/status/" ++ idStr


autoLinkedMarkdown : String -> List (Html msg)
autoLinkedMarkdown rawText =
    rawText
        |> Regex.replace urlInTweetRegex (\{ match } -> "<" ++ match ++ ">")
        |> Regex.replace mentionRegex (\{ match } -> "[" ++ match ++ "](https://twitter.com/" ++ String.dropLeft 1 match ++ ")")
        |> Regex.replace hashtagRegex (\{ match } -> "[" ++ match ++ "](https://twitter.com/hashtag/" ++ String.dropLeft 1 match ++ ")")
        |> Markdown.render


urlInTweetRegex : Regex
urlInTweetRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://t.co/[a-zA-Z0-9]+")


mentionRegex : Regex
mentionRegex =
    Maybe.withDefault Regex.never (Regex.fromString "@[a-zA-Z0-9_]+")


hashtagRegex : Regex
hashtagRegex =
    Maybe.withDefault Regex.never (Regex.fromString "#[^- ]+")
