module Meilisearch exposing (SearchTwilogsResult, emptyResult, searchTwilogs)

import Http
import Json.Decode
import Json.Encode
import OptimizedDecoder
import Shared exposing (Twilog, TwitterStatusId(..))


type alias SearchTwilogsResult =
    { formattedHits : List Twilog
    , estimatedTotalHits : Int
    }


emptyResult =
    { formattedHits = []
    , estimatedTotalHits = 0
    }


searchTwilogs : (Result String SearchTwilogsResult -> msg) -> String -> Cmd msg
searchTwilogs tagger term =
    Http.request
        { method = "POST"
        , url = "https://ms-302b6a5b2398-3215.sgp.meilisearch.io/indexes/ymtszw-twilogs/search"
        , headers = [ Http.header "Authorization" ("Bearer " ++ clientSearchKey) ]
        , body = searchBody term
        , timeout = Just 5000
        , tracker = Nothing
        , expect =
            Http.expectJson (Result.mapError (\_ -> "") >> tagger) searchResultDecoder
        }


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


searchResultDecoder : Json.Decode.Decoder SearchTwilogsResult
searchResultDecoder =
    let
        hitTwilogDecoder =
            OptimizedDecoder.decoder Shared.twilogDecoder
    in
    Json.Decode.map2 SearchTwilogsResult
        (Json.Decode.field "hits"
            (Json.Decode.oneOf
                [ Json.Decode.list (Json.Decode.field "_formatted" hitTwilogDecoder)
                , Json.Decode.list hitTwilogDecoder
                ]
            )
        )
        (Json.Decode.field "estimatedTotalHits" Json.Decode.int)
