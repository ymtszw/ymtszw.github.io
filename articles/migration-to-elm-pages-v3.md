---
title: "elm-pages v2からv3への移行"
description: |
  実際に作業しながらメモとして書き溜めたあと、コードベース全体の移行を完了した時点で清書して公開。
  果たしてv3移行、実際いかほどのものか？
publishedAt: "2024-02-10T04:45:00+09:00"
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
  - このファイルを起点として`import`すれば、別のTypeScriptファイルやnpm depsも簡単に導入できる
- Elm projectとしてのディレクトリ構造が変更になった
  - "Page" moduleは"Route" moduleに変更された（動的routeに対応したので、それを見据えた命名変更か）
  - `app/`ディレクトリが加わり、Route moduleの実装はこちらに置くようになった
    - いくつかのWebフレームワークで、`src/`や`lib/`ディレクトリにプロジェクト内ライブラリのような性質のコードを、`app/`ディレクトリにアプリケーション固有のコード（とくにfile-based routingのためのコード生成に関連するファイル）を置くという慣習があるが、この構造はそれを踏襲している
  - つまり、`src/Page/Hoge.elm`を`app/Route/Hoge.elm`としてコピーすることから移行が始まる

## 頻出の要変更点

- まず`Page.Hoge`は`Route.Hoge`に変更する
- 自動生成されていた`Page` moduleも`RouteBuilder` moduleに変更された
  - `Page.prerender`は`RouteBuilder.preRender`に変更する（lowerCamelCaseに注意）
  - `Page.single`も`RouteBuilder.single`に変更する
  - `RouteBuilder`では自動生成型名も変更になっている
    - `Page.StaticPayload`は`RouteBuilder.App`に変更
    - `Page.PageWithState`は`RouteBuilder.StatefulRoute`に変更
  - 名前だけでなく、引数の数や順序も変わっているAPIがあるので適宜入れ替える
    - 基本的に`BackendTask`で解決される`Data`型が先頭になった。ビルド時に解決されるものから、ランタイムに構成されるもの、という順序を意識すればわかりやすい
- Route moduleでは必須のexportが増え、一部内容も変更になった
  - `ActionData`型が必須になった（プレースホルダーは`{}`）
  - `page`関数は`route`関数に名称変更された
  - 逆に`preRender` routeの`routes`関数は`pages`に名称変更された
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
  - ちなみに、scaffoldingスクリプトの利用は必須ではないので、単純に既存Routeファイルを複製したり、あるいは空ファイルから書き始めても、`elm-pages build`を実行したり、`elm-pages dev`サーバを起動したりすればちゃんとコード生成してくれる
    - この際、export必須の型や関数が不足している場合は単純にコンパイルエラーとして検知される
    - Scaffoldingスクリプトをカスタマイズするにはコード生成実装に手を染める必要があり、elm-pagesによるwebサイト実装とはだいぶ文脈の異なる作業なのでYak-shavingのドツボにはまる可能性が大きい
      - `RouteBuilder.single`と`RouteBuilder.preRender`それぞれでいくつかRoute実装の実績ができたら、日常的にはそこからの複製で作業を開始するほうがおすすめできる

## （今のところ）Undocumentedな変更点

- Route moduleの`init`関数で`Maybe PageUrl`にランタイムアクセスできなくなった
  - ついでに`QueryParams` moduleも提供されなくなった
  - 一方、`Shared.init`では引き続き利用できる
  - したがってquery parameterなどのURL要素にランタイムにアクセスしたい場合、`Shared.init`および`Shared.template.onPageChange`で必要なものを`Shared.Model`に取り込んでおいて使う
