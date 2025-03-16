---
title: "Let's SSR!!! (in elm-pages v3)"
description: |
  elm-pages v3から本格的に導入されたサーバーサイドレンダリング機能の活用方法について、
  実際の作業メモを兼ねながら解説する。静的サイト生成からSSRへの移行アプローチも紹介。
---

## はじめに

elm-pagesは[Elm](https://elm-lang.org/)を使った静的サイトジェネレーターとして知られてきたが、v3からサーバーサイドレンダリング（SSR）機能が本格的に導入された。この記事では、elm-pages v3でSSRを使い始める方法について、実際の作業を行いながらメモとして記録していく。

これまで静的サイトとして運用してきたサイト（このブログを含む）をサーバーサイドレンダリングに移行する過程で得た知見や、新規にSSRサイトを構築する際のポイントを共有する。

## 前提知識

elm-pages v3の（SSGとして使う場合の）基本的な構造については、以前の記事「[elm-pages v2からv3への移行](/articles/migration-to-elm-pages-v3)」で解説している。この記事ではv3の環境がすでにセットアップされていることを前提として、SSR固有の機能に焦点を当てていく。

## elm-pages v3でのSSRとは

elm-pages v2までの静的サイト生成（SSG）では、ビルド時にすべてのページのHTMLが生成され、それがそのままデプロイされていた。これに対してサーバーサイドレンダリング（SSR）では、ユーザーからのリクエストを受けてからHTMLを動的に生成する。

これにより以下のようなメリットがある：

- リクエスト時のデータ（ユーザー認証情報など）に基づいてコンテンツを表示できる
  - 主に`RouteBuilder.serverRender`の機能
  - 事前生成しかない世界では、情報をサーバー側に「隠す」ことができなかったが、これで可能になる
- 頻繁に更新されるコンテンツを含むページでも、都度ビルドし直さずに最新情報を提供できる
  - 主に`RouteBuilder.preRenderWithFallback`の機能
  - こちらは生成するコンテンツとしては事前生成と同じだが、生成タイミングをリクエスト時に遅延させることができる

一方で、サーバー実行環境が必要になるという新たな要件も生まれるし、リファレンス実装は今のところNetlify Functionsしかまだないので、コミュニティ努力が今まさに求められている状況。

## elm-pages v3におけるSSRの実装方法

前述の通りelm-pages v3では、`serverRender`/`preRenderWithFallback`という関数が提供されており、これを使ってSSR（またはオンデマンド静的生成）を実装する。

実装上の差分としては従来の`preRender`や`single`と比較的近い（何なら`preRenderWithFallback`でできることは`preRender`とほぼ同じ？細かくは検証中）。

`serverRender`での大きな違いは、`data`関数にある。

- ビルド時に実行されていた`data`関数が、サーバーで**リクエストごとに実行**されることになる
  - 言い換えると、`serverRender`でも`BackendTask`が`preRender`系と共通の抽象化インターフェイスとなる
  - やってみるとわかるが、これは**elm-pagesに慣れていると書きやすく、うまい設計**だと思う
- `data`関数は`Server.Request.Request`を追加の引数として受け取る
  - これでquery params, body, headers (cookie含む)を取得して利用できる
  - Session抽象化のmoduleもすでに用意されているし、Session cookieの署名機能も提供されている
- 最終的には`BackendTask FatalError (Server.Response.Response Data ErrorPage)`を返すことが求められる
  - 失敗時には`ErrorPage`を返して、v3 scaffold時に用意されている`app/ErrorPage.elm`に処理を渡すことができる

当初リクエスト時だけでなく、同一routeでPOSTを受けたときの処理も`action`関数としてだいたい`data`関数と似たようなインターフェイスで実装する。v3 scaffoldで必須になった`ActionData`型はここでようやく使うようになるというわけ。

**実は基本としてはこれだけ抑えておけば良い。**

サーバーで解決された`Data`や`ActionData`はすでにv3静的サイトで利用中の`app : RouteBuilder.App Data ActionData RouteParams`引数経由で各routeの必須関数群で利用できるので、あとは普通に`app`からデータを引っ張ってクライアント側のロジック(updateやview)で使えばいいだけ。

## 実際の様子

```elm
-- これから実装していく
```
