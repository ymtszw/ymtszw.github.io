module LinkPreview exposing (Metadata, PseudoTweet, getMetadataOnDemand, isTweet, toPseudoTweet)

{-| LinkPreview API module.

サイトビルド時にLinkPreviewに依存するとたまに外部サイトの機嫌によってビルド失敗してしまい、鬱陶しい。
そこで、基本的にはruntimeにブラウザからLinkPreviewを呼び出してもらうにした。

FIXME: レイアウトシフトを嫌うなら、LinkPreviewガロードされていないときのスケルトンを改善する。

-}

import Helper exposing (nonEmptyString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Parser exposing (Node(..))
import Http
import OptimizedDecoder
import Regex
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

                    truncate str =
                        if String.length str > 150 then
                            String.left 150 str ++ "…"

                        else
                            str
                in
                -- If upstream requestUrl returned status >= 400, link-preview service returns error, failing this decoder
                OptimizedDecoder.succeed Metadata
                    -- Treat HTML without title (such as "301 moved permanently" page) as empty.
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" nonEmptyString)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.optionalField "description" (OptimizedDecoder.map truncate nonEmptyString))
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


getMetadataOnDemand : String -> String -> Task String ( String, Metadata )
getMetadataOnDemand amazonAssociateTag url =
    Http.task
        { method = "GET"
        , url = linkPreviewApiEndpoint url
        , headers = []
        , body = Http.emptyBody
        , timeout = Just 5000
        , resolver =
            Http.stringResolver <|
                \response ->
                    case response of
                        Http.GoodStatus_ _ body ->
                            OptimizedDecoder.decodeString (linkPreviewDecoder url) body
                                |> Result.map (\meta -> { meta | canonicalUrl = Helper.makeAmazonUrl amazonAssociateTag meta.canonicalUrl })
                                |> Result.mapError OptimizedDecoder.errorToString

                        _ ->
                            Err "something failed"
        }
        |> Task.map (Tuple.pair url)


isTweet : Metadata -> Bool
isTweet { canonicalUrl } =
    Regex.contains tweetPermalinkRegex canonicalUrl


tweetPermalinkRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://twitter\\.com/[^/]+/status/.+")


type alias PseudoTweet =
    { permalink : String
    , userName : String
    , screenName : String
    , body : String
    , firstAttachedImage : Maybe String
    }


toPseudoTweet : Metadata -> PseudoTweet
toPseudoTweet meta =
    -- LinkPreviewから得られる情報を元に、アーカイブツイートなどを擬似的にTweet情報として再現している。
    { permalink = meta.canonicalUrl
    , userName = String.replace "さんはTwitterを使っています" "" meta.title
    , screenName =
        -- 一度LinkPreviewで取得したTweet URL metadataのcanonicalUrlにはscreen name解決済みのURLが入っている
        -- e.g. https://twitter.com/gada_twt/status/1234567890123456789
        -- screen nameが分かればLinkPreviewサービスの裏機能でアイコン画像に解決できる
        meta.canonicalUrl
            |> Url.fromString
            |> Maybe.map .path
            -- "/gada_twt/status/1234567890123456789"
            |> Maybe.map (String.dropLeft 1)
            -- "gada_twt/status/1234567890123456789"
            |> Maybe.map (String.split "/")
            -- ["gada_twt", "status", "1234567890123456789"]
            |> Maybe.andThen List.head
            |> Maybe.withDefault "x"
    , body =
        meta.description
            |> Maybe.withDefault ""
            -- LinkPreviewではtweet descriptionに本文が入っているが、ダブルクォートされているので解除
            |> String.dropLeft 1
            |> String.dropRight 1
    , firstAttachedImage =
        -- LinkPreviewで取得したTweet URL metadataのimageには、
        -- 1. テキストのみツイートならユーザのアイコン画像が
        -- 2. メディア付きツイートなら1枚目のサムネイル画像が
        -- それぞれ入っているので、ここでは後者の取得を試みる
        meta.imageUrl
            |> Maybe.andThen
                (\url ->
                    if String.contains "profile_images" url then
                        Nothing

                    else
                        Just url
                )
    }
