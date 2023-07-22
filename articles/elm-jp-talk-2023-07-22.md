---
title: "Elm-jp Online #3でelm-reviewについて解説した"
description: |
  例によって報告記事
publishedAt: 2023-07-23T00:00:00.000+09:00
---

こちらで発表した。

<https://elm-jp.connpass.com/event/288224>

内容はelm-reviewのProjectRuleSchemaを使ったボイラープレート生成について。

<https://zenn.dev/siiibo_tech/articles/elm-review-project-rule-schema>

[miyamo](https://twitter.com/miyamo_madoka)の[ボイラープレート生成についてのZenn scrap](https://zenn.dev/miyamoen/scraps/55c5a34398cf3f)を丁寧にしただけの内容になっちゃいそうだな〜と書いてて危惧したが、最終的にはちゃんと最近ギョームでやった漸進的Fix方式での実装とそこで見つかったTipsを紹介できたので良かった。

あと懇親会でこないだ実装した[KindleBookTitleパーサ](https://github.com/ymtszw/ymtszw.github.io/blob/7b50d9b65b351c0559efa8949854daf9368394e2/src/KindleBookTitle.elm#L357)を即席で紹介した。

皆さんの発表：

- [脱・関数型プログラミング](https://github.com/arowM/nihongo-slides/blob/1ce719e6290e2c979389225e78676cd77fd4a8e3/2023-07-22_Elm-Online-03.pdf) by [ヤギの🐐さくらちゃん🎯](https://twitter.com/arowM_)
  - やっぱ最終的にはシナリオからコード生成みたいなこと考えるよね
  - 命令型プログラミングスタイル、記述をコンパクトに整形したくなってくる
  - ["Chaining style"](https://github.com/avh4/elm-format/issues/568)というか、CPSというか、そういったスタイルをいい感じにするフォーマッタがほしい
- [Maybeについて](https://www.figma.com/file/8D7puRCC3aE1DVqTCrnWhu/Elm-jp?type=design&node-id=109-2068&mode=design)
  - なかなか盛り上がった
  - 何ならElmのFloat/Intなどのプリミティブについての話もなにげに深められるような気がする
- 懇親会ネタ
  - [DNCLインタープリタの続報](https://twitter.com/y_taka_23/status/1682650030354886658) by [チェシャ猫](https://twitter.com/y_taka_23)
    - ちょっくらインタープリタでも実装すっか、からここまでやれるのがすごい
  - [vite-plugin-elmの話](https://github.com/hmsk/vite-plugin-elm) by [hmsk](https://twitter.com/hmsk)
    - 実装背景からメンテのあれこれまで。今度からViteでElmやるの勧めよう
    - 流れで[elm-watch](https://github.com/lydell/elm-watch)の内部実装をちょっとリーディングしたりした

次は何かな〜

- elm-pagesを始めやすくするstarterみたいなのを用意してみたい
- 何なら業務で使うために、Jekyllサイトを段階的にelm-pagesへ移行する段取りを開拓したい
- Twilogの話
- KindleLibraryの話
- Cloudflare Workers + link-previewの話

ネタはあんだけどモチベには季節性がある。当日資料をガッと用意するスタイルだしな。
