module KindleBook exposing (ASIN, KindleBook, SeriesName, kindleBooks)

import DataSource exposing (DataSource)
import DataSource.Env
import DataSource.Http
import Date exposing (Date)
import Dict exposing (Dict)
import Helper exposing (dataSourceWith, decodeWith, nonEmptyString)
import KindleBookTitle exposing (kindleBookTitle)
import OptimizedDecoder
import Pages.Secrets as Secrets
import Regex


type alias KindleBook =
    { id : ASIN
    , rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : SeriesName
    , authors : List String
    , img : String -- 書影画像URL
    , acquiredDate : Date
    }


type alias ASIN =
    String


type alias SeriesName =
    String


kindleBooks : DataSource (Dict ASIN KindleBook)
kindleBooks =
    getFromGist (OptimizedDecoder.dict kindleBookDecoder)


getFromGist : OptimizedDecoder.Decoder a -> DataSource a
getFromGist decoder =
    dataSourceWith (DataSource.Env.load "BOOKS_JSON_URL") <|
        \booksJsonUrl -> DataSource.Http.get (Secrets.succeed booksJsonUrl) decoder


kindleBookDecoder : OptimizedDecoder.Decoder KindleBook
kindleBookDecoder =
    OptimizedDecoder.oneOf [ decodeNormalizedBook, decodeRawBook ]


decodeNormalizedBook =
    -- TODO 面倒なので、正規化（人力注釈）機能は必須項目を必ず埋めさせるようにする予定。
    -- また、decodeRawBookで機械的に正規化された結果はある程度そのまま保存する。
    -- ここではそれを前提に、最も特徴的なseriesNameの存在を先にチェックしてfail-fast.
    decodeWith (OptimizedDecoder.field "seriesName" nonEmptyString) <|
        \seriesName ->
            OptimizedDecoder.map8 KindleBook
                (OptimizedDecoder.field "id" nonEmptyString)
                (OptimizedDecoder.field "title" nonEmptyString)
                (OptimizedDecoder.maybe (OptimizedDecoder.field "label" nonEmptyString))
                (OptimizedDecoder.field "volume" OptimizedDecoder.int)
                (OptimizedDecoder.succeed seriesName)
                (OptimizedDecoder.field "authors" (OptimizedDecoder.list nonEmptyString))
                (OptimizedDecoder.field "img" nonEmptyString)
                (OptimizedDecoder.field "acquiredDate" japaneseDate)


decodeRawBook =
    decodeWith (OptimizedDecoder.field "title" kindleBookTitle) <|
        \parsed ->
            OptimizedDecoder.map8 KindleBook
                (OptimizedDecoder.field "id" nonEmptyString)
                (OptimizedDecoder.succeed parsed.rawTitle)
                (OptimizedDecoder.succeed (Maybe.map j2a parsed.label))
                (OptimizedDecoder.succeed parsed.volume)
                (OptimizedDecoder.succeed parsed.seriesName |> OptimizedDecoder.map j2a)
                (OptimizedDecoder.field "authors" (OptimizedDecoder.list (OptimizedDecoder.map (j2a >> normalizeAuthor) nonEmptyString) |> OptimizedDecoder.map (List.filter notStopWords)))
                (OptimizedDecoder.field "img" nonEmptyString)
                (OptimizedDecoder.field "acquiredDate" japaneseDate)


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


japaneseDate : OptimizedDecoder.Decoder Date
japaneseDate =
    decodeWith nonEmptyString <|
        \str ->
            OptimizedDecoder.fromResult <|
                case String.split "年" str of
                    [ year, monthDay ] ->
                        case String.split "月" monthDay of
                            [ month, day ] ->
                                Date.fromIsoString <| String.join "-" <| [ year, String.padLeft 2 '0' month, String.padLeft 2 '0' <| String.dropRight 1 day ]

                            _ ->
                                Err <| "Invalid Date: " ++ str

                    _ ->
                        Err <| "Invalid Date: " ++ str


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
