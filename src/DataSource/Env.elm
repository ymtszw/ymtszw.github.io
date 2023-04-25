module DataSource.Env exposing (load)

import DataSource exposing (DataSource)
import DataSource.Http
import Helper exposing (nonEmptyString)
import OptimizedDecoder
import Pages.Secrets


load : String -> DataSource String
load varName =
    DataSource.Http.request
        (Pages.Secrets.with varName <|
            Pages.Secrets.succeed <|
                \value ->
                    -- HACK elm-pages v2では環境変数をそのままDataSourceとしてビルド時にアプリ内に埋め込むことはできない（v3ではBackendTask.Envとして導入予定）。
                    -- そこでPostman Echo APIを借りて、DataSource.Httpのレスポンスを経由してアプリ内に埋め込む。当然RTTがあるので遅くなる。
                    -- Postmanのポリシー上、Echo APIにPOSTされたdataがどの程度保持されているのかはちゃんと調べていないことに注意。
                    { url = "https://postman-echo.com/post"
                    , method = "POST"
                    , headers = []
                    , body = DataSource.Http.stringBody "text/plain" value
                    }
        )
        (OptimizedDecoder.field "data" nonEmptyString)
