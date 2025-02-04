module Effect exposing
    ( Effect, batch, fromCmd, map, none, perform
    , replaceUrl, runtimePortsToJs
    )

{-| Main.elmから呼び出されるEffect module.

dillonkearns/elm-formなど、serverRender関連で特定のパッケージを使うことを前提にAPI設計・scaffoldされているが、使わない場合は部分的に削除して問題ない。

その場合にも下記callback interfaceの型は保たれる必要があり、困ったら内部実装である[ProgramConfig]型を参考にする。

[ProgramConfig]: https://github.com/dillonkearns/elm-pages/blob/10.2.0/src/Pages/ProgramConfig.elm#L108-L125


## Callback interface

Scaffold時点でexposeされている以下の型と関数は必須。中身の実装は自由に変更可能。

@docs Effect, batch, fromCmd, map, none, perform


## Global Side Effects

`Browser.application`でのみ使える`Browser.Navigation.Key`を使った副作用や、`RuntimePorts`の利用など、アプリケーショングローバルな副作用はこのレイヤーで実装できるような設計となっている。

@docs replaceUrl, runtimePortsToJs

-}

import Browser.Navigation
import Http
import Json.Encode
import Pages.Fetcher
import Pages.FormData exposing (FormData)
import RuntimePorts
import Url exposing (Url)


{-| -}
type Effect msg
    = None
    | Cmd (Cmd msg)
    | Batch (List (Effect msg))
    | ReplaceUrl String
    | RuntimePortsToJs Json.Encode.Value


{-| -}
none : Effect msg
none =
    None


{-| -}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| -}
fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


replaceUrl : String -> Effect msg
replaceUrl =
    ReplaceUrl


runtimePortsToJs : Json.Encode.Value -> Effect msg
runtimePortsToJs =
    RuntimePortsToJs


{-| -}
map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Batch list ->
            Batch (List.map (map fn) list)

        ReplaceUrl url ->
            ReplaceUrl url

        RuntimePortsToJs v ->
            RuntimePortsToJs v


{-| -}
perform :
    { fetchRouteData :
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , submit :
        { values : FormData
        , toMsg : Result Http.Error Url -> pageMsg
        }
        -> Cmd msg
    , runFetcher :
        Pages.Fetcher.Fetcher pageMsg
        -> Cmd msg
    , fromPageMsg : pageMsg -> msg
    , key : Browser.Navigation.Key
    , setField : { formId : String, name : String, value : String } -> Cmd msg
    }
    -> Effect pageMsg
    -> Cmd msg
perform ({ fromPageMsg, key } as helpers) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        Batch list ->
            Cmd.batch (List.map (perform helpers) list)

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl key url

        RuntimePortsToJs v ->
            RuntimePorts.toJs v
