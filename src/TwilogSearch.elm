module TwilogSearch exposing (Model, Msg, Secrets, init, searchBox, secrets, update)

import Browser.Navigation
import DataSource exposing (DataSource)
import DataSource.Env
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
import Route
import Shared exposing (Twilog, TwitterStatusId(..))
import Url


type alias Secrets =
    { algoliaAppId : String
    , clientSearchKey : String
    }


secrets : DataSource Secrets
secrets =
    DataSource.map2 Secrets
        (DataSource.Env.load "ALGOLIA_APP_ID")
        (DataSource.Env.load "ALGOLIA_SEARCH_KEY")


type alias Model =
    { searchResults : SearchTwilogsResult
    , searching : Bool
    , searchTerm : Debounce String
    , algoliaAppId : String
    , clientSearchKey : String
    }


type alias SearchTwilogsResult =
    { searchTerm : String
    , formattedHits : List Twilog
    , estimatedTotalHits : Int
    }


init : Secrets -> Model
init { algoliaAppId, clientSearchKey } =
    { searchResults = emptyResult
    , searching = False
    , searchTerm = Debounce.init
    , algoliaAppId = algoliaAppId
    , clientSearchKey = clientSearchKey
    }


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
                    Debounce.update debounceConfig (Debounce.takeLast (searchTwilogs Res_SearchTwilogs model)) dMsg model.searchTerm
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
    { strategy = Debounce.later 700
    , transform = DebounceMsg
    }


searchTwilogs : (Result String SearchTwilogsResult -> msg) -> Model -> String -> Cmd msg
searchTwilogs tagger { algoliaAppId, clientSearchKey } term =
    Http.request
        { method = "POST"
        , url = "https://" ++ algoliaAppId ++ "-dsn.algolia.net/1/indexes/ymtszw-twilogs/query"
        , headers =
            [ Http.header "X-Algolia-Application-Id" algoliaAppId
            , Http.header "X-Algolia-API-Key" clientSearchKey
            ]
        , body = searchBody term
        , timeout = Just 5000
        , tracker = Nothing
        , expect = Http.expectJson (Result.mapError (\_ -> "") >> tagger) (searchResultDecoder term)
        }


searchBody : String -> Http.Body
searchBody term =
    Http.jsonBody <|
        Json.Encode.object
            [ ( "params", Json.Encode.string <| "query=" ++ Url.percentEncode term ++ "&hitsPerPage=10" )
            ]


searchResultDecoder : String -> Json.Decode.Decoder SearchTwilogsResult
searchResultDecoder term =
    let
        hitTwilogDecoder =
            OptimizedDecoder.decoder (Shared.twilogDecoder Nothing)
    in
    Json.Decode.map2 (SearchTwilogsResult term)
        (Json.Decode.field "hits" (Json.Decode.list hitTwilogDecoder))
        (Json.Decode.field "nbHits" Json.Decode.int)



-----------------
-- SEARCH BOX
-----------------


searchBox : (Msg -> msg) -> (Twilog -> Html msg) -> Model -> Html msg
searchBox tagger renderer { searchResults, searching } =
    div [ class "search", classList [ ( "spinner", searching ) ] ]
        [ input
            [ type_ "search"
            , id "twilogs-search"
            , placeholder "Twilog検索"
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
