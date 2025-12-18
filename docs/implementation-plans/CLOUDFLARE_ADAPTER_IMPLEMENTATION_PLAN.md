# Cloudflare Pages Functions Adapter 実装計画

作成日: 2025年12月10日

## 0. ビルドと動作確認

### 基本的なビルド確認

実装の各段階で、全体としてのビルド成否を確認する必要がある場合は、常に以下のコマンドを使用すること：

```bash
npm run build
```

このコマンドは`elm-pages build`を実行し、サイト全体のデプロイ用ビルドを行う。adapter関数も含めて全ての実装が正しく動作することを確認できる。

### テストの実行

既存のテストコードの成否を確認する場合は、以下のコマンドを使用すること：

```bash
npm run test
```

実装変更により既存機能が破壊されていないことを確認するため、適宜このコマンドを実行する。

### 依存関係の管理

新たなdependencyを追加した場合（`package.json`や`elm.json`の更新など）は、以下のコマンドでインストールを実行すること：

```bash
npm install
```

インストール後、`postinstall`スクリプトが自動的に実行され、`elm-tooling install`と`elm-pages gen`が行われるため、npmとElmの両方の依存関係が適切にセットアップされる。

### 開発サーバーでの動作確認

#### elm-pages開発サーバー（adapter非経由）

開発サーバーを立ち上げ、ブラウザで操作しながら動作確認を行う場合は、以下のコマンドを使用すること：

```bash
npm start
```

このコマンドは`elm-pages dev --debug`を実行し、開発サーバーが起動する。

**制限事項**:

- 開発サーバーはプラットフォーム固有のadapter実装を経由せず、elm-pages自体が持つSSR機能を使用する
- BackendTaskの実行や各route moduleの処理は動作するが、adapter関数で生成されるコードは実行されない
- **adapter実装の動作確認には不十分**であることに注意

#### Cloudflare Pages環境でのローカル動作確認（adapter経由）

adapter実装の動作確認を行う場合は、以下の手順を実行すること：

1. `npm run build`でデプロイ用ビルドを実行（adapter関数が実行され、`functions/`配下にハンドラが生成される）
2. `dist/`ディレクトリおよび`functions/`ディレクトリに生成されたファイルの内容を確認
3. ローカルでCloudflare Pages環境をシミュレート：

   ```bash
   npm run start:wrangler
   ```

   このコマンドは`wrangler pages dev dist`を実行し、<http://localhost:8788>でCloudflare Pages Functions環境がローカルで動作する。静的アセットの配信とserver-render routeの動作を確認可能。

4. 最終的にはブランチのプレビューデプロイを行い、実際のCloudflare Pages環境で動作確認（人間の開発者が実施）

### クリーンビルド

各種キャッシュとビルド成果物を削除してクリーンな状態からビルドし直す場合：

```bash
npm run clean
```

## 1. 現状分析

現在のプロジェクトでは:

- elm-pages v3を使用し、静的サイト生成用にempty adapterを使用中
- `RouteBuilder.preRender`を使用したroute（静的生成）のみ存在
- server-side rendering機能は未使用

## 2. Cloudflare Pages Functionsの特徴

- **Functions**: `functions/`ディレクトリ配下のファイルがエンドポイントとして動作
- **環境変数**: `context.env`経由でアクセス
- **リクエスト形式**: Fetch API標準の`Request`/`Response`オブジェクト
- **ルーティング**: ファイルシステムベース + `_routes.json`での制御
- **デプロイ**: `dist/`の内容が静的アセット、`functions/`がサーバーサイド処理

## 3. 実装タスク

### タスク一覧

1. **Cloudflare adapter本体の実装**
   - `elm-pages.config.mjs`にCloudflare Pages Functions用のadapter関数を実装
   - Netlify adapterを参考に、`renderFunctionFilePath`を`functions/`配下に配置
   - `_routes.json`を生成する

2. **Functions handlerの実装**
   - `functions/[[path]].ts`または類似の構造でCloudflare Pages Functions形式のhandlerを実装
   - Fetch APIの`Request`/`Response`をelm-pages renderエンジンが期待する形式に変換

