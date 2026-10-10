---
name: elm-workflow
description: >-
  Workflows and quality validation steps for editing Elm files in ymtszw.cc.
  Activate when creating, editing, or refactoring Elm source files, or before committing Elm changes.
---

# Elm Workflow & Code Quality

ymtszw.cc リポジトリにおける Elm コード変更時の標準的な検証手順と注意事項です。
Elm ファイル（`app/`、`src/`、`script/` など）を変更した際、コミット前にこの手順に従って検証を行ってください。

## ワークフロー手順

### 1. コードフォーマット (`elm-format`)

変更した Elm ファイルに対して必ずフォーマッタを実行します：

```bash
npx elm-format --yes <編集したファイル>
```

複数ファイルやディレクトリ単位で実行する場合：
```bash
npx elm-format --yes app/ src/ script/
```

### 2. ⚠️ 重要: 行末コメント移動の確認と是正

`elm-format` には、パイプライン行末などのコメント（`-- ...`）を次行の先頭に移動させる特性があります。

**例:**
```elm
-- フォーマット前
    |> List.take 10 -- 先頭10件を取得

-- フォーマット後（意図とずれる場合がある）
    |> List.take 10
    -- 先頭10件を取得
    |> List.map .title
```

**確認手順:**
- `git diff <編集したファイル>` を実行し、コメントの位置が不自然に移動していないか確認する。
- パイプラインなどの文脈が壊れている場合は、パイプライン処理の前の行や関数ヘッダ等、適切な位置に手動で移動・修正する。

### 3. コード生成の確認 (`elm-pages gen`)

新しいページルートの追加（`app/Route/...`）や、メタデータ定義・ルーティングに変更を加えた場合は、コード生成を実行します：

```bash
npx elm-pages gen
```

### 4. テスト実行 (`npm test`)

型整合性と既存機能への影響を確認するため、テストを実行します：

```bash
npm test
```
- `script/GenerateTwilogDataCodecTestFixtures` によるテストフィクスチャ生成と `elm-test-rs` が実行されます。
- すべてのテストがパス（`TEST RUN PASSED`）することを確認してください。

### 5. 静的ビルド検証 (`npm run build`)

elm-pages による静的サイト生成が成功するか検証します：

```bash
npm run build
```
- `--strict` モードでビルドが実行されます。コンパイルエラーや未ハンドルの警告がないことを確認してください。
- **Note**: 本番ビルドには `.env` の環境変数（`MICROCMS_API_KEY` 等）が必要です。シェルに direnv が自動適用されていない場合は `direnv exec . npm run build`（または `mise exec -- npm run build`）を実行してください。また、Windows 環境では `.npmrc` の `script-shell=bash` により Git for Windows 等の bash 経由で実行されます。

### 6. Git 状態確認

```bash
git status
```
- 想定外の差分や生成ファイルの漏れがないことを確認します。
