module TwilogSearch exposing (Model, Msg, Secrets, batchAddObjectsOnBuild, init, searchBox, secrets, update)

import BackendTask exposing (BackendTask)
import BackendTask.Do exposing (do)
import BackendTask.File.Extra
import BackendTask.Http
import Browser.Navigation
import Date
import Debounce exposing (Debounce)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Helper exposing (requireEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode
import Murmur3
import Route
import TwilogData exposing (Twilog, TwitterStatusId(..))
import Url
import UrlPath
import View exposing (imgLazy)


type alias Secrets =
    { algoliaAppId : String
    , clientSearchKey : String
    }


secrets : BackendTask FatalError Secrets
secrets =
    BackendTask.map2 Secrets
        (requireEnv "ALGOLIA_APP_ID")
        (requireEnv "ALGOLIA_SEARCH_KEY")


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


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SetSearchTerm "" ->
            ( { model | searchResults = emptyResult, searchTerm = Debounce.init }
            , Effect.none
            )

        SetSearchTerm input ->
            let
                ( newDebounce, cmd ) =
                    Debounce.push debounceConfig input model.searchTerm
            in
            ( { model | searching = True, searchTerm = newDebounce }
            , Effect.fromCmd cmd
            )

        DebounceMsg dMsg ->
            let
                ( newDebounce, cmd ) =
                    Debounce.update debounceConfig (Debounce.takeLast (searchTwilogs Res_SearchTwilogs model)) dMsg model.searchTerm
            in
            ( { model | searchTerm = newDebounce }
            , Effect.fromCmd cmd
            )

        Res_SearchTwilogs (Ok searchResults) ->
            ( { model | searchResults = searchResults, searching = False }
            , Effect.none
            )

        Res_SearchTwilogs (Err _) ->
            ( { model | searching = False }
            , Effect.none
            )

        JumpToHitTwilog permalink ->
            ( model
            , Browser.Navigation.load permalink |> Effect.fromCmd
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


searchResultDecoder : String -> Decode.Decoder SearchTwilogsResult
searchResultDecoder term =
    Decode.map2 (SearchTwilogsResult term)
        (Decode.field "hits" (Decode.list (TwilogData.twilogDecoder Nothing)))
        (Decode.field "nbHits" Decode.int)



-----------------
-- SEARCH BOX
-----------------


searchBox : (Msg -> msg) -> (Twilog -> Html msg) -> Model -> Html msg
searchBox tagger renderer { searchResults, searching } =
    div [ class "search", classList [ ( "spinner", searching ) ] ]
        [ input
            [ type_ "search"
            , id "twilogs-search"
            , placeholder "Twilog検索 by Algolia"
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
                                    (Route.toPath (Route.Twilogs__YearMonth_ { yearMonth = yearMonth }) |> UrlPath.toAbsolute) ++ "#tweet-" ++ twilog.idStr

                                yearMonth =
                                    String.dropRight 3 (Date.toIsoString twilog.createdDate)
                            in
                            renderer twilog |> permalink
                        )
                    |> (\results ->
                            small [] [ text ("約" ++ String.fromInt searchResults.estimatedTotalHits ++ "件") ]
                                :: results
                                ++ [ div [ class "provider" ]
                                        [ text "Powered by "
                                        , a
                                            [ href "https://algolia.com"
                                            , target "_blank"
                                            , class "has-image"
                                            ]
                                            [ imgLazy [ src "/algolia.svg" ] [] ]
                                        ]
                                   ]
                       )
                    |> div [ class "search-results" ]
        ]


batchAddObjectsOnBuild : List Twilog -> BackendTask FatalError ()
batchAddObjectsOnBuild twilogs =
    do (BackendTask.map2 Tuple.pair (requireEnv "ALGOLIA_APP_ID") (requireEnv "ALGOLIA_ADMIN_KEY")) <|
        \( appId, adminKey ) ->
            let
                headers =
                    [ ( "X-Algolia-Application-Id", appId )
                    , ( "X-Algolia-API-Key", adminKey )
                    , ( "Content-Type", "application/json" )
                    ]

                body =
                    Json.Encode.object
                        [ ( "requests", Json.Encode.list encodeTwilog twilogs )
                        ]

                encodeTwilog twilog =
                    Json.Encode.object
                        [ ( "action", Json.Encode.string "addObject" )
                        , ( "body", TwilogData.serializeToOnelineTwilogJson True twilog )
                        ]
            in
            BackendTask.Http.request
                { url = "https://" ++ appId ++ "-dsn.algolia.net/1/indexes/ymtszw-twilogs/batch"
                , method = "POST"
                , headers = headers
                , body = BackendTask.Http.jsonBody body
                , retries = Nothing
                , timeoutInMs = Just 10000
                }
                (BackendTask.Http.expectWhatever ())
                |> BackendTask.onError
                    (\{ recoverable } ->
                        case recoverable of
                            BackendTask.Http.BadStatus meta _ ->
                                let
                                    dumpedJson =
                                        Json.Encode.encode 4 body

                                    hash =
                                        Murmur3.hashString 1234 dumpedJson |> String.fromInt

                                    dumpJsonFileName =
                                        "algolia-batch-request-body-" ++ hash ++ ".json"
                                in
                                BackendTask.File.Extra.dumpJsonFile dumpJsonFileName body
                                    |> BackendTask.allowFatal
                                    |> BackendTask.andThen
                                        (\_ ->
                                            FatalError.build
                                                { title = "Algolia Batch API Client Error: " ++ String.fromInt meta.statusCode
                                                , body = "See <https://dashboard.algolia.com/apps/" ++ appId ++ "/explorer/logs/ymtszw-twilogs> for details.\nRequest body dumped to tmp/" ++ dumpJsonFileName ++ "."
                                                }
                                                |> BackendTask.fail
                                        )

                            _ ->
                                FatalError.fromString "Algolia Batch API Unexpected Error"
                                    |> BackendTask.fail
                    )
