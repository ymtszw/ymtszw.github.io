module Tweet exposing (TweetParts(..), isTcoUrl, miniMarkdownParser, render)

{-| Tweetのテキストを各種処理してHTMLにする。

  - URLを自動リンク変換
      - Markdown書式を踏襲
  - 最終的に、各種前処理されたtweet由来のテキストをHTML化
      - というか、Markdownとして解釈
      - 副作用として、本来Markdownとして意識されていないTweet本文がMarkdownとして解釈されることになる

ここで`links : Dict String LinkPreview.Metadata`を引いてくればruntime link-previewもできるが、
Tweet表示ではinlineで表示するより別枠にプレビュー表示領域を設けた方がそれっぽくなるのでここではやらない。

TODO: ProユーザのリッチテキストTweetってどうなるんだ？

-}

import Dict
import Generated.HtmlEntities as HtmlEntities
import Helper
import Html exposing (Html)
import Html.Attributes exposing (href)
import Parser exposing (..)
import Regex exposing (Regex)


isTcoUrl : String -> Bool
isTcoUrl =
    Regex.contains tcoUrlInTweetRegex


render : String -> List (Html msg)
render rawText =
    rawText
        -- Shorten remaining t.co URLs. Another URLs, if any, will be autolinked by renderImpl
        |> Regex.replace tcoUrlInTweetRegex (\{ match } -> "[" ++ Helper.makeDisplayUrl match ++ "](" ++ match ++ ")")
        |> Regex.replace mentionRegex (\{ match } -> "[@" ++ String.dropLeft 1 match ++ "](https://twitter.com/" ++ String.dropLeft 1 match ++ ")")
        |> replaceHashtags ""
        |> renderImpl


replaceHashtags : String -> String -> String
replaceHashtags acc input =
    -- `#tokyoex #tokyoex_livestream`のように、前方一致するhashtagが同時存在している場合、まとめて変換されないようにしたい。
    -- 再帰関数で前方から順に処理していく。
    case input of
        "" ->
            acc

        rest ->
            case Regex.findAtMost 1 hashtagRegex rest of
                [ { match, index } ] ->
                    let
                        -- hashtagっぽいmatchが、Markdownリンクの内部にないことを確認する
                        -- これがないと、`[#foo](https://example.com)`や`[foo](https://example.com#foo)`のようなすでにここまでで整形されたテキストに含まれるhashtagらしき文字列が、
                        -- `[[#foo](https://example.com)](https://twitter.com/hashtag/foo)`と二重にリンク化されてしまう
                        hashInMarkdownLinkPattern =
                            Maybe.withDefault Regex.never (Regex.fromString ("(\\[[^\\]]*?" ++ match ++ "[^\\]]*?\\]\\(|\\]\\([^\\]]*?" ++ match ++ "[^\\]]*?\\))"))

                        doReplace _ =
                            let
                                skipped =
                                    String.left index rest

                                replaced =
                                    "[#" ++ String.dropLeft 1 match ++ "](https://twitter.com/hashtag/" ++ String.dropLeft 1 match ++ ")"

                                rest_ =
                                    String.dropLeft (String.length skipped + String.length match) rest
                            in
                            replaceHashtags (acc ++ skipped ++ replaced) rest_
                    in
                    case Regex.findAtMost 1 hashInMarkdownLinkPattern rest of
                        [ innerMatch ] ->
                            if innerMatch.index <= index then
                                -- 見つかったのはMarkdownリンク内部のhashtagっぽいマッチだった。該当部分スキップ
                                let
                                    skipped =
                                        String.left (index + String.length innerMatch.match) rest
                                in
                                replaceHashtags (acc ++ skipped) (String.dropLeft (String.length skipped) rest)

                            else
                                -- Markdownリンクが見つかったが、より後方にあった。とりあえず今のmatchについてはリンク化実行
                                doReplace ()

                        _ ->
                            -- Markdownリンクは見つからず、裸のhashtagだけがあった。リンク化実行
                            doReplace ()

                _ ->
                    -- findAtMostによって2件以上マッチはしないので、ここに来るのは0件のみ。即時終了
                    acc ++ rest


tcoUrlInTweetRegex : Regex
tcoUrlInTweetRegex =
    Maybe.withDefault Regex.never (Regex.fromString "https?://t.co/[a-zA-Z0-9]+")


