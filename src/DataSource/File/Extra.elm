module DataSource.File.Extra exposing (Stat, getImageDimensions, stat)

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


{-| Get the dimensions of an image file in `public/` directory.
-}
getImageDimensions : String -> DataSource { width : Int, height : Int }
getImageDimensions fileName =
    DataSource.Port.get "getImageDimensions" (Json.Encode.string fileName) <|
        OptimizedDecoder.map2
            (\width height -> { width = width, height = height })
            (OptimizedDecoder.field "width" OptimizedDecoder.int)
            (OptimizedDecoder.field "height" OptimizedDecoder.int)
