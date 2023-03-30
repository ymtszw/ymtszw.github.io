module Shared exposing
    ( CmsImage
    , Data
    , Model
    , Msg(..)
    , SharedMsg(..)
    , cmsGet
    , cmsImageDecoder
    , formatPosix
    , getGitHubRepoReadme
    , githubGet
    , iso8601Decoder
    , makeSeoImageFromCmsImage
    , makeTitle
    , ogpHeaderImageUrl
    , posixToYmd
    , publicCmsArticles
    , publicOriginalRepos
    , seoBase
    , template
    , twitterLink
    , unixOrigin
    )

import Base64
import Browser.Navigation
import DataSource
import DataSource.File
import DataSource.Http
import Date
import Dict exposing (Dict)
import Head.Seo
import Html exposing (Html)
import Html.Attributes
import Iso8601
import Markdown
import OptimizedDecoder
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets
import Pages.Url
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Time exposing (Month(..))
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
    , cmsArticles : List CmsArticleMetadata
    , zennArticles : List ZennArticleMetadata
    , qiitaArticles : List QiitaArticleMetadata
    , dailyTwilogs : Dict RataDie (List Twilog)
    , externalCss : String
    }


type alias RataDie =
    Int


type alias CmsArticleMetadata =
    { contentId : String
    , publishedAt : Time.Posix
    , revisedAt : Time.Posix
    , title : String
    , image : Maybe CmsImage
    }


type alias ZennArticleMetadata =
    { url : String
    , bodyUpdatedAt : Time.Posix
    , publishedAt : Time.Posix
    , title : String
    , likedCount : Int
    , articleType : String
    }


type alias QiitaArticleMetadata =
    { url : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , title : String
    , likesCount : Int
    , tags : List String
    }


type alias CmsImage =
    { url : String
    , height : Int
    , width : Int
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
    DataSource.map6 Data
        publicOriginalRepos
        publicCmsArticles
        publicZennArticles
        publicQiitaArticles
        dailyTwilogs
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


cmsGet url =
    DataSource.Http.request
        (Pages.Secrets.succeed
            (\microCmsApiKey ->
                { url = url
                , method = "GET"
                , headers = [ ( "X-MICROCMS-API-KEY", microCmsApiKey ) ]
                , body = DataSource.Http.emptyBody
                }
            )
            |> Pages.Secrets.with "MICROCMS_API_KEY"
        )


publicCmsArticles : DataSource.DataSource (List CmsArticleMetadata)
publicCmsArticles =
    let
        articleMetadataDecoder =
            OptimizedDecoder.succeed CmsArticleMetadata
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "id" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "publishedAt" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "revisedAt" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.maybe (OptimizedDecoder.field "image" cmsImageDecoder))
    in
    cmsGet "https://ymtszw.microcms.io/api/v1/articles?limit=10000&orders=-publishedAt&fields=id,title,image,publishedAt,revisedAt"
        (OptimizedDecoder.field "contents" (OptimizedDecoder.list articleMetadataDecoder))


cmsImageDecoder : OptimizedDecoder.Decoder CmsImage
cmsImageDecoder =
    OptimizedDecoder.succeed CmsImage
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "url" OptimizedDecoder.string)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "height" OptimizedDecoder.int)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "width" OptimizedDecoder.int)


iso8601Decoder : OptimizedDecoder.Decoder Time.Posix
iso8601Decoder =
    OptimizedDecoder.andThen (Iso8601.toTime >> Result.mapError Markdown.deadEndsToString >> OptimizedDecoder.fromResult) OptimizedDecoder.string


publicZennArticles : DataSource.DataSource (List ZennArticleMetadata)
publicZennArticles =
    let
        baseUrl =
            "https://zenn.dev/ymtszw/articles/"

        articleMetadataDecoder =
            OptimizedDecoder.succeed ZennArticleMetadata
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "slug" (OptimizedDecoder.map ((++) baseUrl) OptimizedDecoder.string))
                |> OptimizedDecoder.andMap
                    (OptimizedDecoder.oneOf
                        [ OptimizedDecoder.field "body_updated_at" iso8601Decoder
                        , OptimizedDecoder.field "published_at" iso8601Decoder
                        ]
                    )
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "published_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "liked_count" OptimizedDecoder.int)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "article_type" OptimizedDecoder.string)
    in
    cmsGet "https://zenn.dev/api/articles?username=ymtszw&count=500&order=latest"
        (OptimizedDecoder.field "articles" (OptimizedDecoder.list articleMetadataDecoder))


publicQiitaArticles : DataSource.DataSource (List QiitaArticleMetadata)
publicQiitaArticles =
    let
        articleMetadataDecoder =
            OptimizedDecoder.succeed QiitaArticleMetadata
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "url" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "created_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "updated_at" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "title" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "likes_count" OptimizedDecoder.int)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "tags" (OptimizedDecoder.list (OptimizedDecoder.field "name" OptimizedDecoder.string)))
    in
    cmsGet "https://qiita.com/api/v2/users/ymtszw/items?per_page=100"
        (OptimizedDecoder.list articleMetadataDecoder)


