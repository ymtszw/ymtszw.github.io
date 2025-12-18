---
title: "elm-pages v3: Cloudflare Pages Functions Adapter実装記録"
description: |
  elm-pages v3でCloudflare Pages Functions対応のadapterを実装した記録。
  静的サイトからserver-side renderingへの拡張、実装の詳細、CI/CD統合、トラブルシューティングまで。
publishedAt: "2025-12-19T00:00:00+09:00"
draft: true
---

このサイト（ymtszw.cc）は[elm-pages]を使って作られています。

elm-pages v3では、静的サイト生成（Static Site Generation, SSG）だけでなく、server-side rendering（SSR）機能も提供されています。
この記事では、Cloudflare Pages Functions上でSSRを動作させるための**adapter**を実装した過程を記録します。

[elm-pages]: https://github.com/dillonkearns/elm-pages

## 背景と動機

### elm-pages v3のadapter機能

elm-pages v3では、異なるホスティングプラットフォーム向けに「adapter」という仕組みを提供しています。
これは、elm-pagesのビルド時に実行され、各プラットフォーム固有の形式でサーバーサイドコードを生成します。

公式で提供されているadapterは：

- **Netlify adapter**: Netlify FunctionsとNetlify Edge Functions対応
- **Vercel adapter**: Vercel Serverless Functions対応（コミュニティ実装）
- **Empty adapter**: 静的サイト生成のみ（SSR機能なし）

### なぜCloudflare Pages adapter？

私はこのサイトをCloudflare Pagesにデプロイしています。理由は：

- 無料枠が充実している
- グローバルなCDN
- 高速なデプロイ
- Cloudflare Workersとの統合

しかし、公式のCloudflare Pages adapter は提供されていなかったため、自分で実装することにしました。

### SSR機能の必要性

当初、このサイトは完全な静的サイトでした。しかし、以下のような用途でSSRが欲しくなりました：

- リクエストヘッダーを使った動的なコンテンツ生成
- APIエンドポイントの実装
- プレビュー機能の実装
- 将来的な動的機能の拡張

## Cloudflare Pages Functionsの特徴

Cloudflare Pages Functionsは、Cloudflare Workersベースのサーバーサイド実行環境です。

### 主要な特徴

- **Fetch API標準**: `Request`/`Response`オブジェクトを使用
- **ファイルベースルーティング**: `functions/`ディレクトリの構造がエンドポイントになる
- **_routes.json**: どのルートをFunctions経由にするか制御
- **Edge実行**: Cloudflareのグローバルネットワークで実行
- **環境変数**: `context.env`経由でアクセス

### 他のプラットフォームとの違い

| 項目               | Netlify Functions                               | Cloudflare Pages Functions       |
| ------------------ | ----------------------------------------------- | -------------------------------- |
| エンドポイント形式 | AWS Lambda形式                                  | Fetch API標準                    |
| ルーティング制御   | `_redirects`ファイル                            | `_routes.json`                   |
| 環境変数アクセス   | `process.env`                                   | `context.env`                    |
| 実行環境           | AWS Lambda（Node.js）                           | Cloudflare Workers（V8 isolate） |
| ファイル配置       | `functions/render/`, `functions/server-render/` | `functions/[[path]].ts`          |

## アーキテクチャ設計

### 全体の流れ

```text
elm-pages build
  ↓
elm-pages.config.mjs (adapter実行)
  ↓
├─ dist/ (静的アセット)
│  ├─ _routes.json (ルーティング設定)
│  └─ ... (HTML, CSS, JS等)
└─ functions/ (Server-side)
   ├─ [[path]].ts (catch-allハンドラ)
   └─ elm-pages-cli.mjs (renderエンジン)
```

### 主要コンポーネント

#### 1. Adapter関数（elm-pages.config.mjs）

elm-pagesのビルド時に実行される関数で、以下を行います：

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

### リクエスト/レスポンス変換

#### リクエスト変換（Fetch API → elm-pages形式）

