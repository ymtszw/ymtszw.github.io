---
name: implementation-planning
description: >-
  Plan and track large-scale or multi-phase feature implementations, refactorings, or architectural changes.
  Activate when designing new features, decomposing complex tasks into phases, or tracking implementation progress in docs/implementation-plans/.
---

# Implementation Planning & Progress Tracking

ymtszw.cc リポジトリにおいて、複数ステップにわたる大規模な機能追加、リファクタリング、アーキテクチャ変更を安全かつ確実に進めるためのワークフローです。
軽微な修正や単一ファイルの変更には不要ですが、設計判断を伴うタスクやセッションを跨ぐ作業ではこの手順に従って計画・進捗管理を行います。

## 前提事項

- **デフォルトブランチ直接作業の禁止（必須チェック）**:
  - 大規模な機能開発や複数フェーズの実装を開始する前に、現在のブランチがデフォルトブランチ（`master`）でないことを必ず確認する。
  - `master` ブランチがチェックアウトされている場合は直接作業を行わず、開発者に警告して作業用ブランチ（例: `feat/<name>`, `fix/<name>`）の作成とチェックアウトを促すこと。
- **ブランチ命名規則**: ブランチ名は機能や目的を明確に示すこと（例: `feat/cloudflare_adapter`, `fix/bug-123`, `refactor/component-structure`）。
- **未コミットファイルの定期確認**: エディタのファイル保持等で未コミットの差分が発生する場合があるため、定期的に `git status` を確認し、適切な単位でコミットする。
- **Auto Approve設定**: 開発者が `.vscode/settings.json` 等で設定するため、エージェント側で設定ファイルを変更しない。

## 開発の進め方

1. **計画書の作成**:
   - 実装開始前に `docs/implementation-plans/<FEATURE_NAME>_PLAN.md` を作成する。
   - 全体像、背景、技術的要件、Phase 分割を明記する。
2. **段階的な実装**:
   - 各 Phase のタスクを順次進め、Phase ごとに品質検証（`elm-workflow` スキルに従ったテスト・ビルド等）を行う。
3. **困難に直面した時の報告**:
   - 計画通りの実装が困難と判明した場合は無理に進めず、その理由と代替案を開発者に報告・相談する。
4. **進捗の記録**:
   - Phase 完了時やセッション終了時に、計画書内の「実装進捗」セクションを更新する。
5. **Git コミット**:
   - 各 Phase または論理的な単位ごとに意味のあるコミットを作成する。

## 計画書テンプレート

`docs/implementation-plans/<FEATURE_NAME>_PLAN.md` は以下の構造で作成します：

```markdown
# <機能名> 実装計画書

## 1. 概要・目的
...

## 2. 要件と設計
...

## 3. 実装 Phase 一覧
- Phase 1: ...
- Phase 2: ...
- Phase 3: ...

---

## 実装進捗

### Phase 1: 完了 (YYYY-MM-DD)
**実装内容:**
- ✅ <タスク1>
- ✅ <タスク2>
- ✅ テスト・ビルド検証結果

**コミット:**
- `<commit-hash>`: コミットメッセージ

**成果物:**
- `path/to/file`: 説明

### Phase 2: 進行中 / 未着手
**残タスク:**
- [ ] <タスク1>
- [ ] <タスク2>
```

## 進捗記録のタイミングと目的

- **タイミング**:
  - 各 Phase 完了時
  - セッション終了時
  - 設計変更や重要な技術的決定があった時
  - 予期しない問題が発生し、解決方法を記録する必要がある時
- **目的**:
  - セッション間でのコンテキスト継続性の確保
  - 実装の履歴と判断根拠の明確化
  - 次回作業開始時の状況把握の容易化
