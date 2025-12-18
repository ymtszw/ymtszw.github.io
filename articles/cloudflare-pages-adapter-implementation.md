---
title: "elm-pagesでSSR: Cloudflare Pages対応"
description: |
  elm-pages v3でCloudflare Pages Functions対応のadapterを実装した記録。
  静的サイトからserver-side renderingへの拡張、実装の詳細、CI/CD統合、トラブルシューティングまで。
---

> **Note**: この記事は、実装作業を行った[GitHub Copilot](https://github.com/features/copilot)のコーディングエージェントが自動生成したものです。
> 人間の指示をもとに[実装計画書](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/docs/implementation-plans/CLOUDFLARE_ADAPTER_IMPLEMENTATION_PLAN.md)を作成し、その計画に従って実装作業を進めました。
> この記事は、実装計画書や作業ログを元に、技術的な詳細を包括的にまとめています。

このサイト（ymtszw.cc）は[elm-pages]を使って作られています。

elm-pages v3では、静的サイト生成（Static Site Generation, SSG）だけでなく、server-side rendering（SSR）機能も提供されています。
この記事では、Cloudflare Pages Functions上でSSRを動作させるための**adapter**を実装した過程を記録します。

[elm-pages]: https://github.com/dillonkearns/elm-pages

## 背景と動機

このサイトをCloudflare Pagesにデプロイしていますが、elm-pagesの公式Cloudflare Pages adapterが存在しなかったため、自分で実装しました。

elm-pagesには公式の[Netlify adapter](https://github.com/dillonkearns/elm-pages/blob/master/adapter/netlify.js)がリファレンス実装として存在します。
コミュニティでは[Express](https://github.com/shahnhogan/elm-pages-starter-express)、[Fastify](https://github.com/shahnhogan/elm-pages-starter-fastify)、[AWS Lambda](https://gist.github.com/adamdicarlo0/221e839050a3e8cef51f1849e7af71a9)などのプラットフォーム向けadapterが開発されていますが（[Discussion #378](https://github.com/dillonkearns/elm-pages/discussions/378)参照）、Cloudflare Pages Functions向けの実装は存在しませんでした。

## Cloudflare Pages Functions

[Cloudflare Pages Functions](https://developers.cloudflare.com/pages/functions/)は、Cloudflare Workersベースのサーバーサイド実行環境です。

adapter実装で重要な特徴：

- **Fetch API標準**: `Request`/`Response`オブジェクトを使用（[リクエスト仕様](https://developers.cloudflare.com/workers/runtime-apis/request/)）
- **ファイルベースルーティング**: `functions/[[path]].ts`形式のcatch-allハンドラ（[ルーティング仕様](https://developers.cloudflare.com/pages/functions/routing/)）
- **_routes.json**: Functions実行の制御（[_routes.json仕様](https://developers.cloudflare.com/pages/functions/routing/#functions-invocation-routes)）

詳細は[Cloudflare Pages Functions公式ドキュメント](https://developers.cloudflare.com/pages/functions/)を参照してください。

## アーキテクチャ設計

### 全体の流れ

```text
elm-pages build
  ↓
elm-pages.config.mjs
  ↓ adapter/cloudflare-pages.js を実行
  ↓
├─ dist/ (静的アセット)
│  ├─ _routes.json (ルーティング設定)
│  └─ ... (HTML, CSS, JS等)
└─ functions/ (Server-side)
   ├─ [[path]].ts (catch-allハンドラ)
   └─ elm-pages-cli.mjs (renderエンジン)
```

### 主要コンポーネント

#### 1. Adapter関数（adapter/cloudflare-pages.js）

`elm-pages.config.mjs`から読み込まれ、elm-pagesのビルド時に実行される関数で、以下を行います：

- elm-pages renderエンジンを`functions/`にコピー
- TypeScriptハンドラファイルを生成
- `_routes.json`を生成してルーティングを制御

```javascript
export default async function run({
  renderFunctionFilePath,
  routePatterns,
  apiRoutePatterns,
}) {
  // 1. renderエンジンをコピー
  fs.copyFileSync(renderFunctionFilePath, "./functions/elm-pages-cli.mjs");

  // 2. ハンドラを生成
  fs.writeFileSync("./functions/[[path]].ts", handlerCode());

  // 3. ルーティング設定を生成
  const routesJson = generateRoutesJson(routePatterns, apiRoutePatterns);
  fs.writeFileSync("./dist/_routes.json", JSON.stringify(routesJson, null, 2));
}
```

#### 2. Functions Handler（functions/[[path]].ts）

Cloudflare Pages Functionsの`onRequest`ハンドラを実装します：

```typescript
export async function onRequest(context) {
  // 1. Fetch API Request → elm-pages形式に変換
  const elmPagesRequest = await reqToJson(context.request);

  // 2. elm-pages renderエンジンを実行
  const renderResult = await elmPages.render(elmPagesRequest);

  // 3. 結果 → Fetch API Responseに変換
  return new Response(renderResult.body, {
    status: renderResult.statusCode,
    headers: renderResult.headers,
  });
}
```

#### 3. _routes.json

どのパスをFunctions経由にするか、どのパスを静的配信にするかを制御します：

```json
{
  "version": 1,
  "include": ["/server-test"],
  "exclude": [
    "/assets/*",
    "/*.html",
    "/*.js",
    "/*.css"
  ]
}
```

- **include**: Functions経由でレンダリングするパス
- **exclude**: 静的配信するパス（Functionsを経由しない）

## 実装の詳細

### Phase 1: 基本的なadapter実装

最初に、Netlify adapterを参考にしながら、基本的な構造を実装しました。

**実装したファイル:**

- `adapter/cloudflare-pages.js`: adapter本体
- 自動生成ファイルの.gitignore設定

**ポイント:**

- `// @ts-nocheck`ディレクティブでTypeScriptエラーを抑制しました
- 静的アセットの除外パターンを追加しました

### Phase 2: Server-render routeのテスト

実際にSSRが動作するかテストするため、[`/server-test`](/server-test)ページ（[実装](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/app/Route/ServerTest.elm)）を作成しました。以下の情報を表示します：

- リクエスト時刻（POSIXミリ秒）
- HTTPメソッド（GET, POST等）
- リクエストパス（rawUrl）
- 全HTTPヘッダー
- Cloudflare Pages Functions検出（`x-elm-pages-cloudflare`ヘッダーの有無）

### Phase 3: ローカル開発環境の整備

#### wrangler.tomlの作成

```toml
compatibility_date = "2025-12-11"
compatibility_flags = ["nodejs_compat"]
pages_build_output_dir = "dist"
```

- **nodejs_compat**: Node.js互換モジュール（path, fs等）を使用可能に
- **pages_build_output_dir**: ビルド成果物のディレクトリ

#### ローカル開発サーバーの起動

ビルド後、wranglerでローカルにCloudflare Pages環境をシミュレートできます：

```bash
npx wrangler pages dev dist
```

これにより、`http://localhost:8788`でadapter経由のSSR動作を確認できます。

#### Runtime detection機能

開発中、elm-pages devサーバーとwranglerのどちらで動いているか判別する必要がありました。
そこで、カスタムヘッダーを注入する仕組みを追加：

```javascript
// adapter内でヘッダーを注入
headers["x-elm-pages-cloudflare"] = "true";
```

```javascript
// レスポンスヘッダーにも追加
responseHeaders.set("x-elm-pages-cloudflare", "true");
```

Elmコード側で検出（[`app/Route/ServerTest.elm`](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/app/Route/ServerTest.elm#L127-L148)）：

```elm
view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app _ =
    let
        cloudflareHeader =
            app.data.headers
                |> List.filter (\( key, _ ) -> String.toLower key == "x-elm-pages-cloudflare")
                |> List.head

        isCloudflare =
            cloudflareHeader /= Nothing

        runtimeInfo =
            if isCloudflare then
                "✅ Running on Cloudflare Pages Functions (or wrangler dev)"
            else
                "⚠️ Running on elm-pages dev server (adapter not active)"
    in
    -- ... view body
```

#### 開発時の技術的課題と解決策

##### 1. globby v14のimport問題

**問題**: wranglerでバンドル時に`unicorn-magic`パッケージのimportエラーが発生（[sindresorhus/globby#260](https://github.com/sindresorhus/globby/issues/260)）

**解決**: [globby v16にアップグレード](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/package.json#L40)

```json
"dependencies": {
  "globby": "^16.0"
}
```

##### 2. Node.js互換モジュールの警告

**問題**: `path`, `fs`などのNode.js組み込みモジュール使用時の警告

**解決**: [wrangler.toml](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/wrangler.toml#L3)で`nodejs_compat`フラグを有効化

```toml
compatibility_flags = ["nodejs_compat"]
```

##### 3. MODULE_TYPELESS_PACKAGE_JSON警告

**問題**: wranglerでのバンドル時に、`.js`ファイルがES Modules（`import`/`export`構文）として認識されず警告が発生

**意味**: `"type": "module"`を指定すると、Node.jsが`.js`ファイルをES Modules形式として扱う。指定しない場合はCommonJS（`require`/`module.exports`）がデフォルト

**このプロジェクトで採用可能な理由**:

- adapter実装（`adapter/cloudflare-pages.js`）や設定ファイル（`elm-pages.config.mjs`）で既にES Modules構文を使用
- 依存パッケージ（globby v16等）もES Modulesをサポート
- Cloudflare Workers/Pages Functions環境はES Modulesネイティブ対応

**解決**: [package.json](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/package.json#L2)に`"type": "module"`を追加

```json
{
  "type": "module"
}
```

##### 4. 静的アセットの除外

**問題**: `_routes.json`で静的アセットを除外しないと、静的ファイルへのリクエストにもFunctionsが実行されてしまい、不要なコストとレイテンシが発生します。動的なファイルスキャン（`fs.readdir`）はCloudflare Workers環境で使えないため、実行時に判定できません

**解決**: [adapter内](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/adapter/cloudflare-pages.js#L85-L104)で静的アセットパターンを事前定義し、`_routes.json`の`exclude`に追加

```javascript
const staticAssetPatterns = [
  "/assets/*",
  "/*.html",
  "/*.js",
  "/*.css",
  "/*.json",
  // ... 17パターン
];
```

### Phase 3.5: 実環境デプロイとCI/CD統合

#### GitHub Actionsワークフロー

Pull Request時の自動プレビューデプロイと、masterブランチマージ時の本番デプロイを実現。

**主要な実装**:

1. **PRプレビューデプロイ**: `cloudflare/wrangler-action@v3`を使用
2. **プレビューURLの自動コメント**: Branch URLとCommit URLの両方を投稿
3. **本番デプロイ**: masterマージ時に`--branch=main`で本番環境へデプロイ

```yaml
- name: Deploy to Cloudflare Pages (Preview)
  if: github.event_name == 'pull_request'
  id: deploy-preview
  uses: cloudflare/wrangler-action@v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    command: pages deploy dist --project-name=ymtszw-github-io --branch=${{ github.head_ref }}

- name: Comment preview URL on PR
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v7
  with:
    script: |
      const branchUrl = "${{ steps.deploy-preview.outputs.pages-deployment-alias-url }}";
      const commitUrl = "${{ steps.deploy-preview.outputs.deployment-url }}";
      await github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `🚀 Preview deployment ready!\n\n**Branch URL:** ${branchUrl}\n**Commit URL:** ${commitUrl}`
      });
```

**必要な権限**:

```yaml
permissions:
  contents: read
  pull-requests: write  # PRコメント投稿に必要
```

#### 実環境での動作確認

プレビュー環境で確認した項目：

- ✅ 静的ページ（/, /about, /articles等）: 正常配信
- ✅ [SSRページ](/server-test): Runtime detection成功
- ✅ Cloudflare固有ヘッダー（cf-ray, cf-visitor, cf-connecting-ip, cf-ipcountry等）の確認
- ✅ 静的アセット（CSS, JS, 画像）の直接配信（Functions非経由）

### Phase 4: E2E自動テスト

CI環境でadapterの動作を自動検証するため、実デプロイ環境でのsmoke testを実装。

#### テストの仕組み

プレビューデプロイ完了後、以下をチェック：

1. 静的ページのHTTP 200レスポンス
2. SSRページのHTTP 200レスポンスと内容確認
3. Runtime detectionヘッダー（`x-elm-pages-cloudflare: true`）の存在
4. 静的アセット（robots.txt）の配信

#### Smoke testスクリプト

実装（[tests/e2e/wrangler-smoke.sh](https://github.com/ymtszw/ymtszw.github.io/blob/62c767e3353aea3b9e377c35bbe525b0fb074002/tests/e2e/wrangler-smoke.sh)）では、デプロイ完了後の実環境URLに対してテストを実行：

```bash
#!/usr/bin/env bash
DEPLOY_URL="$1"

# Test 1: 静的ページ
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ Index page returned $HTTP"
  exit 1
fi

# Test 2: SSRルート
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/server-test" || true)
curl -s "$DEPLOY_URL/server-test" | grep -q "Running on Cloudflare Pages"

# Test 3: Runtime detectionヘッダー
curl -s -I "$DEPLOY_URL/server-test" | grep -i 'x-elm-pages-cloudflare: true'

# Test 4: 静的アセット
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/robots.txt" || true)
```

**実行**:

デプロイ後にワークフローから呼び出し：

```yaml
- name: Run smoke test on preview
  run: bash tests/e2e/wrangler-smoke.sh ${{ steps.deploy-preview.outputs.pages-deployment-alias-url }}
```

これにより、各PR/コミットで自動的にSSR機能とruntime detectionが検証されます。

## 使用方法

### ローカル開発

#### elm-pages devサーバー（adapter非経由）

```bash
npx elm-pages dev --debug
```

- 開発時の高速リロード
- BackendTaskの実行は動作
- **adapter実装は動作しない**（SSR routeの完全な動作確認には不十分）

#### wranglerでの動作確認（adapter経由）

```bash
# ビルド
npx elm-pages build

# wranglerでローカル起動
npx wrangler pages dev dist
```

`http://localhost:8788`でCloudflare Pages環境がローカルで動作します。

### デプロイ

#### 自動デプロイ（GitHub Actions）

1. **PRプレビュー**: Pull Request作成時に自動デプロイ
   - プレビューURLがPRにコメントされる
   - ブランチURL: `https://<branch-name>.<project-name>.pages.dev`
   - コミットURL: `https://<commit-hash>.<project-name>.pages.dev`

2. **本番デプロイ**: masterブランチへのマージで本番環境に自動デプロイ

#### 手動デプロイ（wrangler CLI）

```bash
# プレビュー環境
npx wrangler pages deploy dist --project-name=<your-project>

# 本番環境
npx wrangler pages deploy dist --project-name=<your-project> --branch=main
```

## まとめ

elm-pages v3のCloudflare Pages Functions adapterを実装することで、
静的サイト生成とserver-side renderingを組み合わせた柔軟なサイト構築が可能になりました。

**実装の成果**:

- ✅ 完全に動作するCloudflare Pages adapter
- ✅ ローカル開発環境（wrangler pages dev）
- ✅ CI/CD統合（GitHub Actions）
- ✅ E2E自動テスト
- ✅ Runtime detection機能

**開発体験の向上**:

- 型安全なElmコードでSSRロジックを記述
- ローカルで実環境と同じ動作を確認可能
- PRごとの自動プレビューデプロイ
- CI環境での自動テスト

この実装は、将来的にはelm-pagesのコミュニティに還元し、
他の開発者も簡単にCloudflare Pagesでelm-pagesを使えるようにしたいと考えています。

---

## 編集後記

*（この欄は人間（サイト管理者）が記入します）*
