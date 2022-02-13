module Page.Articles.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import QueryParams
import Shared exposing (seoBase)
import View exposing (View)


type alias Model =
    { contentId : String
    , draftKey : String
    }


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


page : PageWithState RouteParams Data Model Msg
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithLocalState
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }


init :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> ( Model, Cmd Msg )
init maybeUrl sharedModel static =
    let
        withPageUrl fun =
            Maybe.andThen .query maybeUrl
                |> Maybe.andThen getContentIdAndDraftKey
                |> Maybe.map fun
                |> Maybe.withDefault ( { contentId = "MISSING", draftKey = "MISSING" }, Cmd.none )

        getContentIdAndDraftKey query =
            QueryParams.parse (QueryParams.map2 Tuple.pair (QueryParams.string "contentId") (QueryParams.string "draftKey")) query
                |> Result.toMaybe
    in
    withPageUrl <|
        \( contentId, draftKey ) ->
            ( { contentId = contentId, draftKey = draftKey }, Cmd.none )


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg )
update pageUrl navKey {} _ () m =
    ( m, Cmd.none )


subscriptions : Maybe PageUrl -> RouteParams -> Path -> Model -> Sub Msg
subscriptions maybeUrl routeParams path {} =
    Sub.none


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    Seo.summary seoBase
        |> Seo.website


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ _ m _ =
    { title = "記事（下書き）"
    , body =
        [ Html.table []
            [ Html.tr [] [ Html.th [] [ Html.text "Content ID" ], Html.th [] [ Html.text "Draft Key" ] ]
            , Html.tr [] [ Html.td [] [ Html.text m.contentId ], Html.td [] [ Html.text m.draftKey ] ]
            ]
        ]
    }
