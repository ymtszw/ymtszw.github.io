module Page.Articles.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Html
import Http
import Iso8601
import Json.Decode
import OptimizedDecoder
import Page exposing (PageWithState, StaticPayload)
import Page.Articles.ArticleId_ exposing (Body, cmsArticleBodyDecoder, renderArticle)
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import QueryParams
import Shared exposing (unixOrigin)
import Time
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
    { createdAt : Time.Posix
    , updatedAt : Time.Posix
    , title : String
    , image : Maybe Shared.CmsImage
    , body : Body Msg
    , type_ : String
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
init maybeUrl _ _ =
    let
        empty =
            { keys = { contentId = "MISSING", draftKey = "MISSING", microCmsApiKey = "MISSING" }
            , contents =
                { createdAt = unixOrigin
                , updatedAt = unixOrigin
                , title = ""
                , image = Nothing
                , body = { html = [], excerpt = "" }
                , type_ = "unknown"
                }
            }

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
    let
        andMap =
            Json.Decode.map2 (|>)
    in
    Json.Decode.succeed DraftContents
        |> andMap (Json.Decode.field "createdAt" Iso8601.decoder)
        |> andMap (Json.Decode.field "updatedAt" Iso8601.decoder)
        |> andMap (Json.Decode.field "title" Json.Decode.string)
        |> andMap (Json.Decode.maybe (Json.Decode.field "image" (OptimizedDecoder.decoder Shared.cmsImageDecoder)))
        |> Json.Decode.andThen (cmsArticleBodyDecoder >> OptimizedDecoder.decoder)


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg )
update _ _ _ _ msg m =
    case msg of
        Res_getDraft (Ok contents) ->
            ( { m | contents = contents }, Cmd.none )

        Res_getDraft (Err _) ->
            ( m, Cmd.none )


subscriptions : Maybe PageUrl -> RouteParams -> Path -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


data : DataSource Data
data =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


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
            [ Html.tbody []
                [ Html.tr [] [ Html.th [] [ Html.text "Content ID" ], Html.td [] [ Html.text m.keys.contentId ] ]
                , Html.tr [] [ Html.th [] [ Html.text "Type" ], Html.td [] [ Html.text m.contents.type_ ] ]
                , Html.tr [] [ Html.th [] [ Html.text "Title" ], Html.td [] [ Html.text m.contents.title ] ]
                , Html.tr [] [ Html.th [] [ Html.text "Excerpt" ], Html.td [] [ Html.text m.contents.body.excerpt ] ]
                , Html.tr [] [ Html.th [] [ Html.text "CreatedAt" ], Html.td [] [ Html.text (Shared.formatPosix m.contents.createdAt) ] ]
                , Html.tr [] [ Html.th [] [ Html.text "UpdatedAt" ], Html.td [] [ Html.text (Shared.formatPosix m.contents.updatedAt) ] ]
                ]
            ]
        , Html.hr [] []
        , renderArticle m.contents
        ]
    }
