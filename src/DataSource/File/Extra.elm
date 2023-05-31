module DataSource.File.Extra exposing (Stat, stat)

import DataSource exposing (DataSource)
import DataSource.Port
import Helper exposing (iso8601Decoder)
import Json.Encode
import OptimizedDecoder
import Time


type alias Stat =
    { birthtime : Time.Posix
    , mtime : Time.Posix
    , size : Int
    }


stat : String -> DataSource Stat
stat fileName =
    DataSource.Port.get "statFile" (Json.Encode.string fileName) <|
        OptimizedDecoder.map3 Stat
            (OptimizedDecoder.field "birthtime" iso8601Decoder)
            (OptimizedDecoder.field "mtime" iso8601Decoder)
            (OptimizedDecoder.field "size" OptimizedDecoder.int)
