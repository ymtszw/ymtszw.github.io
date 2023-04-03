module Shared exposing
    ( CmsArticleMetadata
    , CmsImage
    , Data
    , Media
    , Model
    , Msg(..)
    , Quote
    , RataDie
    , Reply(..)
    , SharedMsg(..)
    , TcoUrl
    , Twilog
    , TwitterStatusId(..)
    , TwitterUserId(..)
    , cmsGet
    , cmsImageDecoder
    , dailyTwilogsFromOldest
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
import Helper exposing (nonEmptyString)
import Html exposing (Html)
import Html.Attributes
import Iso8601
import LinkPreview
import List.Extra
import Markdown
import OptimizedDecoder
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Pages.Secrets
import Pages.Url
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Task
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
    | Req_LinkPreview (List String)
    | Res_LinkPreview (List String) (Result String ( String, LinkPreview.Metadata ))


type alias Model =
    { showMobileMenu : Bool
    , links : Dict String LinkPreview.Metadata
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
    ( { showMobileMenu = False, links = Dict.empty }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg (Req_LinkPreview (url :: urls)) ->
            ( model, requestLinkPreviewSequentially urls url )

        SharedMsg (Res_LinkPreview remainingUrls result) ->
            ( case result of
                Ok ( url, metadata ) ->
                    { model | links = Dict.insert url metadata model.links }

                Err _ ->
                    model
            , case remainingUrls of
                [] ->
                    Cmd.none

                url :: urls ->
                    requestLinkPreviewSequentially urls url
            )

        SharedMsg _ ->
            ( model, Cmd.none )


requestLinkPreviewSequentially : List String -> String -> Cmd Msg
requestLinkPreviewSequentially urls url =
    LinkPreview.getMetadataOnDemand url
        |> Task.attempt (Res_LinkPreview urls)
        |> Cmd.map SharedMsg


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
        dailyTwilogsFromOldest
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
    , touchedAt : Time.Posix
    , createdDate : Date.Date
    , text : String
    , id : TwitterStatusId
    , userName : String
    , userProfileImageUrl : String
    , retweet : Maybe Retweet
    , inReplyTo : Maybe InReplyTo
    , replies : List Reply
    , quote : Maybe Quote
    , entitiesTcoUrl : List TcoUrl
    , extendedEntitiesMedia : List Media
    }


type Reply
    = Reply Twilog


type alias Retweet =
    { fullText : String
    , id : TwitterStatusId
    , userName : String
    , userProfileImageUrl : String
    , quote : Maybe Quote
    , entitiesTcoUrl : List TcoUrl
    , extendedEntitiesMedia : List Media
    }


type alias InReplyTo =
    { id : TwitterStatusId
    , userId : TwitterUserId
    }


type alias Quote =
    { fullText : String
    , id : TwitterStatusId
    , userName : String
    , userProfileImageUrl : String
    , permalinkUrl : String
    }


type alias TcoUrl =
    { url : String
    , expandedUrl : String
    }


type alias Media =
    { url : String
    , sourceUrl : String
    , type_ : String
    , expandedUrl : String
    }


type TwitterStatusId
    = TwitterStatusId String


type TwitterUserId
    = TwitterUserId String


dailyTwilogsFromOldest : DataSource.DataSource (Dict RataDie (List Twilog))
dailyTwilogsFromOldest =
    let
        twilogDecoder =
            OptimizedDecoder.succeed Twilog
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" createdAtDecoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" createdAtDecoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" (createdAtDecoder |> OptimizedDecoder.map (Date.fromPosix jst)))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "Text" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "StatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserName" nonEmptyString)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserProfileImageUrl" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.maybe retweetDecoder)
                |> OptimizedDecoder.andMap (OptimizedDecoder.maybe inReplyToDecoder)
                -- Resolve replies later
                |> OptimizedDecoder.andMap (OptimizedDecoder.succeed [])
                |> OptimizedDecoder.andMap (OptimizedDecoder.maybe quoteDecoder)
                |> OptimizedDecoder.andMap entitiesTcoUrlDecoder
                |> OptimizedDecoder.andMap extendedEntitiesMediaDecoder
                |> OptimizedDecoder.maybe

        createdAtDecoder =
            OptimizedDecoder.oneOf
                [ iso8601Decoder
                , -- Decode date time string formatted with "ddd MMM DD HH:mm:ss Z YYYY" (originates from Twitter API)
                  OptimizedDecoder.andThen
                    (\str ->
                        case String.split " " str of
                            [ _, mon, paddedDay, paddedHourMinSec, zone, year ] ->
                                Iso8601.toTime (year ++ "-" ++ monthToPaddedNumber mon ++ "-" ++ paddedDay ++ "T" ++ paddedHourMinSec ++ zone)
                                    |> Result.mapError Markdown.deadEndsToString
                                    |> OptimizedDecoder.fromResult

                            _ ->
                                OptimizedDecoder.fail ("Failed to parse date: " ++ str)
                    )
                    OptimizedDecoder.string
                ]

        retweetDecoder =
            OptimizedDecoder.field "Retweet" boolString
                |> OptimizedDecoder.andThen
                    (\isRetweet ->
                        if isRetweet then
                            OptimizedDecoder.succeed Retweet
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusFullText" OptimizedDecoder.string)
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusUserName" nonEmptyString)
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusUserProfileImageUrl" OptimizedDecoder.string)
                                |> OptimizedDecoder.andMap (OptimizedDecoder.maybe retweetQuoteDecoder)
                                |> OptimizedDecoder.andMap retweetEntitiesTcoUrlDecoder
                                |> OptimizedDecoder.andMap retweetExtendedEntitiesMediaDecoder

                        else
                            OptimizedDecoder.fail "Not a retweet"
                    )

        inReplyToDecoder =
            OptimizedDecoder.succeed InReplyTo
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToUserId" (OptimizedDecoder.map TwitterUserId nonEmptyString))

        quoteDecoder =
            OptimizedDecoder.succeed Quote
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusFullText" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusUserName" nonEmptyString)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusUserProfileImageUrl" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusPermalinkUrl" nonEmptyString)

        entitiesTcoUrlDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map2 TcoUrl)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "EntitiesUrlsUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "EntitiesUrlsExpandedUrls" commaSeparatedList)
                , OptimizedDecoder.succeed []
                ]

        extendedEntitiesMediaDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map4 Media)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaExpandedUrls" commaSeparatedList)
                , OptimizedDecoder.succeed (List.map3 (\url sourceUrl type_ -> Media url sourceUrl type_ sourceUrl))
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                , OptimizedDecoder.succeed []
                ]

        retweetEntitiesTcoUrlDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map2 TcoUrl)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusEntitiesUrlsUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusEntitiesUrlsExpandedUrls" commaSeparatedList)
                , OptimizedDecoder.succeed []
                ]

        retweetExtendedEntitiesMediaDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map4 Media)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaSourceUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaExpandedUrls" commaSeparatedList)
                , OptimizedDecoder.succeed []
                ]

        retweetQuoteDecoder =
            OptimizedDecoder.succeed Quote
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusFullText" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusUserName" nonEmptyString)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusUserProfileImageUrl" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusPermalinkUrl" nonEmptyString)

        toDailyDict =
            List.foldl
                (\maybeTwilog dict ->
                    case maybeTwilog of
                        Just twilog ->
                            Dict.update (Date.toRataDie twilog.createdDate)
                                (\dailySortedTwilogs ->
                                    case dailySortedTwilogs of
                                        Just twilogs ->
                                            Just (List.sortBy (.createdAt >> Time.posixToMillis) (twilog :: twilogs))

                                        Nothing ->
                                            Just [ twilog ]
                                )
                                dict

                        Nothing ->
                            dict
                )
                Dict.empty
    in
    DataSource.File.jsonFile
        (OptimizedDecoder.list twilogDecoder |> OptimizedDecoder.map toDailyDict |> OptimizedDecoder.map resolveRepliesWithinDay)
        "twilogs.json"


