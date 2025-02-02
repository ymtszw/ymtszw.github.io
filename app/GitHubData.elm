module GitHubData exposing (githubGet)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import FatalError exposing (FatalError)
import Helper exposing (dataSourceWith, requireEnv)
import Json.Decode as Decode


githubGet : String -> Decode.Decoder a -> BackendTask FatalError a
githubGet url decoder =
    dataSourceWith (requireEnv "GITHUB_TOKEN") <|
        \githubToken ->
            BackendTask.Http.getWithOptions
                { url = url
                , headers = [ ( "Authorization", "token " ++ githubToken ) ]
                , expect = BackendTask.Http.expectJson decoder
                , cachePath = Nothing
                , cacheStrategy = Nothing
                , retries = Just 3
                , timeoutInMs = Just 10000
                }
                |> BackendTask.allowFatal
