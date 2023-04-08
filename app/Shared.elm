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
    , TwilogArchiveMetadata
    , TwitterStatusId(..)
    , TwitterUserId(..)
    , cmsGet
    , cmsImageDecoder
    , dailyTwilogsFromOldest
    , dumpTwilog
    , formatPosix
    , githubGet
    , iso8601Decoder
    , makeSeoImageFromCmsImage
    , makeTitle
    , makeTwilogsJsonPath
    , ogpHeaderImageUrl
    , posixToYmd
    , publicCmsArticles
    , publicOriginalRepos
    , seoBase
    , template
    , twilogArchives
    , unixOrigin
    )

import BackendTask exposing (BackendTask)
import BackendTask.Env
import BackendTask.File
import BackendTask.Glob
import BackendTask.Http
import Date
import Dict exposing (Dict)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head.Seo
import Helper exposing (nonEmptyString)
import Html exposing (Html)
import Html.Attributes
import Iso8601
import Json.Decode
import Json.Decode.Extra
import Json.Encode
import LanguageTag.Country
import LanguageTag.Language
import LinkPreview
import List.Extra
import Markdown
import MimeType exposing (MimeImage(..), MimeType(..))
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Site
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
    , twilogArchives : List TwilogArchiveMetadata
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
    Pages.Flags.Flags
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
    -> ( Model, Effect Msg )
init _ _ =
    ( { showMobileMenu = False, links = Dict.empty }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Effect.none )

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
                    Effect.none

                url :: urls ->
                    requestLinkPreviewSequentially urls url
            )

        SharedMsg _ ->
            ( model, Effect.none )


requestLinkPreviewSequentially : List String -> String -> Effect Msg
requestLinkPreviewSequentially urls url =
    url
        |> LinkPreview.getMetadataOnDemand
        |> Task.attempt (Res_LinkPreview urls)
        |> Cmd.map SharedMsg
        |> Effect.fromCmd


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.map5 Data
        publicOriginalRepos
        publicCmsArticles
        publicZennArticles
        publicQiitaArticles
        twilogArchives


githubGet : String -> Json.Decode.Decoder a -> BackendTask FatalError a
githubGet url decoder =
    BackendTask.Env.expect "GITHUB_TOKEN"
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\githubToken ->
                BackendTask.Http.request
                    { url = url
                    , method = "GET"
                    , headers = [ ( "Authorization", "token " ++ githubToken ) ]
                    , body = BackendTask.Http.emptyBody
                    , retries = Nothing
                    , timeoutInMs = Just 3000
                    }
                    (BackendTask.Http.expectJson decoder)
                    |> BackendTask.allowFatal
            )


publicOriginalRepos =
    githubGet "https://api.github.com/users/ymtszw/repos?per_page=100&direction=desc&sort=created"
        (Json.Decode.list
            (Json.Decode.map2 Tuple.pair
                (Json.Decode.field "fork" (Json.Decode.map not Json.Decode.bool))
                (Json.Decode.field "name" Json.Decode.string)
            )
            |> Json.Decode.map
                (List.filterMap
                    (\( fork, name ) ->
                        if fork then
                            Just name

                        else
                            Nothing
                    )
                )
        )


cmsGet url decoder =
    BackendTask.Env.expect "MICROCMS_API_KEY"
        |> BackendTask.allowFatal
        |> BackendTask.andThen
            (\microCmsApiKey ->
                BackendTask.Http.request
                    { url = url
                    , method = "GET"
                    , headers = [ ( "X-MICROCMS-API-KEY", microCmsApiKey ) ]
                    , body = BackendTask.Http.emptyBody
                    , retries = Nothing
                    , timeoutInMs = Just 2000
                    }
                    (BackendTask.Http.expectJson decoder)
                    |> BackendTask.allowFatal
            )


publicCmsArticles =
    let
        articleMetadataDecoder =
            Json.Decode.succeed CmsArticleMetadata
                |> Json.Decode.Extra.andMap (Json.Decode.field "id" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "publishedAt" iso8601Decoder)
                |> Json.Decode.Extra.andMap (Json.Decode.field "revisedAt" iso8601Decoder)
                |> Json.Decode.Extra.andMap (Json.Decode.field "title" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.maybe (Json.Decode.field "image" cmsImageDecoder))
    in
    cmsGet "https://ymtszw.microcms.io/api/v1/articles?limit=10000&orders=-publishedAt&fields=id,title,image,publishedAt,revisedAt"
        (Json.Decode.field "contents" (Json.Decode.list articleMetadataDecoder))


