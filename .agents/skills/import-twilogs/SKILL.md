---
name: import-twilogs
description: >-
  Twilog CSV のダウンロード確認からインポート、ビルド検証、コミット＆プッシュまでの一連の流れを実行する共同作業ワークフロー。
  Twilog データの取り込みや定期更新を行う際、または手動実行 automation から呼び出される際に使用する。
---

# Twilog データ取り込みワークフロー (`import-twilogs`)

ymtszw.cc における Twilog（Twitter/X ログ）データの定期取り込み・同期を、**ユーザーと Agent の共同作業**として実行するためのワークフローです。
macOS および Windows の両環境に対応しています。

---

## 役割分担（ユーザーと Agent の共同作業）

| 担当 | 内容 |
| :--- | :--- |
| **ユーザー** | 1. ブラウザで [Twilog](https://twilog.togetter.com/) にログイン<br>2. 最新ログの CSV をエクスポート・ダウンロード（`gada_twt-*.csv`）<br>3. ダウンロード完了を Agent に伝える（またはダウンロード済み状態で automation を実行） |
| **Agent** | 1. ダウンロードフォルダ内の最新 CSV ファイルの確認<br>2. `npm run import_twilogs` の実行<br>3. テスト・ビルド等の検証（`npm test` など）<br>4. `npm run push_recent_twilogs` によるコミット＆プッシュ<br>5. 完了報告 |

---

## ワークフロー手順

### Step 1: ダウンロード済み CSV の確認

Agent は、ユーザーのダウンロードフォルダ（macOS: `~/Downloads/`, Windows: `%USERPROFILE%\Downloads\`）に最新の `gada_twt-*.csv` が存在するか確認します。

- **ファイルが見つかった場合**:
  - ファイルの更新日時やファイル名の日付サフィックスを確認し、最新のダウンロードであることを確認して Step 2 へ進みます。
- **ファイルが見つからない、または明らかに古い場合**:
  - ユーザーに Twilog からの最新 CSV エクスポート・ダウンロードを依頼し、ダウンロード完了の合図を待ちます。

### Step 2: インポート実行 (`npm run import_twilogs`)

リポジトリルートでインポートスクリプトを実行します：

```bash
npm run import_twilogs
```

- スクリプト内部（`script/ImportTwilogCsvAndBuildSearchIndex.elm`）で自動的にホームディレクトリ（`HOME` または `USERPROFILE`）配下の `Downloads/gada_twt-*.csv` から最新のファイルを取得し、取り込み処理を行います。
- パスを直接指定して実行することも可能です：
  ```bash
  npm run import_twilogs -- /path/to/gada_twt-YYMMDD.csv
  ```

**実行結果の判定**:
- `Imported N Twilogs`: 新規ツイートが正常に取り込まれ、検索インデックス・アーカイブ一覧が更新された状態。→ Step 3 へ。
- `No new Twilogs to import`: すでに最新データまで取り込み済み。追加作業は不要のため、ユーザーにその旨を報告して終了します。

### Step 3: 品質・ビルド検証

新規データが取り込まれた場合は、サイトの整合性を検証します：

1. **テスト実行**:
   ```bash
   npm test
   ```
   - テストフィクスチャの再生成とテストがすべて通ることを確認します。

2. **本番ビルド検証（推奨）**:
   - リポジトリに `.env` がある環境の場合：
     - macOS / Linux: `env $(grep -v '^#' .env | xargs) npm run build`
     - Windows (PowerShell): `$env:MICROCMS_API_KEY="..." ; npm run build` （direnv / 環境変数が適用されている場合は `npm run build` 単体で可）

### Step 4: 変更確認とコミット＆プッシュ

1. **Git 状態の確認**:
   ```bash
   git status
   ```
   - ブランチが `master` であることを確認します。
   - `data/` 配下および `src/Generated/TwilogArchives.elm` に変更があることを確認します。

2. **プッシュスクリプトの実行**:
   クロスプラットフォーム対応のスクリプトを実行します（macOS / Windows 共通）：
   ```bash
   npm run push_recent_twilogs
   ```

   このスクリプトは内部で以下を自動実行します：
   - 現在のブランチが `master` か検証
   - `data/` および `src/Generated/` の変更をステージング
   - `feat: imported recent twilogs (<日時>)` でコミット
   - `git push origin HEAD:master` でリモートへプッシュ

### Step 5: 完了報告

Agent はユーザーに以下を報告して終了します：
- 取り込まれたツイート件数
- コミットとプッシュの完了（またはコミットハッシュ）

---

## OS 互換性（macOS / Windows）について

- **パス解決**:
  - `script/ImportTwilogCsvAndBuildSearchIndex.elm` は `HOME` および `USERPROFILE` の両方を参照し、バックスラッシュ（`\`）をスラッシュ（`/`）に正規化して glob パターンを評価します。
- **実行スクリプト**:
  - コミット＆プッシュ処理は elm-pages script（`script/PushRecentTwilogs.elm`）および最小限の Custom BackendTask（`custom-backend-task.ts` の `execCommand`）として実装されています。
  - `npm run push_recent_twilogs` を通じて macOS (zsh/bash) でも Windows (PowerShell/cmd) でも Elm ベースの同一ロジックで動作します。

---

## Automation での実行例

手動実行の Automation を定義する場合のプロンプト例：

```markdown
Twilog データの取り込みを実行してください。
Downloads フォルダにある最新の Twilog CSV (gada_twt-*.csv) を確認し、
import-twilogs スキルの手順に従ってインポート、テスト検証、コミット＆プッシュまで完了してください。
もし最新の CSV が見つからない場合は、ダウンロードを促してください。
```
