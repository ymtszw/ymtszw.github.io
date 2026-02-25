module Route.Reviews.Draft exposing (ActionData, Data, Model, Msg, route)

import BackendTask exposing (BackendTask)
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import Helper exposing (onChange)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import KindleBook exposing (ASIN, KindleBook, allBooksFromAlgolia)
import LinkPreview
import Markdown
import Maybe.Extra
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Task
import Time exposing (Posix)
import View exposing (View)


route : StatefulRoute RouteParams Data ActionData Model Msg
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



-----------------
-- STATIC PART
-----------------


type alias RouteParams =
    {}


type alias Data =
    { kindleBooks : Dict ASIN KindleBook
    , secrets : KindleBook.Secrets
    }


data : BackendTask FatalError Data
data =
    BackendTask.map2 Data
        allBooksFromAlgolia
        KindleBook.secrets


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]


type alias ActionData =
    {}



-----------------
-- DYNAMIC PART
-----------------


type alias Model =
    { book : Maybe KindleBook
    , reviewTitle : String
    , reviewMarkdown : String
    , reviewUpdatedAt : Maybe Posix
    , reviewPublishedAt : Maybe Posix
    , clean : Bool
    }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    case getStaticBook shared.queryParams app.data.kindleBooks of
        Just book ->
            ( bookToModel book
            , KindleBook.getOnDemand Res_refreshKindleBookOnDemand app.data.secrets book.id |> Effect.fromCmd
            )

        Nothing ->
            ( Model Nothing "タイトル" sample Nothing Nothing True, Helper.initMsg RuntimeInit )


bookToModel : KindleBook -> Model
bookToModel book =
    Model (Just book) (Maybe.withDefault "タイトル" book.reviewTitle) (Maybe.withDefault sample book.reviewMarkdown) book.reviewUpdatedAt book.reviewPublishedAt True


getStaticBook : Dict String (List String) -> Dict ASIN KindleBook -> Maybe KindleBook
getStaticBook queryParams books =
    queryParams
        |> Dict.get "id"
        |> Maybe.andThen List.head
        |> Maybe.andThen (\id -> Dict.get id books)


sample =
    """## 心得

- 公開には100字以上が必須
- Markdownが使える
"""


type Msg
    = Res_refreshKindleBookOnDemand (Result String KindleBook)
    | SetReviewTitle String
    | SetReviewMarkdown String
    | Save
    | Publish Bool
      --| HACK v3ではclient sideでquery parameterにアクセスしづらくなり、他ページからの遷移時のinitではquery parameterを使った初期化処理が動かない。
      --| （ページを直接訪問したときには動作する）
      --| 代わりにinitMsgを飛ばしてupdateで再度初期化を試みる。
    | RuntimeInit


update :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg m =
    case msg of
        Res_refreshKindleBookOnDemand (Ok book) ->
            bookToModel book
                |> (\updated ->
                        ( { updated | clean = True }
                        , Effect.none
                        , requestLinkPreview updated.reviewMarkdown
                        )
                   )

        Res_refreshKindleBookOnDemand (Err _) ->
            ( m, Effect.none, Nothing )

        SetReviewTitle s ->
            ( { m | reviewTitle = s, clean = False }, Effect.none, Nothing )

        SetReviewMarkdown s ->
            ( { m | reviewMarkdown = s, clean = False }, Effect.none, requestLinkPreview s )

        Save ->
            ( m
            , modelToBook m
                |> Maybe.Extra.unwrap Effect.none
                    (\book ->
                        putWithTimestamp book
                            |> Task.attempt Res_refreshKindleBookOnDemand
                            |> Effect.fromCmd
                    )
            , Nothing
            )

        Publish publishing ->
            ( m
            , if readyToPublish m then
                case modelToBook m of
                    Just book ->
                        putWithTimestamp book
                            |> Task.map
                                (\updated ->
                                    { updated
                                        | reviewPublishedAt =
                                            if publishing then
                                                updated.reviewUpdatedAt

                                            else
                                                Nothing
                                    }
                                )
                            |> Task.attempt Res_refreshKindleBookOnDemand
                            |> Effect.fromCmd

                    Nothing ->
                        Effect.none

              else
                Effect.none
            , Nothing
            )

        RuntimeInit ->
            case getStaticBook shared.queryParams app.data.kindleBooks of
                Just book ->
                    ( bookToModel book
                    , KindleBook.getOnDemand Res_refreshKindleBookOnDemand app.data.secrets book.id |> Effect.fromCmd
                    , Nothing
                    )

                Nothing ->
                    -- RuntimeInitの無限ループを防ぐため、updateでもbookを解決できなかったら諦める
                    ( Model Nothing "タイトル" sample Nothing Nothing True, Effect.none, Nothing )


