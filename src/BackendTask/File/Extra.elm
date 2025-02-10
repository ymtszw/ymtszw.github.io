module BackendTask.File.Extra exposing (getImageDimensions)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import FatalError exposing (FatalError)
import Json.Decode as Decode
import Json.Encode


{-| Get the dimensions of an image file in `public/` directory.
-}
getImageDimensions : String -> BackendTask { fatal : FatalError, recoverable : BackendTask.Custom.Error } { width : Int, height : Int }
getImageDimensions fileName =
    BackendTask.Custom.run "getImageDimensions" (Json.Encode.string fileName) <|
        Decode.map2
            (\width height -> { width = width, height = height })
            (Decode.field "width" Decode.int)
            (Decode.field "height" Decode.int)
