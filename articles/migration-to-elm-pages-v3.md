---
title: "elm-pages v2からv3への移行"
description: |
  後に記事にするためのメモがてら書き溜めていく
---

詳細は[**パッケージ本体のアップグレードドキュメント**](https://github.com/dillonkearns/elm-pages/blob/master/docs/3.0-upgrade-notes.md)を参照。

基本的にはこのドキュメントのとおりにv2リポジトリを改造していけばv3のビルドを通すこともできると思われるが、
まだドキュメントが網羅的ではないのと、アップグレードスクリプトなどは提供されていないため手作業が求められ、ハマりどころが多め。

Dillonさんは再三、[starter repo](https://github.com/dillonkearns/elm-pages-starter)をtemplateとして新規リポジトリを作り、ビルドが通る状態を確認した上で、
v2リポジトリのPage moduleを一つずつ移管してインクリメンタルにビルドを通しながら進めるのを推奨している。

自分もそのように進めたが、その中でキーとなった変更点を中心に上げていく。
特に、**v2で静的サイトを作っていて、基本的にはv3でも静的サイトのまままず移行したい**という意図で進める。
個人的な印象として、この需要は大きいと感じている。記事末尾では**v3移行後の開発体験やビルドパフォーマンス**なども触れる。

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
  - 名前だけでなく、引数の数や順序も変わっているAPIがあるので適宜入れ替える
- Route moduleでは必須のexportが増え、一部内容も変更になった
  - `ActionData`型が必須になった（プレースホルダーは`{}`）
  - `page`関数は`route`関数に変更された
  - 逆に`preRender` routeの`routes`関数は`pages`に変更された
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

## 静的サイトビルダーとしては不要な追加機能と、関連実装の除去

- Server rendering機能（`RouteBuilder.serverRender`を用いるRoute module）の追加と、それを実現するためのサーバ側実装と結線するadapter機構が導入された
  - リファレンス実装として、Netlify Functionsを利用するNetlify adapterが提供されている
  - このあたりを使わない場合にクリーニングするには、`elm-pages.config.mjs`を編集し、no-opなadapter（empty adapter）を定義する
    - [このサイトのリポジトリにあるもの](https://github.com/ymtszw/ymtszw-v3/blob/master/elm-pages.config.mjs)が例。Starter repoからのdiffとして示すと、
      ```diff
      diff --git a/elm-pages.config.mjs b/elm-pages.config.mjs
      index 8982a8d..94c3c6c 100644
      --- a/elm-pages.config.mjs
      +++ b/elm-pages.config.mjs
      @@ -1,5 +1,4 @@
       import { defineConfig } from "vite";
      -import adapter from "elm-pages/adapter/netlify.js";

       export default {
         vite: defineConfig({}),
      @@ -16,3 +15,12 @@ export default {
           return !file.endsWith(".css");
         },
       };
      +
      +async function adapter({
      +  renderFunctionFilePath,
      +  routePatterns,
      +  apiRoutePatterns,
      +}) {
      +  console.log("Running empty adapter");
      +  return;
      +}
      ```
    - 不要になる`netlify.toml`等のファイルは削除してOK
    - リファレンス実装であるNetlify adapter自体はelm-pages v3に同梱されていて、`node_modules/elm-pages/adapter/netlify.js`にある
      - ユーザランドに生成されるファイルはない
- スクリプト機構が導入され、新規Routeのscaffolding機能もここから提供されるようになった（`npx elm-pages run AddRoute <route module name>`）
  - Starter repoで用意されているスクリプト例のうち、使わなそうなものは削除してOK
  - ちなみに、scaffoldingスクリプトの利用は必須ではないので、単純に既存Routeファイルを複製したり、あるいは空ファイルから書き始めても、
    `elm-pages build`を実行したり、`elm-pages dev`サーバを起動したりすればちゃんとコード生成してくれる
    - この際、export必須の型や関数が不足している場合は単純にコンパイルエラーとして検知される
    - Scaffoldingスクリプトをカスタマイズするにはコード生成実装に手を染める必要があり、
      elm-pagesによるwebサイト実装とはだいぶ文脈の異なる作業なのでYak-shavingのドツボにはまる可能性が大きい
      - `RouteBuilder.single`と`RouteBuilder.preRender`それぞれでいくつかRoute実装の実績ができたら、日常的にはそこからの複製で作業を開始するほうがおすすめできる

## （今のところ）Undocumentedな変更点

- Route moduleの`init`関数で`Maybe PageUrl`にランタイムアクセスできなくなった
  - ついでに`QueryParams` moduleも提供されなくなった
  - 一方、`Shared.init`では引き続き利用できる
  - したがってquery parameterなどのURL要素にランタイムにアクセスしたい場合、`Shared.init`の時点で必要なものを`Shared.Model`に取り込んでおいて使う
  - おそらくだが、query parameterを第一義的にはserver renderingにおけるペイロードの受渡手段として使うためのAPI再設計が想定にある？あまりちゃんと調べていない
    - 関連issue: <https://github.com/dillonkearns/elm-pages/issues/509>
- 同一ページ内でquery parameterやfragmentだけを変更したURLにリンクし、ユーザがそのリンクをクリックしたとき、Route moduleの`init`に処理が渡らなくなった
  - 結果として、query parameterやfragmentに状態をもたせることによるクライアント側での表示変更が難しくなった
  - 関連issue: <https://github.com/dillonkearns/elm-pages/issues/479>, <https://github.com/dillonkearns/elm-pages/issues/509>
  - なんらかworkaroundがありそうな気はするので調査中
