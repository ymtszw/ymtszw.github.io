module Page.Twilogs exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Date
import Dict
import Head
import Head.Seo as Seo
import Html exposing (..)
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared exposing (RataDie, Twilog, seoBase)
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
head static =
    Seo.summaryLarge seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Twilog"
    , body =
        -- Dict.foldr over dailyTwilogs (dict by RataDie keys), producing list of twilogs up to 30 recent days
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
        [ h2 [] [ text (Date.format "yyyy/MM/dd (E)" (Date.fromRataDie rataDie)) ]
        , twilogs
            |> List.map
                (\twilog ->
                    p [] [ text twilog.text ]
                )
            |> div []
        ]
