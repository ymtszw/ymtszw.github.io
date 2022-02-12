module Shared exposing (Data, Model, Msg(..), SharedMsg(..), githubGet, publicOriginalRepos, template)

import Browser.Navigation
import DataSource
import DataSource.Http
import Html exposing (Html)
import OptimizedDecoder
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data =
    { repos : List String
    , externalCss : String
    }


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init _ _ _ =
    ( { showMobileMenu = False }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg _ ->
            ( model, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    let
        normalizeCss =
            DataSource.Http.unoptimizedRequest
                (Pages.Secrets.succeed
                    { url = "https://raw.githubusercontent.com/necolas/normalize.css/8.0.1/normalize.css"
                    , method = "GET"
                    , headers = []
                    , body = DataSource.Http.emptyBody
                    }
                )
                (DataSource.Http.expectString Result.Ok)

        classlessCss =
            DataSource.Http.unoptimizedRequest
                (Pages.Secrets.succeed
                    { url = "https://unpkg.com/sakura.css@1.3.1/css/sakura.css"
                    , method = "GET"
                    , headers = []
                    , body = DataSource.Http.emptyBody
                    }
                )
                (DataSource.Http.expectString Result.Ok)
    in
    DataSource.map2 Data
        publicOriginalRepos
        (DataSource.map2 (++) normalizeCss classlessCss)


githubGet url =
    DataSource.Http.request
        (Pages.Secrets.succeed
            (\githubToken ->
                { url = url
                , method = "GET"
                , headers = [ ( "Authorization", "token " ++ githubToken ) ]
                , body = DataSource.Http.emptyBody
                }
            )
            |> Pages.Secrets.with "GITHUB_TOKEN"
        )


publicOriginalRepos =
    githubGet "https://api.github.com/users/ymtszw/repos?per_page=100&direction=desc&sort=created"
        (OptimizedDecoder.list
            (OptimizedDecoder.map2 Tuple.pair
                (OptimizedDecoder.field "fork" (OptimizedDecoder.map not OptimizedDecoder.bool))
                (OptimizedDecoder.field "name" OptimizedDecoder.string)
            )
            |> OptimizedDecoder.map
                (List.filterMap
                    (\( fork, name ) ->
                        if fork then
                            Just name

                        else
                            Nothing
                    )
                )
        )


view :
    Data
    ->
        { path : Path
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData _ _ _ pageView =
    { title = pageView.title
    , body = Html.main_ [] (Html.node "style" [] [ Html.text sharedData.externalCss ] :: pageView.body)
    }
