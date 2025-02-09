module Tests exposing (..)

import Expect
import KindleBookTitle exposing (KindleBookTitle)
import Test exposing (Test)


suite : Test
suite =
    Test.describe "KindleBookTitle.parse" <|
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


t : String -> String -> Int -> Maybe String -> Test
t input seriesName volume label =
    Test.test input <|
        \_ ->
            KindleBookTitle.parse input
                |> Expect.equal (Ok (KindleBookTitle input label volume seriesName))
