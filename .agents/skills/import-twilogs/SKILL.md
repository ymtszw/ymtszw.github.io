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
| **ユーザー** | 初回またはセッション切れ時のみ、専用Chromeプロファイル（`~/.chrome-profiles/twilog-sync`）で [Twilog](https://twilog.togetter.com/) にログインし、ウィンドウを閉じておく |
| **Agent** | 1. リポジトリの最新化（`git pull` 等）<br>2. `npm run download_twilogs` による最新 CSV（UTF-8）の自動ダウンロード<br>3. `npm run import_twilogs` の実行（※最新 CSV の検出はスクリプトが自動処理）<br>4. テスト・ビルド等の検証（`npm test`, `npm run build`）<br>5. `npm run push_recent_twilogs` によるコミット＆プッシュ<br>6. 完了報告 |

---

## ワークフロー手順

### Step 1: コードの最新化

作業開始前にリモートの最新状態を取り込みます：

```bash
git checkout master
git pull origin master
```

### Step 2: 最新 CSV の自動ダウンロード (`npm run download_twilogs`)

専用Chromeプロファイル（`~/.chrome-profiles/twilog-sync`、環境変数 `TWILOG_CHROME_PROFILE_DIR` で上書き可）のログイン済みセッションを使い、ヘッドレスで Twilog 設定画面から UTF-8 版 CSV を `~/Downloads` へ自動ダウンロードします：

```bash
npm run download_twilogs
# Windows 環境で .npmrc の script-shell=bash が見つからない場合:
node script/download-twilog-csv.mjs
```

- `Downloaded: ... (N bytes)`: ダウンロード成功 → Step 3 へ。
- `AUTH_REQUIRED`（終了コード `2`）またはタイムアウト: セッション切れまたは未ログイン状態です。ユーザーに専用Chromeプロファイルでの手動ログイン（起動後にブラウザを閉じる）を促して終了します。
- ※ 同一プロファイルを開いたままにするとロック競合で失敗するため、手動ログイン後は必ず専用ウィンドウを閉じてください。

### Step 3: インポート実行 (`npm run import_twilogs`)

リポジトリルートでインポートスクリプトを実行します：

```bash
npm run import_twilogs
```

- スクリプト内部（`script/ImportTwilogCsvAndBuildSearchIndex.elm`）で自動的にホームディレクトリ（`HOME` または `USERPROFILE`）配下の `Downloads/gada_twt-*.csv` から最新のファイルを取得し、取り込み処理を行います。**Agent による事前の CSV 存在確認は不要です**。
- パスを直接指定して実行することも可能です：
  ```bash
  npm run import_twilogs -- /path/to/gada_twt-YYMMDD.csv
  ```

**実行結果の判定**:
- `Imported N Twilogs`: 新規ツイートが正常に取り込まれ、検索インデックス・アーカイブ一覧が更新された状態。→ Step 3 へ。
- `No new Twilogs to import`: すでに最新データまで取り込み済み。追加作業は不要のため、ユーザーにその旨を報告して終了します。
- `No Twilog CSV files found in ...`: CSV ファイルが見つからない場合のエラー。ユーザーに Twilog からの最新 CSV エクスポート・ダウンロードを促すメッセージを出力して終了します。

### Step 3: 品質・ビルド検証

新規データが取り込まれた場合は、サイトの整合性を検証します：

1. **テスト実行**:
   ```bash
   npm test
   ```
   - テストフィクスチャの再生成とテストがすべて通ることを確認します。

2. **本番ビルド検証（推奨）**:
   - direnv / mise が有効な環境では通常通り実行します：
     ```bash
     npm run build
     ```
   - direnv が自動適用されていないシェルの場合：
     ```bash
     direnv exec . npm run build
     # または
     mise exec -- npm run build
     ```

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
- **ランタイムと環境変数 (direnv & mise)**:
  - macOS および Windows の双方で direnv および mise が利用可能です。`.envrc` により Node.js 24、`NODE_OPTIONS`、および `.env`（`MICROCMS_API_KEY` 等）が自動的にロードされます。シェルに自動フックされていない場合は `direnv exec . <command>` または `mise exec -- <command>` を前置して実行可能です。

---

## Automation での実行例

手動実行の Automation を定義する場合のプロンプト例：

```markdown
import-twilogs スキルを実行してください。
事前に最新のコードを取得（git checkout master && git pull origin master）した上で、CSVダウンロード（npm run download_twilogs）、インポート（npm run import_twilogs）、テスト実行（npm test）、ビルド検証（npm run build）、プッシュ（npm run push_recent_twilogs）まで完了してください。
（認証切れ等で download_twilogs が失敗した場合は、専用Chromeプロファイルでの再ログインを促すメッセージを出力して終了してください。）
```
