# Cloudflare Pages Functions Adapter 実装計画

作成日: 2025年12月10日

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

| 項目 | Netlify | Cloudflare Pages |
|------|---------|------------------|
| エンドポイント形式 | AWS Lambda形式 | Fetch API標準 |
| ルーティング | `_redirects`ファイル | `_routes.json` |
| 環境変数アクセス | `process.env` | `context.env` |
| ビルダー機能 | `@netlify/functions` | 標準のon-demand動作 |
| ファイル配置 | `functions/render/`, `functions/server-render/` | `functions/[[path]].ts` (catch-all) |

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
- [Cloudflare Pages _routes.json 仕様](https://developers.cloudflare.com/pages/platform/functions/routing/#functions-invocation-routes)

## 9. 次のステップ

この計画に基づいて、Phase 1から順次実装を進める。各フェーズの完了後、動作確認とコードレビューを実施し、次のフェーズに進む。
