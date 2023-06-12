module Page.Articles.Draft exposing
    ( ActionData
    , Data
    , Model
    , Msg
    , RouteParams
    , page
    )

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import Dict
import Head
import Helper
import Html
import Http
import Iso8601
import Json.Decode
import OptimizedDecoder
import Page
import Page.Articles.ArticleId_ exposing (ExternalView, HtmlOrMarkdown(..), cmsArticleBodyDecoder, renderArticle)
import Pages.PageUrl
import QueryParams
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
    { microCmsApiKey : String
    , amazonAssociateTag : String
    }


type alias ActionData =
    {}


page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildWithSharedState
            { init = init
            , update = update
            , subscriptions = \_ _ _ _ _ -> Sub.none
            , view = view
            }


data : DataSource Data
data =
    DataSource.map2 Data
        (DataSource.Env.load "MICROCMS_API_KEY")
        (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")


head : Page.StaticPayload Data RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


init : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Page.StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init maybeUrl _ _ =
    let
        withPageUrl fun =
            Maybe.andThen .query maybeUrl
                |> Maybe.andThen
                    (\query ->
                        QueryParams.parse getContentIdAndDraftKey query
                            |> Result.toMaybe
                    )
                |> Maybe.map fun
                |> Maybe.withDefault ( empty, Cmd.none )

        getContentIdAndDraftKey =
            QueryParams.succeed DraftKeys
                |> andMap (QueryParams.string "contentId")
                |> andMap (QueryParams.string "draftKey")

        andMap =
            QueryParams.map2 (|>)
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


update : Pages.PageUrl.PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> Page.StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ shared app msg m =
    case msg of
        Req_Draft ->
            ( m, getDraft app.data.microCmsApiKey m.keys, Nothing )

        Res_Draft (Ok contents) ->
            ( { m | contents = contents }
            , if m.polling then
                Helper.waitMsg (pollingIntervalSeconds * 1000) Req_Draft

              else
                Cmd.none
            , case List.filter (\newLink -> not (List.member newLink (Dict.keys shared.links))) contents.body.links of
                [] ->
                    Nothing

                nonEmpty ->
                    Just (Shared.SharedMsg (Shared.Req_LinkPreview app.data.amazonAssociateTag nonEmpty))
            )

        Res_Draft (Err _) ->
            ( { m | polling = False }, Cmd.none, Nothing )


pollingIntervalSeconds =
    3


getDraft : String -> DraftKeys -> Cmd Msg
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
        |> Json.Decode.andThen (\cont -> OptimizedDecoder.decoder (cmsArticleBodyDecoder cont))


view : Maybe Pages.PageUrl.PageUrl -> Shared.Model -> Model -> Page.StaticPayload Data RouteParams -> View.View Msg
view _ shared m _ =
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
