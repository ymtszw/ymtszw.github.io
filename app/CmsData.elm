module CmsData exposing (CmsArticle, CmsArticleMetadata, CmsImage, CmsSource(..), ExternalView, HtmlOrMarkdown(..), allMetadata, cmsGet)

import BackendTask exposing (BackendTask)
import BackendTask.Env
import BackendTask.File
import BackendTask.Glob
import BackendTask.Http
import FatalError exposing (FatalError)
import Html.Parser
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Markdown.Block
import Pages
import Time


type alias CmsArticle =
    { meta : CmsArticleMetadata
    , body : ExternalView
    , type_ : String
    }


type alias CmsArticleMetadata =
    { contentId : String
    , published : Bool
    , publishedAt : Time.Posix
    , revisedAt : Time.Posix
    , title : String
    , image : Maybe CmsImage
    , source : CmsSource
    }


type alias ExternalView =
    { parsed : HtmlOrMarkdown
    , excerpt : String
    , links : List String
    }


type HtmlOrMarkdown
    = Html (List Html.Parser.Node)
    | Markdown (List Markdown.Block.Block)


type alias CmsImage =
    { url : String
    , height : Int
    , width : Int
    }


type CmsSource
    = MicroCms
    | MarkdownFile


{-| Markdown記事と外部CMS記事すべてのメタデータ。

最新の記事が先頭に来るようにソートされている。

-}
allMetadata : BackendTask FatalError (List CmsArticleMetadata)
allMetadata =
    BackendTask.map2 (++) markdownMetadata microCmsMetadata
        |> BackendTask.map (List.sortBy (.publishedAt >> Time.posixToMillis >> negate))


markdownMetadata : BackendTask FatalError (List CmsArticleMetadata)
markdownMetadata =
    let
        markdownMetadataDecoder slug =
            Decode.map4
                (\title publishedAt revisedAt image ->
                    { contentId = slug
                    , published = Time.posixToMillis publishedAt <= Time.posixToMillis Pages.builtAt
                    , publishedAt = publishedAt
                    , revisedAt = Maybe.withDefault publishedAt revisedAt
                    , title = title
                    , image = image
                    , source = MarkdownFile
                    }
                )
                (Decode.field "title" Decode.string)
                cmsArticlePublishedAtDecoder
                (Decode.maybe (Decode.field "revisedAt" Iso8601.decoder))
                (Decode.maybe (Decode.field "image" cmsImageDecoder))
    in
    BackendTask.Glob.succeed Tuple.pair
        |> BackendTask.Glob.captureFilePath
        |> BackendTask.Glob.match (BackendTask.Glob.literal "articles/")
        |> BackendTask.Glob.capture BackendTask.Glob.wildcard
        |> BackendTask.Glob.match (BackendTask.Glob.literal ".md")
        |> BackendTask.Glob.toBackendTask
        |> BackendTask.andThen
            (\files ->
                files
                    |> List.map
                        (\( path, slug ) ->
                            BackendTask.File.onlyFrontmatter (markdownMetadataDecoder slug) path
                                |> BackendTask.allowFatal
                        )
                    |> BackendTask.combine
            )


cmsArticlePublishedAtDecoder : Decode.Decoder Time.Posix
cmsArticlePublishedAtDecoder =
    Decode.oneOf
        [ Decode.field "publishedAt" Iso8601.decoder
        , -- 未来の日付にfallbackして記事一覧ページに表示させないようにする
          Decode.succeed (Time.millisToPosix (Time.posixToMillis Pages.builtAt + 240 * 60 * 60 * 1000))
        ]


cmsImageDecoder : Decode.Decoder CmsImage
cmsImageDecoder =
    Decode.succeed CmsImage
        |> Decode.andMap (Decode.field "url" Decode.string)
        |> Decode.andMap (Decode.field "height" Decode.int)
        |> Decode.andMap (Decode.field "width" Decode.int)


microCmsMetadata : BackendTask FatalError (List CmsArticleMetadata)
microCmsMetadata =
    let
        articleMetadataDecoder =
            Decode.succeed CmsArticleMetadata
                |> Decode.andMap (Decode.field "id" Decode.string)
                |> Decode.andMap (Decode.succeed True)
                |> Decode.andMap (Decode.field "publishedAt" Iso8601.decoder)
                |> Decode.andMap (Decode.field "revisedAt" Iso8601.decoder)
                |> Decode.andMap (Decode.field "title" Decode.string)
                |> Decode.andMap (Decode.maybe (Decode.field "image" cmsImageDecoder))
                |> Decode.andMap (Decode.succeed MicroCms)
    in
    cmsGet "https://ymtszw.microcms.io/api/v1/articles?limit=10000&orders=-publishedAt&fields=id,title,image,publishedAt,revisedAt"
        (Decode.field "contents" (Decode.list articleMetadataDecoder))


cmsGet : String -> Decode.Decoder a -> BackendTask FatalError a
cmsGet url decoder =
    BackendTask.Env.expect "MICROCMS_API_KEY"
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\microCmsApiKey ->
                BackendTask.Http.getWithOptions
                    { url = url
                    , headers = [ ( "X-MICROCMS-API-KEY", microCmsApiKey ) ]
                    , expect = BackendTask.Http.expectJson decoder
                    , cachePath = Nothing
                    , cacheStrategy = Nothing
                    , retries = Just 3
                    , timeoutInMs = Just 10000
                    }
                    |> BackendTask.allowFatal
            )