- （上記と関連するが、）同一ページ内でquery parameterやfragmentだけを変更したURLにリンクし、ユーザがそのリンクをクリックしたとき、Route moduleの`init`に処理が渡らなくなった
  - 結果として、query parameterやfragmentに状態を持たせることによるクライアント側でのUI状態変更が難しくなった。以前v2で実装していた機能の内容によっては、移行ができない
    - 個人的にはこの状況になった。Fragmentに情報を持たせて、linkを踏ませてLightbox風の画像ビューアを表示する実装を自前でやっていたのだが、それが動かせなくなった
  - 関連issue: <https://github.com/dillonkearns/elm-pages/issues/479>, <https://github.com/dillonkearns/elm-pages/issues/509>
  - [Issue上で議論した](https://github.com/dillonkearns/elm-pages/issues/509#issuecomment-2639219898)が、基本的にはAPI再設計に伴う考慮漏れであって、おそらく今後新規APIとして経路が用意される
    - ただし、`init`を再呼び出しする形ではなく、専用のハンドラー関数を実装する形になる。これは`init`はRoute進入時に1回だけ実行されることを前提としている（＝冪等でない）既存コードを尊重する措置
- `dist/`以下に生成されるファイルのうち、埋め込みデータファイル（＝`BackendTask`でビルド時に静的生成される、アプリケーション初期化用データ）のフォーマットが`content.json`からバイナリの`content.dat`になった
  - elm-pagesランタイムが面倒を見てくれるので我々は気にする必要はない

## v3移行後の開発体験・ビルドパフォーマンス

- Viteはいい
  - npm depsの導入とbundlingをサクッとやれるので、基盤がviteになったのは助かる
    - 個人的には、Hightlight.jsを導入していなかったのに気づいたのでやってみたところ、非常に簡単だった
    - 成果物の実行時容量の最適化とかもvite起点でそれなりにやれる
  - 別プロジェクトですでに使っていて慣れていたり、snippetを持っていたりする場合に流用が効く
- Lamderaの導入と組み合わせたAPIの改善は合理的でそこまで複雑でない
  - `DataSource` => `BackendTask`の変更はほとんどfind-and-replaceでいける
  - `OptimizedDecoder`の不要化による`Json.Decode`への統一も同様、かつ通常のElm appとの差を減らしてくれる
  - 上記に伴う`Pages.Secrets`の廃止と`BackendTask.Env`への移行も直感的でelm-pages v2に親しんでいたならスムーズ
- **静的ビルドパフォーマンスも明確に改善**
  - v2でJSONファイルをソースとする大量のページ生成を行っていたときに大きな課題だった
  - 恐らくは`OptimizedDecoder`周りの挙動に起因していて、数百ファイル（＝ページ）の生成には[**CIで6分半ほどかかっていた**](https://github.com/ymtszw/ymtszw.github.io/actions/runs/13227746810/job/36920767626)
  - 移行後は、同数のファイル生成が[**30秒程度にまで短縮された**](https://github.com/ymtszw/ymtszw-v3/actions/runs/13228008829/job/36921331170)
    - これは思ったより効果がデカくて驚きだった
    - 元々v2での体験をDillonさんに報告していたところ、v3にて期待できる改善として聞いていたのが、その通りだった

## 未評価の部分

- Server-Render Routes
  - Pre-Renderと同様に`BackendTask`を起動してページコンテンツを生成するのだが、これをリクエスト時に動的に行える
    - 最近のfullstack TypeScript frameworkと同様の流れ
  - 静的生成と異なり、URL以外のリクエストに紐づくランタイムデータ（Cookie含むヘッダー、あるいはボディ）にも依存できるので、例えばログイン状態によって表示を変えるページなどの実装が可能になった
  - あるいは、ECサイトのように大量のコンテンツがあり、かつサイトの静的なビルド周期よりも早くコンテンツを更新しなければならないroutesのあるサイトも構築できるようになるはず
  - データストレージにアクセスするためのAPIや秘密情報を公にしなくても上記が実現できるし、おそらくこのroutesが返すコンテンツで動的にエッジキャッシュ更新を促すような戦略も取れるだろう
  - ビジネスで利用する場合により重要度が高まるはず。ただ、個人サイトで欲しくなるケースは限られるか
  - また、リファレンス実装がNetlify Functionsを使ったものなのだが、[ホスティング環境としてのNetlifyは日本からだと遅い](https://blog.anatoo.jp/2020-08-03)というのは界隈で知られた知識で、この状況は少なくとも2025年現在も変化していない
    - 記事書きながら1時間未満の調査だが、Standard Edge Locationsの範囲が拡大されたなら自信を持ってニュースにするはずなので、見つからないということは未だにAsia-PacificだとSingaporeにしかないのだろう
    - ということで、日本のユーザとしてはCloudflare FunctionsやVercelを使ったAdapter実装の登場を待ちたいところ
    - [こちらのコミュニティディスカッション](https://github.com/dillonkearns/elm-pages/discussions/378)を追っておこう

## 終わりに：アップグレードすべき？／始めどき？

これまでの内容を踏まえ、最後に[現時点で最新のelm-pagesの設計に関するFAQ](https://github.com/dillonkearns/elm-pages/blob/2cf36c670aafddd97f21171b1d0b9f7223eaaa1f/docs/FAQ.md)を一読しておくと理解が深まると思う。

その上で、アップグレードの労力を割くべきかどうか？個人的な評価としては：

- **サイトの規模が小さい（比較的作業が小規模で済む）なら、ぜひやるべき**
  - そもそもv2のままだと今後機能追加もないし、security issueに対応するためのdeps updateも徐々に面倒になっていくので、早めにやってしまったほうがいいだろう
  - この記事で書いた、pre-renderサイトのままアップグレードするためのtipsは役に立つはず
- **サイトの規模は大きいが、ビルド時間の肥大化に課題を感じてるなら、ぜひやるべき**
  - これはv3で明確に改善されたポイントのひとつなので、恩恵に預かれるだろう
  - とくに業務でやっている場合はビルド時間短縮は多大なる福利厚生である
- **Client-side routing機構に依存したUI機能がそれなりにあるなら、ちょっと待ったほうがいい**
  - URL遷移経由だと、Elm appのmodule構造/parent-children関係を飛び越えて副作用を呼び出せるわけだが、個人的にもこの機能（というか抜け道）は結構利用していて、いくつかの機能がアップグレードできずにいる
  - 単純な`onClick`起点の副作用に置き換えられる単一ページ内の機能なら現状でもpatch可能だが、複数ページに共通設置して`Shared`で処理を記述していたような機能の場合はちょっと厳しい

といったところ。

また、今v2のサイトを持っていなくてelm-pagesが気になってる場合は？　それなら**間違いなく始めどき**といっていいだろう。

elm-pages v3のベータ期間やリリース直後は、Lamderaコンパイラのインストール等、開発環境のセットアップに難があったのだが、現在そこは解決されていて普通のElm projectと何ら遜色なく開発できる。

Elm自体に慣れていない場合は先に[おなじみのElm Guide](https://guide.elm-lang.jp/)ベースで、あるいは誰かメンターを見つけて**Elmの基礎を学んでからのほうがいい**が、Elmにはすでに慣れていて、より良い感じに静的サイトをElmで書きたいとか、full-stack Elmをやり始めたいとかいった場合は非常に優れた選択肢に間違いない。

Disclosure: [筆者はelm-pagesの作者、DillonさんのGitHubスポンサーです](https://github.com/sponsors/dillonkearns)
