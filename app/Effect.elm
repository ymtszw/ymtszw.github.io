module Effect exposing
    ( Effect(..)
    , batch
    , fromCmd
    , init
    , map
    , none
    , perform
    , wait
    )

import Browser.Navigation
import Form.FormData exposing (FormData)
import Http
import Pages.Fetcher
import Process
import Task
import Url exposing (Url)


{-| -}
type Effect msg
    = None
    | Cmd (Cmd msg)
    | Batch (List (Effect msg))
    | Init msg
    | Wait Float msg
    | SetField { formId : String, name : String, value : String }
    | FetchRouteData
        { data : Maybe FormData
        , toMsg : Result Http.Error Url -> msg
        }
    | Submit
        { values : FormData
        , toMsg : Result Http.Error Url -> msg
        }
    | SubmitFetcher (Pages.Fetcher.Fetcher msg)


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


init : msg -> Effect msg
init =
    Init


wait : Float -> msg -> Effect msg
wait =
    Wait


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

        Init msg ->
            Init (fn msg)

        Wait ms msg ->
            Wait ms (fn msg)

        FetchRouteData fetchInfo ->
            FetchRouteData
                { data = fetchInfo.data
                , toMsg = fetchInfo.toMsg >> fn
                }

        Submit fetchInfo ->
            Submit
                { values = fetchInfo.values
                , toMsg = fetchInfo.toMsg >> fn
                }

        SetField info ->
            SetField info

        SubmitFetcher fetcher ->
            fetcher
                |> Pages.Fetcher.map fn
                |> SubmitFetcher


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
perform ({ fromPageMsg } as helpers) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        SetField info ->
            helpers.setField info

        Batch list ->
            Cmd.batch (List.map (perform helpers) list)

        Init msg ->
            Task.perform fromPageMsg (Task.succeed msg)

        Wait ms msg ->
            Process.sleep ms
                |> Task.andThen (\_ -> Task.succeed msg)
                |> Task.perform fromPageMsg

        FetchRouteData fetchInfo ->
            helpers.fetchRouteData
                fetchInfo

        Submit record ->
            helpers.submit record

        SubmitFetcher record ->
            helpers.runFetcher record
