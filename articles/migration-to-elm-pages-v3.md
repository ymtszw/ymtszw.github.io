---
title: "elm-pages v2からv3への移行"
description: |
  後に記事にするためのメモがてら書き溜めていく
---

詳細は[パッケージ本体のアップグレードドキュメント](https://github.com/dillonkearns/elm-pages/blob/master/docs/3.0-upgrade-notes.md)を参照。

基本的にはこのドキュメントのとおりにv2リポジトリを改造していけばv3のビルドを通すこともできると思われるが、
アップグレードスクリプトなどは提供されていないため手作業が求められ、ハマりどころが多め。

Dillonさんは再三、starter-repoをtemplateとして新規リポジトリを作り、ビルドが通る状態を確認した上で、
v2リポジトリのPage moduleを一つずつ移管してインクリメンタルにビルドを通しながら進めるのを推奨している。

自分もそのように進めたが、その中でキーとなった変更点を中心に上げていく。
特に、**v2で静的サイトを作っていて、基本的にはv3でも静的サイトのまままず移行したい**という意図で進める。

## 大前提

- [Lamderaコンパイラ](https://lamdera.com/)を使うようになった
  - Elmコンパイラの["un-fork"](https://dashboard.lamdera.app/releases/open-source-compiler)で、[将来のElmコンパイラとの互換性を約束しつつ、独自機能を盛り込んでいる](https://dashboard.lamdera.app/docs/differences)代物
  - `npm install`によって降ってくるので、ビルドするだけなら手元環境に手を入れる必要はない
  - ElmLSを使っている場合、Lamderaコンパイラを使うようにworkspace設定を追加する
    ```jsonc
    # .vscode/settings.jsonの例
    "elmLS.elmPath": "node_modules/.bin/lamdera"
    ```
- 開発ツールとしてViteを使うようになった
  - `public/index.js`が`index.ts`になったが、Vite経由で自然にTypeScriptにも対応
- Elm projectとしてのディレクトリ構造が変更になった
  - "Page" moduleは"Route" moduleに変更された（動的routeに対応したので、それを見据えた命名変更）
  - `app/`ディレクトリが加わり、Route moduleの実装はこちらに置くようになった
  - いくつかのWebフレームワークで、`src/`や`lib/`ディレクトリにプロジェクト内ライブラリのような性質のコードを、
    `app/`ディレクトリにアプリケーション固有のコードを置くという慣習があるが、この構造はそれを踏襲している
  - つまり、`src/Page/Hoge.elm`を`app/Route/Hoge.elm`としてコピーすることから移行が始まる

## 頻出の要変更点

- まず`Page.Hoge`は`Route.Hoge`に変更する
- 自動生成されていた`Page` moduleも`RouteBuilder` moduleに変更された
  - `Page.prerender`は`RouteBuilder.preRender`に変更する
  - `Page.single`も`RouteBuilder.single`に変更する
  - `RouteBuilder`では自動生成型名も変更になっている
    - `Page.StaticPayload`は`RouteBuilder.App`に変更
    - `Page.PageWithState`は`RouteBuilder.StatefulRoute`に変更
  - 名前だけでなく、引数の数や順序も変わっているので適宜入れ替える
- Route moduleでは必須のexportが増え、一部内容も変更になった
  - `ActionData`型が必須になった（プレースホルダーは`{}`）
  - `page`関数は`route`関数に変更された
  - `Model`型のプレースホルダーは`()`から`{}`に変更された
  - `Msg`型のプレースホルダーは`Never`から`()`に変更された
- `Path` moduleは`UrlPath` moduleに変更された
- `DataSource`は`BackendTask`に発展的に変更された
  - ビルド時に静的に解決される仕組みには変わりないが、エラーハンドリングの選択肢が増えたり、細かく変わっている
- `OptimizedDecoder`を用いたあれこれはLamderaの導入によって発展解消され、普通の`Json.Decode`が使えるようになった
- `Pages.Secrets`で環境変数を取り込んで`DataSource.Http`などで使っていた部分が、上記２つの組み合わせで`BackendTask.Env`に発展的に変更された
- Route module内から副作用を発行するときは`Cmd`ではなく`Effect`を使うようになった
  - よくある中間層パターン（cf. [elm-spa](https://www.elm-spa.dev/guide/03-pages#pageadvanced), [elm-land](https://elm.land/concepts/effect.html), [ConcourseCI](https://github.com/concourse/concourse/blob/master/web/elm/src/Message/Effects.elm)）
  - `Effect.elm`はユーザランドにあるので、ここで`Effect.perform`を改造してアプリ内共通の副作用を追加することもできる
  - `Browser.Navigation.Key`は`Effect.perform`内でのみ利用できるので、keyを利用する`Browser.Navigation`の副作用は`Effect`として実装する構造になった
- Route moduleの`view`関数の`Msg`具体型は`PagesMsg Msg`とラップする構造になった
- `Route.link`の引数順序が変わった
  - ```elm
    -- v2
    Route.link Route.Index [ Attr.class "class" ] [ Html.text "child"]
    ```
  - ```elm
    -- v3
    Route.link [ Attr.class "class" ] [ Html.text "child"] Route.Index

    -- 多分Pipelineで書きやすくしている？
    Route.Index |> Route.link [ Attr.class "class" ] [ Html.text "child"]
    ```

## （今のところ）Undocumentedな変更点

- Route moduleの`init`関数で`Maybe PageUrl`にランタイムアクセスできなくなった
  - ついでに`QueryParams` moduleも提供されなくなった
  - 一方、`Shared.init`では引き続き利用できる
  - したがってquery parameterなどのURL要素にランタイムにアクセスしたい場合、`Shared.init`の時点で必要なものを`Shared.Model`に取り込んでおいて使う
  - おそらくだが、query parameterを第一義的にはserver renderingにおけるペイロードの受渡手段として使うためのAPI再設計が想定にある？あまりちゃんと調べていない
    - 関連issue: <https://github.com/dillonkearns/elm-pages/issues/509>