```typescript
async function reqToJson(req) {
  const headers = {};
  for (const [key, value] of req.headers.entries()) {
    headers[key] = value;
  }

  let body = null;
  let multiPartFormData = null;

  if (req.method !== "GET" && req.method !== "HEAD") {
    const contentType = req.headers.get("content-type") || "";
    if (contentType.includes("multipart/form-data")) {
      const formData = await req.formData();
      multiPartFormData = Object.fromEntries(formData.entries());
    } else {
      body = await req.text();
    }
  }

  return {
    requestTime: Math.round(new Date().getTime()),
    method: req.method,
    headers,
    rawUrl: req.url,
    body,
    multiPartFormData,
  };
}
```

#### レスポンス変換（elm-pages形式 → Fetch API Response）

elm-pagesのrenderエンジンは3種類の出力形式を返します：

1. **html**: 通常のHTMLレスポンス
2. **api-response**: APIエンドポイントのレスポンス
3. **bytes**: バイナリデータ

それぞれを適切なFetch API Responseに変換します。

## 実装の詳細

### Phase 1: 基本的なadapter実装

最初に、Netlify adapterを参考にしながら、基本的な構造を実装しました。

**実装したファイル:**

- `adapter/cloudflare.js`: adapter本体（189行）
- 自動生成ファイルの.gitignore設定

**ポイント:**

- `// @ts-nocheck`ディレクティブでTypeScriptエラーを抑制
- 静的アセットの除外パターンを追加（17パターン）

### Phase 2: Server-render routeのテスト

実際にSSRが動作するかテストするため、`/server-test`ページを作成しました。

```elm
route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender
        { data = data
        , action = \_ -> Request.skip
        , head = \_ -> head
        }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = \_ _ _ -> ( {}, Effect.none )
            , update = \_ _ _ _ _ -> ( {}, Effect.none )
            , subscriptions = \_ _ _ _ -> Sub.none
            }

data : RouteParams -> Request.Parser (BackendTask FatalError (Response Data ErrorPage))
data _ =
    Request.requestTime
        |> Request.andThen
            (\requestTime ->
                Request.map2
                    (\method path ->
                        { requestTime = requestTime
                        , method = method
                        , path = path
                        }
                    )
                    Request.method
                    (Request.queryParam "path" |> Request.map (Maybe.withDefault "/"))
            )
        |> Request.map
            (\requestData ->
                BackendTask.succeed
                    (Response.render
                        { requestTime = requestData.requestTime
                        , method = requestData.method
                        , path = requestData.path
                        }
                    )
            )
```

このページでは、リクエストの以下の情報を表示します：

- リクエスト時刻
- HTTPメソッド
- パス
- ヘッダー一覧

### Phase 3: ローカル開発環境の整備

#### wrangler.tomlの作成

```toml
compatibility_date = "2025-12-11"
compatibility_flags = ["nodejs_compat"]
pages_build_output_dir = "dist"
```

- **nodejs_compat**: Node.js互換モジュール（path, fs等）を使用可能に
- **pages_build_output_dir**: ビルド成果物のディレクトリ

#### npm scriptの追加

```json
{
  "scripts": {
    "start:wrangler": "wrangler pages dev dist"
  }
}
```

これで、ローカルでCloudflare Pages環境をシミュレートできます。

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

Elmコード側で検出：

```elm
Request.headers
    |> Request.map
        (\headers ->
            headers
                |> Dict.get "x-elm-pages-cloudflare"
                |> Maybe.map (\_ -> "✅ Running on Cloudflare Pages Functions")
                |> Maybe.withDefault "⚠️ Running on elm-pages dev server"
        )
```

#### トラブルシューティング（開発時）

##### 1. globby v14のimport問題

wranglerでバンドル時に`unicorn-magic`パッケージのimportエラーが発生。
→ globby v16にアップグレードして解決

##### 2. Node.js互換モジュールの警告

path, fsなどのNode.js組み込みモジュール使用時の警告。
→ `compatibility_flags = ["nodejs_compat"]`で解決

##### 3. MODULE_TYPELESS_PACKAGE_JSON警告

→ package.jsonに`"type": "module"`を追加して解決

##### 4. 静的アセットのfs.readdir エラー

Cloudflare Workers環境で`fs.readdir`が使えない。
→ `_routes.json`の`exclude`パターンを事前定義して回避

### Phase 3.5: 実環境デプロイとCI/CD統合

#### GitHub Actionsワークフロー

`.github/workflows/build-test-deploy.yml`を更新し、以下を実現：

