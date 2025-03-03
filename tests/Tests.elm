module Tests exposing (..)

import Ephemeral.TwilogDataCodecTestFixtures
import Expect
import Json.Decode
import Json.Encode
import KindleBookTitle exposing (KindleBookTitle)
import Parser
import Test exposing (Test)
import Tweet exposing (TweetParts(..))
import TwilogData


suite : Test
suite =
    Test.concat
        [ Test.describe "KindleBookTitle.parse" <|
            let
                t : String -> String -> Int -> Maybe String -> Test
                t input seriesName volume label =
                    Test.test input <|
                        \_ ->
                            KindleBookTitle.parse input
                                |> Expect.equal (Ok (KindleBookTitle input label volume seriesName))
            in
            [ Test.test "(blank)" <| \_ -> KindleBookTitle.parse "" |> Expect.err
            , t "少年ノート（８） (モーニングコミックス)" "少年ノート" 8 (Just "モーニングコミックス")
            , t "乙嫁語り 6巻 (青騎士コミックス)" "乙嫁語り" 6 (Just "青騎士コミックス")
            , t "つぐもも ： 3 (アクションコミックス)" "つぐもも" 3 (Just "アクションコミックス")
            , t "大室家: 1 (百合姫コミックス)" "大室家" 1 (Just "百合姫コミックス")
            , t "ドリフターズ（４） (ヤングキングコミックス)" "ドリフターズ" 4 (Just "ヤングキングコミックス")
            , t "沈黙（新潮文庫）" "沈黙" 0 (Just "新潮文庫")
            , t "みつどもえ\u{3000}14 (少年チャンピオン・コミックス)" "みつどもえ" 14 (Just "少年チャンピオン・コミックス")
            , t "蒼き鋼のアルペジオ(11) (ヤングキングコミックス)" "蒼き鋼のアルペジオ" 11 (Just "ヤングキングコミックス")
            , t "妄想先生\u{3000}2巻【電子特典付き】 (バンチコミックス)" "妄想先生" 2 (Just "バンチコミックス")
            , t "花は咲く、修羅の如く 4 (ヤングジャンプコミックスDIGITAL)" "花は咲く、修羅の如く" 4 (Just "ヤングジャンプコミックスDIGITAL")
            , t "上野さんは不器用【Kindle限定おまけ付き】 5 (ヤングアニマルコミックス)" "上野さんは不器用" 5 (Just "ヤングアニマルコミックス")
            , t "上野さんは不器用 【公式アンソロジー小冊子「上野本」付き】限定版 6 (ヤングアニマルコミックス)" "上野さんは不器用" 6 (Just "ヤングアニマルコミックス")
            , t "少女終末旅行\u{3000}4巻: バンチコミックス" "少女終末旅行" 4 (Just "バンチコミックス")
            , t "少女終末旅行\u{3000}6巻（完）: バンチコミックス" "少女終末旅行" 6 (Just "バンチコミックス")
            , t "定時にあがれたら（２） (FC Jam)" "定時にあがれたら" 2 (Just "FC Jam")
            , t "見える子ちゃん\u{3000}１ (MFC)" "見える子ちゃん" 1 (Just "MFC")
            , t "火の鳥\u{3000}14" "火の鳥" 14 Nothing
            , t "【推しの子】 4 (ヤングジャンプコミックスDIGITAL)" "【推しの子】" 4 (Just "ヤングジャンプコミックスDIGITAL")
            , t "ＭＡＳＴＥＲキートン\u{3000}完全版\u{3000}デジタルVer.（１１） (ビッグコミックススペシャル)" "ＭＡＳＴＥＲキートン" 11 (Just "ビッグコミックススペシャル")
            , t "MASTERキートン Reマスター 豪華版 デジタルVer.（１） (ビッグコミックススペシャル)" "MASTERキートン Reマスター" 1 (Just "ビッグコミックススペシャル")
            , t "銃夢（１）" "銃夢" 1 Nothing
            , t "彼とカレット。 (―)" "彼とカレット。" 1 Nothing
            , t "フラッシュ・ボーイズ\u{3000}10億分の1秒の男たち" "フラッシュ・ボーイズ\u{3000}10億分の1秒の男たち" 0 Nothing
            , t "SQL Antipatterns: Avoiding the Pitfalls of Database Programming (Pragmatic Programmers) (English Edition)" "SQL Antipatterns: Avoiding the Pitfalls of Database Programming" 0 (Just "Pragmatic Programmers")
            , t "Metaprogramming Elixir: Write Less Code, Get More Done (and Have Fun!) (English Edition)" "Metaprogramming Elixir: Write Less Code, Get More Done (and Have Fun!)" 0 Nothing
            , t "初版\u{3000}金枝篇\u{3000}上 (ちくま学芸文庫)" "初版\u{3000}金枝篇" 1 (Just "ちくま学芸文庫")
            , t "アフタヌーン 2019年1月号 [2018年11月24日発売] [雑誌]" "アフタヌーン 2019年1月号 [2018年11月24日発売] [雑誌]" 0 Nothing
            , -- サブタイトルの前に巻数が入っているパターンには対応できない。これは人力注釈が必要
              t "サピエンス全史（下）\u{3000}文明の構造と人類の幸福 サピエンス全史\u{3000}文明の構造と人類の幸福" "サピエンス全史（下）\u{3000}文明の構造と人類の幸福 サピエンス全史\u{3000}文明の構造と人類の幸福" 0 Nothing
            ]
        , Test.describe "Tweet.linkAndLineBreakParser" <|
            let
                t : String -> List TweetParts -> Test
                t input expected =
                    Test.test ("---input START---\n" ++ input ++ "\n---END---") <|
                        \_ ->
                            input
                                |> Parser.run Tweet.miniMarkdownParser
                                |> Expect.equal (Ok expected)
            in
            [ t "" []
            , t "https://example.com" [ Text "https://example.com" ]
            , t "[Link](https://example.com)" [ Link "Link" "https://example.com" ]
            , t """１行目
[２行目](https://example.com)
３行目
[４行目の１](https://example.com) [４行目の２](https://example.com)
５行目、[壊れたLink](http://example.comを含む
６行目も壊れたLinkを含む](https://example.com)
７行目は[一応Linkとして成立しているが](https://example.com)余計な物がある)
８行目は[絶対URLとして正しくないLinkを含む](ftp://example.com)


11行目は上２行の空行のあとにある
12行目には[複数の](https://example.com, 壊れたURL](//example.com)を含む"""
                [ Text "１行目"
                , LineBreak
                , Link "２行目" "https://example.com"
                , LineBreak
                , Text "３行目"
                , LineBreak
                , Link "４行目の１" "https://example.com"
                , Text " "
                , Link "４行目の２" "https://example.com"
                , LineBreak
                , Text "５行目、[壊れたLink](http://example.comを含む"
                , LineBreak
                , Text "６行目も壊れたLinkを含む](https://example.com)"
                , LineBreak
                , Text "７行目は"
                , Link "一応Linkとして成立しているが" "https://example.com"
                , Text "余計な物がある)"
                , LineBreak
                , Text "８行目は[絶対URLとして正しくないLinkを含む](ftp://example.com)"
                , LineBreak
                , LineBreak
                , LineBreak
                , Text "11行目は上２行の空行のあとにある"
                , LineBreak
                , Text "12行目には[複数の](https://example.com, 壊れたURL](//example.com)を含む"
                ]
            ]
        , Test.describe "TwilogData codec roundtrip" <|
            let
                t : String -> Test
                t input =
                    Test.test ("Test codec with: " ++ String.left 200 input) <|
                        \_ ->
                            case
                                -- Note: 以前のimport_twilogs.mjsでCSVからインポートしたJSON形式とTwilogData.serializeToOnelineTwilogJsonで生成したJSON形式は本質的には同等だが、
                                -- フィールドの順序や、対応するElmデータがempty listやNothingのときにフィールドを省略するかどうかなど、細かい部分で異なる。
                                -- そこでoriginalJson |> decode1 |> encode |> decode2と2回decodeを試して1回目と2回目の結果（Elmでの取り込み済みデータ）が一致しているかどうかを検証する。
                                input
                                    |> Json.Decode.decodeString (TwilogData.twilogDecoder Nothing)
                                    |> Result.map (\decoded1 -> ( decoded1, TwilogData.serializeToOnelineTwilogJson False decoded1 |> Json.Encode.encode 0 ))
                                    |> Result.andThen (\( decoded1, serialized ) -> Json.Decode.decodeString (TwilogData.twilogDecoder Nothing) serialized |> Result.map (Tuple.pair decoded1))
                            of
                                Ok ( decoded1, decoded2 ) ->
                                    Expect.equal decoded1 decoded2

                                Err err ->
                                    Expect.fail (Debug.toString err)
            in
            List.map t Ephemeral.TwilogDataCodecTestFixtures.fixtures
        ]