cmsImageDecoder : Json.Decode.Decoder CmsImage
cmsImageDecoder =
    Json.Decode.succeed CmsImage
        |> Json.Decode.Extra.andMap (Json.Decode.field "url" Json.Decode.string)
        |> Json.Decode.Extra.andMap (Json.Decode.field "height" Json.Decode.int)
        |> Json.Decode.Extra.andMap (Json.Decode.field "width" Json.Decode.int)


iso8601Decoder : Json.Decode.Decoder Time.Posix
iso8601Decoder =
    Json.Decode.andThen (Iso8601.toTime >> Result.mapError Markdown.deadEndsToString >> Json.Decode.Extra.fromResult) Json.Decode.string


publicZennArticles =
    let
        baseUrl =
            "https://zenn.dev/ymtszw/articles/"

        articleMetadataDecoder =
            Json.Decode.succeed ZennArticleMetadata
                |> Json.Decode.Extra.andMap (Json.Decode.field "slug" (Json.Decode.map ((++) baseUrl) Json.Decode.string))
                |> Json.Decode.Extra.andMap
                    (Json.Decode.oneOf
                        [ Json.Decode.field "body_updated_at" iso8601Decoder
                        , Json.Decode.field "published_at" iso8601Decoder
                        ]
                    )
                |> Json.Decode.Extra.andMap (Json.Decode.field "published_at" iso8601Decoder)
                |> Json.Decode.Extra.andMap (Json.Decode.field "title" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "liked_count" Json.Decode.int)
                |> Json.Decode.Extra.andMap (Json.Decode.field "article_type" Json.Decode.string)
    in
    cmsGet "https://zenn.dev/api/articles?username=ymtszw&count=500&order=latest"
        (Json.Decode.field "articles" (Json.Decode.list articleMetadataDecoder))


publicQiitaArticles =
    let
        articleMetadataDecoder =
            Json.Decode.succeed QiitaArticleMetadata
                |> Json.Decode.Extra.andMap (Json.Decode.field "url" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "created_at" iso8601Decoder)
                |> Json.Decode.Extra.andMap (Json.Decode.field "updated_at" iso8601Decoder)
                |> Json.Decode.Extra.andMap (Json.Decode.field "title" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "likes_count" Json.Decode.int)
                |> Json.Decode.Extra.andMap (Json.Decode.field "tags" (Json.Decode.list (Json.Decode.field "name" Json.Decode.string)))
    in
    cmsGet "https://qiita.com/api/v2/users/ymtszw/items?per_page=100"
        (Json.Decode.list articleMetadataDecoder)