1. **PRプレビューデプロイ**: Pull Request作成時に自動デプロイ
2. **本番デプロイ**: masterブランチマージ時に本番環境へデプロイ
3. **プレビューURLコメント**: PRにデプロイURLを自動コメント

```yaml
- name: Deploy to Cloudflare Pages (Preview)
  if: github.event_name == 'pull_request'
  uses: cloudflare/wrangler-action@v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    command: pages deploy dist --project-name=ymtszw-github-io

- name: Comment preview URL on PR
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v7
  with:
    script: |
      const branchUrl = "${{ steps.deploy-preview.outputs.pages-deployment-alias-url }}";
      const commitUrl = "${{ steps.deploy-preview.outputs.deployment-url }}";
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `🚀 Preview deployment ready!\n\n**Branch URL:** ${branchUrl}\n**Commit URL:** ${commitUrl}`
      });
```

#### 実環境での動作確認

プレビュー環境（`https://feat-cloudflare-adapter.ymtszw-github-io.pages.dev`）で確認した項目：

- ✅ トップページ（/）: 静的配信が正常動作
- ✅ About（/about）: 静的配信が正常動作
- ✅ ServerTest（/server-test）: SSR動作確認
  - Runtime detection成功（`x-elm-pages-cloudflare`ヘッダー検出）
  - Cloudflare固有ヘッダーの確認（cf-ray, cf-visitor, cf-connecting-ip等）

### Phase 4: E2E自動テスト

CI環境でadapterの動作を自動検証するため、wrangler pages devを使ったE2Eテストを追加。

#### ワークフローの作成

`.github/workflows/e2e-wrangler-dev.yml`:

```yaml
name: E2E - wrangler pages dev smoke

on:
  pull_request:

jobs:
  e2e-wrangler-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build site
        run: npm run build
        env:
          MICROCMS_API_KEY: ${{ secrets.MICROCMS_API_KEY }}
          AMAZON_ASSOCIATE_TAG: ${{ secrets.AMAZON_ASSOCIATE_TAG }}

      - name: Run smoke test
        run: bash tests/e2e/wrangler-smoke.sh
        timeout-minutes: 5
```

#### Smoke testスクリプト

`tests/e2e/wrangler-smoke.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Starting wrangler pages dev in background..."
npx wrangler pages dev dist --port 8788 > wrangler.log 2>&1 &
WRANGLER_PID=$!

# Wait for wrangler to be ready
for i in {1..30}; do
  if curl -s http://localhost:8788/server-test > /dev/null 2>&1; then
    echo "wrangler is ready"
    break
  fi
  sleep 1
done

# Test 1: HTTP 200
if ! curl -f -s http://localhost:8788/server-test > /dev/null; then
  echo "ERROR: /server-test returned non-200"
  kill $WRANGLER_PID
  exit 1
fi

# Test 2: SSR body content
BODY=$(curl -s http://localhost:8788/server-test)
if ! echo "$BODY" | grep -q "Running on Cloudflare Pages"; then
  echo "ERROR: Expected SSR content not found"
  kill $WRANGLER_PID
  exit 1
fi

# Test 3: Runtime detection header
HEADER=$(curl -s -I http://localhost:8788/server-test | grep -i "x-elm-pages-cloudflare")
if [ -z "$HEADER" ]; then
  echo "ERROR: x-elm-pages-cloudflare header not found"
  kill $WRANGLER_PID
  exit 1
fi

echo "All smoke tests passed!"
kill $WRANGLER_PID
```

#### adapter修正: レスポンスヘッダー注入

テスト用に、レスポンスヘッダーに`x-elm-pages-cloudflare: true`を注入：

```javascript
// functions/[[path]].tsで生成されるコード
responseHeaders.set("x-elm-pages-cloudflare", "true");
```

これにより、CI環境でruntime detectionが正常に動作することを検証できます。

## 使用方法

### ローカル開発

#### elm-pages devサーバー（adapter非経由）

```bash
npm start
```

- 開発時の高速リロード
- BackendTaskの実行は動作
- **adapter実装は動作しない**（SSR routeの完全な動作確認には不十分）

#### wranglerでの動作確認（adapter経由）

```bash
# ビルド
npm run build

# wranglerでローカル起動
npm run start:wrangler
```

<http://localhost:8788>でCloudflare Pages環境がローカルで動作します。

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

