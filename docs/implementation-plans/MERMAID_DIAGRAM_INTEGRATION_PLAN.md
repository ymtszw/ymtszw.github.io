# Mermaid図のレンダリング機能 実装計画

- 作成日: 2025年12月24日
- 更新日: 2025年12月25日（クライアントサイドレンダリングへ方針変更）
- 完了日: 2025年12月25日

## 0. 概要

Markdown記事内に記述されたMermaid図をクライアントサイド（ブラウザ）でレンダリングする機能を実装する。
記事執筆者はMermaidコードを記事内に直接書くだけで、ページ読み込み時に自動的に図として描画される。

### 実装方針の変更履歴

**当初の計画（2025-12-24）**:

- ビルド時にmermaid-cli（Puppeteer + Chromium）でSVG画像を生成
- カスタムBackendTaskで画像への参照に置換

**変更後の計画（2025-12-25）**:

- クライアントサイドでmermaid.jsを使用してレンダリング
- 既存のhighlight.jsと同様のruntime描画パターン

**変更理由**:

- ビルド時のPuppeteer依存関係による複雑性の回避
- GitHub Actionsでのシステムライブラリ要件の削減
- SSRルートでも動作可能な実装
- 既存のhighlight.jsパターンとの一貫性

### 実装の目的

現状の課題：

- 記事内のMermaid図はGitHub等の一部環境でしか表示されない
- 手動で画像を生成・管理する必要があり、メンテナンス性が低い
- ソースコードと画像の同期が困難

実装後の改善：

- 記事内にMermaidコードを直接記述
- ページ読み込み時に自動的に図として描画
- バージョン管理はMermaidソースのみで完結
- ビルド依存関係なし
- SSRでも動作

## 1. アーキテクチャ設計

### データフロー

```text
Markdown記事ファイル
  ↓
既存のMarkdownレンダリング処理
  ├─ ```mermaidブロックはコードブロックとして扱われる
  ├─ highlight.jsが language-mermaid クラスを付与
  └─ HTMLとして出力
  ↓
ページ読み込み (OnPageChange)
  ├─ Shared.elm が triggerMermaidRender を発行
  ↓
RuntimePorts経由でJavaScriptへ
  ├─ TriggerMermaidRender メッセージ受信
  ├─ document.querySelectorAll('pre code.language-mermaid')
  ├─ mermaid.js の mermaid.run() を実行
  └─ 各mermaidブロックがSVG図に置換される
```

### 主要コンポーネント

#### 1. Elm側（Shared.elm）

- **`triggerMermaidRender`**: RuntimePortsにメッセージを送る関数
  - メッセージ: `{ tag: "TriggerMermaidRender" }`
  - 呼び出しタイミング: `OnPageChange`時（highlight.jsと同様）

#### 2. JavaScript側（index.ts）

- **Mermaid.js CDN読み込み**: `<script>`タグで読み込み
- **RuntimePortsハンドラ**: `TriggerMermaidRender`を処理
  - `code.language-mermaid`要素を検索
  - mermaid.jsでレンダリング実行

#### 3. Markdown処理

- **既存のままで動作**: `src/Markdown.elm`は変更不要
- コードブロックとして処理される
- highlight.jsが適切なクラスを付与

## 2. 実装の詳細

### Phase 1: Elm側のRuntimePorts追加 ✅ 完了

**目的**: ページ変更時にMermaidレンダリングをトリガーする

**実装状況**: 2025年12月25日完了

**実装内容**: ✅

1. **`triggerMermaidRender`関数の追加**: `TriggerMermaidRender`メッセージをRuntimePortsへ送信
2. **`OnPageChange`ハンドラでの呼び出し**: ページ遷移時にMermaid図を再レンダリング
3. **`init`関数での呼び出し**: 直接ページアクセス時の初期レンダリング

**変更ファイル**: [src/Shared.elm](../../src/Shared.elm)

**確認方法**: ✅

```bash
npm run build
```

### Phase 2: JavaScript側のMermaid.js統合 ✅ 完了

**目的**: RuntimePortsメッセージを受けてMermaid図をレンダリング

**実装状況**: 2025年12月25日完了

**実装内容**: ✅

1. **Mermaid.js CDNの追加**: @mermaid-js/tiny（軽量版、約280KB）をCDN経由で読み込み
   - 基本的な図（フローチャート、シーケンス図など）をサポート
   - Cloudflare Workers環境との互換性確保

2. **RuntimePortsハンドラの実装**: `TriggerMermaidRender`ケースを追加
   - `renderMermaidDiagrams()`関数: `pre code.language-mermaid`要素を検索してレンダリング
   - `requestAnimationFrame`で非同期実行

3. **highlight.js統合**: `language-mermaid`クラスを持つコードブロックをハイライト処理から除外

4. **TypeScript型定義**: `declare const mermaid: typeof import("mermaid")["default"]`でCDN読み込みの型情報を提供
   - `package.json`: `dependencies`から`mermaid`を削除（126パッケージ削減）、`devDependencies`に追加（型情報のみ）

**変更ファイル**:

- [elm-pages.config.mjs](../../elm-pages.config.mjs)
- [index.ts](../../index.ts)
- [package.json](../../package.json)

**確認方法**: ✅

```bash
npm start
```

**実装時の課題と対応**:

1. **Cloudflare Workers互換性問題**
   - 問題: npm経由でバンドルするとWorkers環境でfs API関連エラー
   - 解決: CDN経由での読み込みに変更

2. **パッケージサイズの最適化**
   - 解決: @mermaid-js/tinyに切り替え

### Phase 3: テスト記事での動作確認 ✅ 完了

**目的**: 実際の記事でMermaid図が正しくレンダリングされることを確認

**実装内容**: ✅

1. **動作確認**: `npm start`で開発サーバー起動後、記事内のMermaid図が正しく表示されることを確認
2. **ページ遷移テスト**: ページ遷移時にMermaid図が再レンダリングされることを確認

**確認方法**:
```bash
npm start
# ブラウザで記事を開いて確認
```

### Phase 4: スタイリング調整（オプション）

**目的**: Mermaid図の見た目を調整

**実装内容**:

- `.mermaid`クラスへのCSSスタイリング追加（必要に応じて）
- `mermaid.initialize()`でのテーマ設定調整（`default`, `dark`, `forest`, `neutral`など）

**変更ファイル**: [style.css](../../style.css)（オプション）

## 3. 技術的な詳細

### Markdownでの記述方法

記事内に```mermaidコードブロックを記述するだけで、ページ読み込み時に自動的にSVG図として描画されます。