resolveRepliesWithinDay : Dict RataDie (List Twilog) -> Dict RataDie (List Twilog)
resolveRepliesWithinDay =
    let
        -- Assume twilogsOfDay is newest-first.
        -- Here we traverse the list so that reply tweets are brought under `.replies` field of the tweet (within the same day) they replied to.
        -- Also at the same time, propagate touchedAt field to the tweet they replied to, eventually to the root tweet. At last we re-sort the list with touchedAt
        resolveHelp : List Twilog -> List Twilog -> List Twilog
        resolveHelp acc twilogsOfDay =
            case twilogsOfDay of
                [] ->
                    List.sortBy (.touchedAt >> Time.posixToMillis) acc

                twilog :: olderTwilogs ->
                    case Maybe.andThen (\inReplyTo -> List.Extra.findIndex (\olderTwilog -> olderTwilog.id == inReplyTo.id) olderTwilogs) twilog.inReplyTo of
                        Just index ->
                            let
                                updatedOlderTwilogs =
                                    List.Extra.updateAt index (\repliedTwilog -> { repliedTwilog | touchedAt = maxTime repliedTwilog.touchedAt twilog.touchedAt, replies = sortReplies (Reply { twilog | inReplyTo = Nothing } :: repliedTwilog.replies) }) olderTwilogs
                            in
                            resolveHelp acc updatedOlderTwilogs

                        Nothing ->
                            resolveHelp (twilog :: acc) olderTwilogs

        sortReplies =
            -- Reverse to newsest-first
            List.sortBy (\(Reply twilog) -> Time.posixToMillis twilog.touchedAt) >> List.reverse
    in
    -- Reverse the list so that the latest twilog is at the head
    Dict.map (\_ twilogs -> twilogs |> List.reverse |> resolveHelp [])


