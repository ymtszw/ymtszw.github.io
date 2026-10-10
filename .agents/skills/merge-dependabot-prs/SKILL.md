---
name: merge-dependabot-prs
description: >-
  Dependabot が作成した更新 PR を手元の master ブランチに順次マージし、依存関係の更新・テスト・ビルド検証を行って GitHub リモートへプッシュ・反映するワークフロー。
  Dependabot PR の一括・個別マージや定期的な依存更新対応時に使用する。
---

# Dependabot PR マージ & 検証ワークフロー (`merge-dependabot-prs`)

ymtszw.cc において、Dependabot が作成した依存パッケージ更新 PR を手元の `master` ブランチに安全に取り込み、検証・プッシュして GitHub 上で `MERGED` 扱いにするための定型ワークフローです。

---

## ワークフロー手順

### Step 1: リモートの更新と PR の特定

1. **リモートブランチの取得**:
   ```bash
   git fetch --all --prune
   ```

2. **オープンな Dependabot PR の確認**:
   ```bash
   gh pr list
   ```
   - 出力された PR のうち、Dependabot 作成（タイトルが `chore(deps...): bump ...` 等）の PR 番号とブランチ名を確認します。
   - `git status` を確認し、ローカルがクリーンな `master` ブランチ（`origin/master` と一致）であることを確認します。

### Step 2: `master` への順次マージ

各 Dependabot ブランチを `master` に順次マージします：

```bash
git merge --no-edit origin/<dependabot-branch-name>
```

#### ⚠️ コンフリクト（競合）発生時の対処手順
複数の Dependabot PR（特に `package-lock.json` のみの更新）を連続してマージすると、`package-lock.json` 内で競合が発生することがあります。その場合は以下の手順で解消します：

1. `package.json` に更新がある場合はその変更を取り込みます。
2. 競合した `package-lock.json` は手動編集せず、`npm install` を実行して lockfile を再解決・再生成させます：
   ```bash
   npm install
   git add package.json package-lock.json
   git commit --no-edit
   ```

### Step 3: Sanity Check（整合性・品質検証）

マージ完了後、依存関係のインストール、テスト、本番静的ビルドを一通り検証します：

1. **依存関係の同期 & コード生成**:
   ```bash
   npm install
   ```
   - `postinstall` スクリプト（`elm-tooling install` および `elm-pages gen`）が正常に完了することを確認します。

2. **テスト実行**:
   ```bash
   npm test
   ```
   - `script/GenerateTwilogDataCodecTestFixtures` によるテストフィクスチャ生成と `elm-test-rs` による 140+ 件のテストがすべて成功（`TEST RUN PASSED`）することを確認します。

3. **本番静的ビルド検証**:
   - **重要**: 本番ビルドには `.env` の環境変数（`MICROCMS_API_KEY` 等）が必須です。シェルに direnv が自動適用されていない場合は必ず `direnv exec`（または `mise exec`）を使用してください：
     ```bash
     direnv exec . npm run build
     # または
     mise exec -- npm run build
     ```
   - 静的サイト生成および Cloudflare Pages adapter の生成がエラーなく完了することを確認します。

### Step 4: 差分・制約チェック

コミットログと全体の差分を確認します：

```bash
git log -n 5 --graph --oneline
git diff origin/master..HEAD
```

- **⚠️ 最重要制約チェック**:
  - `README.md` が差分に含まれていないことを必ず確認してください（公開サイト `/about` に影響するため）。
  - 差分が `package.json` や `package-lock.json`（および必要に応じた最小限のコード修正）のみであることを確認します。

### Step 5: プッシュ & GitHub 側の状態確認

1. **`master` へのプッシュ**:
   ```bash
   git push origin master
   ```
   - GitHub は手元でのマージコミットを検知し、対象の PR を自動的に `MERGED` 扱いにします。

2. **PR 状態の確認**:
   ```bash
   gh pr view <PR番号> --json state,mergedAt,title
   # またはオープンな PR 一覧の確認
   gh pr list
   ```
   - 対象 PR が `MERGED` となり、オープンな PR 一覧から解消されたことを確認します。

### Step 6: 完了報告

ユーザーに以下を報告します：
- マージ・解消された Dependabot PR 一覧
- テストおよびビルド検証の結果
- `master` へのプッシュおよび GitHub 上での `MERGED` 状態遷移の確認