**変換の流れ**:

1. Markdownの```mermaidブロック
2. HTMLの`<pre><code class="language-mermaid">`タグ
3. Mermaid.jsによる`<div class="mermaid"><svg>...</svg></div>`への置換

### Mermaid.jsの設定

現在の設定: `startOnLoad: false`（手動トリガー）、`theme: 'default'`

詳細な設定オプションは[Mermaid.js公式ドキュメント](https://mermaid.js.org/config/setup/modules/mermaidAPI.html)を参照

## 4. パフォーマンス考慮事項

### レンダリング時間

- Mermaid図1つあたり約10〜50ms（ブラウザ依存）
- ページ読み込み時に非同期で実行（`requestAnimationFrame`使用）
- ユーザー体験への影響は最小限

### クライアントサイド負荷

- **メリット**: ビルド時間の短縮、サーバー負荷なし
- **デメリット**: 初回描画の遅延、JavaScript必須

### 最適化戦略

1. **遅延ロード**: ページスクロールに応じて描画（将来的な拡張）
2. **キャッシュ**: ブラウザキャッシュによる再訪時の高速化
3. **CDN**: Mermaid.js自体はCDNから配信

## 5. 実装の順序

推奨される実装順序：

1. Phase 1: Elm側のRuntimePorts追加
2. Phase 2: JavaScript側のMermaid.js統合
3. Phase 3: テスト記事での動作確認
4. Phase 4: スタイリング調整（オプション）

各フェーズ後に動作確認を行う。

## 6. ロールバック計画

実装中に問題が発生した場合：

1. **Phase 1-2の段階**: 追加したコードをコメントアウト
2. **完全なロールバック**:
   - `src/Shared.elm`から`triggerMermaidRender`関連コードを削除
   - `index.html`からMermaid.js CDNを削除
   - `index.ts`から`TriggerMermaidRender`ケースを削除

## 7. セキュリティ考慮事項

- Mermaidソースは信頼できる記事作成者のみが編集
- mermaid.jsはクライアントサイドで実行されるが、サンドボックス化されている
- XSSリスクは既存のMarkdownレンダリングと同等
- CDNからの配信により、パッケージの整合性チェックが重要

## 8. 成功の評価基準

実装完了の判断基準：

- ✅ 記事内のMermaidブロックが自動的に図として描画される
- ✅ ページ遷移時に再描画される
- ✅ highlight.jsと同様の動作パターン
- ✅ JavaScriptが有効な環境で正しく表示される
- ✅ ビルド時間に影響がない
- ✅ 既存の記事・機能に影響がない

## 9. 利点と欠点

### 利点

- ✅ ビルド時間の短縮（Puppeteer不要）
- ✅ GitHub Actionsでの依存関係が不要
- ✅ SSRルートでも動作可能
- ✅ 既存パターン（highlight.js）との一貫性
- ✅ 実装がシンプル

### 欠点

- ⚠️ 初回描画時の遅延（通常は気にならないレベル）
- ⚠️ JavaScript無効環境では表示不可（コードブロックとして表示）
- ⚠️ サーバーサイドレンダリング（SSR）時はコードブロックのまま
- ⚠️ SEOへの影響（図の内容は検索エンジンにインデックスされない）

### 将来の拡張案（削除済み）

※ 当初計画していたサーバーサイド生成は複雑性のため見送り。
  必要に応じて将来的に検討可能。

## 10. 参考資料

- [Mermaid.js公式ドキュメント](https://mermaid.js.org/)
- [Mermaid CDN](https://www.jsdelivr.com/package/npm/mermaid)
- [elm-pages RuntimePorts](https://elm-pages.com/docs/runtime-ports/)
- [Mermaid構文リファレンス](https://mermaid.js.org/intro/)
- [既存のhighlight.js実装](../src/Shared.elm) - 参考パターン
