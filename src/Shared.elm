module Shared exposing (Data, Model, Msg(..), SharedMsg(..), Viewport, template, viewportDecoder)

import BackendTask exposing (BackendTask)
import Browser.Dom
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Helper exposing (makeTitle, nonEmptyString)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode
import LinkPreview
import Maybe.Extra
import Pages
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Task
import TwilogData
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type alias Data =
    { twilogArchives : List TwilogArchiveYearMonth }



-----------------
-- SHARED MODEL & INIT
-----------------


type alias Model =
    { links : Dict String LinkPreview.Metadata
    , lightbox : Maybe View.LightboxMedia
    , storedLibraryKey : Maybe String
    , initialViewport : Viewport
    , queryParams : Dict String (List String)
    , fragment : Maybe String
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybeUrl =
    let
        model =
            { links = Dict.empty
            , lightbox = Nothing
            , storedLibraryKey = decodeStoredLibraryKey flags
            , initialViewport = decodeInitialViewport flags
            , queryParams = maybeUrl |> Maybe.andThen .pageUrl |> Maybe.map .query |> Maybe.withDefault Dict.empty
            , fragment = maybeUrl |> Maybe.andThen .pageUrl |> Maybe.andThen .fragment
            }
    in
    case Maybe.andThen (\url -> initLightBox url.path) maybeUrl of
        (Just _) as lbMedia ->
            ( { model | lightbox = lbMedia }, lockScrollPosition )

        Nothing ->
            ( model, Effect.none )


initLightBox : { path : UrlPath, query : Maybe String, fragment : Maybe String } -> Maybe View.LightboxMedia
initLightBox location =
    Maybe.andThen (\fr -> View.parseLightboxFragment location fr) location.fragment


decodeStoredLibraryKey flags =
    case flags of
        Pages.Flags.PreRenderFlags ->
            Nothing

        Pages.Flags.BrowserFlags v ->
            Json.Decode.decodeValue (Json.Decode.field "libraryKey" nonEmptyString) v
                |> Result.toMaybe


decodeInitialViewport flags =
    let
        fallback =
            -- 富豪的に、ちょっと大きめのスクリーンをfallbackとして仮定する
            { height = 1500, top = 0, bottom = 0 }
    in
    case flags of
        Pages.Flags.PreRenderFlags ->
            fallback

        Pages.Flags.BrowserFlags v ->
            Json.Decode.decodeValue (Json.Decode.field "viewport" viewportDecoder) v
                |> Result.withDefault fallback


type alias Viewport =
    { height : Float, top : Float, bottom : Float }


viewportDecoder : Json.Decode.Decoder Viewport
viewportDecoder =
    Json.Decode.map3 Viewport
        (Json.Decode.field "viewportHeight" Json.Decode.float)
        (Json.Decode.field "viewportTop" Json.Decode.float)
        (Json.Decode.field "viewportBottom" Json.Decode.float)



-----------------
-- SHARED UPDATE
-----------------


type Msg
    = OnPageChange
        { path : UrlPath
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type SharedMsg
    = NoOp
    | Req_LinkPreview String (List String)
    | Res_LinkPreview String (List String) (Result String ( String, LinkPreview.Metadata ))
    | ScrollToTop
    | ScrollToBottom
    | CloseLightbox
      --| v3ではclient-sideでquery parameter/fragmentを使ったroutingが今のところできない。SharedMsgで擬似的にworkaroundする
    | PushQueryParam String String
    | PushFragment String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        OnPageChange req ->
            case initLightBox req of
                (Just _) as lbMedia ->
                    ( { model | lightbox = lbMedia, queryParams = parseQuery req }, Effect.batch [ lockScrollPosition, triggerHighlightJs ] )

                Nothing ->
                    ( { model | queryParams = parseQuery req }, triggerHighlightJs )

        SharedMsg (Req_LinkPreview amazonAssociateTag (url :: urls)) ->
            ( model, requestLinkPreviewSequentially amazonAssociateTag urls url )

        SharedMsg (Res_LinkPreview amazonAssociateTag remainingUrls result) ->
            ( case result of
                Ok ( url, metadata ) ->
                    { model | links = Dict.insert url metadata model.links }

                Err _ ->
                    model
            , case remainingUrls of
                [] ->
                    Effect.none

                url :: urls ->
                    requestLinkPreviewSequentially amazonAssociateTag urls url
            )

        SharedMsg ScrollToTop ->
            ( model, Browser.Dom.setViewport 0 0 |> Task.perform (always NoOp) |> Cmd.map SharedMsg |> Effect.fromCmd )

        SharedMsg ScrollToBottom ->
            ( model
            , Browser.Dom.getViewport
                |> Task.andThen (\viewport -> Browser.Dom.setViewport 0 viewport.scene.height)
                |> Task.perform (always NoOp)
                |> Cmd.map SharedMsg
                |> Effect.fromCmd
            )

        SharedMsg CloseLightbox ->
            ( { model | lightbox = Nothing }, clearLightboxLink model )

        SharedMsg (PushQueryParam key value) ->
            ( { model | queryParams = Dict.insert key [ value ] model.queryParams }, Effect.none )

        SharedMsg (PushFragment value) ->
            ( { model | fragment = Just value }, Effect.none )

        SharedMsg _ ->
            ( model, Effect.none )


parseQuery : { a | query : Maybe String } -> Dict String (List String)
parseQuery req =
    req.query
        |> Maybe.withDefault ""
        |> Pages.PageUrl.parseQueryParams


{-| Viewportを現在と全く同じ位置に明示的にセットする

URL Fragment経由でLightboxオープンの命令が来たとき、ブラウザデフォルト挙動によって、
文書内にFragmentと合致するidをもつ要素がなかった場合は文書先頭にスクロールされてしまう。

このCmdでそれを抑制する（次回描画フレームでgetViewportとsetViewportが走るので、
ブラウザデフォルト挙動を上書きするような動作が達成できる。）

-}
lockScrollPosition : Effect Msg
lockScrollPosition =
    Browser.Dom.getViewport
        |> Task.andThen (\vp -> Browser.Dom.setViewport vp.viewport.x vp.viewport.y)
        |> Task.perform (always NoOp)
        |> Cmd.map SharedMsg
        |> Effect.fromCmd


triggerHighlightJs : Effect msg
triggerHighlightJs =
    Json.Encode.object [ ( "tag", Json.Encode.string "TriggerHighlightJs" ) ]
        |> Effect.runtimePortsToJs


{-| Runtimeにリンクプレビューを要求する。

特にTwilogなど、大量のリンクをビルド時にプレビューするのは時間がかかるので、
ビルド時にプレビューを事前生成したい要求が強いページ以外は基本的にruntimeに寄せる。

-}
requestLinkPreviewSequentially : String -> List String -> String -> Effect Msg
requestLinkPreviewSequentially amazonAssociateTag urls url =
    url
        |> LinkPreview.getMetadataOnDemand amazonAssociateTag
        |> Task.attempt (Res_LinkPreview amazonAssociateTag urls)
        |> Cmd.map SharedMsg
        |> Effect.fromCmd


clearLightboxLink : Model -> Effect msg
clearLightboxLink m =
    case m.lightbox of
        Just lbMedia ->
            let
                internalUrl =
                    UrlPath.toAbsolute lbMedia.originReq.path ++ Maybe.Extra.unwrap "" ((++) "?") lbMedia.originReq.query
            in
            Effect.replaceUrl internalUrl

        Nothing ->
            Effect.none


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.map Data
        TwilogData.twilogArchives


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view _ page shared sharedTagger pageView =
    { title = makeTitle pageView.title
    , body =
        [ Html.header []
            [ Html.nav [] <|
                List.intersperse (Html.text " / ") <|
                    List.map (\kid -> Html.strong [] [ kid ]) <|
                        case Maybe.withDefault Route.Index page.route of
                            Route.About ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "このサイトについて"
                                ]

                            Route.Articles ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "記事"
                                ]

                            Route.Articles__ArticleId_ _ ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Route.Articles |> Route.link [] [ Html.text "記事" ]
                                ]

                            Route.Articles__Draft ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "記事（下書き）"
                                ]

                            Route.Library ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "書架"
                                ]

                            Route.Reviews__Draft ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "レビュー（下書き）"
                                ]

                            Route.Twilogs ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "Twilog"
                                ]

                            Route.Twilogs__YearMonth_ { yearMonth } ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Route.Twilogs |> Route.link [] [ Html.text "Twilog" ]
                                , Html.text yearMonth
                                ]

                            Route.ServerTest ->
                                [ Route.Index |> Route.link [] [ Html.text "Index" ]
                                , Html.text "Server Test"
                                ]

                            Route.Index ->
                                [ Html.text "Index"
                                ]
            , sitemap
            , Html.nav [ Html.Attributes.class "meta" ]
                [ siteBuildStatus
                , twitterLink
                ]
            ]
        , Html.hr [] []
        , Html.main_ [] pageView.body
        , Html.hr [] []
        , Html.footer []
            [ Html.text "© Yu Matsuzawa (ymtszw, Gada), 2022 "
            , sitemap
            , Html.nav [ Html.Attributes.class "meta" ]
                [ siteBuildStatus
                , twitterLink
                , siteBuiltAt
                ]
            , Html.map (SharedMsg >> sharedTagger) scrollButtons
            ]
        , case shared.lightbox of
            Just lbMedia ->
                Html.map (SharedMsg >> sharedTagger) (lightbox lbMedia)

            Nothing ->
                Html.text ""
        ]
    }


