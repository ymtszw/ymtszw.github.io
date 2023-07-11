port module RuntimePorts exposing (..)

import Json.Encode


port toJs : Json.Encode.Value -> Cmd msg
