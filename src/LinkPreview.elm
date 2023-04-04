module LinkPreview exposing (Metadata, collectMetadataOnBuild, getMetadataOnBuild, getMetadataOnDemand, previewMetadata)

{-| LinkPreview API module.
-}

import DataSource
import DataSource.Http
import Dict exposing (Dict)
import Helper exposing (nonEmptyString)
import Html.Parser exposing (Node(..))
import Http
import Json.Decode
import OptimizedDecoder
import Pages.Secrets
import Task exposing (Task)
import Url


{-| Metadata for link preview.

Consumers of this metadata should:

  - show preview, if `title` is resolved to `Just`
  - otherwise just fall back to plain text link

-}
type alias Metadata =
    { -- Defaults to requested URL
      title : String
    , description : Maybe String
    , imageUrl : Maybe String
    , -- Defaults to requested URL
      canonicalUrl : String
    }


previewMetadata : String -> Metadata
previewMetadata url =
    { title = linkPreviewTitle
    , description = Just linkPreviewDescription
    , canonicalUrl = url
    , imageUrl = Just "https://via.placeholder.com/640x480"
    }


linkPreviewTitle =
    "... Title is loading ..."


linkPreviewDescription =
    """... Descrption is loading (may fail. If failed, it will be omitted on published build.) ..."""


collectMetadataOnBuild : List String -> DataSource.DataSource (Dict String Metadata)
collectMetadataOnBuild links =
    links
        |> List.map getMetadataOnBuild
        |> DataSource.combine
        |> DataSource.map Dict.fromList


getMetadataOnBuild : String -> DataSource.DataSource ( String, Metadata )
getMetadataOnBuild url =
    DataSource.Http.get
        (Pages.Secrets.succeed (linkPreviewApiEndpoint url))
        (linkPreviewDecoder url)
        |> DataSource.map (Tuple.pair url)


{-| Using personal link preview service. <https://github.com/ymtszw/link-preview>
-}
linkPreviewApiEndpoint url =
    "https://link-preview.ymtszw.workers.dev/?q=" ++ Url.percentEncode url


linkPreviewDecoder : String -> OptimizedDecoder.Decoder Metadata
linkPreviewDecoder requestUrl =
    OptimizedDecoder.field "url" OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\canonicalUrl ->
                let
                    -- canonicalUrl does not include fragment, so we need to append it back from requestUrl
                    -- OTOH inclusion of query parameters should be determined by the server, so we do not bring them up
                    -- i.e. if the parameters affect contents of the page, it should be part of the canonical URL. if not, they can be safely stripped
                    -- cf. https://webmasters.stackexchange.com/q/114622
                    canonicalUrlWithFragment =
                        case String.split "#" requestUrl of
                            [ _, fragment ] ->
                                canonicalUrl ++ "#" ++ fragment

                            _ ->
                                canonicalUrl
                in
                OptimizedDecoder.succeed Metadata
                    -- Treat HTML without title (such as "301 moved permanently" page) as empty.
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" nonEmptyString)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "description" nonEmptyString)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "image" (OptimizedDecoder.map (resolveUrl canonicalUrl) nonEmptyString))
                    |> OptimizedDecoder.andMap (OptimizedDecoder.succeed canonicalUrlWithFragment)
            )


resolveUrl : String -> String -> String
resolveUrl baseUrl pathOrUrl =
    if String.startsWith "http:" pathOrUrl || String.startsWith "https:" pathOrUrl || String.startsWith "data:" pathOrUrl then
        pathOrUrl

    else if String.startsWith "//" pathOrUrl then
        case String.split ":" baseUrl of
            scheme :: _ ->
                scheme ++ ":" ++ pathOrUrl

            _ ->
                -- fallback to HTTPS
                "https:" ++ pathOrUrl

    else if String.startsWith "/" pathOrUrl then
        if String.endsWith "/" baseUrl then
            String.dropRight 1 baseUrl ++ pathOrUrl

        else
            baseUrl ++ pathOrUrl

    else if String.endsWith "/" baseUrl then
        baseUrl ++ pathOrUrl

    else
        baseUrl ++ String.dropLeft 1 pathOrUrl


getMetadataOnDemand : String -> Task String ( String, Metadata )
getMetadataOnDemand url =
    Http.task
        { method = "GET"
        , url = linkPreviewApiEndpoint url
        , headers = []
        , body = Http.emptyBody
        , timeout = Just 20000
        , resolver =
            Http.stringResolver <|
                \response ->
                    case response of
                        Http.GoodStatus_ _ body ->
                            Json.Decode.decodeString (OptimizedDecoder.decoder (linkPreviewDecoder url)) body
                                |> Result.mapError OptimizedDecoder.errorToString

                        _ ->
                            Err "something failed"
        }
        |> Task.map (Tuple.pair url)