siteBuiltAt =
    Html.small [] [ Html.text (Helper.formatPosix Pages.builtAt) ]


siteBuildStatus =
    Html.a [ Html.Attributes.href "https://github.com/ymtszw/ymtszw.github.io/actions", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ View.imgLazy
            [ Html.Attributes.src "https://github.com/ymtszw/ymtszw.github.io/actions/workflows/build-test-deploy.yml/badge.svg"
            , Html.Attributes.alt "Build status badge of the site"
            , Html.Attributes.height 20
            , Html.Attributes.width 152
            ]
            []
        ]


twitterLink =
    Html.a [ Html.Attributes.href "https://twitter.com/gada_twt", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ View.imgLazy
            [ Html.Attributes.src "https://img.shields.io/twitter/follow/gada_twt.svg?style=social"
            , Html.Attributes.alt "Twitter: gada_twt"
            , Html.Attributes.height 20
            , Html.Attributes.width 123
            ]
            []
        ]


sitemap =
    Html.nav [] <|
        List.intersperse (Html.text " | ")
            [ Html.text ""
            , Route.About |> Route.link [] [ Html.text "このサイトについて" ]
            , Route.Twilogs |> Route.link [] [ Html.text "Twilog" ]
            , Route.Articles |> Route.link [] [ Html.text "記事" ]
            , Route.Library |> Route.link [] [ Html.text "書架" ]
            , Html.text ""
            ]


scrollButtons =
    Html.nav [ Html.Attributes.class "scroll-buttons" ]
        [ Html.button [ Html.Events.onClick ScrollToTop ] [ Html.text "▲" ]
        , Html.button [ Html.Events.onClick ScrollToBottom ] [ Html.text "▼" ]
        ]


lightbox : View.LightboxMedia -> Html.Html SharedMsg
lightbox lbMedia =
    Html.div
        [ Html.Attributes.class "lightbox"
        , Html.Events.onClick CloseLightbox
        ]
        [ Html.a
            [ Html.Attributes.href lbMedia.href
            , Html.Attributes.target "_blank"
            , Html.Attributes.rel "noopener noreferrer"
            , Html.Attributes.class "has-image"
            , Html.Events.stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True ))
            ]
            [ if lbMedia.type_ == "video" || lbMedia.type_ == "animated_gif" then
                Html.figure [ Html.Attributes.class "video-thumbnail" ]
                    [ View.imgLazy [ Html.Attributes.src lbMedia.src ] [] ]

              else
                View.imgLazy [ Html.Attributes.src lbMedia.src ] []
            ]
        ]
