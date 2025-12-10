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

開発サーバーを立ち上げ、ブラウザで操作しながら動作確認を行う場合は、以下のコマンドを使用すること：

```bash
npm start
```

このコマンドは`elm-pages dev --debug`を実行し、開発サーバーが起動する。

**重要な制限事項**:

- 開発サーバーはプラットフォーム固有のadapter実装を経由せず、elm-pages自体が持つSSR機能を使用する
- BackendTaskの実行や各route moduleの処理は動作するが、adapter関数で生成されるコードは実行されない
- **adapter実装の動作確認には不十分**であることに注意

**adapter実装の確認方法**:

1. `npm run build`でデプロイ用ビルドを実行
2. `dist/`ディレクトリおよび`functions/`ディレクトリに生成されたファイルの内容を確認
3. 最終的にはブランチのプレビューデプロイを行い、実際のCloudflare Pages環境で動作確認
4. プレビューデプロイの実行には人間の開発者の介在が必要

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
- [Cloudflare Pages _routes.json 仕様](https://developers.cloudflare.com/pages/platform/functions/routing/#functions-invocation-routes)

## 9. 次のステップ

この計画に基づいて、Phase 1から順次実装を進める。各フェーズの完了後、動作確認とコードレビューを実施し、次のフェーズに進む。

## 10. 実装進捗

### Phase 1: 完了（2025-12-11）

**実装内容:**

- ✅ Cloudflare adapter本体の実装（`adapter/cloudflare.js`）
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

- `adapter/cloudflare.js`: 189行のadapter実装
- `functions/[[path]].ts`: Fetch API標準のonRequest handler（自動生成）
- `functions/elm-pages-cli.mjs`: renderエンジン（自動コピー）
- `dist/_routes.json`: Cloudflare Pagesルーティング設定（自動生成）

### Phase 2: 未着手

**残タスク:**

- server-render routeの作成とテスト
- 実際のCloudflare Pages環境でのリクエスト/レスポンス変換の動作確認
- multiPartFormData処理の検証
- エラーハンドリングの確認

### Phase 3: 未着手

**残タスク:**

- wrangler.tomlとの統合確認
- 環境変数アクセスのテスト
- ビルドスクリプトの最適化

### Phase 4: 未着手

**残タスク:**

- READMEまたは別ファイルへのドキュメント作成
- デプロイ手順の記載
- 制約事項の明記