mentionRegex : Regex
mentionRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...,@mention`のようなURLがあると誤認識する。が、制限事項とする
    -- 少なくともauthority partに@を含む認証可能URL（URL内に@を含むパターンとして第一にありがちなやつ）などはカンマが先行しないはず
    -- また、開きカッコなどの識別用意な記号に続くものも可能な限り対応。
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|[\\s,\\.\\(（、。])@[a-zA-Z0-9_]+")


hashtagRegex : Regex
hashtagRegex =
    -- 厳密にはURLはカンマを含むことができるので、`https://...?foo,bar,#hashtag`のようなURLがあると誤認識する。が、制限事項とする
    -- このRegexはdeny-list方式で、hashtagに使用できない文字列をひたすら列挙している。ASCII記号としては`_`以外すべての記号を除外。
    -- その他、Unicodeの記号系文字列も可能な範囲で弾いている。TODO: 「数字のみからなるもの」も除外対象だが、一つのRegexだと表現しづらい
    Maybe.withDefault Regex.never (Regex.fromString "(?<=^|[\\s,\\.\\(（、。])(#|＃)[^\\s!-/:-@\\[-\\^`{-~＠＃「」（）…]+")


renderImpl : String -> List (Html msg)
renderImpl str =
    str
        |> Helper.preprocessMarkdown
        |> Parser.run miniMarkdownParser
        |> Result.map tweetPartsToHtml
        |> Result.withDefault [ Html.text str ]


type TweetParts
    = Link String String
    | HtmlEntity String
    | LineBreak
    | Text String


{-| Markdownのサブセットとして、

  - `[...](...)`形式のリンク
  - HTMLエンティティ
  - 改行

だけをサポートしたParser. ハッシュタグやメンション、URL文字列などは事前処理で`[...](...)`形式に変換されていることを前提とする。

`Markdown.Parser`や`Markdown.Block`などの型はここでは使用せず、直接`List (Html msg)`に変換する。

-}
miniMarkdownParser : Parser (List TweetParts)
miniMarkdownParser =
    let
        linkParser =
            succeed Link
                |. symbol "["
                |= linkTextParser
                |. symbol "]("
                |= linkUrlParser
                |. symbol ")"

        linkTextParser =
            getChompedString (chompWhile (\c -> c /= ']' && c /= '\n' && c /= ' '))

        linkUrlParser =
            -- 絶対URLだけをvalidとする
            succeed (\rest -> "http" ++ rest)
                |. token "http"
                |= getChompedString (chompWhile (\c -> c /= ')' && c /= '\n' && c /= ' '))

        htmlEntityParser =
            succeed identity
                |. symbol "&"
                |= getChompedString (chompWhile (\c -> c /= ';' && c /= '\n' && c /= ' '))
                |. symbol ";"
                |> andThen lookupHtmlEntity

        lookupHtmlEntity entity =
            case Dict.get entity HtmlEntities.dict of
                Just value ->
                    succeed (HtmlEntity value)

                Nothing ->
                    problem ("Unknown HTML entity: &" ++ entity ++ ";")

        lineBreakParser =
            succeed LineBreak
                |. oneOf [ symbol "\n", symbol "\u{000D}\n" ]

        textParser =
            succeed Text
                |= getChompedString (chompIf (always True))

        finalize acc parsed =
            -- 例）
            -- parsed =
            --   [ Text "目"
            --   , Text "行"
            --   , Text "４"
            --   , LineBreak
            --   , Link "３行目" "https://example.com"
            --   , LineBreak
            --   , Text "目"
            --   , Text "行"
            --   , Text "２"
            --   , LineBreak
            --   , Text "目"
            --   , Text "行"
            --   , Text "１"
            --   ]
            case parsed of
                [] ->
                    acc

                (Text text) :: rest ->
                    case rest of
                        (Text nextText) :: restOfRest ->
                            -- 直後のトークンもTextだった場合、1つのTextにまとめていく
                            finalize acc (Text (nextText ++ text) :: restOfRest)

                        _ ->
                            -- Text以外の何か、またはparsed listの終わりが見えたときにはそのまま
                            finalize (Text text :: acc) rest

                other :: rest ->
                    finalize (other :: acc) rest
    in
    loop [] <|
        \acc ->
            oneOf
                [ oneOf
                    [ backtrackable linkParser
                    , backtrackable htmlEntityParser
                    , lineBreakParser
                    , textParser
                    ]
                    |> map (\parsed -> Loop (parsed :: acc))
                , end |> map (\() -> Done (finalize [] acc))
                ]


tweetPartsToHtml : List TweetParts -> List (Html msg)
tweetPartsToHtml parts =
    List.map
        (\part ->
            case part of
                Link text url ->
                    Html.a [ href url ] [ Html.text text ]

                HtmlEntity entity ->
                    Html.text entity

                LineBreak ->
                    Html.br [] []

                Text text ->
                    Html.text text
        )
        parts
