module Page.Reviews.Draft exposing (Data, Model, Msg, page)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
import Dict exposing (Dict)
import Head
import Helper
import Html exposing (Html)
import KindleBook exposing (ASIN, KindleBook, kindleBooks)
import LinkPreview
import Markdown
import Page exposing (PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import QueryParams
import Shared
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
    }


data : DataSource Data
data =
    DataSource.map2 Data kindleBooks (DataSource.Env.load "AMAZON_ASSOCIATE_TAG")


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
    }


init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
init pageUrl _ static =
    ( getStaticBook pageUrl static.data.kindleBooks
    , Helper.initMsg StartLinkPreview
    )


getStaticBook : Maybe PageUrl -> Dict ASIN KindleBook -> Model
getStaticBook pageUrl books =
    pageUrl
        |> Maybe.andThen .query
        |> Maybe.map QueryParams.toDict
        |> Maybe.andThen (Dict.get "id")
        |> Maybe.andThen List.head
        |> Maybe.andThen (\id -> Dict.get id books)
        |> Maybe.map (\book -> Model (Just book) (Maybe.withDefault "タイトル" book.reviewTitle) (Maybe.withDefault "本文" book.reviewMarkdown) book.reviewUpdatedAt book.reviewPublishedAt)
        |> Maybe.withDefault (Model Nothing "タイトル" "本文" Nothing Nothing)


type Msg
    = StartLinkPreview


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
        StartLinkPreview ->
            ( m
            , Cmd.none
            , m.reviewMarkdown
                |> Markdown.parseAndEnumerateLinks
                |> Shared.Req_LinkPreview static.data.amazonAssociateTag
                |> Shared.SharedMsg
                |> Just
            )


view :
    Maybe PageUrl
    -> Shared.Model
    -> Model
    -> StaticPayload Data RouteParams
    -> View Msg
view _ { links } m _ =
    { title = "レビュー（下書き）"
    , body =
        let
            timestamp =
                Html.small [] <|
                    case m.reviewPublishedAt of
                        Just pa ->
                            Html.text ("公開: " ++ Shared.formatPosix pa)
                                :: (case m.reviewUpdatedAt of
                                        Just ua ->
                                            [ Html.text (" (更新: " ++ Shared.formatPosix ua ++ ")") ]

                                        Nothing ->
                                            []
                                   )

                        Nothing ->
                            [ Html.text "未公開" ]
        in
        [ Html.header [] [ timestamp ]
        , renderReview links m
        , Html.div [] [ timestamp ]
        ]
    }


renderReview :
    Dict String LinkPreview.Metadata
    ->
        { a
            | reviewTitle : String
            , reviewMarkdown : String
        }
    -> Html msg
renderReview links m =
    Html.article [] <|
        Html.h1 [] [ Html.text m.reviewTitle ]
            :: Markdown.parseAndRender links m.reviewMarkdown