type alias Twilog =
    { createdAt : Time.Posix
    , createdDate : Date.Date
    , text : String
    , statusId : TwitterStatusId
    , userName : String
    , userProfileImageUrl : String
    , retweet : Bool
    , retweetedStatusFullText : Maybe String
    , retweetedStatusId : Maybe TwitterStatusId
    , retweetedStatusUserName : Maybe String
    , retweetedStatusProfileUserImageUrl : Maybe String
    , inReplyToStatusId : Maybe TwitterStatusId
    , inReplyToUserId : Maybe TwitterUserId
    }


type TwitterStatusId
    = TwitterStatusId String


type TwitterUserId
    = TwitterUserId String


dailyTwilogs : DataSource.DataSource (Dict RataDie (List Twilog))
dailyTwilogs =
    let
        twilogDecoder =
            OptimizedDecoder.succeed Twilog
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" iso8601Decoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" (iso8601Decoder |> OptimizedDecoder.map (Date.fromPosix Time.utc)))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "Text" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "StatusId" (OptimizedDecoder.map TwitterStatusId OptimizedDecoder.string))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserName" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserProfileImageUrl" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "Retweet" boolString)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusFullText" (OptimizedDecoder.maybe nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusId" (OptimizedDecoder.maybe (OptimizedDecoder.map TwitterStatusId nonEmptyString)))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusUserName" (OptimizedDecoder.maybe nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusProfileUserImageUrl" (OptimizedDecoder.maybe nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToStatusId" (OptimizedDecoder.maybe (OptimizedDecoder.map TwitterStatusId nonEmptyString)))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToUserId" (OptimizedDecoder.maybe (OptimizedDecoder.map TwitterUserId nonEmptyString)))

        toDailyDict =
            List.foldl
                (\twilog dict ->
                    Dict.update (Date.toRataDie twilog.createdDate)
                        (\dailySortedTwilogs ->
                            case dailySortedTwilogs of
                                Just twilogs ->
                                    Just (List.sortBy (.createdAt >> Time.posixToMillis) (twilog :: twilogs))

                                Nothing ->
                                    Just [ twilog ]
                        )
                        dict
                )
                Dict.empty
    in
    DataSource.File.jsonFile
        (OptimizedDecoder.list twilogDecoder |> OptimizedDecoder.map toDailyDict)
        "twilogs.json"


boolString =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\s ->
                case s of
                    "TRUE" ->
                        OptimizedDecoder.succeed True

                    _ ->
                        OptimizedDecoder.succeed False
            )


nonEmptyString =
    OptimizedDecoder.string
        |> OptimizedDecoder.andThen
            (\s ->
                if String.isEmpty s then
                    OptimizedDecoder.fail "String is empty"

                else
                    OptimizedDecoder.succeed s
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


makeSeoImageFromCmsImage : CmsImage -> Head.Seo.Image
makeSeoImageFromCmsImage cmsImage =
    { url = Pages.Url.external cmsImage.url
    , alt = "Article Header Image"
    , dimensions = Just { width = cmsImage.width, height = cmsImage.height }
    , mimeType = Nothing
    }


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
    { title = makeTitle pageView.title
    , body =
        Html.div []
            [ Html.node "style" [] [ Html.text sharedData.externalCss ]
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
                , twitterLink
                ]
            , Html.hr [] []
            , Html.main_ [] pageView.body
            , Html.hr [] []
            , Html.footer [] [ Html.text "© Yu Matsuzawa (ymtszw, Gada), 2022 ", Html.br [] [], twitterLink ]
            ]
    }


twitterLink =
    Html.a [ Html.Attributes.href "https://twitter.com/gada_twt", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ Html.img
            [ Html.Attributes.src "https://img.shields.io/twitter/follow/gada_twt.svg?style=social"
            , Html.Attributes.alt "Twitter: gada_twt"
            , Html.Attributes.width 156
            , Html.Attributes.height 20
            ]
            []
        ]


makeTitle pageTitle =
    pageTitle ++ " | " ++ seoBase.siteName


posixToYmd : Time.Posix -> String
posixToYmd posix =
    String.fromInt (Time.toYear jst posix)
        ++ "年"
        ++ (case Time.toMonth jst posix of
                Jan ->
                    "1月"

                Feb ->
                    "2月"

                Mar ->
                    "3月"

                Apr ->
                    "4月"

                May ->
                    "5月"

                Jun ->
                    "6月"

                Jul ->
                    "7月"

                Aug ->
                    "8月"

                Sep ->
                    "9月"

                Oct ->
                    "10月"

                Nov ->
                    "11月"

                Dec ->
                    "12月"
           )
        ++ String.fromInt (Time.toDay jst posix)
        ++ "日"


formatPosix : Time.Posix -> String
formatPosix posix =
    posixToYmd posix
        ++ " "
        ++ String.padLeft 2 '0' (String.fromInt (Time.toHour jst posix))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (Time.toMinute jst posix))
        ++ ":"
        ++ String.padLeft 2 '0' (String.fromInt (Time.toSecond jst posix))
        ++ " JST"


jst =
    Time.customZone (9 * 60) []


unixOrigin =
    Time.millisToPosix 0
