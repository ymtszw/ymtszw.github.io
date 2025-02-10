module KindleBook exposing (ASIN, KindleBook, SearchResult, Secrets, SeriesName, allBooksFromAlgolia, emptyResult, getOnDemand, putOnDemand, putOnDemandTask, search, secrets)

import BackendTask exposing (BackendTask)
import BackendTask.Http
import Date exposing (Date)
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Helper exposing (dataSourceWith, decodeWith, japaneseDateDecoder, nonEmptyString, requireEnv)
import Http
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Json.Encode
import KindleBookTitle exposing (kindleBookTitle)
import List.Extra
import Regex
import Task exposing (Task)
import Time exposing (Posix)
import Url


type alias KindleBook =
    { id : ASIN
    , rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : SeriesName
    , authors : List String
    , img : String -- 書影画像URL
    , acquiredDate : Date
    , reviewTitle : Maybe String
    , reviewMarkdown : Maybe String
    , reviewUpdatedAt : Maybe Posix
    , reviewPublishedAt : Maybe Posix
    }


type alias ASIN =
    String


type alias SeriesName =
    String


type alias Secrets =
    { appId : String
    , searchKey : String
    }


secrets : BackendTask FatalError Secrets
secrets =
    BackendTask.map2 Secrets
        (requireEnv "ALGOLIA_APP_ID")
        -- RuntimeにはReferrerと権限を制限したsearchKeyを使う
        (requireEnv "ALGOLIA_SEARCH_KEY")


type alias SearchResult =
    { searchTerm : String
    , formattedHits : List KindleBook
    , estimatedTotalHits : Int
    }


emptyResult : SearchResult
emptyResult =
    { searchTerm = ""
    , formattedHits = []
    , estimatedTotalHits = 0
    }


search : (Result String SearchResult -> msg) -> Secrets -> String -> Cmd msg
search tagger { appId, searchKey } term =
    Http.request
        { method = "POST"
        , url = "https://" ++ appId ++ "-dsn.algolia.net/1/indexes/ymtszw-kindle/query"
        , headers =
            [ Http.header "X-Algolia-Application-Id" appId
            , Http.header "X-Algolia-API-Key" searchKey
            ]
        , body = searchBody term
        , timeout = Just 5000
        , tracker = Nothing
        , expect = Http.expectJson (Result.mapError (\_ -> "") >> tagger) (searchResultDecoder term)
        }


searchBody : String -> Http.Body
searchBody term =
    Http.jsonBody <|
        Json.Encode.object
            [ ( "params", Json.Encode.string <| "query=" ++ Url.percentEncode term ++ "&hitsPerPage=100" )
            ]


searchResultDecoder : String -> Decode.Decoder SearchResult
searchResultDecoder term =
    Decode.map2 (SearchResult term)
        (Decode.field "hits" (Decode.list kindleBookDecoder))
        (Decode.field "nbHits" Decode.int)


getOnDemand : (Result String KindleBook -> msg) -> Secrets -> ASIN -> Cmd msg
getOnDemand tagger { appId, searchKey } objectId =
    Http.request
        { method = "GET"
        , url = "https://" ++ appId ++ "-dsn.algolia.net/1/indexes/ymtszw-kindle/" ++ objectId
        , headers =
            [ Http.header "X-Algolia-Application-Id" appId
            , Http.header "X-Algolia-API-Key" searchKey
            ]
        , body = Http.emptyBody
        , expect = Http.expectJson (Result.mapError (\_ -> "") >> tagger) kindleBookDecoder
        , timeout = Just 5000
        , tracker = Nothing
        }


putOnDemand : (Result String KindleBook -> msg) -> Secrets -> KindleBook -> Cmd msg
putOnDemand tagger secrets_ updatedBook =
    Task.attempt tagger (putOnDemandTask secrets_ updatedBook)


putOnDemandTask : Secrets -> KindleBook -> Task String KindleBook
putOnDemandTask { appId, searchKey } updatedBook =
    Http.task
        { method = "PUT"
        , url = "https://" ++ appId ++ "-dsn.algolia.net/1/indexes/ymtszw-kindle/" ++ updatedBook.id
        , headers =
            [ Http.header "X-Algolia-Application-Id" appId
            , Http.header "X-Algolia-API-Key" searchKey
            ]
        , body = Http.jsonBody (serialize updatedBook)
        , -- getOnDemand相当の結果は帰ってこない。当座は成功時、入力をそのまま返しておく。
          -- Call siteでgetOnDemandするかどうかは自由。
          resolver =
            Http.stringResolver <|
                \httpRes ->
                    case httpRes of
                        Http.GoodStatus_ _ _ ->
                            Ok updatedBook

                        _ ->
                            Err ""
        , timeout = Just 10000
        }