type alias Twilog =
    { createdAt : Time.Posix
    , touchedAt : Time.Posix
    , createdDate : Date.Date
    , text : String
    , id : TwitterStatusId
    , idStr : String
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


type alias TwilogArchiveMetadata =
    { date : Date.Date
    , isoDate : String
    , rataDie : RataDie
    , path : String
    }


twilogArchives : BackendTask FatalError (List TwilogArchiveMetadata)
twilogArchives =
    BackendTask.Glob.succeed makeTwilogArchiveMetadata
        |> BackendTask.Glob.match (BackendTask.Glob.literal "data/")
        |> BackendTask.Glob.capture BackendTask.Glob.int
        |> BackendTask.Glob.match (BackendTask.Glob.literal "/")
        |> BackendTask.Glob.capture BackendTask.Glob.int
        |> BackendTask.Glob.match (BackendTask.Glob.literal "/")
        |> BackendTask.Glob.capture BackendTask.Glob.int
        |> BackendTask.Glob.match (BackendTask.Glob.literal "-twilogs.json")
        |> BackendTask.Glob.toBackendTask
        -- Make newest first
        |> BackendTask.map (List.sortBy .rataDie >> List.reverse)


makeTwilogArchiveMetadata : Int -> Int -> Int -> TwilogArchiveMetadata
makeTwilogArchiveMetadata year month day =
    let
        date =
            Date.fromCalendarDate year (Date.numberToMonth month) day
    in
    { date = date
    , isoDate = Date.toIsoString date
    , rataDie = Date.toRataDie date
    , path = makeTwilogsJsonPath date
    }


makeTwilogsJsonPath : Date.Date -> String
makeTwilogsJsonPath date =
    "data/" ++ Date.format "yyyy/MM/dd" date ++ "-twilogs.json"


twilogDecoder : Json.Decode.Decoder Twilog
twilogDecoder =
    let
        createdAtDecoder =
            Json.Decode.oneOf
                [ iso8601Decoder
                , -- Decode date time string formatted with "ddd MMM DD HH:mm:ss Z YYYY" (originates from Twitter API)
                  Json.Decode.andThen
                    (\str ->
                        case String.split " " str of
                            [ _, mon, paddedDay, paddedHourMinSec, zone, year ] ->
                                Iso8601.toTime (year ++ "-" ++ monthToPaddedNumber mon ++ "-" ++ paddedDay ++ "T" ++ paddedHourMinSec ++ zone)
                                    |> Result.mapError Markdown.deadEndsToString
                                    |> Json.Decode.Extra.fromResult

                            _ ->
                                Json.Decode.fail ("Failed to parse date: " ++ str)
                    )
                    Json.Decode.string
                ]

        retweetDecoder =
            Json.Decode.field "Retweet" boolString
                |> Json.Decode.andThen
                    (\isRetweet ->
                        if isRetweet then
                            Json.Decode.succeed Retweet
                                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusFullText" Json.Decode.string)
                                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusId" (Json.Decode.map TwitterStatusId nonEmptyString))
                                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusUserName" nonEmptyString)
                                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusUserProfileImageUrl" Json.Decode.string)
                                |> Json.Decode.Extra.andMap (Json.Decode.maybe retweetQuoteDecoder)
                                |> Json.Decode.Extra.andMap retweetEntitiesTcoUrlDecoder
                                |> Json.Decode.Extra.andMap retweetExtendedEntitiesMediaDecoder

                        else
                            Json.Decode.fail "Not a retweet"
                    )

        inReplyToDecoder =
            Json.Decode.succeed InReplyTo
                |> Json.Decode.Extra.andMap (Json.Decode.field "InReplyToStatusId" (Json.Decode.map TwitterStatusId nonEmptyString))
                |> Json.Decode.Extra.andMap (Json.Decode.field "InReplyToUserId" (Json.Decode.map TwitterUserId nonEmptyString))

        quoteDecoder =
            Json.Decode.succeed Quote
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusFullText" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusId" (Json.Decode.map TwitterStatusId nonEmptyString))
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusUserName" nonEmptyString)
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusUserProfileImageUrl" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusPermalinkUrl" nonEmptyString)

        entitiesTcoUrlDecoder =
            Json.Decode.oneOf
                [ Json.Decode.succeed (List.map2 TcoUrl)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "EntitiesUrlsUrls" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "EntitiesUrlsExpandedUrls" commaSeparatedUrls)
                , Json.Decode.succeed []
                ]

        extendedEntitiesMediaDecoder =
            Json.Decode.oneOf
                [ Json.Decode.succeed (List.map4 Media)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , Json.Decode.succeed (List.map3 (\url sourceUrl type_ -> Media url sourceUrl type_ sourceUrl))
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                , Json.Decode.succeed []
                ]

        retweetEntitiesTcoUrlDecoder =
            Json.Decode.oneOf
                [ Json.Decode.succeed (List.map2 TcoUrl)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusEntitiesUrlsUrls" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusEntitiesUrlsExpandedUrls" commaSeparatedUrls)
                , Json.Decode.succeed []
                ]

        retweetExtendedEntitiesMediaDecoder =
            Json.Decode.oneOf
                [ Json.Decode.succeed (List.map4 Media)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , Json.Decode.succeed []
                ]

        retweetQuoteDecoder =
            Json.Decode.succeed Quote
                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusQuotedStatusFullText" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusQuotedStatusId" (Json.Decode.map TwitterStatusId nonEmptyString))
                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusQuotedStatusUserName" nonEmptyString)
                |> Json.Decode.Extra.andMap (Json.Decode.field "RetweetedStatusQuotedStatusUserProfileImageUrl" Json.Decode.string)
                |> Json.Decode.Extra.andMap (Json.Decode.field "QuotedStatusPermalinkUrl" nonEmptyString)
    in
    Json.Decode.succeed Twilog
        |> Json.Decode.Extra.andMap (Json.Decode.field "CreatedAt" createdAtDecoder)
        |> Json.Decode.Extra.andMap (Json.Decode.field "CreatedAt" createdAtDecoder)
        |> Json.Decode.Extra.andMap (Json.Decode.field "CreatedAt" (createdAtDecoder |> Json.Decode.map (Date.fromPosix jst)))
        |> Json.Decode.Extra.andMap (Json.Decode.field "Text" Json.Decode.string)
        |> Json.Decode.Extra.andMap (Json.Decode.field "StatusId" (Json.Decode.map TwitterStatusId nonEmptyString))
        |> Json.Decode.Extra.andMap (Json.Decode.field "StatusId" nonEmptyString)
        |> Json.Decode.Extra.andMap (Json.Decode.field "UserName" nonEmptyString)
        |> Json.Decode.Extra.andMap (Json.Decode.field "UserProfileImageUrl" Json.Decode.string)
        |> Json.Decode.Extra.andMap (Json.Decode.maybe retweetDecoder)
        |> Json.Decode.Extra.andMap (Json.Decode.maybe inReplyToDecoder)
        -- Resolve replies later
        |> Json.Decode.Extra.andMap (Json.Decode.succeed [])
        |> Json.Decode.Extra.andMap (Json.Decode.maybe quoteDecoder)
        |> Json.Decode.Extra.andMap entitiesTcoUrlDecoder
        |> Json.Decode.Extra.andMap extendedEntitiesMediaDecoder


