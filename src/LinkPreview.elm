module LinkPreview exposing (Metadata, collectMetadataOnBuild, collectMetadataOnDemand, getMetadataOnBuild, getMetadataOnDemand, htmlMetadataParser, isEmpty, previewMetadata)

{-| LinkPreview API module.
-}

import DataSource
import DataSource.Http
import Dict exposing (Dict)
import Html.Parser exposing (Node(..))
import Http
import Json.Decode
import Maybe.Extra
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
        (Pages.Secrets.succeed (\key -> linkPreviewApiEndpoint key url)
            |> Pages.Secrets.with "LINK_PREVIEW_API_KEY"
        )
        (linkPreviewDecoder conf (emptyMetadata url))
        |> DataSource.map (Tuple.pair url)


{-| Using <https://www.linkpreview.net/> for now,
but this part is exchangeable to another API provider with appropriate decoder.
-}
linkPreviewApiEndpoint key url =
    "https://api.linkpreview.net/?key=" ++ key ++ "&q=" ++ Url.percentEncode url


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


collectMetadataOnDemand : { errOnFail : Bool } -> String -> List String -> Task String (Dict String Metadata)
collectMetadataOnDemand conf key links =
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
        |> List.map (getMetadataOnDemand conf key >> removeEmpty)
        |> Task.sequence
        |> Task.map (List.concat >> Dict.fromList)


getMetadataOnDemand : { errOnFail : Bool } -> String -> String -> Task String ( String, Metadata )
getMetadataOnDemand conf key url =
    Http.task
        { method = "GET"
        , url = linkPreviewApiEndpoint key url
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


htmlMetadataParser : { errOnFail : Bool } -> String -> String -> Result String Metadata
htmlMetadataParser { errOnFail } url rawBody =
    let
        empty =
            emptyMetadata url
    in
    case Html.Parser.runDocument rawBody of
        Err e ->
            if errOnFail then
                Err (List.map (showHtmlParseError rawBody) e |> String.join "\n\n")

            else
                Ok empty

        Ok parsed ->
            Ok (parsed.document |> Tuple.second |> removeInsignificant [] |> walkHtmlNodesForMetadata empty)


showHtmlParseError str =
    let
        lines =
            String.split "\n" str

        showErrorLine deadEnd =
            List.indexedMap (pickNearbyLine deadEnd) lines
                |> List.concat
                |> String.join "\n"

        pickNearbyLine deadEnd iFromZero line =
            let
                lNum =
                    iFromZero + 1

                pad =
                    String.padLeft 6 ' ' (String.fromInt lNum) ++ "| "
            in
            if lNum == deadEnd.row then
                [ pad ++ line
                , "        " ++ String.repeat (deadEnd.col - 1) " " ++ "^"
                ]

            else if deadEnd.row - 10 <= lNum && lNum <= deadEnd.row + 10 then
                [ pad ++ line ]

            else
                []
    in
    (++) "Html syntax error:\n\n" << showErrorLine


removeInsignificant acc nodes =
    case nodes of
        [] ->
            List.reverse acc

        (Comment _) :: xs ->
            removeInsignificant acc xs

        (Text t) :: xs ->
            case String.trim t of
                "" ->
                    removeInsignificant acc xs

                trimmed ->
                    removeInsignificant (Text trimmed :: acc) xs

        (Element name attrs kids) :: xs ->
            removeInsignificant (Element name attrs (removeInsignificant [] kids) :: acc) xs


walkHtmlNodesForMetadata acc nodes =
    case nodes of
        [] ->
            acc

        (Element "head" [] heads) :: _ ->
            walkHtmlNodesForMetadata acc heads

        (Element "title" _ [ Text title ]) :: heads ->
            walkHtmlNodesForMetadata { acc | title = Just title } heads

        (Element "meta" attrs _) :: heads ->
            walkHtmlNodesForMetadata (metaAttrs acc attrs) heads

        (Element "link" attrs _) :: heads ->
            walkHtmlNodesForMetadata (linkAttrs acc attrs) heads

        _ :: heads ->
            walkHtmlNodesForMetadata acc heads


metaAttrs : Metadata -> List ( String, String ) -> Metadata
metaAttrs acc attrs =
    { acc
        | title =
            Maybe.Extra.orListLazy
                [ \_ -> acc.title
                , \_ -> metaValue "og:title" attrs
                , \_ -> metaValue "twitter:title" attrs
                ]
        , description =
            Maybe.Extra.orListLazy
                [ \_ -> acc.description
                , \_ -> metaValue "description" attrs
                , \_ -> metaValue "og:description" attrs
                , \_ -> metaValue "twitter:description" attrs
                ]
        , imageUrl =
            Maybe.Extra.orListLazy
                [ \_ -> acc.imageUrl
                , \_ -> metaValue "og:image" attrs
                , \_ -> metaValue "twitter:image" attrs
                ]
    }


metaValue : String -> List ( String, String ) -> Maybe String
metaValue query attrs =
    Maybe.Extra.andThen2
        (\name content ->
            if name == query then
                Just content

            else
                Nothing
        )
        (Maybe.Extra.orListLazy [ \_ -> listGet "name" attrs, \_ -> listGet "property" attrs ])
        (listGet "content" attrs)


linkAttrs : Metadata -> List ( String, String ) -> Metadata
linkAttrs acc attrs =
    { acc
        | iconUrl =
            Maybe.Extra.orListLazy
                [ \_ -> acc.iconUrl
                , \_ -> linkValue "icon" attrs
                , \_ -> linkValue "apple-touch-icon" attrs
                ]
        , canonicalUrl = Maybe.withDefault acc.canonicalUrl (linkValue "canonical" attrs)
    }


linkValue : String -> List ( String, String ) -> Maybe String
linkValue query attrs =
    Maybe.Extra.andThen2
        (\rel href ->
            if rel == query then
                Just href

            else
                Nothing
        )
        (listGet "rel" attrs)
        (listGet "href" attrs)


listGet query list =
    case list of
        [] ->
            Nothing

        ( k, v ) :: tail ->
            if k == query then
                Just v

            else
                listGet query tail
