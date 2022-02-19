module Page.Articles.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import Head
import Html
import Http
import Iso8601
import Json.Decode
import Markdown
import OptimizedDecoder
import Page exposing (PageWithState, StaticPayload)
import Page.Articles.ArticleId_ exposing (cmsArticleBodyDecoder, renderArticle)
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import Process
import QueryParams
import Shared exposing (unixOrigin)
import Task
import Time
import View exposing (View)


type alias Model =
    { keys : DraftKeys
    , contents : DraftContents
    , polling : Bool
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
    , body : Markdown.DecodedBody Msg
    , type_ : String
    }


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
            , polling = False
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
    withPageUrl <| \keys -> ( { empty | keys = keys, polling = True }, Task.attempt Res_getDraft (getDraft keys) )


getDraft keys =
    Http.task
        { method = "GET"
        , url = "https://ymtszw.microcms.io/api/v1/articles/" ++ keys.contentId ++ "?draftKey=" ++ keys.draftKey
        , headers = [ Http.header "X-MICROCMS-API-KEY" keys.microCmsApiKey ]
        , body = Http.emptyBody
        , resolver =
            Http.stringResolver <|
                \resp ->
                    case resp of
                        Http.GoodStatus_ _ body ->
                            Result.mapError Json.Decode.errorToString (Json.Decode.decodeString draftDecoder body)

                        _ ->
                            Err "something erroneous"
        , timeout = Nothing
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


type Msg
    = Res_getDraft (Result String DraftContents)


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
            ( { m | contents = contents }
            , Process.sleep (pollingIntervalSeconds * 1000)
                |> Task.andThen (\_ -> getDraft m.keys)
                |> Task.attempt Res_getDraft
            )

        Res_getDraft (Err _) ->
            ( { m | polling = False }, Cmd.none )


pollingIntervalSeconds : Float
pollingIntervalSeconds =
    3


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
        [ if m.polling then
            Html.text <| "自動更新中（" ++ String.fromFloat pollingIntervalSeconds ++ "秒ごとに更新）"

          else
            Html.text "⛔ 自動更新エラー、またはクエリパラメータ不足"
        , Html.hr [] []
        , Html.table []
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