dailyTwilogsFromOldest : List String -> BackendTask FatalError (Dict RataDie (List Twilog))
dailyTwilogsFromOldest paths =
    let
        toDailyDictFromNewest baseDict =
            List.foldl
                (\maybeTwilog dict ->
                    case maybeTwilog of
                        Just twilog ->
                            Dict.update (Date.toRataDie twilog.createdDate)
                                (\dailySortedTwilogs ->
                                    case dailySortedTwilogs of
                                        Just twilogs ->
                                            -- コミット済みJSON由来のtwilogは古い順、かつArchive/Spreadsheetをマージ済み
                                            -- foldlで古い順からtraverseし、ここで到着順にconsしているので、最終的に結果は新しい順になる
                                            Just (twilog :: twilogs)

                                        Nothing ->
                                            Just [ twilog ]
                                )
                                dict

                        Nothing ->
                            dict
                )
                baseDict
    in
    List.foldl
        (\path accDS ->
            BackendTask.andThen
                (\accDict ->
                    BackendTask.File.jsonFile
                        -- Make it Maybe, allow decode-failures to be ignored
                        (Json.Decode.list (Json.Decode.maybe twilogDecoder)
                            |> Json.Decode.map (toDailyDictFromNewest accDict)
                            |> Json.Decode.map resolveRepliesWithinDayAndSortFromOldest
                        )
                        path
                )
                accDS
        )
        (BackendTask.succeed Dict.empty)
        paths
        |> BackendTask.allowFatal


resolveRepliesWithinDayAndSortFromOldest : Dict RataDie (List Twilog) -> Dict RataDie (List Twilog)
resolveRepliesWithinDayAndSortFromOldest =
    let
        -- Assume twilogsOfDay is newest-first.
        -- Here we traverse the list so that reply tweets are brought under `.replies` field of the tweet (within the same day) they replied to.
        -- Also at the same time, propagate touchedAt field to the tweet they replied to, eventually to the root tweet. At last we re-sort the list with touchedAt
        resolveHelp : List Twilog -> List Twilog -> List Twilog
        resolveHelp acc twilogsOfDay =
            case twilogsOfDay of
                [] ->
                    -- Finally sort acc list again with touchedAt, but stays mostly oldest-first
                    List.sortBy (.touchedAt >> Time.posixToMillis) acc

                twilog :: olderTwilogs ->
                    -- With this recursion acc list eventually becomes oldest-first
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
    Dict.map (\_ twilogs -> resolveHelp [] twilogs)


