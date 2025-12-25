module BackendTask.MermaidDiagram exposing (processMermaid)

{-| Mermaid図の処理を行うBackendTask

このmoduleは、Markdownソース内のMermaidコードブロックを検出し、
自動的にSVG画像を生成して画像参照に置換します。

@docs processMermaid

-}

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import FatalError
import Json.Decode
import Json.Encode


{-| Markdownソース内のMermaidブロックを画像参照に置換する

入力: Markdownソース（フロントマター有無両対応）
出力: 処理済みMarkdownソース

Mermaidブロック（\`\`\`mermaid ... \`\`\`）が見つかった場合：

  - 各ブロックのソースからハッシュベースのIDを生成
  - mermaid-cliを使用してSVG画像を生成（`dist/images/diagrams/<hash>.svg`）
  - Markdownソース内のMermaidブロックを画像参照（`![Mermaid Diagram](...)`）に置換

Mermaidブロックが見つからない場合：

  - 元のMarkdownソースをそのまま返す

エラー処理：

  - 画像生成に失敗した場合は、元のMermaidブロックをそのまま残す（フォールバック）
  - TypeScript側でエラーログを出力

-}
processMermaid : String -> BackendTask FatalError.FatalError String
processMermaid markdownSource =
    BackendTask.Custom.run "processMermaid"
        (Json.Encode.string markdownSource)
        Json.Decode.string
        |> BackendTask.allowFatal