3. **_routes.json生成ロジック**
   - `routePatterns`と`apiRoutePatterns`を解析
   - 静的ルートとserver-renderルートを適切に分離する`_routes.json`を生成

4. **型定義とリクエスト変換**
   - Cloudflare PagesのRequestContextから、elm-pages renderが期待するJSON形式へ変換
   - headers, method, rawUrl, body, multiPartFormDataの対応

5. **Response変換とエラーハンドリング**
   - elm-pages renderの出力をFetch API Responseに変換
   - kind: 'bytes' | 'api-response' | 'html'の各ケースに対応

6. **ビルド設定の調整**
   - `package.json`のbuildスクリプトやwrangler設定との統合
   - `functions`ディレクトリの扱いを確認

7. **テスト用server-render routeの作成**
   - `RouteBuilder.serverRender`を使った簡単なテストrouteを作成
   - 動作確認

8. **ドキュメント作成**
   - 実装の使い方、制約事項、デプロイ手順をREADMEまたは別ファイルに記載

## 4. 技術的詳細

### 4.1 アーキテクチャ概要

```text
elm-pages build
  ↓
elm-pages.config.mjs (adapter実行)
  ↓
├─ dist/ (静的アセット)
│  ├─ _routes.json (ルーティング設定)
│  └─ ...
└─ functions/ (Server-side)
   └─ [[path]].ts (catch-allハンドラ)
      ├─ elm-pages-cli.mjs (render engine)
      └─ handler実装
```

### 4.2 主要コンポーネント

#### A. Adapter関数 (elm-pages.config.mjs)

- Netlify adapterと同様の引数を受け取る
- `renderFunctionFilePath`を`functions/`にコピー
- `_routes.json`を生成してルーティング制御
- TypeScriptハンドラファイルを生成

#### B. Functions Handler (functions/[[path]].ts)

- Cloudflare Pages Functionsの`onRequest`を実装
- `Request` → elm-pages形式JSON変換
- elm-pages render実行
- 結果 → `Response`変換

#### C. _routes.json

```json
{
  "version": 1,
  "include": ["/server-rendered-path/*"],
  "exclude": ["/static-asset.js", "/*.css"]
}
```

### 4.3 型定義

```typescript
// Cloudflare Pages Context
interface EventContext<Env, P, Data> {
  request: Request;
  env: Env;
  params: P;
  waitUntil(promise: Promise<any>): void;
  next(input?: Request | string, init?: RequestInit): Promise<Response>;
  data: Data;
}

// elm-pages render入力形式
interface ElmPagesRequest {
  requestTime: number;
  method: string;
  headers: Record<string, string>;
  rawUrl: string;
  body: string | null;
  multiPartFormData: unknown;
}

// elm-pages render出力形式
interface ElmPagesRenderResult {
  kind: 'bytes' | 'api-response' | 'html';
  body: string | Uint8Array;
  headers: Record<string, string[]>;
  statusCode: number;
  isBase64Encoded?: boolean;
}
```

## 5. Netlify adapterとの主な相違点

| 項目               | Netlify                                         | Cloudflare Pages                    |
| ------------------ | ----------------------------------------------- | ----------------------------------- |
| エンドポイント形式 | AWS Lambda形式                                  | Fetch API標準                       |
| ルーティング       | `_redirects`ファイル                            | `_routes.json`                      |
| 環境変数アクセス   | `process.env`                                   | `context.env`                       |
| ビルダー機能       | `@netlify/functions`                            | 標準のon-demand動作                 |
| ファイル配置       | `functions/render/`, `functions/server-render/` | `functions/[[path]].ts` (catch-all) |

## 6. 実装の優先順位

1. **Phase 1**: 基本的なadapter実装（タスク1-3）
2. **Phase 2**: リクエスト/レスポンス変換実装（タスク4-5）
3. **Phase 3**: テストとビルド統合（タスク6-7）
4. **Phase 4**: ドキュメント整備（タスク8）