maxTime : Time.Posix -> Time.Posix -> Time.Posix
maxTime t1 t2 =
    if Time.posixToMillis t1 > Time.posixToMillis t2 then
        t1

    else
        t2


boolString =
    Json.Decode.string
        |> Json.Decode.andThen
            (\s ->
                case s of
                    "TRUE" ->
                        Json.Decode.succeed True

                    _ ->
                        Json.Decode.succeed False
            )


commaSeparatedList =
    nonEmptyString
        |> Json.Decode.andThen (\s -> Json.Decode.succeed (String.split "," s))


commaSeparatedUrls =
    nonEmptyString
        |> Json.Decode.andThen
            (\s ->
                let
                    -- Since URLs MAY contain commas, we need special handling
                    -- If split items are not starting with "http", merge it with previous item
                    normalize : List String -> List String -> List String
                    normalize acc items =
                        case items of
                            [] ->
                                List.reverse acc

                            item :: rest ->
                                if String.startsWith "http" item then
                                    normalize (item :: acc) rest

                                else
                                    case acc of
                                        prev :: prevRest ->
                                            normalize ((prev ++ "," ++ item) :: prevRest) rest

                                        [] ->
                                            -- 最初のスロットがURLでない文字列だった場合。まず起こらないが、fallbackとしては通常進行にしちゃう
                                            normalize (item :: acc) rest
                in
                String.split "," s
                    |> normalize []
                    |> Json.Decode.succeed
            )