maxTime : Time.Posix -> Time.Posix -> Time.Posix
maxTime t1 t2 =
    if Time.posixToMillis t1 > Time.posixToMillis t2 then
        t1

    else
        t2


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


commaSeparatedList =
    nonEmptyString
        |> OptimizedDecoder.andThen (\s -> OptimizedDecoder.succeed (String.split "," s))


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
                        List.concatMap (\kids -> List.map (\kid -> Html.strong [] [ kid ]) kids)
                            [ [ Route.link Route.Index [] [ Html.text "Index" ] ]
                            , page.route
                                |> Maybe.map
                                    (\route ->
                                        case route of
                                            Route.About ->
                                                [ Html.text "このサイトについて" ]

                                            Route.Articles ->
                                                [ Html.text "記事" ]

                                            Route.Articles__ArticleId_ { articleId } ->
                                                [ Route.link Route.Articles [] [ Html.text "記事" ]
                                                , Html.text (cmsArticleShortTitle articleId sharedData.cmsArticles)
                                                ]

                                            Route.Articles__Draft ->
                                                [ Html.text "記事（下書き）" ]

                                            Route.Twilogs ->
                                                [ Html.text "Twilog" ]

                                            Route.Twilogs__Day_ { day } ->
                                                [ Route.link Route.Twilogs [] [ Html.text "Twilog" ]
                                                , Html.text day
                                                ]

                                            Route.Index ->
                                                []
                                    )
                                |> Maybe.withDefault []
                            ]
                , sitemap
                , Html.nav [ Html.Attributes.class "meta" ]
                    [ siteBuildStatus
                    , twitterLink
                    ]
                ]
            , Html.hr [] []
            , Html.main_ [] pageView.body
            , Html.hr [] []
            , Html.footer []
                [ Html.text "© Yu Matsuzawa (ymtszw, Gada), 2022 "
                , sitemap
                , Html.nav [ Html.Attributes.class "meta" ]
                    [ siteBuildStatus
                    , twitterLink
                    ]
                ]
            ]
    }


cmsArticleShortTitle : String -> List CmsArticleMetadata -> String
cmsArticleShortTitle articleId cmsArticles =
    cmsArticles
        |> List.Extra.find (\cmsArticle -> cmsArticle.contentId == articleId)
        |> Maybe.map
            (\cmsArticle ->
                if String.length cmsArticle.title > 40 then
                    String.left 40 cmsArticle.title ++ "..."

                else
                    cmsArticle.title
            )
        |> Maybe.withDefault articleId


siteBuildStatus =
    Html.a [ Html.Attributes.href "https://github.com/ymtszw/ymtszw.github.io", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ Html.img
            [ Html.Attributes.src "https://github.com/ymtszw/ymtszw.github.io/actions/workflows/gh-pages.yml/badge.svg"
            , Html.Attributes.alt "GitHub Pages: ymtszw/ymtszw.github.io"
            , Html.Attributes.height 20
            ]
            []
        ]


twitterLink =
    Html.a [ Html.Attributes.href "https://twitter.com/gada_twt", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ Html.img
            [ Html.Attributes.src "https://img.shields.io/twitter/follow/gada_twt.svg?style=social"
            , Html.Attributes.alt "Twitter: gada_twt"
            ]
            []
        ]


sitemap =
    Html.nav [] <|
        List.intersperse (Html.text " | ")
            [ Html.text ""
            , Route.link Route.About [] [ Html.text "このサイトについて" ]
            , Route.link Route.Twilogs [] [ Html.text "Twilog" ]
            , Route.link Route.Articles [] [ Html.text "記事" ]
            , Html.text ""
            ]



-----------------
-- HELPERS
-----------------


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


monthToPaddedNumber monStr =
    case monStr of
        "Jan" ->
            "01"

        "Feb" ->
            "02"

        "Mar" ->
            "03"

        "Apr" ->
            "04"

        "May" ->
            "05"

        "Jun" ->
            "06"

        "Jul" ->
            "07"

        "Aug" ->
            "08"

        "Sep" ->
            "09"

        "Oct" ->
            "10"

        "Nov" ->
            "11"

        _ ->
            -- Dec
            "12"