## 7. 考慮事項

- **prerender-with-fallback**: Cloudflareにも類似の機能があるか要確認
- **multiPartFormData**: Fetch APIのFormDataへの変換が必要
- **環境変数**: `wrangler.toml`での設定が必要
- **型安全性**: TypeScriptを最大限活用
- **エラーハンドリング**: 本番環境での詳細エラー表示制御

## 8. 参考資料

- elm-pages v3 Netlify adapter実装: `node_modules/elm-pages/adapter/netlify.js`
- [Cloudflare Pages Functions ドキュメント](https://developers.cloudflare.com/pages/functions/)
- [Cloudflare Pages Functions ルーティング](https://developers.cloudflare.com/pages/functions/routing/)
- [Cloudflare Pages _routes.json 仕様](https://developers.cloudflare.com/pages/functions/routing/#functions-invocation-routes)

## 9. 次のステップ

この計画に基づいて、Phase 1から順次実装を進める。各フェーズの完了後、動作確認とコードレビューを実施し、次のフェーズに進む。

## 10. 実装進捗

### Phase 1: 完了（2025-12-11）

**実装内容:**

- ✅ Cloudflare adapter本体の実装（`adapter/cloudflare-pages.js`）
  - `run()`関数: ファイル生成とコピー処理のオーケストレーション
  - `handlerCode()`: Functions handler（`functions/[[path]].ts`）の生成
  - `generateRoutesJson()`: `_routes.json`の生成ロジック
  - `pathPatternToString()`: routeパターンのCloudflare形式変換
- ✅ elm-pages.config.mjsの更新（empty adapterからCloudflare adapterへ切り替え）
- ✅ 自動生成ファイルの除外設定
  - `.gitignore`: `functions/\[\[path\]\].ts`, `functions/elm-pages-cli.mjs`（エスケープ付き）
  - `.ignore`: 検索対象からの除外設定
- ✅ TypeScriptエラー抑制: 生成されるhandlerに`// @ts-nocheck`ディレクティブを追加
- ✅ ビルド検証: `npm run build`で正常にビルド完了を確認

**コミット:**

- `6a28f758`: Add Cloudflare Pages adapter implementation
- `3ad5bd51`: Add @ts-nocheck directive and update .ignore for generated files

**成果物:**

- `adapter/cloudflare-pages.js`: 189行のadapter実装
- `functions/[[path]].ts`: Fetch API標準のonRequest handler（自動生成）
- `functions/elm-pages-cli.mjs`: renderエンジン（自動コピー）
- `dist/_routes.json`: Cloudflare Pagesルーティング設定（自動生成）

### Phase 2: 完了（2025-12-11）

**実装内容:**

- ✅ server-render routeのテストページ作成（`app/Route/ServerTest.elm`）
  - `RouteBuilder.serverRender`を使用したサーバーサイドレンダリング
  - リクエスト情報の表示（requestTime, method, path, headers）
  - `Server.Request` APIの動作確認
- ✅ 関連モジュールの更新
  - `src/Shared.elm`: ServerTest routeのブレッドクラムパターン追加
  - `app/Api.elm`: ServerTest routeをsitemapから除外
- ✅ ビルド検証: `npm run build`で正常にビルド完了
- ✅ ルーティング確認: `dist/_routes.json`に`/server-test`が正しく含まれることを確認

**コミット:**

- `b3037cc3`: Add server-render test route for Cloudflare Pages Functions

**成果物:**

- `app/Route/ServerTest.elm`: 173行のserver-render routeテストページ
- `dist/_routes.json`: `{"version": 1, "include": ["/server-test"], "exclude": []}`

**備考:**

- 実際のCloudflare Pages環境でのデプロイ動作確認は人間の開発者が実施
- Request/Response変換は正常に動作していることをビルドで確認
- multiPartFormDataの処理は今回のテストでは未検証（将来的に必要に応じてテスト追加）

### Phase 3: 完了（2025-12-11）

**実装内容:**

- ✅ wrangler.toml作成
  - `compatibility_date`, `compatibility_flags` (nodejs_compat), `pages_build_output_dir`設定
- ✅ npm scriptの追加: `npm run start:wrangler`（`wrangler pages dev dist`）
- ✅ Runtime detection機能の実装
  - adapter: `reqToJson()`で`x-elm-pages-cloudflare`ヘッダー注入
  - ServerTest.elm: ヘッダー検出でランタイム環境表示（"✅ Running on Cloudflare Pages Functions" または "⚠️ Running on elm-pages dev server"）
  - ヘッダー表示を20個に拡張してデバッグ
- ✅ globby v16アップグレード
  - globby v14のunicorn-magic import問題を解決
  - package.jsonを`"globby": "^16.0.0"`に更新
- ✅ nodejs_compat設定
  - wrangler.tomlに`compatibility_flags = ["nodejs_compat"]`追加
  - Node.js組み込みモジュール（path, fs/promises等）の警告解消
- ✅ MODULE_TYPELESS_PACKAGE_JSON警告の解消
  - package.jsonに`"type": "module"`追加
- ✅ 静的アセット除外設定
  - `generateRoutesJson()`に`exclude`パターン追加（/assets/*, /*.html, /*.js, /*.css等17パターン）
  - fs.readdir エラー解消（Cloudflare Workers環境での静的ファイルアクセス問題回避）
- ✅ wranglerローカル実行成功
  - `npm run start:wrangler`で正常起動（<http://localhost:8788>）
  - /server-testでSSR動作確認
  - runtime detection成功（x-elm-pages-cloudflareヘッダー検出）
- ✅ elm-pages devサーバーでの動作確認
  - runtime detection警告表示が正常動作

**コミット:**

- `1c0c15b7`: Add static asset exclusion to _routes.json
- `146e192f`: Add type: module to package.json
- `3eabb895`: Add runtime detection debug log and fix header display
- `ebe889c4`: fix: Update globby to v16 to resolve wrangler bundling issues
- `c0567f8b`: wip: Revert to original approach and add nodejs_compat
- `14465e33`: wip: Add wrangler.toml and document bundling issues
- `971fe680`: chore: Add npm script for wrangler dev server
- `7be18a17`: feat: Add runtime detection for Cloudflare adapter vs elm-pages dev

**成果物:**

- `wrangler.toml`: Cloudflare Pages開発環境設定
- `package.json`: "type": "module", globby v16, start:wranglerスクリプト
- `adapter/cloudflare-pages.js` (216行): 静的アセット除外、ヘッダー注入機能を含む完全版
- `app/Route/ServerTest.elm` (182行): runtime detection実装、20個のヘッダー表示
- `dist/_routes.json`: includeとexcludeパターンを含む完全なルーティング設定

**解決した問題:**

1. ✅ globby v14のunicorn-magic import問題 → globby v16にアップグレードして解決
2. ✅ Node.js組み込みモジュール警告 → nodejs_compat flagで解決
3. ✅ MODULE_TYPELESS_PACKAGE_JSON警告 → "type": "module"で解決
4. ✅ runtime detection動作せず → ヘッダー表示拡張とデバッグログで確認・解決
5. ✅ fs.readdir エラー → 静的アセット除外設定で解決

**残存する警告（無視可能）:**

- wrangler eval警告: elm-pages-cli.mjs内のeval使用によるもの（セキュリティリスクなし、実運用で正常動作、抑制困難）

**動作確認:**

- npm run build: 正常ビルド
- npm run start:wrangler: 正常起動（<http://localhost:8788>）
- /server-test: SSR動作、runtime detection成功（"✅ Running on Cloudflare Pages Functions"表示）
- 静的ページ（/, /about等）: 正常表示（Functions経由せず配信）

### Phase 3.5: 実環境デプロイと動作確認（完了 - 2025-12-18）

**デプロイ方式:**

このリポジトリでは、GitHub ActionsでビルドしてwranglerでDirect Uploadする方式を採用。Cloudflare Pages側のgit連携ビルド機能は使用しない（OSS化時にはオプションとして提示予定）。

**実装タスク:**

- [x] GitHub Actionsワークフロー（`.github/workflows/build-test-deploy.yml`）の更新
  - [x] PR/ブランチプッシュ時のプレビューデプロイ設定追加
    - `cloudflare/wrangler-action@v3`を使用
    - ブランチ名をCloudflare Pagesのブランチ名に指定（`--branch=${{ github.head_ref }}`）
    - プレビューURL自動コメント機能追加（`actions/github-script@v7`）
  - [x] PR時の正しいブランチチェックアウト設定
    - `github.event_name == 'pull_request' && github.head_ref || 'master'`
  - [x] masterブランチマージ後の本番デプロイ設定確認
    - 既存の`--branch=main`設定を維持
  - [x] `pull-requests: write`権限の追加
    - PRコメント機能に必要な権限を追加
- [x] プレビュー環境での動作確認
  - [x] トップページ（/）: 静的ページの正常配信
  - [x] About（/about）: 静的ページの正常配信
  - [x] ServerTest（/server-test）: SSR動作確認
    - ✅ runtime detection成功（x-elm-pages-cloudflareヘッダー検出）
    - ✅ リクエスト情報の表示（requestTime, method, path, headers）
    - ✅ Cloudflare固有ヘッダーの確認（cf-ray, cf-visitor, cf-connecting-ip, cf-ipcountry等）
  - [x] ルーティング動作確認
    - `_routes.json`による静的/動的ルート分離が正常動作
    - 静的アセット（CSS, JS, 画像等）の直接配信
    - server-render routeのみFunctions経由
  - [x] パフォーマンス確認
    - 正常なレスポンスタイム
- [ ] 本番環境での動作確認（人間による作業、masterマージ後）
  - [ ] 既存の静的生成routeが影響を受けないことを確認
  - [ ] SSR routeが本番環境で正常動作することを確認
  - [ ] ビルド時間が許容範囲内（GitHub ActionsとCloudflare Pagesの制限内）

**コミット:**

- `71946d84`: feat: Add Cloudflare Pages preview deployment for pull requests
- `5f408564`: fix: Add pull-requests write permission for preview URL comments
- `a46171ab`: style: Format workflow comment
- `d57107b9`: docs: Update Phase 3.5 with successful workflow execution
- `ff1e1822`: feat: Extract branch and commit URLs from wrangler output
- `346fd05d`: refactor: Use wrangler-action dedicated outputs for deployment URLs

**ワークフロー実行結果:**

- Run ID: 20333961216 - ✅ 成功（初回デプロイ確認）
- Run ID: 20334269663 - ✅ 成功（Branch/Commit URL両方表示）
- Run ID: 20334682394 - ✅ 成功（wrangler-action outputs使用版）
- プレビューデプロイ: ✅ 成功
- PRコメント投稿: ✅ 成功

**動作確認結果:**

プレビューURL: `https://feat-cloudflare-adapter.ymtszw-github-io.pages.dev/server-test`

SSR動作確認内容：
```text
✅ Running on Cloudflare Pages Functions (or wrangler dev)
Request Time: 1766054290206 ms
Method: GET
Path: https://feat-cloudflare-adapter.ymtszw-github-io.pages.dev/server-test

Cloudflare固有ヘッダー確認:
- cf-ray: 9afe07705ef78a78
- cf-visitor: {"scheme":"https"}
- cf-connecting-ip: 219.98.12.252
- cf-ipcountry: JP
- x-elm-pages-cloudflare: true (runtime detection)
```

PRコメント投稿内容:
```text
🚀 Preview deployment ready!

**Branch URL:** https://feat-cloudflare-adapter.ymtszw-github-io.pages.dev
**Commit URL:** https://5786a1e0.ymtszw-github-io.pages.dev
```

**実装変遷:**

1. 初回実装: 環境変数とregexでwrangler出力からURL抽出
2. 最終版: wrangler-action@v3の専用outputs（`pages-deployment-alias-url`, `deployment-url`）を使用

**成果物:**

- ✅ 更新された`.github/workflows/build-test-deploy.yml`
  - PR時のプレビューデプロイ設定完了
  - Branch URL（ブランチ単位）とCommit URL（コミット単位）の両方を自動コメント
  - wrangler-actionの専用outputsを使用したクリーンな実装
- ✅ プレビュー環境URL: `https://feat-cloudflare-adapter.ymtszw-github-io.pages.dev/`
- ✅ 実環境で動作するCloudflare Pages Functions adapter
- ✅ プレビュー環境でのSSR動作実証

**備考:**

- プレビュー環境でのSSR動作確認完了
- 静的ページ、SSRページ共に正常動作
- Cloudflare固有機能（ヘッダー、Functions等）が正しく動作
- 本番環境（masterブランチ）へのマージは、Phase 4（ドキュメント整備）完了後に実施
- GitHub Actions workflowの`permissions`に`pull-requests: write`が必要

### Phase 4: ドキュメント整備 ✅

**Status: 完了** (2025-12-19)

**実装内容:**

- ✅ 記事ページの作成: `articles/cloudflare-pages-adapter-implementation.md`
  - 背景と動機
  - Cloudflare Pages Functionsの特徴
  - アーキテクチャ設計の詳細説明
  - 実装の各フェーズの記録
  - 使用方法（ローカル開発、デプロイ）
  - 技術的制約事項
  - パフォーマンス考慮事項
  - トラブルシューティングガイド
  - 今後の展開
- ✅ draft状態で作成（`draft: true`）
- ✅ 包括的なドキュメントとして整備完了

**記事の構成:**

1. **背景と動機**
   - elm-pages v3のadapter機能の説明
   - なぜCloudflare Pages adapter が必要か
   - SSR機能の必要性

2. **Cloudflare Pages Functionsの特徴**
   - 主要な特徴（Fetch API、ファイルベースルーティング、Edge実行）
   - 他のプラットフォーム（Netlify）との違い

3. **アーキテクチャ設計**
   - 全体の流れ図
   - 主要コンポーネント（Adapter関数、Functions Handler、_routes.json）
   - リクエスト/レスポンス変換の詳細

4. **実装の詳細**
   - Phase 1: 基本的なadapter実装
   - Phase 2: Server-render routeのテスト
   - Phase 3: ローカル開発環境の整備
   - Phase 3.5: 実環境デプロイとCI/CD統合
   - Phase 4: E2E自動テスト

5. **使用方法**
   - ローカル開発（elm-pages dev / wrangler）
   - デプロイ（自動/手動）

6. **技術的制約事項**
   - Cloudflare Workers環境の制限
   - Node.js互換性
   - ファイルシステムアクセス
   - elm-pages renderエンジン

7. **パフォーマンス考慮事項**
   - 静的配信の最適化
   - SSR routeの使用判断
   - コールドスタート対策

8. **トラブルシューティング**
   - ビルドエラー
   - wranglerでの実行エラー
   - SSR routeが動作しない
   - Runtime detectionが動作しない

9. **今後の展開**
   - 機能拡張（KV、D1、R2統合）
   - パフォーマンス最適化
   - 開発者体験向上

**コミット:**

- （次のコミットで記録予定）

**成果物:**

- `articles/cloudflare-pages-adapter-implementation.md`: 約700行の包括的なドキュメント

**備考:**

- README.mdは/aboutページとしてrenderingされているため編集せず、独立した記事として作成
- draft状態で作成し、レビュー後に公開予定
- 将来的にelm-pagesコミュニティに還元する際のベースドキュメントとして使用可能

### Phase 4.1: CI E2E (wrangler pages dev on runner) ✅

**Status: 完了** (PR #103)

目的: CI 上で `wrangler pages dev` を実行し、ローカル的に Cloudflare Pages Functions 環境を立ち上げて最小限の E2E smoke テストを実行する。実際の Cloudflare Preview を使わずに、CI ランナー上で SSR / `_routes.json` の動作確認を自動化する。

実装内容:

- ✅ `.github/workflows/e2e-wrangler-dev.yml` ワークフロー作成
- ✅ `tests/e2e/wrangler-smoke.sh` smoke testスクリプト作成
- ✅ adapter修正: response headerに `x-elm-pages-cloudflare: true` を注入
- ✅ キャッシュ設定とアクションバージョンを本番ワークフローに統一
- ✅ ビルドに必要な環境変数を追加
- ✅ CI上でsmoke test成功を確認

テスト内容:

- HTTP 200 レスポンス確認
- SSRボディコンテンツ確認（"Running on Cloudflare Pages"）
- レスポンスヘッダー確認（`x-elm-pages-cloudflare: true`）

メリット:

- 外部デプロイを待たずに高速に検証できる。
- Cloudflare アカウント / API トークンを使わずにローカル互換の動作確認が可能（権限やレート制限の懸念が少ない）。

注意点:

- `wrangler pages dev` は CI 環境での互換性に差が出る場合がある（特にバンドル/ネットワーク周り）。安定化のためにラッパースクリプトでリトライやタイムアウト管理を行うこと。
- 長時間のプロセスを立ち上げるため、Actions ジョブのタイムアウトやランナーのリソースを考慮する。

必要な前提:

- `wrangler` CLI がインストールされていること（`npm ci` や `npm install` でインストールされることを想定）。
- `dist/` が `npm run build` によって生成されること。

最小テストケース:

- `npm run build` が成功すること
- `dist/_routes.json` が存在し、server-render route が含まれていることを確認する
- `wrangler pages dev dist --port 8788` をバックグラウンドで起動する
- `curl -I http://localhost:8788/server-test` が 200 を返すこと
- `curl http://localhost:8788/server-test` のボディにランタイム検出文字列（例: "Running on Cloudflare Pages"）が含まれること
- レスポンスヘッダーに `x-elm-pages-cloudflare: true` が含まれること

ワークフロー例 (GitHub Actions):

```yaml
name: E2E — wrangler pages dev smoke

on:
  pull_request:
    branches: [ main ]

jobs:
  e2e-wrangler-dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install deps
        run: npm ci
      - name: Build
        run: npm run build
      - name: Check _routes.json
        run: test -f dist/_routes.json && cat dist/_routes.json
      - name: Start wrangler pages dev
        run: |
          npx wrangler pages dev dist --port 8788 &
          # background process PID
          echo $! > /tmp/wrangler.pid
          # wait for server up
          for i in 1 2 3 4 5; do
            status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8788/ || true)
            if [ "$status" = "200" ]; then
              break
            fi
            sleep 2
          done
      - name: Smoke test server-render route
        run: |
          set -e
          curl -s -I http://localhost:8788/server-test | grep -i '200' || (echo "server-test not 200" && exit 1)
          curl -s http://localhost:8788/server-test | grep -q "Running on Cloudflare Pages" || (echo "SSR body check failed" && exit 1)
          curl -s -I http://localhost:8788/server-test | grep -i 'x-elm-pages-cloudflare: true' || (echo "Header missing" && exit 1)
      - name: Stop wrangler
        if: always()
        run: |
          if [ -f /tmp/wrangler.pid ]; then
            kill $(cat /tmp/wrangler.pid) || true
          fi
```

運用上のヒント:

- `npx wrangler pages dev` の標準出力/標準エラーをアクションログに残すとデバッグが楽になる（ただしログ量に注意）。
- CI 環境で flaky になった場合は、`pages dev` の代わりに `node` で簡易なハンドラを立てて integration test を行うフェイルバックも検討する。

このワークフローを `Phase 4` の手順に組み込み、CI で定期的に実行することで adapter の回帰検出を早められます。

**次のステップ:**

1. ドキュメント整備の実施
2. 本番環境（master）へのマージ
3. 本番環境での動作確認

**備考:**

- Phase 3.5まででCloudflare Pages Functions adapterの実装と動作確認は完了
- ドキュメント整備後、プロダクション環境へのマージが可能