serialize : KindleBook -> Json.Encode.Value
serialize book =
    let
        maybe encoder val =
            Maybe.withDefault Json.Encode.null (Maybe.map encoder val)
    in
    Json.Encode.object
        [ ( "id", Json.Encode.string book.id )
        , ( "rawTitle", Json.Encode.string book.rawTitle )
        , ( "label", maybe Json.Encode.string book.label )
        , ( "volume", Json.Encode.int book.volume )
        , ( "seriesName", Json.Encode.string book.seriesName )
        , ( "authors", Json.Encode.list Json.Encode.string book.authors )
        , ( "img", Json.Encode.string book.img )
        , ( "acquiredDate", Json.Encode.string (Helper.toJapaneseDate book.acquiredDate) )
        , ( "reviewTitle", maybe Json.Encode.string book.reviewTitle )
        , ( "reviewMarkdown", maybe Json.Encode.string book.reviewMarkdown )
        , ( "reviewUpdatedAt", maybe (Json.Encode.string << Iso8601.fromTime) book.reviewUpdatedAt )
        , ( "reviewPublishedAt", maybe (Json.Encode.string << Iso8601.fromTime) book.reviewPublishedAt )
        ]


{-| KindleBookの全件DBを構成するDataSource.

スクレイピングデータの一時置き場であるGistから全IDリストを獲得し、
その後Algoliaから1000件ずつデータを取得して、最終的にDictに変換している。

Algolia側のデータはスクレイピングデータを格納したあと、
正規化（人力注釈）機能で更新されている情報が増えているかもしれない。

-}
allBooksFromAlgolia : BackendTask FatalError (Dict ASIN KindleBook)
allBooksFromAlgolia =
    let
        idsDecoder =
            Decode.dict (Decode.succeed ())
                |> Decode.map Dict.keys

        toDict =
            List.foldl
                (\books dict ->
                    List.foldl (\book dict_ -> Dict.insert book.id book dict_) dict books
                )
                Dict.empty
    in
    dataSourceWith (getFromGist idsDecoder) <|
        \ids ->
            ids
                |> List.Extra.greedyGroupsOf 1000
                |> List.map get1000FromAlgolia
                |> BackendTask.combine
                |> BackendTask.map toDict


{-| AlgoliaのGet Objects APIからデータを取得する。

ドキュメントされていないが、1回最大1000件までしか取得できないことに注意。

DocumentDBとしてAlgoliaを使っている格好だが、検索以外にフィルタ機構などはないので、
DataSourceとして全件取得してからよしなに使うことになる。

-}
get1000FromAlgolia : List ASIN -> BackendTask FatalError (List KindleBook)
get1000FromAlgolia ids =
    dataSourceWith secrets <|
        \{ appId } ->
            -- DataSourceではReferrer制限のないadminKeyを使う
            dataSourceWith (requireEnv "ALGOLIA_ADMIN_KEY") <|
                \adminKey ->
                    let
                        request id =
                            Json.Encode.object
                                [ ( "indexName", Json.Encode.string "ymtszw-kindle" )
                                , ( "objectID", Json.Encode.string id )
                                ]
                    in
                    BackendTask.Http.request
                        { method = "POST"
                        , url = "https://" ++ appId ++ "-dsn.algolia.net/1/indexes/*/objects"
                        , headers = [ ( "X-Algolia-Application-Id", appId ), ( "X-Algolia-API-Key", adminKey ) ]
                        , body = BackendTask.Http.jsonBody <| Json.Encode.object [ ( "requests", Json.Encode.list request ids ) ]
                        , retries = Nothing
                        , timeoutInMs = Just 30000
                        }
                        (BackendTask.Http.expectJson (Decode.field "results" (Decode.list kindleBookDecoder)))
                        |> BackendTask.allowFatal


getFromGist : Decode.Decoder a -> BackendTask FatalError a
getFromGist decoder =
    dataSourceWith (requireEnv "BOOKS_JSON_URL") <|
        \booksJsonUrl -> BackendTask.Http.getJson booksJsonUrl decoder |> BackendTask.allowFatal


kindleBookDecoder : Decode.Decoder KindleBook
kindleBookDecoder =
    Decode.oneOf [ decodeNormalizedBook, decodeRawBook ]
        |> Decode.andMap (Decode.maybe (Decode.field "reviewTitle" nonEmptyString))
        |> Decode.andMap (Decode.maybe (Decode.field "reviewMarkdown" nonEmptyString))
        |> Decode.andMap (Decode.maybe (Decode.field "reviewUpdatedAt" Iso8601.decoder))
        |> Decode.andMap (Decode.maybe (Decode.field "reviewPublishedAt" Iso8601.decoder))


