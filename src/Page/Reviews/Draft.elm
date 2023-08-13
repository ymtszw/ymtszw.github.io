module Page.Reviews.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import Dict exposing (Dict)
import Head
import Helper exposing (onChange)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import KindleBook exposing (ASIN, KindleBook, kindleBooks)
import LinkPreview
import Markdown
import Maybe.Extra
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import QueryParams
import Shared
import Task
import Time exposing (Posix)
import View exposing (View)


page : PageWithState RouteParams Data Model Msg
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



-----------------
-- STATIC PART
-----------------


type alias RouteParams =
    {}


type alias Data =
    { kindleBooks : Dict ASIN KindleBook
    , amazonAssociateTag : String
    , secrets : KindleBook.Secrets
    }


data : DataSource Data
data =
    DataSource.map3 Data
        kindleBooks
        (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")
        KindleBook.secrets


head : StaticPayload Data RouteParams -> List Head.Tag
head _ =
    [ Head.metaName "robots" (Head.raw "noindex,nofollow,noarchive,nocache") ]



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


init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init pageUrl _ static =
    case getStaticBook pageUrl static.data.kindleBooks of
        Just book ->
            ( bookToModel book
            , KindleBook.getOnDemand Res_refreshKindleBookOnDemand static.data.secrets book.id
            )

        Nothing ->
            ( Model Nothing "タイトル" sample Nothing Nothing True, Cmd.none )


bookToModel : KindleBook -> Model
bookToModel book =
    Model (Just book) (Maybe.withDefault "タイトル" book.reviewTitle) (Maybe.withDefault sample book.reviewMarkdown) book.reviewUpdatedAt book.reviewPublishedAt True


getStaticBook : Maybe PageUrl -> Dict ASIN KindleBook -> Maybe KindleBook
getStaticBook pageUrl books =
    pageUrl
        |> Maybe.andThen .query
        |> Maybe.map QueryParams.toDict
        |> Maybe.andThen (Dict.get "id")
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


update :
    PageUrl
    -> Maybe Browser.Navigation.Key
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Maybe Shared.Msg )
update _ _ _ static msg m =
    case msg of
        Res_refreshKindleBookOnDemand (Ok book) ->
            bookToModel book
                |> (\updated ->
                        ( { updated | clean = True }
                        , Cmd.none
                        , requestLinkPreview static.data.amazonAssociateTag updated.reviewMarkdown
                        )
                   )

        Res_refreshKindleBookOnDemand (Err _) ->
            ( m, Cmd.none, Nothing )

        SetReviewTitle s ->
            ( { m | reviewTitle = s, clean = False }, Cmd.none, Nothing )

        SetReviewMarkdown s ->
            ( { m | reviewMarkdown = s, clean = False }, Cmd.none, requestLinkPreview static.data.amazonAssociateTag s )

        Save ->
            ( m
            , modelToBook m
                |> Maybe.Extra.unwrap Cmd.none
                    (\book ->
                        putWithTimestamp book
                            |> Task.attempt Res_refreshKindleBookOnDemand
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

                    Nothing ->
                        Cmd.none

              else
                Cmd.none
            , Nothing
            )


requestLinkPreview amazonAssociateTag body =
    body
        |> Markdown.parseAndEnumerateLinks
        |> Shared.Req_LinkPreview amazonAssociateTag
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
                -- KindleBook.putOnDemandTask static.data.secrets
                Task.succeed { book | reviewUpdatedAt = Just now }
            )


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ { links } m static =
    { title = "レビュー（下書き）"
    , body =
        [ case m.book of
            Just book ->
                renderReview static.data.amazonAssociateTag links book m

            Nothing ->
                Html.div [] []
        , reviewEditor m
        ]
    }


renderReview :
    String
    -> Dict String LinkPreview.Metadata
    -> KindleBook
    -> Model
    -> Html msg
renderReview amazonAssociateTag links book m =
    let
        timestamp =
            Html.small [] <|
                case m.reviewPublishedAt of
                    Just pa ->
                        Html.text ("公開: " ++ Shared.formatPosix pa)
                            :: (case m.reviewUpdatedAt of
                                    Just ua ->
                                        if ua == pa then
                                            []

                                        else
                                            [ Html.text (" (更新: " ++ Shared.formatPosix ua ++ ")") ]

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
        , bookDetails amazonAssociateTag book
        , Html.h1 [] [ Html.text m.reviewTitle ]
        ]
            ++ Markdown.parseAndRender links m.reviewMarkdown
            ++ [ Html.div [] [ timestamp ]
               , bookDetails amazonAssociateTag book
               ]


bookDetails amazonAssociateTag book =
    blockquote [ class "kindle-book-details" ]
        [ a [ href (Helper.makeAmazonUrl amazonAssociateTag book.id), target "_blank", class "has-image" ]
            [ View.imgLazy [ src book.img, width 150, alt <| book.rawTitle ++ "の書影" ] [] ]
        , div []
            [ h5 [] [ a [ href (Helper.makeAmazonUrl amazonAssociateTag book.id), target "_blank" ] [ text book.rawTitle ] ]
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
