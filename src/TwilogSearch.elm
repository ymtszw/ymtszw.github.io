module TwilogSearch exposing (Model, Msg, init, searchBox, update)

import Browser.Navigation
import Date
import Debounce exposing (Debounce)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode
import Json.Encode
import OptimizedDecoder
import Path
import Process
import Route
import Shared exposing (Twilog, TwitterStatusId(..))
import Task


type alias Model =
    { searchResults : SearchTwilogsResult
    , searching : Bool
    , searchTerm : Debounce String
    }


type alias SearchTwilogsResult =
    { searchTerm : String
    , formattedHits : List Twilog
    , estimatedTotalHits : Int
    }


init : Model
init =
    { searchResults = emptyResult, searching = False, searchTerm = Debounce.init }


emptyResult =
    { searchTerm = ""
    , formattedHits = []
    , estimatedTotalHits = 0
    }


type Msg
    = SetSearchTerm String
    | DebounceMsg Debounce.Msg
    | Res_SearchTwilogs (Result String SearchTwilogsResult)
    | JumpToHitTwilog String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetSearchTerm "" ->
            ( { model | searchResults = emptyResult, searchTerm = Debounce.init }
            , Cmd.none
            )

        SetSearchTerm input ->
            let
                ( newDebounce, cmd ) =
                    Debounce.push debounceConfig input model.searchTerm
            in
            ( { model | searching = True, searchTerm = newDebounce }
            , cmd
            )

        DebounceMsg dMsg ->
            let
                ( newDebounce, cmd ) =
                    Debounce.update debounceConfig (Debounce.takeLast (searchTwilogs Res_SearchTwilogs)) dMsg model.searchTerm
            in
            ( { model | searchTerm = newDebounce }
            , cmd
            )

        Res_SearchTwilogs (Ok searchResults) ->
            ( { model | searchResults = searchResults, searching = False }
            , Cmd.none
            )

        Res_SearchTwilogs (Err _) ->
            ( { model | searching = False }
            , Cmd.none
            )

        JumpToHitTwilog permalink ->
            ( model
            , Browser.Navigation.load permalink
            )


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 500
    , transform = DebounceMsg
    }


searchTwilogs : (Result String SearchTwilogsResult -> msg) -> String -> Cmd msg
searchTwilogs tagger term =
    Process.sleep searchBackPressureMs
        |> Task.andThen
            (\() ->
                Http.task
                    { method = "POST"
                    , url = "https://ms-302b6a5b2398-3215.sgp.meilisearch.io/indexes/ymtszw-twilogs/search"
                    , headers = [ Http.header "Authorization" ("Bearer " ++ clientSearchKey) ]
                    , body = searchBody term
                    , timeout = Just 5000
                    , resolver =
                        Http.stringResolver
                            (\resp ->
                                case resp of
                                    Http.GoodStatus_ _ body ->
                                        Json.Decode.decodeString (searchResultDecoder term) body
                                            |> Result.mapError (\_ -> "")

                                    _ ->
                                        Err ""
                            )
                    }
            )
        |> Task.attempt tagger


searchBackPressureMs : Float
searchBackPressureMs =
    500


clientSearchKey : String
clientSearchKey =
    -- TODO v3ではこれをBackendTask.Env経由でビルド時に埋め込む？
    "01ee096032b6b41617b155ef5d9efec6e9a41e2de16a126cbf51a9385d12116c"


searchBody : String -> Http.Body
searchBody term =
    Http.jsonBody <|
        Json.Encode.object
            [ ( "q", Json.Encode.string term )
            , ( "limit", Json.Encode.int 10 )
            ]


searchResultDecoder : String -> Json.Decode.Decoder SearchTwilogsResult
searchResultDecoder term =
    let
        hitTwilogDecoder =
            OptimizedDecoder.decoder Shared.twilogDecoder
    in
    Json.Decode.map2 (SearchTwilogsResult term)
        (Json.Decode.field "hits"
            (Json.Decode.oneOf
                [ Json.Decode.list (Json.Decode.field "_formatted" hitTwilogDecoder)
                , Json.Decode.list hitTwilogDecoder
                ]
            )
        )
        (Json.Decode.field "estimatedTotalHits" Json.Decode.int)



-----------------
-- SEARCH BOX
-----------------


searchBox : (Msg -> msg) -> (Twilog -> Html msg) -> Model -> Html msg
searchBox tagger renderer { searchResults, searching } =
    div [ class "search" ]
        [ label [ for "twilogs-search", classList [ ( "spinner", searching ) ] ] [ text "検索" ]
        , input
            [ type_ "search"
            , id "twilogs-search"
            , onInput (SetSearchTerm >> tagger)
            ]
            []
        , case searchResults.formattedHits of
            [] ->
                text ""

            nonEmpty ->
                nonEmpty
                    |> List.map
                        (\twilog ->
                            let
                                permalink rendered =
                                    button [ class "jump-to-button", onClick (tagger (JumpToHitTwilog pathWithFragment)) ] [ rendered ]

                                pathWithFragment =
                                    (Route.toPath (Route.Twilogs__YearMonth_ { yearMonth = yearMonth }) |> Path.toAbsolute) ++ "#tweet-" ++ twilog.idStr

                                yearMonth =
                                    String.dropRight 3 (Date.toIsoString twilog.createdDate)
                            in
                            renderer twilog |> permalink
                        )
                    |> List.append [ small [] [ text ("約" ++ String.fromInt searchResults.estimatedTotalHits ++ "件") ] ]
                    |> div [ class "search-results" ]
        ]
