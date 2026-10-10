# Agent Instructions for ymtszw.cc

このファイルは、各種 AI コーディングエージェント（GitHub Copilot, Claude Code, Cursor, Gemini, その他 AGENTS.md / Agents.md 対応ツール）がこのリポジトリで作業する際の共通指示書です。

---

## ⚠️ 最重要制約: README.md の編集禁止

- **`README.md` を勝手に更新・編集・リライトしてはなりません。**
- **理由**: 本リポジトリの `README.md` は、一般的なリポジトリ説明にとどまらず、Webサイトの公開ページである `/about` ページの本文コンテンツとして直接読み込まれて表示されています（参照: `app/Route/About.elm` 内の `BackendTask.File.bodyWithoutFrontmatter "README.md"`）。
- エージェントがリポジトリの概要更新や作業履歴の記載などの目的で `README.md` を編集すると、**公開サイトの表示内容が意図せず書き換わってしまいます**。
- プロジェクトや仕様の説明、実装計画、エージェント向け指示などは、本ファイル（`Agents.md`）や `docs/` ディレクトリ配下（`docs/GUIDELINES.md`、`docs/implementation-plans/` など）に記載してください。

---

## 必須の事前チェック

1. **コミュニケーション言語**:
   - 開発者とのやり取りは原則として**日本語**で行ってください。
2. **作業規模に応じたブランチ運用**:
   - 日常的な軽微な修正やドキュメント整備等は `master` ブランチで直接作業可能です。
   - 複数フェーズにわたる大規模な新機能開発やリファクタリングを行う場合は、`implementation-planning` スキルに従い作業用ブランチ（例: `feat/<name>`, `fix/<name>`）を作成・チェックアウトして進めてください。

---

## 開発開始のためのセットアップの流れ

### 1. 前提ツール・バージョン管理
- **Node.js**: v24系（リポジトリ直下の `.tool-versions` に指定あり。`mise` または `asdf` 等で自動切り替え可能）
- **direnv**（利用環境の場合）: `.envrc` により環境変数および `mise` 経由のツールパスが読み込まれます。

### 2. 依存関係インストール & 初期化
リポジトリルートで以下のコマンドを実行します：

```bash
npm install
```

> **Note**: `package.json` の `postinstall` スクリプトにより、以下の処理が自動的に実行されます：
> 1. `elm-tooling install`: `elm-tooling.json` で定義されたツール群（`elm`, `elm-format`, `elm-json`, `elm-test-rs`）の検証とインストール
> 2. `elm-pages gen`: elm-pages のコード生成（ページルートやメタデータの生成）

### 3. テスト実行による動作確認
インストール完了後、テストが通ることを確認します：

```bash
npm test
```
（`script/GenerateTwilogDataCodecTestFixtures` によるフィクスチャ生成と `elm-test-rs` によるテストが実行されます）

### 4. 開発サーバー起動
```bash
npm start
```
- `elm-pages dev --debug` が起動します（通常は `http://localhost:1234` でアクセス可能）。

### 5. 本番ビルド検証
```bash
npm run build
```
- `elm-pages build --strict` による静的ビルドが行われます。

### 6. Cloudflare Pages プレビュー（必要に応じて）
```bash
npm run start:wrangler
```
- 本番ビルド成果物（`dist`）を Wrangler ローカル環境で確認できます。

---

## 技術スタックと構成

- **言語 / フレームワーク**:
  - [Elm](https://elm-lang.org/) (0.19.1)
  - [elm-pages v3](https://github.com/dillonkearns/elm-pages)
  - TypeScript (カスタムバックエンドタスク `custom-backend-task.ts`, `index.ts` 等)
  - Vite (バンドラ / 開発サーバー基盤)
  - Cloudflare Pages / Wrangler (ホスティング・デプロイ)
  - CSS: Sakura.css ベースのカスタムスタイル (`style.css`)
- **ディレクトリ構成の概要**:
  - `app/`: elm-pages のページルートやレイアウト定義
  - `src/`: 共通の Elm モジュール
  - `articles/`: サイトに掲載される記事 Markdown ファイル
  - `data/`: Twilog データや天気データ等の静的データ
  - `script/`: データ生成・変換用スクリプト（Elm スクリプト）
  - `docs/`: 開発ガイドライン、実装計画書などのドキュメント
  - `dist/`: 本番ビルド出力先

---

## 実装・コード品質ガイドライン

- **Elm コードのフォーマット**:
  - Elm コード編集後は必ずフォーマッタを実行してください：
    ```bash
    npx elm-format --yes <編集したファイル>
    ```
  - **重要**: `elm-format` は行末コメント（`-- ...`）を次行の先頭に移動させる特性があります。コメントの意図が崩れていないか確認してください。
- **型安全性の重視**:
  - Elm および TypeScript の型システムを最大限に活用し、コンパイルエラーや未ハンドルのケースを残さないようにしてください。
- **ワークフロー・スキル**:
  - **Elm コード品質検証**: [.agents/skills/elm-workflow/SKILL.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/.agents/skills/elm-workflow/SKILL.md)（フォーマット、行末コメント確認、テスト、ビルド）
  - **大規模開発・計画策定**: [.agents/skills/implementation-planning/SKILL.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/.agents/skills/implementation-planning/SKILL.md)（Phase 分割、進捗記録フォーマット、計画書 `docs/implementation-plans/` の作成・管理）
  - **Twilog データ取り込み**: [.agents/skills/import-twilogs/SKILL.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/.agents/skills/import-twilogs/SKILL.md)（Twilog CSV 取り込み、検証、コミット＆プッシュの共同作業フロー）

