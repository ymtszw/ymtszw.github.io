module DataSource.Env exposing (load)

import DataSource exposing (DataSource)
import DataSource.Port
import Helper exposing (nonEmptyString)
import Json.Encode


{-| 環境変数をそのままDataSourceとしてビルド時にアプリ内に埋め込む。

elm-pages v3ではBackendTask.Envとして導入予定。

-}
load : String -> DataSource String
load varName =
    DataSource.Port.get "loadEnv" (Json.Encode.string varName) nonEmptyString