decodeNormalizedBook =
    -- 人力注釈機能の仕様上、decodeRawBookで機械的に正規化された結果はある程度そのまま保存されることが多い。
    -- ここではそれを前提に、最も特徴的なseriesNameの存在を先にチェックしてfail-fast.
    decodeWith (Decode.field "seriesName" nonEmptyString) <|
        \seriesName ->
            Decode.map8 KindleBook
                (Decode.field "id" nonEmptyString)
                (Decode.field "rawTitle" nonEmptyString)
                (Decode.maybe (Decode.field "label" nonEmptyString))
                (Decode.field "volume" Decode.int)
                (Decode.succeed seriesName)
                (Decode.field "authors" (Decode.list nonEmptyString))
                (Decode.field "img" nonEmptyString)
                (Decode.field "acquiredDate" japaneseDateDecoder)


decodeRawBook =
    decodeWith (Decode.field "title" kindleBookTitle) <|
        \parsed ->
            Decode.map8 KindleBook
                (Decode.field "id" nonEmptyString)
                (Decode.succeed parsed.rawTitle)
                (Decode.succeed (Maybe.map j2a parsed.label))
                (Decode.succeed parsed.volume)
                (Decode.succeed parsed.seriesName |> Decode.map j2a)
                (Decode.field "authors" (Decode.list (Decode.map (j2a >> normalizeAuthor) nonEmptyString) |> Decode.map (List.filter notStopWords)))
                (Decode.field "img" nonEmptyString)
                (Decode.field "acquiredDate" japaneseDateDecoder)


j2a : String -> String
j2a =
    let
        mapper c =
            case c of
                '０' ->
                    '0'

                '１' ->
                    '1'

                '２' ->
                    '2'

                '３' ->
                    '3'

                '４' ->
                    '4'

                '５' ->
                    '5'

                '６' ->
                    '6'

                '７' ->
                    '7'

                '８' ->
                    '8'

                '９' ->
                    '9'

                'Ａ' ->
                    'A'

                'Ｂ' ->
                    'B'

                'Ｃ' ->
                    'C'

                'Ｄ' ->
                    'D'

                'Ｅ' ->
                    'E'

                'Ｆ' ->
                    'F'

                'Ｇ' ->
                    'G'

                'Ｈ' ->
                    'H'

                'Ｉ' ->
                    'I'

                'Ｊ' ->
                    'J'

                'Ｋ' ->
                    'K'

                'Ｌ' ->
                    'L'

                'Ｍ' ->
                    'M'

                'Ｎ' ->
                    'N'

                'Ｏ' ->
                    'O'

                'Ｐ' ->
                    'P'

                'Ｑ' ->
                    'Q'

                'Ｒ' ->
                    'R'

                'Ｓ' ->
                    'S'

                'Ｔ' ->
                    'T'

                'Ｕ' ->
                    'U'

                'Ｖ' ->
                    'V'

                'Ｗ' ->
                    'W'

                'Ｘ' ->
                    'X'

                'Ｙ' ->
                    'Y'

                'Ｚ' ->
                    'Z'

                'ａ' ->
                    'a'

                'ｂ' ->
                    'b'

                'ｃ' ->
                    'c'

                'ｄ' ->
                    'd'

                'ｅ' ->
                    'e'

                'ｆ' ->
                    'f'

                'ｇ' ->
                    'g'

                'ｈ' ->
                    'h'

                'ｉ' ->
                    'i'

                'ｊ' ->
                    'j'

                'ｋ' ->
                    'k'

                'ｌ' ->
                    'l'

                'ｍ' ->
                    'm'

                'ｎ' ->
                    'n'

                'ｏ' ->
                    'o'

                'ｐ' ->
                    'p'

                'ｑ' ->
                    'q'

                'ｒ' ->
                    'r'

                'ｓ' ->
                    's'

                'ｔ' ->
                    't'

                'ｕ' ->
                    'u'

                'ｖ' ->
                    'v'

                'ｗ' ->
                    'w'

                'ｘ' ->
                    'x'

                'ｙ' ->
                    'y'

                'ｚ' ->
                    'z'

                '\u{3000}' ->
                    ' '

                '（' ->
                    '('

                '）' ->
                    ')'

                _ ->
                    c
    in
    String.map mapper


normalizeAuthor : String -> String
normalizeAuthor raw =
    if String.all (\c -> Char.toCode c < 256) raw then
        -- Extended ASCIIまでは英字氏名とみなし、スペースを除去しない
        raw

    else
        -- 日本語表記の著者名は、姓名間のスペースを除去して正規化。カタカナ表記の海外著者名は若干不自然になるが許容する
        -- また、"()"で囲まれた装飾が後置されていることがあるので削除する
        -- ただし、著者名表記はほかにも表記揺れが多く、この正規化処理はおまけ程度。正規化（人力注釈）機能で巻き取る
        raw
            |> String.replace " " ""
            |> Regex.replace redundantAuthorSuffixPattern (\_ -> "")


redundantAuthorSuffixPattern =
    Regex.fromString "(\\(.*\\))$" |> Maybe.withDefault Regex.never


notStopWords raw =
    case raw of
        "ほか" ->
            False

        _ ->
            True
