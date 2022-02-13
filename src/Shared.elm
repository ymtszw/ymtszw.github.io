module Shared exposing (Data, Model, Msg(..), SharedMsg(..), getGitHubRepoReadme, githubGet, ogpHeaderImageUrl, publicOriginalRepos, seoBase, template)

import Base64
import Browser.Navigation
import DataSource
import DataSource.Http
import Head.Seo
import Html exposing (Html)
import Markdown
import OptimizedDecoder
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets
import Pages.Url
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
                    { url = "https://raw.githubusercontent.com/oxalorg/sakura/master/css/sakura.css"
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


getGitHubRepoReadme : String -> DataSource.DataSource (List (Html Never))
getGitHubRepoReadme repo =
    githubGet ("https://api.github.com/repos/ymtszw/" ++ repo ++ "/contents/README.md")
        (OptimizedDecoder.oneOf
            [ OptimizedDecoder.field "content" OptimizedDecoder.string
                |> OptimizedDecoder.map (String.replace "\n" "")
                |> OptimizedDecoder.andThen (Base64.toString >> Result.fromMaybe "Base64 Error!" >> OptimizedDecoder.fromResult)
            , OptimizedDecoder.field "message" OptimizedDecoder.string
            ]
            |> OptimizedDecoder.andThen Markdown.decoder
        )


seoBase :
    { canonicalUrlOverride : Maybe String
    , siteName : String
    , image : Head.Seo.Image
    , description : String
    , title : String
    , locale : Maybe String
    }
seoBase =
    { canonicalUrlOverride = Nothing
    , siteName = "ymtszw's page"
    , image =
        { url = Pages.Url.external <| ogpHeaderImageUrl ++ "?w=900&h=300"
        , alt = "Mt. Asama Header Image"
        , dimensions = Just { width = 900, height = 300 }
        , mimeType = Just "image/jpeg"
        }
    , description = "ymtszw's personal biography page"
    , locale = Just "ja_JP"
    , title = "ymtszw's page"
    }


ogpHeaderImageUrl =
    "https://images.microcms-assets.io/assets/032d3ec87506420baf0093fac244c29b/4a220ee277a54bd4a7cf59a2c423b096/header1500x500.jpg"


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
view sharedData page _ _ pageView =
    { title = pageView.title
    , body =
        Html.div []
            [ Html.node "style" [] <|
                [ -- See Markdown.htmlRenderer
                  Html.text ".inline>p{display:inline;margin-top:unset;margin-bottom:unset;}\n"
                , Html.text sharedData.externalCss
                ]
            , Html.header []
                [ Html.nav [] <|
                    List.intersperse (Html.text " / ") <|
                        List.concat
                            [ [ Route.link Route.Index [] [ Html.text "Index" ] ]
                            , page.route
                                |> Maybe.map
                                    (\route ->
                                        case route of
                                            Route.Articles__ArticleId_ _ ->
                                                [ Html.text "記事" ]

                                            Route.Articles__Draft ->
                                                [ Html.text "記事（下書き）" ]

                                            Route.Index ->
                                                []
                                    )
                                |> Maybe.withDefault []
                            ]
                ]
            , Html.main_ [] pageView.body
            ]
    }