requestLinkPreview body =
    body
        |> Markdown.parseAndEnumerateLinks
        |> Shared.Req_LinkPreview
        |> Shared.SharedMsg
        |> Just


readyToPublish m =
    String.length m.reviewTitle >= 1 && String.length m.reviewMarkdown >= 100


modelToBook : Model -> Maybe KindleBook
modelToBook m =
    m.book
        |> Maybe.map
            (\book ->
                { book
                    | reviewTitle = Just m.reviewTitle
                    , reviewMarkdown = Just m.reviewMarkdown
                }
            )


putWithTimestamp book =
    Time.now
        |> Task.andThen
            (\now ->
                -- KindleBook.putOnDemandTask app.data.secrets
                Task.succeed { book | reviewUpdatedAt = Just now }
            )


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View (PagesMsg Msg)
view _ { links } m =
    { title = "レビュー（下書き）"
    , body =
        [ case m.book of
            Just book ->
                renderReview links book m

            Nothing ->
                Html.div [] []
        , reviewEditor m
        ]
    }
        |> View.map PagesMsg.fromMsg


renderReview :
    Dict String LinkPreview.Metadata
    -> KindleBook
    -> Model
    -> Html msg
renderReview links book m =
    let
        timestamp =
            Html.small [] <|
                case m.reviewPublishedAt of
                    Just pa ->
                        Html.text ("公開: " ++ Helper.formatPosix pa)
                            :: (case m.reviewUpdatedAt of
                                    Just ua ->
                                        if ua == pa then
                                            []

                                        else
                                            [ Html.text (" (更新: " ++ Helper.formatPosix ua ++ ")") ]

                                    Nothing ->
                                        []
                               )

                    Nothing ->
                        [ Html.text "未公開" ]
    in
    Html.article [] <|
        let
            optionalVolume =
                if book.volume <= 0 then
                    ""

                else
                    "（" ++ String.fromInt book.volume ++ "）"
        in
        [ Html.h1 [] [ Html.text <| "レビュー：" ++ book.seriesName ++ optionalVolume ]
        , Html.div [] [ timestamp ]
        , bookDetails book
        , Html.h1 [] [ Html.text m.reviewTitle ]
        ]
            ++ Markdown.parseAndRender links m.reviewMarkdown
            ++ [ Html.div [] [ timestamp ]
               , bookDetails book
               ]


bookDetails book =
    blockquote [ class "kindle-book-details" ]
        [ a [ href (Helper.makeAmazonUrl book.id), target "_blank", class "has-image" ]
            [ View.imgLazy [ src book.img, width 150, alt <| book.rawTitle ++ "の書影" ] [] ]
        , div []
            [ h5 [] [ a [ href (Helper.makeAmazonUrl book.id), target "_blank" ] [ text book.rawTitle ] ]
            , ul [] <|
                List.filterMap (Maybe.map (\( key, kids ) -> li [] (strong [] [ text key ] :: text " : " :: kids)))
                    [ Just ( "著者", List.map tag book.authors )
                    , if book.seriesName == book.rawTitle then
                        Nothing

                      else
                        Just ( "シリーズ", [ text book.seriesName ] )
                    , Maybe.map (\label_ -> ( "レーベル", [ tag label_ ] )) book.label
                    , Just ( "購入日", [ text (Helper.toJapaneseDate book.acquiredDate) ] )
                    ]
            ]
        ]


tag word =
    span [ class "kindle-filterable-tag" ] [ text word ]



-----------------
-- EDITOR
-----------------


reviewEditor : Model -> Html Msg
reviewEditor m =
    div [ class "kindle-review-editor" ]
        [ input
            [ type_ "text"
            , placeholder "タイトル"
            , value m.reviewTitle
            , autofocus True
            , onChange SetReviewTitle
            ]
            []
        , View.markdownEditor SetReviewMarkdown m.reviewMarkdown
        , button [ onClick Save, disabled m.clean ] [ text "保存" ]
        , div []
            [ text "公開 "
            , View.toggleSwitch
                [ onCheck Publish
                , disabled (not (readyToPublish m))
                , checked (m.reviewPublishedAt /= Nothing)
                ]
                []
            ]
        ]
