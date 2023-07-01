module KindleBookTitle exposing (KindleBookTitle, parse)

import Parser as P exposing ((|.), (|=), Parser)


type alias KindleBookTitle =
    { error : Maybe String
    , rawTitle : String
    , labelAndPublisher : Maybe ( String, String )
    , volume : Int
    , seriesName : String
    }


parse : String -> KindleBookTitle
parse rawTitle =
    case P.run (parser rawTitle) (String.reverse rawTitle) |> Result.mapError d2s of
        Ok result ->
            result

        Err err ->
            KindleBookTitle (Just err) rawTitle Nothing 1 rawTitle


parser rawTitle =
    P.succeed (KindleBookTitle Nothing rawTitle)
        |= parseLabelAndPublisherReversed
        |. spaces_
        |= parseOptionalVolumeReversed
        |. spaces_
        |= parseSeriesNameReversed


parseLabelAndPublisherReversed : Parser (Maybe ( String, String ))
parseLabelAndPublisherReversed =
    P.succeed Just
        |. braceClose
        |= knownLabelAndPublisherReversed
        |. braceOpen


parseOptionalVolumeReversed : Parser Int
parseOptionalVolumeReversed =
    P.oneOf
        [ P.succeed identity
            |. braceClose
            |= numericVolumeReversed
            |. braceOpen
        , P.succeed identity
            |= numericVolumeReversed
            |. spaces_
            |. colons
            |> P.backtrackable
        , P.succeed identity
            |. volumeSuffixReversed
            |= numericVolumeReversed
        , P.succeed identity
            |= numericVolumeReversed
        , P.succeed 0
        ]


numericVolumeReversed =
    P.chompWhile (\c -> Char.isDigit c || List.member c [ '０', '１', '２', '３', '４', '５', '６', '７', '８', '９' ])
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

        _ ->
            c


volumeSuffixReversed =
    P.oneOf [ P.token "巻" ]


parseSeriesNameReversed : Parser String
parseSeriesNameReversed =
    P.chompWhile (always True)
        |> P.getChompedString
        |> P.map String.reverse



-- HELPERS


spaces_ =
    P.chompWhile (\c -> c == ' ' || c == '\u{3000}' || c == '\n' || c == '\u{000D}' || c == '\t')


colons =
    P.oneOf [ P.token ":", P.token "：" ]


braceOpen =
    P.oneOf [ P.token "(", P.token "（" ]


braceClose =
    P.oneOf [ P.token ")", P.token "）" ]


knownLabelAndPublisherReversed : Parser ( String, String )
knownLabelAndPublisherReversed =
    let
        help ( label, publisher ) =
            P.token (String.reverse label)
                |> P.map (\_ -> ( label, publisher ))
    in
    P.oneOf <|
        List.map help <|
            [ ( "モーニングコミックス", "講談社" )
            , ( "青騎士コミックス", "KADOKAWA" )
            , ( "アクションコミックス", "DCコミックス" )
            , ( "百合姫コミックス", "一迅社" )
            , ( "ヤングキングコミックス", "少年画報社" )
            , ( "新潮文庫", "新潮社" )
            , ( "少年チャンピオン・コミックス", "秋田書店" )
            ]


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
