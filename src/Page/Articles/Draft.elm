module Page.Articles.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Head.Seo as Seo
import Html
import Html.Parser
import Html.Parser.Util
import Http
import Json.Decode
import Markdown
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import QueryParams
import Shared exposing (seoBase)
import View exposing (View)


type alias Model =
    { keys : DraftKeys
    , contents : DraftContents
    }


type alias DraftKeys =
    { contentId : String
    , draftKey : String
    , microCmsApiKey : String
    }


type alias DraftContents =
    { type_ : String
    , body : List (Html.Html Msg)
    }


type Msg
    = Res_getDraft (Result Http.Error DraftContents)


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
        empty =
            { keys = { contentId = "MISSING", draftKey = "MISSING", microCmsApiKey = "MISSING" }, contents = { type_ = "unknown", body = [] } }

        withPageUrl fun =
            Maybe.andThen .query maybeUrl
                |> Maybe.andThen getContentIdAndDraftKey
                |> Maybe.map fun
                |> Maybe.withDefault ( empty, Cmd.none )

        getContentIdAndDraftKey query =
            QueryParams.parse queryParser query
                |> Result.toMaybe

        queryParser =
            QueryParams.succeed DraftKeys
                |> andMap (QueryParams.string "contentId")
                |> andMap (QueryParams.string "draftKey")
                |> andMap (QueryParams.string "microCmsApiKey")

        andMap =
            QueryParams.map2 (|>)
    in
    withPageUrl <| \keys -> ( { empty | keys = keys }, getDraft keys )


getDraft keys =
    Http.request
        { method = "GET"
        , url = "https://ymtszw.microcms.io/api/v1/articles/" ++ keys.contentId ++ "?draftKey=" ++ keys.draftKey
        , headers = [ Http.header "X-MICROCMS-API-KEY" keys.microCmsApiKey ]
        , body = Http.emptyBody
        , expect = Http.expectJson Res_getDraft draftDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


draftDecoder : Json.Decode.Decoder DraftContents
draftDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "html"
            (Json.Decode.string
                |> Json.Decode.andThen
                    (\input ->
                        case Html.Parser.run input of
                            Ok nodes ->
                                Json.Decode.succeed (Html.Parser.Util.toVirtualDom nodes)

                            Err e ->
                                Json.Decode.fail (Markdown.deadEndsToString e)
                    )
                |> Json.Decode.map (DraftContents "html")
            )
        , Json.Decode.field "markdown"
            (Json.Decode.string
                |> Json.Decode.andThen
                    (\input ->
                        case Markdown.render input of
                            Ok html ->
                                Json.Decode.succeed html

                            Err e ->
                                Json.Decode.fail e
                    )
                |> Json.Decode.map (DraftContents "markdown")
            )
        ]


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg )
update pageUrl navKey {} _ msg m =
    case msg of
        Res_getDraft (Ok contents) ->
            ( { m | contents = contents }, Cmd.none )

        Res_getDraft (Err e) ->
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
            [ Html.thead []
                [ Html.tr []
                    [ Html.th [] [ Html.text "Content ID" ]
                    , Html.th [] [ Html.text "Draft Key" ]
                    , Html.th [] [ Html.text "Type" ]
                    ]
                ]
            , Html.tbody []
                [ Html.tr []
                    [ Html.td [] [ Html.text m.keys.contentId ]
                    , Html.td [] [ Html.text m.keys.draftKey ]
                    , Html.td [] [ Html.text m.contents.type_ ]
                    ]
                ]
            ]
        , Html.hr [] []
        , Html.article [] m.contents.body
        ]
    }
