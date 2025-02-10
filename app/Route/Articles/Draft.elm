module Route.Articles.Draft exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , route
    )

import BackendTask exposing (BackendTask)
import CmsData
import Dict
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Helper exposing (decodeWith, requireEnv, unixOrigin)
import Html
import Http
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Pages
import PagesMsg exposing (PagesMsg)
import Route.Articles.ArticleId_ exposing (cmsArticleBodyDecoder, renderArticle)
import RouteBuilder exposing (App)
import Shared
import Time
import View


type alias Model =
    { keys : DraftKeys
    , contents : CmsData.CmsArticle
    , polling : Bool
    }


type alias DraftKeys =
    { contentId : String
    , draftKey : String
    }


type alias RouteParams =
    {}


type alias Data =
    { microCmsApiKey : String
    , amazonAssociateTag : String
    }


type alias ActionData =
    {}


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
    BackendTask.map2 Data
        (requireEnv "MICROCMS_API_KEY")
        (requireEnv "AMAZON_ASSOCIATE_TAG")


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ shared =
    let
        withPageUrl fun =
            getContentIdAndDraftKey
                |> Maybe.map fun
                |> Maybe.withDefault ( empty, Effect.none )

        getContentIdAndDraftKey =
            Maybe.map2 DraftKeys
                (qp "contentId")
                (qp "draftKey")

        qp key =
            shared.queryParams |> Dict.get key |> Maybe.andThen List.head
    in
    withPageUrl <|
        \keys ->
            ( { empty | keys = keys, polling = True }
            , Helper.initMsg Req_Draft
            )


empty : Model
empty =
    { keys = { contentId = "MISSING", draftKey = "MISSING" }
    , contents =
        { meta =
            { contentId = "MISSING"
            , title = ""
            , image = Nothing
            , published = False
            , publishedAt = unixOrigin
            , revisedAt = unixOrigin
            , source = CmsData.MicroCms
            }
        , body = { parsed = CmsData.Html [], excerpt = "", links = [] }
        , type_ = "unknown"
        }
    , polling = False
    }


type Msg
    = Req_Draft
    | Res_Draft (Result Http.Error CmsData.CmsArticle)


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg m =
    case msg of
        Req_Draft ->
            ( m, getDraft app.data.microCmsApiKey m.keys, Nothing )

        Res_Draft (Ok contents) ->
            ( { m | contents = contents }
            , if m.polling then
                Helper.waitMsg (pollingIntervalSeconds * 1000) Req_Draft

              else
                Effect.none
            , case List.filter (\newLink -> not (List.member newLink (Dict.keys shared.links))) contents.body.links of
                [] ->
                    Nothing

                nonEmpty ->
                    Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag nonEmpty))
            )

        Res_Draft (Err _) ->
            ( { m | polling = False }, Effect.none, Nothing )


pollingIntervalSeconds =
    3


getDraft : String -> DraftKeys -> Effect Msg
getDraft microCmsApiKey keys =
    Http.request
        { method = "GET"
        , url = "https://ymtszw.microcms.io/api/v1/articles/" ++ keys.contentId ++ "?draftKey=" ++ keys.draftKey
        , headers = [ Http.header "X-MICROCMS-API-KEY" microCmsApiKey ]
        , body = Http.emptyBody
        , expect = Http.expectJson Res_Draft draftDecoder
        , timeout = Just 5000
        , tracker = Nothing
        }
        |> Effect.fromCmd


draftDecoder : Decode.Decoder CmsData.CmsArticle
draftDecoder =
    draftMetadataDecoder
        |> Decode.map CmsData.CmsArticle
        |> Decode.andThen cmsArticleBodyDecoder


draftMetadataDecoder =
    decodeWith CmsData.cmsArticlePublishedAtDecoder <|
        \publishedAt ->
            Decode.succeed CmsData.CmsArticleMetadata
                |> Decode.andMap (Decode.field "id" Decode.string)
                |> Decode.andMap (Decode.succeed (Time.posixToMillis publishedAt <= Time.posixToMillis Pages.builtAt))
                |> Decode.andMap (Decode.succeed publishedAt)
                |> Decode.andMap (Decode.field "revisedAt" Iso8601.decoder |> Decode.withDefault publishedAt)
                |> Decode.andMap (Decode.field "title" Decode.string)
                |> Decode.andMap (Decode.maybe (Decode.field "image" CmsData.cmsImageDecoder))
                |> Decode.andMap (Decode.succeed CmsData.MicroCms)


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View.View (PagesMsg Msg)
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
                , Html.tr [] [ Html.th [] [ Html.text "Title" ], Html.td [] [ Html.text m.contents.meta.title ] ]
                , Html.tr [] [ Html.th [] [ Html.text "Excerpt" ], Html.td [] [ Html.text m.contents.body.excerpt ] ]
                ]
            ]
        , Html.hr [] []
        , renderArticle shared.links m.contents
        ]
    }