## 技術的制約事項

### 1. Cloudflare Workers環境の制限

- **CPU時間制限**: 無料プランでは10ms、有料プランでは50ms
- **メモリ制限**: 128MB
- **実行時間**: 最大30秒（有料プランでは延長可能）

### 2. Node.js互換性

- `nodejs_compat`フラグで基本的なNode.js APIは使用可能
- しかし、完全なNode.js環境ではないため、一部のパッケージは動作しない可能性

### 3. ファイルシステムアクセス

- ビルド時には通常のNode.js環境で動作
- ランタイムではV8 isolate環境のため、ファイルシステムアクセスは制限される

### 4. elm-pages renderエンジン

- elm-pages-cli.mjsは自動生成されるため、直接編集不可
- カスタマイズが必要な場合はadapter関数で対応

## パフォーマンス考慮事項

### 静的配信の最適化

`_routes.json`で静的アセットを適切に除外することで、Functionsのコールドスタートを回避：

```javascript
const staticAssetPatterns = [
  "/assets/*",
  "/*.html",
  "/*.js",
  "/*.css",
  "/*.json",
  "/*.txt",
  "/*.xml",
  "/*.ico",
  // 画像ファイル
  "/*.png",
  "/*.jpg",
  "/*.jpeg",
  "/*.gif",
  "/*.svg",
  "/*.webp",
  // フォント
  "/*.woff",
  "/*.woff2",
  "/*.ttf",
  "/*.eot",
];
```

### SSR routeの使用判断

- **静的生成で済む場合**: `RouteBuilder.preRender`を使用（ビルド時に生成、配信は高速）
- **リクエストデータが必要な場合**: `RouteBuilder.serverRender`を使用（SSR）
- **APIエンドポイント**: `RouteBuilder.serverRender`でAPIレスポンスを返す

### コールドスタート対策

Cloudflare Workersはコールドスタートが非常に速い（数ミリ秒）ため、
AWS Lambdaのような大きな問題にはなりにくいです。

## 運用時のトラブルシューティング

### ビルドエラー

**症状**: `npm run build`でエラー

**確認事項**:

1. `elm-tooling.json`で正しいバージョンのツールを指定しているか
2. `elm.json`の依存関係が正しいか
3. 環境変数が設定されているか（MICROCMS_API_KEY等）

### wranglerでの実行エラー

**症状**: `npm run start:wrangler`でエラー

**確認事項**:

1. `npm run build`が成功しているか
2. `dist/`ディレクトリが存在するか
3. `functions/[[path]].ts`と`functions/elm-pages-cli.mjs`が生成されているか

### SSR routeが動作しない

**症状**: `/server-test`にアクセスしても404

**確認事項**:

1. `dist/_routes.json`に該当パスが含まれているか
2. `functions/[[path]].ts`が生成されているか
3. wranglerのログを確認（`wrangler.log`）

### Runtime detectionが動作しない

**症状**: 常に"Running on elm-pages dev server"と表示

**確認事項**:

1. `npm run start:wrangler`を使っているか（`npm start`ではadapter非経由）
2. `x-elm-pages-cloudflare`ヘッダーが注入されているか（ブラウザのDevToolsで確認）

## 今後の展開

### 機能拡張

- [ ] Cloudflare KVとの統合
- [ ] Cloudflare D1（SQLite）との統合
- [ ] Cloudflare R2（オブジェクトストレージ）との統合
- [ ] WebSocketsサポート

### パフォーマンス最適化

- [ ] ストリーミングレスポンス対応
- [ ] キャッシュ戦略の最適化
- [ ] CDNとの連携強化

### 開発者体験向上

- [ ] 型安全な環境変数アクセス
- [ ] デバッグツールの充実
- [ ] エラーメッセージの改善

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

## リンク

- [実装計画書](./../docs/implementation-plans/CLOUDFLARE_ADAPTER_IMPLEMENTATION_PLAN.md)
- [adapter実装](https://github.com/ymtszw/ymtszw.github.io/blob/master/adapter/cloudflare.js)
- [GitHub Actions workflow](https://github.com/ymtszw/ymtszw.github.io/blob/master/.github/workflows/build-test-deploy.yml)
- [Cloudflare Pages Functions ドキュメント](https://developers.cloudflare.com/pages/functions/)
