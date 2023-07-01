module Tests exposing (..)

import Expect
import KindleBookTitle exposing (KindleBookTitle)
import Test exposing (Test)


suite : Test
suite =
    Test.describe "KindleBookTitle.parse" <|
        [ t "少年ノート（８） (モーニングコミックス)" "少年ノート" 8 ( "モーニングコミックス", "講談社" )
        , t "乙嫁語り 6巻 (青騎士コミックス)" "乙嫁語り" 6 ( "青騎士コミックス", "KADOKAWA" )
        , t "つぐもも ： 3 (アクションコミックス)" "つぐもも" 3 ( "アクションコミックス", "DCコミックス" )
        , t "大室家: 1 (百合姫コミックス)" "大室家" 1 ( "百合姫コミックス", "一迅社" )
        , t "ドリフターズ（４） (ヤングキングコミックス)" "ドリフターズ" 4 ( "ヤングキングコミックス", "少年画報社" )
        , t "沈黙（新潮文庫）" "沈黙" 0 ( "新潮文庫", "新潮社" )
        , t "みつどもえ\u{3000}14 (少年チャンピオン・コミックス)" "みつどもえ" 14 ( "少年チャンピオン・コミックス", "秋田書店" )
        , t "蒼き鋼のアルペジオ(11) (ヤングキングコミックス)" "蒼き鋼のアルペジオ" 11 ( "ヤングキングコミックス", "少年画報社" )
        , f "フラッシュ・ボーイズ\u{3000}10億分の1秒の男たち"
        ]


t : String -> String -> Int -> ( String, String ) -> Test
t input seriesName volume labelAndPublisher =
    Test.test input <| \_ -> KindleBookTitle.parse input |> Expect.equal (KindleBookTitle Nothing input (Just labelAndPublisher) volume seriesName)


f input =
    Test.test input <|
        \_ ->
            case (KindleBookTitle.parse input).error of
                Just _ ->
                    Expect.pass

                Nothing ->
                    Expect.fail "Unexpectedly parsed"
