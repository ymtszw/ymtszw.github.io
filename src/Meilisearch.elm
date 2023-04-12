module Meilisearch exposing (HitTwilog, SearchTwilogsResult, emptyResult, searchTwilogs)

import Date
import Http
import Json.Decode
import Json.Encode
import OptimizedDecoder
import Shared exposing (TwitterStatusId(..))
import Time


type alias SearchTwilogsResult =
    { formattedHits : List HitTwilog
    , estimatedTotalHits : Int
    }


emptyResult =
    { formattedHits = []
    , estimatedTotalHits = 0
    }


type alias HitTwilog =
    { id : TwitterStatusId
    , idStr : String
    , text : String
    , userName : String
    , createdAt : Time.Posix
    , createdDate : Date.Date
    }


searchTwilogs : (Result String SearchTwilogsResult -> msg) -> String -> Cmd msg
searchTwilogs tagger term =
    Http.request
        { method = "POST"
        , url = "https://ms-302b6a5b2398-3215.sgp.meilisearch.io/indexes/ymtszw-twilogs/search"
        , headers = [ Http.header "Authorization" "Bearer 01ee096032b6b41617b155ef5d9efec6e9a41e2de16a126cbf51a9385d12116c" ]
        , body = searchBody term
        , timeout = Just 5000
        , tracker = Nothing
        , expect =
            Http.expectJson (Result.mapError (\_ -> "") >> tagger) searchResultDecoder
        }


searchBody : String -> Http.Body
searchBody term =
    Http.jsonBody <|
        Json.Encode.object
            [ ( "q", Json.Encode.string term )
            , ( "limit", Json.Encode.int 10 )
            , ( "attributesToHighlight", Json.Encode.list Json.Encode.string [ "Text", "QuotedStatusFullText" ] )
            , ( "highlightPreTag", Json.Encode.string " **" )
            , ( "highlightPostTag", Json.Encode.string "** " )
            ]


searchResultDecoder : Json.Decode.Decoder SearchTwilogsResult
searchResultDecoder =
    let
        hitTwilogDecoder =
            Json.Decode.map6 HitTwilog
                (Json.Decode.field "StatusId" (Json.Decode.map TwitterStatusId Json.Decode.string))
                (Json.Decode.field "StatusId" Json.Decode.string)
                (Json.Decode.field "Text" Json.Decode.string)
                (Json.Decode.field "UserName" Json.Decode.string)
                (Json.Decode.field "CreatedAt" createdAtDecoder)
                (Json.Decode.field "CreatedAt" (createdAtDecoder |> Json.Decode.map (Date.fromPosix Shared.jst)))

        createdAtDecoder =
            OptimizedDecoder.decoder Shared.createdAtDecoder
    in
    Json.Decode.map2 SearchTwilogsResult
        (Json.Decode.field "hits" (Json.Decode.list (Json.Decode.field "_formatted" hitTwilogDecoder)))
        (Json.Decode.field "estimatedTotalHits" Json.Decode.int)
