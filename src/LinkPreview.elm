module LinkPreview exposing (Metadata, collectMetadataOnBuild, collectMetadataOnDemand, getMetadataOnBuild, getMetadataOnDemand, isEmpty, previewMetadata)

{-| LinkPreview API module.
-}

import DataSource
import DataSource.Http
import Dict exposing (Dict)
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
    { title : Maybe String
    , description : Maybe String
    , iconUrl : Maybe String
    , imageUrl : Maybe String
    , -- Defaults to requested URL
      canonicalUrl : String
    }


emptyMetadata url =
    { title = Nothing
    , description = Nothing
    , iconUrl = Nothing
    , imageUrl = Nothing
    , canonicalUrl = url
    }


previewMetadata : String -> Metadata
previewMetadata url =
    { title = Just linkPreviewTitle
    , description = Just linkPreviewDescription
    , canonicalUrl = url
    , imageUrl = Just "https://via.placeholder.com/640x480"
    , iconUrl = Just "https://via.placeholder.com/150x150"
    }


linkPreviewTitle =
    "... Title is loading ..."


linkPreviewDescription =
    """... Descrption is loading (may fail. If failed, it will be omitted on published build.) ..."""


collectMetadataOnBuild : { errOnFail : Bool } -> List String -> DataSource.DataSource (Dict String Metadata)
collectMetadataOnBuild conf links =
    let
        removeEmpty =
            DataSource.map
                (\(( _, meta ) as result) ->
                    if isEmpty meta then
                        []

                    else
                        [ result ]
                )
    in
    links
        |> List.map (getMetadataOnBuild conf >> removeEmpty)
        |> DataSource.combine
        |> DataSource.map (List.concat >> Dict.fromList)


{-| Treat HTML without title (such as "301 moved permanently" page) as empty.
-}
isEmpty : Metadata -> Bool
isEmpty { title } =
    case title of
        Just _ ->
            False

        Nothing ->
            True


getMetadataOnBuild : { errOnFail : Bool } -> String -> DataSource.DataSource ( String, Metadata )
getMetadataOnBuild conf url =
    DataSource.Http.get
        (Pages.Secrets.succeed (linkPreviewApiEndpoint url))
        (linkPreviewDecoder conf (emptyMetadata url))
        |> DataSource.map (Tuple.pair url)


{-| Using personal link preview service. <https://github.com/ymtszw/link-preview>
-}
linkPreviewApiEndpoint url =
    "https://link-preview.ymtszw.workers.dev/?q=" ++ Url.percentEncode url


linkPreviewDecoder : { errOnFail : Bool } -> Metadata -> OptimizedDecoder.Decoder Metadata
linkPreviewDecoder { errOnFail } meta =
    OptimizedDecoder.oneOf <|
        (OptimizedDecoder.field "url" OptimizedDecoder.string
            |> OptimizedDecoder.andThen
                (\baseUrl ->
                    OptimizedDecoder.succeed Metadata
                        |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" (OptimizedDecoder.map Just OptimizedDecoder.string))
                        |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "description" OptimizedDecoder.string)
                        |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "icon" (OptimizedDecoder.map (resolveUrl baseUrl) OptimizedDecoder.string))
                        |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "image" (OptimizedDecoder.map (resolveUrl baseUrl) OptimizedDecoder.string))
                        |> OptimizedDecoder.andMap (OptimizedDecoder.succeed baseUrl)
                )
        )
            :: (if errOnFail then
                    []

                else
                    [ OptimizedDecoder.succeed meta ]
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


collectMetadataOnDemand : { errOnFail : Bool } -> List String -> Task String (Dict String Metadata)
collectMetadataOnDemand conf links =
    let
        removeEmpty =
            Task.map
                (\(( _, meta ) as result) ->
                    if isEmpty meta then
                        []

                    else
                        [ result ]
                )
    in
    links
        |> List.map (getMetadataOnDemand conf >> removeEmpty)
        |> Task.sequence
        |> Task.map (List.concat >> Dict.fromList)


getMetadataOnDemand : { errOnFail : Bool } -> String -> Task String ( String, Metadata )
getMetadataOnDemand conf url =
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
                            Json.Decode.decodeString (OptimizedDecoder.decoder (linkPreviewDecoder conf (emptyMetadata url))) body
                                |> Result.mapError OptimizedDecoder.errorToString

                        _ ->
                            if conf.errOnFail then
                                Err "something failed"

                            else
                                Ok (emptyMetadata url)
        }
        |> Task.map (Tuple.pair url)
