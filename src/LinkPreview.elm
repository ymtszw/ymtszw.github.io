module LinkPreview exposing (Metadata, getMetadata)

{-| Metadata for link preview.

Consumers of this metadata should:

  - show preview, if `title` is resolved to `Just`
  - otherwise just fall back to plain text link

-}

import DataSource
import DataSource.Http
import Html.Parser exposing (Node(..))
import Maybe.Extra
import Pages.Secrets


type alias Metadata =
    { title : Maybe String
    , description : Maybe String
    , iconUrl : Maybe String
    , imageUrl : Maybe String
    , -- Defaults to requested URL
      canonicalUrl : String
    }


getMetadata : String -> DataSource.DataSource ( String, Metadata )
getMetadata url =
    DataSource.Http.unoptimizedRequest
        (Pages.Secrets.succeed
            { url = url
            , method = "GET"
            , headers = []
            , body = DataSource.Http.emptyBody
            }
        )
        (DataSource.Http.expectString (htmlMetadataParser (emptyMetadata url)))
        |> DataSource.map (Tuple.pair url)


htmlMetadataParser : Metadata -> String -> Result String Metadata
htmlMetadataParser meta str =
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
    Html.Parser.runDocument str
        |> Result.mapError (List.map (\deadEnd -> "Html syntax error:\n\n" ++ showErrorLine deadEnd) >> String.join "\n\n")
        |> Result.map (.document >> Tuple.second >> removeInsignificant [] >> walkHtmlNodesForMetadata meta)


emptyMetadata url =
    { title = Nothing
    , description = Nothing
    , iconUrl = Nothing
    , imageUrl = Nothing
    , canonicalUrl = url
    }


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
