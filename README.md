# ymtszw's page

## 概要

* [elm-pages]で作成している個人ページ
* これまでに書いたものなどをリンクしていく予定
* スタイルは[sakura](https://github.com/oxalorg/sakura)をバニラで使用
* [elm-pages]について
  * すごく良く出来てる
  * ビルド時にヘッドレスCMSや他サイト、特定ディレクトリなどからリソースをフェッチしてきて、HTMLを事前ビルドする仕組みが最初から想定されている
  * 静的ビルドされるのでちゃんとOGP/Twitter Cardヘッダも出る
  * その割にブラウザロード後は普通のElm appになる
  * つまり、ビルドに関連するコードも、クライアントサイドスクリプティングに関するコードも、全部Elmで書けるという世界観

[elm-pages]: https://github.com/dillonkearns/elm-pages
