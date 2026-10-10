# Agent 実装ガイドライン

本リポジトリにおける Agent 向けガイドラインおよび開発運用ルールは、役割ごとに以下のファイル・スキルに整理・移行されました。

## ガイドライン・指示書の参照先

1. **基本ルール & 開発環境セットアップ**:
   - [Agents.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/Agents.md)
   - `README.md` 編集禁止制約、環境セットアップ、Elm フォーマットの基本ルールなどを定義しています。日常的な軽微な修正は `master` ブランチで直接作業可能です。

2. **大規模・複数フェーズにわたる機能開発**:
   - [.agents/skills/implementation-planning/SKILL.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/.agents/skills/implementation-planning/SKILL.md)
   - 実装計画書（`docs/implementation-plans/<FEATURE_NAME>_PLAN.md`）の作成テンプレート、Phase 分割、進捗記録フォーマットを定義したスキルです。

3. **Elm コード品質検証ワークフロー**:
   - [.agents/skills/elm-workflow/SKILL.md](file:///Users/yumatsuzawa/workspace/ymtszw.cc/.agents/skills/elm-workflow/SKILL.md)
   - `elm-format` 実行、行末コメントずれ確認、コード生成、テスト、ビルド検証の手順を定義したスキルです。

4. **過去の実装計画書**:
   - `docs/implementation-plans/` 配下を参照してください。
