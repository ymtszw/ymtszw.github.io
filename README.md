# ymtszw's page [(source)](https://github.com/ymtszw/ymtszw.github.io)

[![GitHub Pages](https://github.com/ymtszw/ymtszw.github.io/actions/workflows/gh-pages.yml/badge.svg)](https://github.com/ymtszw/ymtszw.github.io/actions/workflows/gh-pages.yml)

## 概要

* [elm-pages]で作成している個人ページ
* これまでに書いたものなどをリンクしていく予定
* スタイルは[sakura](https://github.com/oxalorg/sakura)をバニラで使用。このページではCSSを触らないという強い意志
* [elm-pages]について
  * すごく良く出来てる
  * ビルド時にヘッドレスCMSや他サイト、特定ディレクトリなどからリソースをフェッチしてきて、HTMLを事前ビルドする仕組みが最初から想定されている
  * 静的ビルドされるのでちゃんとOGP/Twitter Cardヘッダも出る
  * その割にブラウザロード後は普通のElm appになる
  * つまり、**ビルドに関連するコードも、クライアントサイドスクリプティングに関するコードも、全部Elmで書ける**という世界観
  * ちなみに、スタイル自前でやりたくなったら[elm-css]/[elm-tailwind-modules]/[elm-ui]あたりでハッピーに書ける
    * 最近のオススメは[elm-css]系。styled-components風のscoped CSSになっている

[elm-pages]: https://github.com/dillonkearns/elm-pages
[elm-css]: https://github.com/rtfeldman/elm-css
[elm-tailwind-modules]: https://github.com/matheus23/elm-tailwind-modules
[elm-ui]: https://github.com/mdgriffith/elm-ui
