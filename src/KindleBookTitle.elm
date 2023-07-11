module KindleBookTitle exposing (KindleBookTitle, parse, possibleFailure)

import Parser as P exposing ((|.), (|=), Parser)


type alias KindleBookTitle =
    { rawTitle : String
    , label : Maybe String
    , volume : Int
    , seriesName : String
    }


possibleFailure : KindleBookTitle -> Maybe String
possibleFailure title =
    if title.volume == 0 && title.label == Nothing then
        Just <| "Volume/label missing" ++ " 『" ++ title.rawTitle ++ "』"

    else
        Nothing


parse : String -> Result String KindleBookTitle
parse rawTitle =
    case rawTitle of
        "" ->
            Err "Empty title"

        nonEmpty ->
            P.run (parser nonEmpty) (String.reverse nonEmpty) |> Result.mapError d2s


parser rawTitle =
    P.succeed (KindleBookTitle rawTitle)
        |. optional (reversedToken "(English Edition)")
        |. spaces_
        |= parseLabelReversed
        |. spaces_
        |. optional parsePerkReversed
        |. spaces_
        |= parseVolumeReversed
        |. spaces_
        |. optional parsePerkReversed
        |. spaces_
        |= parseSeriesNameReversed


parseLabelReversed : Parser (Maybe String)
parseLabelReversed =
    P.oneOf
        [ P.succeed Just
            |. braceClose
            |= labelLikeStringInBracesReversed
            |. braceOpen
            |> P.backtrackable
        , P.succeed Just
            |= nonSeparatedLabelLikeStringReversed
            |> P.backtrackable
        , P.succeed Nothing
        ]


labelLikeStringInBracesReversed : Parser String
labelLikeStringInBracesReversed =
    P.chompWhile (\c -> c /= '(' && c /= '（')
        |> P.getChompedString
        |> P.andThen labelLikeStringReversed


nonSeparatedLabelLikeStringReversed : Parser String
nonSeparatedLabelLikeStringReversed =
    P.chompWhile (\c -> c /= ' ' && c /= '\u{3000}')
        |> P.getChompedString
        |> P.andThen labelLikeStringReversed


labelLikeStringReversed : String -> Parser String
labelLikeStringReversed s =
    let
        reversed =
            String.reverse s

        labelLikeStringParts =
            -- よくある文字列を含まないこまっしゃくれたレーベル名や、英書のレーベル名が見つかったら例外対応する
            [ "A.L.C."
            , "BOOK"
            , "COMI"
            , "FC Jam"
            , "GANMA"
            , "KADOKAWA"
            , "KATTS"
            , "LiLy"
            , "MANGA"
            , "MFC"
            , "Oxford"
            , "Pragmatic Programmers"
            , "カドカワ"
            , "コミ"
            , "サンデー"
            , "ジャンプ"
            , "シリーズ"
            , "スペシャル"
            , "デジコレ"
            , "ブルーバックス"
            , "マガジン"
            , "まんが"
            , "マンガ"
            , "ライブラリ"
            , "角川"
            , "講談社"
            , "集英社"
            , "出版"
            , "小学館"
            , "新書"
            , "新潮"
            , "文庫"
            ]
    in
    if List.any (\part -> String.contains (String.toLower part) (String.toLower reversed)) labelLikeStringParts then
        P.succeed reversed

    else
        P.problem ("Expecting label-like string, got " ++ reversed)


parsePerkReversed : Parser ()
parsePerkReversed =
    -- 「【電子特典付き】」のような文字列。隅付き括弧で書かれていることが多い...？
    -- 「【公式アンソロジー小冊子「上野本」付き】限定版」のように連続してもよい。
    P.loop () <|
        \() ->
            P.oneOf
                [ P.oneOf
                    [ P.succeed ()
                        |. P.token "】"
                        -- 「【推しの子】」の例外対応。'子'で判定すると「【電子書籍版特典付き】」のようなケースを誤判定するので
                        -- より特徴的な文字で判定しなければならない。「【文化庁推薦】」のようなケースは諦めている
                        |. P.chompWhile (\c -> c /= '【' && c /= '推')
                        |. P.token "【"
                        |> P.backtrackable
                    , reversedToken "（通常版）"
                    , reversedToken "（限定版）"
                    , reversedToken "通常版"
                    , reversedToken "限定版"
                    , reversedToken "特装版"
                    , reversedToken "完全版"
                    , reversedToken "豪華版"
                    , reversedToken "デジタルVer."
                    , reversedToken "（完）"
                    , P.token " "
                    , P.token "\u{3000}"
                    ]
                    |> P.map (\_ -> P.Loop ())
                , P.succeed (P.Done ())
                ]


