module Route.Articles.Draft exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import Dict
import Effect
import FatalError exposing (FatalError)
import Head
import Html
import Http
import Iso8601
import Json.Decode
import PagesMsg
import Route.Articles.ArticleId_ exposing (ExternalView, HtmlOrMarkdown(..), cmsArticleBodyDecoder, renderArticle)
import RouteBuilder
import Shared exposing (unixOrigin)
import Time
import View


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
    , body : ExternalView
    , type_ : String
    }


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildWithSharedState
            { init = init
            , update = update
            , subscriptions = \_ _ _ _ -> Sub.none
            , view = view
            }


data : BackendTask FatalError Data
data =
    BackendTask.succeed {}


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app _ =
    let
        withPageUrl fun =
            Maybe.map .query app.url
                |> Maybe.andThen getContentIdAndDraftKey
                |> Maybe.map fun
                |> Maybe.withDefault ( empty, Effect.none )

        getContentIdAndDraftKey query =
            Maybe.map3 DraftKeys
                (singleString "contentId" query)
                (singleString "draftKey" query)
                (singleString "microCmsApiKey" query)

        singleString key =
            Dict.get key >> Maybe.andThen List.head
    in
    withPageUrl <|
        \keys ->
            ( { empty | keys = keys, polling = True }
            , Effect.init Req_Draft
            )


empty : Model
empty =
    { keys = { contentId = "MISSING", draftKey = "MISSING", microCmsApiKey = "MISSING" }
    , contents =
        { createdAt = unixOrigin
        , updatedAt = unixOrigin
        , title = ""
        , image = Nothing
        , body = { parsed = Html [], excerpt = "", links = [] }
        , type_ = "unknown"
        }
    , polling = False
    }


type Msg
    = Req_Draft
    | Res_Draft (Result Http.Error DraftContents)


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg, Maybe Shared.Msg )
update _ shared msg m =
    case msg of
        Req_Draft ->
            ( m, getDraft m.keys, Nothing )

        Res_Draft (Ok contents) ->
            ( { m | contents = contents }
            , if m.polling then
                Effect.wait (pollingIntervalSeconds * 1000) Req_Draft

              else
                Effect.none
            , case List.filter (\newLink -> not (List.member newLink (Dict.keys shared.links))) contents.body.links of
                [] ->
                    Nothing

                nonEmpty ->
                    Just (Shared.SharedMsg (Shared.Req_LinkPreview nonEmpty))
            )

        Res_Draft (Err _) ->
            ( { m | polling = False }, Effect.none, Nothing )


pollingIntervalSeconds =
    3


getDraft : DraftKeys -> Effect.Effect Msg
getDraft keys =
    Http.request
        { method = "GET"
        , url = "https://ymtszw.microcms.io/api/v1/articles/" ++ keys.contentId ++ "?draftKey=" ++ keys.draftKey
        , headers = [ Http.header "X-MICROCMS-API-KEY" keys.microCmsApiKey ]
        , body = Http.emptyBody
        , expect = Http.expectJson Res_Draft draftDecoder
        , timeout = Just 10000
        , tracker = Nothing
        }
        |> Effect.fromCmd


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
        |> andMap (Json.Decode.maybe (Json.Decode.field "image" Shared.cmsImageDecoder))
        |> Json.Decode.andThen cmsArticleBodyDecoder


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view _ shared m =
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
        , renderArticle shared.links m.contents
        ]
    }