seoBase =
    { canonicalUrlOverride = Nothing
    , siteName = Site.title
    , image =
        { url = Pages.Url.external <| ogpHeaderImageUrl ++ "?w=900&h=300"
        , alt = "Mt. Asama Header Image"
        , dimensions = Just { width = 900, height = 300 }
        , mimeType = Just (Image Jpeg)
        }
    , description = Site.tagline
    , locale = Just ( LanguageTag.Language.ja, LanguageTag.Country.jp )
    , title = Site.title
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
    -> { body : List (Html msg), title : String }
view sharedData page _ _ pageView =
    { title = makeTitle pageView.title
    , body =
        [ Html.header []
            [ Html.nav [] <|
                List.intersperse (Html.text " / ") <|
                    List.concatMap (\kids -> List.map (\kid -> Html.strong [] [ kid ]) kids)
                        [ [ Route.link [] [ Html.text "Index" ] Route.Index ]
                        , page.route
                            |> Maybe.map
                                (\route ->
                                    case route of
                                        Route.About ->
                                            [ Html.text "このサイトについて" ]

                                        Route.Articles ->
                                            [ Html.text "記事" ]

                                        Route.Articles__ArticleId_ { articleId } ->
                                            [ Route.link [] [ Html.text "記事" ] Route.Articles
                                            , Html.text (cmsArticleShortTitle articleId sharedData.cmsArticles)
                                            ]

                                        Route.Articles__Draft ->
                                            [ Html.text "記事（下書き）" ]

                                        Route.Twilogs ->
                                            [ Html.text "Twilog" ]

                                        Route.Twilogs__Day_ { day } ->
                                            [ Route.link [] [ Html.text "Twilog" ] Route.Twilogs
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
        [ View.imgLazy
            [ Html.Attributes.src "https://github.com/ymtszw/ymtszw.github.io/actions/workflows/gh-pages.yml/badge.svg"
            , Html.Attributes.alt "GitHub Pages: ymtszw/ymtszw.github.io"
            , Html.Attributes.height 20
            ]
            []
        ]


twitterLink =
    Html.a [ Html.Attributes.href "https://twitter.com/gada_twt", Html.Attributes.target "_blank", Html.Attributes.class "has-image" ]
        [ View.imgLazy
            [ Html.Attributes.src "https://img.shields.io/twitter/follow/gada_twt.svg?style=social"
            , Html.Attributes.alt "Twitter: gada_twt"
            ]
            []
        ]


sitemap =
    Html.nav [] <|
        List.intersperse (Html.text " | ")
            [ Html.text ""
            , Route.link [] [ Html.text "このサイトについて" ] Route.About
            , Route.link [] [ Html.text "Twilog" ] Route.Twilogs
            , Route.link [] [ Html.text "記事" ] Route.Articles
            , Html.text ""
            ]



-----------------
-- HELPERS
-----------------


makeTitle : String -> String
makeTitle pageTitle =
    case pageTitle of
        "" ->
            seoBase.siteName

        nonEmpty ->
            nonEmpty ++ " | " ++ seoBase.siteName


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


dumpTwilog : Twilog -> String
dumpTwilog =
    let
        dumpStatusId (TwitterStatusId statusId) =
            "TwitterStatusId " ++ statusId

        dumpUserId (TwitterUserId userId) =
            "TwitterUserId " ++ userId

        maybeEncode encoder value =
            case value of
                Just v ->
                    encoder v

                Nothing ->
                    Json.Encode.null

        encodeTwilog twilog =
            -- Reverse of twilogDecoder for debugging. Dump twilog into pretty-printed JSON string
            Json.Encode.object
                [ ( "createdAt", Json.Encode.string (formatPosix twilog.createdAt) )
                , ( "touchedAt", Json.Encode.string (formatPosix twilog.touchedAt) )
                , ( "createdDate", Json.Encode.string (Date.toIsoString twilog.createdDate) )
                , ( "text", Json.Encode.string twilog.text )
                , ( "id", Json.Encode.string (dumpStatusId twilog.id) )
                , ( "idStr", Json.Encode.string twilog.idStr )
                , ( "userName", Json.Encode.string twilog.userName )
                , ( "userProfileImageUrl", Json.Encode.string twilog.userProfileImageUrl )
                , ( "retweet", maybeEncode encodeRetweet twilog.retweet )
                , ( "inReplyTo", maybeEncode encodeInReplyTo twilog.inReplyTo )
                , ( "replies", Json.Encode.list encodeReply twilog.replies )
                , ( "quote", maybeEncode encodeQuote twilog.quote )
                , ( "entitiesTcoUrl", Json.Encode.list encodeTcoUrl twilog.entitiesTcoUrl )
                , ( "extendedEntitiesMedia", Json.Encode.list encodeMedia twilog.extendedEntitiesMedia )
                ]

        encodeReply (Reply twilog) =
            encodeTwilog twilog

        encodeRetweet rt =
            Json.Encode.object
                [ ( "fullText", Json.Encode.string rt.fullText )
                , ( "id", Json.Encode.string (dumpStatusId rt.id) )
                , ( "userName", Json.Encode.string rt.userName )
                , ( "userProfileImageUrl", Json.Encode.string rt.userProfileImageUrl )
                , ( "quote", maybeEncode encodeQuote rt.quote )
                , ( "entitiesTcoUrl", Json.Encode.list encodeTcoUrl rt.entitiesTcoUrl )
                , ( "extendedEntitiesMedia", Json.Encode.list encodeMedia rt.extendedEntitiesMedia )
                ]

        encodeInReplyTo irt =
            Json.Encode.object
                [ ( "id", Json.Encode.string (dumpStatusId irt.id) )
                , ( "userId", Json.Encode.string (dumpUserId irt.userId) )
                ]

        encodeQuote q =
            Json.Encode.object
                [ ( "fullText", Json.Encode.string q.fullText )
                , ( "id", Json.Encode.string (dumpStatusId q.id) )
                , ( "userName", Json.Encode.string q.userName )
                , ( "userProfileImageUrl", Json.Encode.string q.userProfileImageUrl )
                , ( "permalinkUrl", Json.Encode.string q.permalinkUrl )
                ]

        encodeTcoUrl tu =
            Json.Encode.object
                [ ( "url", Json.Encode.string tu.url )
                , ( "expandedUrl", Json.Encode.string tu.expandedUrl )
                ]

        encodeMedia m =
            Json.Encode.object
                [ ( "url", Json.Encode.string m.url )
                , ( "sourceUrl", Json.Encode.string m.sourceUrl )
                , ( "type_", Json.Encode.string m.type_ )
                , ( "expandedUrl", Json.Encode.string m.expandedUrl )
                ]
    in
    encodeTwilog >> Json.Encode.encode 4