parseVolumeReversed : Parser Int
parseVolumeReversed =
    P.oneOf
        [ P.succeed identity
            |. braceClose
            |= P.oneOf
                [ numericVolumeReversed
                , -- 「彼とカレット。」１巻の例外対応
                  P.token "―" |> P.map (\_ -> 1)
                ]
            |. braceOpen
            |> P.backtrackable
        , P.succeed identity
            |= numericVolumeReversed
            |. spaces_
            |. colons
            |> P.backtrackable
        , P.succeed identity
            |. optional colons
            |. optional parsePerkReversed
            |. volumeSuffixReversed
            |= numericVolumeReversed
            |> P.backtrackable
        , P.succeed identity
            |= numericVolumeReversed
        , P.succeed 0
        ]


numericVolumeReversed =
    P.chompWhile (\c -> Char.isDigit c || List.member c [ '０', '１', '２', '３', '４', '５', '６', '７', '８', '９', '上', '中', '下' ])
        |> P.getChompedString
        |> P.andThen
            (\s ->
                case s of
                    "" ->
                        P.problem "Nothing to chomp, continue"

                    nonEmpty ->
                        case nonEmpty |> String.map j2a |> String.reverse |> String.toInt of
                            Just i ->
                                P.succeed i

                            Nothing ->
                                P.problem ("Expecting reversed Int, got " ++ nonEmpty)
            )


j2a c =
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

        '上' ->
            '1'

        '中' ->
            '2'

        '下' ->
            '3'

        _ ->
            c


volumeSuffixReversed =
    P.oneOf [ P.token "巻" ]


parseSeriesNameReversed : Parser String
parseSeriesNameReversed =
    P.chompWhile (always True)
        |> P.getChompedString
        |> P.andThen
            (\chomped ->
                case chomped of
                    "" ->
                        P.problem "SeriesName resulted in empty!"

                    nonEmpty ->
                        P.succeed (String.reverse nonEmpty)
            )



-- HELPERS


optional : Parser () -> Parser ()
optional p =
    P.oneOf
        [ p
        , P.succeed ()
        ]


spaces_ =
    P.chompWhile (\c -> c == ' ' || c == '\u{3000}' || c == '\n' || c == '\u{000D}' || c == '\t')


colons =
    P.oneOf [ P.token ":", P.token "：" ]


braceOpen =
    P.oneOf [ P.token "(", P.token "（" ]


braceClose =
    P.oneOf [ P.token ")", P.token "）" ]


reversedToken : String -> P.Parser ()
reversedToken label =
    P.token (String.reverse label)


d2s : List P.DeadEnd -> String
d2s deadends =
    deadends
        |> List.map
            (\{ col, row, problem } ->
                "(" ++ String.fromInt row ++ "," ++ String.fromInt col ++ "): " ++ p2s problem
            )
        |> String.join "\n"


p2s : P.Problem -> String
p2s problem =
    case problem of
        P.Expecting s ->
            "Expecting " ++ s

        P.ExpectingInt ->
            "ExpectingInt"

        P.ExpectingHex ->
            "ExpectingHex"

        P.ExpectingOctal ->
            "ExpectingOctal"

        P.ExpectingBinary ->
            "ExpectingBinary"

        P.ExpectingFloat ->
            "ExpectingFloat"

        P.ExpectingNumber ->
            "ExpectingNumber"

        P.ExpectingVariable ->
            "ExpectingVariable"

        P.ExpectingSymbol s ->
            "ExpectingSymbol " ++ s

        P.ExpectingKeyword s ->
            "ExpectingKeyword " ++ s

        P.ExpectingEnd ->
            "ExpectingEnd"

        P.UnexpectedChar ->
            "UnexpectedChar"

        P.Problem s ->
            "Problem: " ++ s

        P.BadRepeat ->
            "BadRepeat"
