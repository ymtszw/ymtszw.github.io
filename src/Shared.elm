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
    , TwilogArchiveYearMonth
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
    , miscGet
    , ogpHeaderImageUrl
    , posixToYmd
    , publicCmsArticles
    , seoBase
    , template
    , twilogArchives
    , twilogDecoder
    , unixOrigin
    )

import Browser.Dom
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob
import DataSource.Http
import Date
import Dict exposing (Dict)
import Head.Seo
import Helper exposing (nonEmptyString)
import Html
import Html.Attributes
import Html.Events
import Iso8601
import Json.Decode
import Json.Encode
import LinkPreview
import List.Extra
import Markdown
import MimeType exposing (MimeImage(..), MimeType(..))
import OptimizedDecoder
import Pages.Secrets
import Pages.Url
import Path exposing (Path)
import Route
import SharedTemplate exposing (SharedTemplate)
import Site
import Task
import Time exposing (Month(..))
import View


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = \_ _ -> Sub.none
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
    { twilogArchives : List TwilogArchiveYearMonth
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


type alias CmsImage =
    { url : String
    , height : Int
    , width : Int
    }


type SharedMsg
    = NoOp
    | Req_LinkPreview (List String)
    | Res_LinkPreview (List String) (Result String ( String, LinkPreview.Metadata ))
    | ScrollToTop
    | ScrollToBottom
    | CloseLightbox


type alias Model =
    { links : Dict String LinkPreview.Metadata
    , lightbox : Maybe LightboxMedia
    }


type alias LightboxMedia =
    { href : String
    , src : String
    , type_ : String
    }


init _ _ _ =
    ( { links = Dict.empty, lightbox = Nothing }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange req ->
            case parseLightboxMedia req of
                (Just _) as lbMedia ->
                    ( { model | lightbox = lbMedia }, lockScrollPosition )

                Nothing ->
                    ( model, Cmd.none )

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

        SharedMsg ScrollToTop ->
            ( model, Browser.Dom.setViewport 0 0 |> Task.perform (always NoOp) |> Cmd.map SharedMsg )

        SharedMsg ScrollToBottom ->
            ( model
            , Browser.Dom.getViewport
                |> Task.andThen (\viewport -> Browser.Dom.setViewport 0 viewport.scene.height)
                |> Task.perform (always NoOp)
                |> Cmd.map SharedMsg
            )

        SharedMsg CloseLightbox ->
            ( { model | lightbox = Nothing }, Cmd.none )

        SharedMsg _ ->
            ( model, Cmd.none )


{-| Viewportを現在と全く同じ位置に明示的にセットする

URL Fragment経由でLightboxオープンの命令が来たとき、ブラウザデフォルト挙動によって、
文書内にFragmentと合致するidをもつ要素がなかった場合は文書先頭にスクロールされてしまう。

このCmdでそれを抑制する（次回描画フレームでgetViewportとsetViewportが走るので、
ブラウザデフォルト挙動を上書きするような動作が達成できる。）

-}
lockScrollPosition : Cmd Msg
lockScrollPosition =
    Browser.Dom.getViewport
        |> Task.andThen (\vp -> Browser.Dom.setViewport vp.viewport.x vp.viewport.y)
        |> Task.perform (always NoOp)
        |> Cmd.map SharedMsg


parseLightboxMedia { fragment } =
    Maybe.andThen
        (\fr ->
            if String.startsWith "lightbox:src(" fr then
                case String.split "):href(" (String.dropLeft 13 fr) of
                    [ src, rest ] ->
                        case String.split "):type(" (String.dropRight 1 rest) of
                            [ href, type_ ] ->
                                Just { href = href, src = src, type_ = type_ }

                            _ ->
                                Nothing

                    _ ->
                        Nothing

            else
                Nothing
        )
        fragment


requestLinkPreviewSequentially : List String -> String -> Cmd Msg
requestLinkPreviewSequentially urls url =
    url
        |> LinkPreview.getMetadataOnDemand
        |> Task.attempt (Res_LinkPreview urls)
        |> Cmd.map SharedMsg


data : DataSource Data
data =
    DataSource.map Data twilogArchives


githubGet : String -> OptimizedDecoder.Decoder a -> DataSource a
githubGet url decoder =
    DataSource.Http.request
        (Pages.Secrets.with "GITHUB_TOKEN" <|
            Pages.Secrets.succeed <|
                \githubToken ->
                    { url = url
                    , method = "GET"
                    , headers = [ ( "Authorization", "token " ++ githubToken ) ]
                    , body = DataSource.Http.emptyBody
                    }
        )
        decoder


cmsGet : String -> OptimizedDecoder.Decoder a -> DataSource a
cmsGet url decoder =
    DataSource.Http.request
        (Pages.Secrets.with "MICROCMS_API_KEY" <|
            Pages.Secrets.succeed <|
                \microCmsApiKey ->
                    { url = url
                    , method = "GET"
                    , headers = [ ( "X-MICROCMS-API-KEY", microCmsApiKey ) ]
                    , body = DataSource.Http.emptyBody
                    }
        )
        decoder


miscGet : String -> OptimizedDecoder.Decoder a -> DataSource a
miscGet url decoder =
    DataSource.Http.get (Pages.Secrets.succeed url) decoder


publicCmsArticles : DataSource (List CmsArticleMetadata)
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


type alias TwilogArchiveYearMonth =
    String


{-| The data source for the list of all twilog archives.

Archive directory/file structure:

    data/
        2019/
            01/
                01-twilogs.json
                02-twilogs.json
                ...
            02/
                01-twilogs.json
                ...
            ...
        2020/
            01/
                01-twilogs.json
                ...
            ...
        ...

This data source returns a list of year-month strings in the format of "YYYY-MM",
sorted in descending (newest-first) order.

-}
twilogArchives : DataSource (List TwilogArchiveYearMonth)
twilogArchives =
    DataSource.Glob.succeed (\year month -> year ++ "-" ++ month)
        |> DataSource.Glob.match (DataSource.Glob.literal "data/")
        |> DataSource.Glob.capture DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "/")
        |> DataSource.Glob.capture DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "/")
        |> DataSource.Glob.match DataSource.Glob.wildcard
        |> DataSource.Glob.match (DataSource.Glob.literal "-twilogs.json")
        |> DataSource.Glob.toDataSource
        -- Make newest first
        |> DataSource.map (List.Extra.unique >> List.sort >> List.reverse)


makeTwilogsJsonPath : String -> String
makeTwilogsJsonPath dateString =
    "data/" ++ String.replace "-" "/" dateString ++ "-twilogs.json"


twilogDecoder : OptimizedDecoder.Decoder Twilog
twilogDecoder =
    let
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
                                -- Postprocesses
                                |> OptimizedDecoder.map removeQuoteUrlFromEntitiesTcoUrls

                        else
                            OptimizedDecoder.fail "Not a retweet"
                    )

        inReplyToDecoder =
            -- アーカイブ由来のデータでは、Retweet: "TRUE"でもInReplyToが入っていることがあるので除く。
            -- つまり両方入っていた場合はRetweetとしての表示を優先。
            OptimizedDecoder.field "Retweet" boolString
                |> OptimizedDecoder.andThen
                    (\isRetweet ->
                        if isRetweet then
                            OptimizedDecoder.fail "Is a retweet"

                        else
                            OptimizedDecoder.succeed InReplyTo
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                                |> OptimizedDecoder.andMap (OptimizedDecoder.field "InReplyToUserId" (OptimizedDecoder.map TwitterUserId nonEmptyString))
                    )

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
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "EntitiesUrlsExpandedUrls" commaSeparatedUrls)
                , OptimizedDecoder.succeed []
                ]

        extendedEntitiesMediaDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map4 Media)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , OptimizedDecoder.succeed (List.map3 (\url sourceUrl type_ -> Media url sourceUrl type_ sourceUrl))
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                , OptimizedDecoder.succeed []
                ]

        retweetEntitiesTcoUrlDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map2 TcoUrl)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusEntitiesUrlsUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusEntitiesUrlsExpandedUrls" commaSeparatedUrls)
                , OptimizedDecoder.succeed []
                ]

        retweetExtendedEntitiesMediaDecoder =
            OptimizedDecoder.oneOf
                [ OptimizedDecoder.succeed (List.map4 Media)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , OptimizedDecoder.succeed []
                ]

        retweetQuoteDecoder =
            OptimizedDecoder.succeed Quote
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusFullText" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusUserName" nonEmptyString)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "RetweetedStatusQuotedStatusUserProfileImageUrl" OptimizedDecoder.string)
                |> OptimizedDecoder.andMap (OptimizedDecoder.field "QuotedStatusPermalinkUrl" nonEmptyString)

        removeQuoteUrlFromEntitiesTcoUrls tw =
            case tw.quote of
                Just quote ->
                    -- アーカイブツイートにはQuote情報がないので、TcoUrlをプレビューしてQuote表示の代替としたい。
                    -- 一方、最近のツイートにはQuote情報があるので、TcoUrlとして含まれているQuoteのURLは除外する。
                    { tw | entitiesTcoUrl = List.filter (\tcoUrl -> tcoUrl.url /= quote.permalinkUrl) tw.entitiesTcoUrl }

                Nothing ->
                    tw

        removeRtQuoteUrlFromEntitiesTcoUrls twilog =
            case Maybe.andThen .quote twilog.retweet of
                Just rtQuote ->
                    -- RetweetのQuoteのURLも、rootのTwilogのentitiesTcoUrlに含まれているので、二重に除外しなければならない
                    { twilog | entitiesTcoUrl = List.filter (\tcoUrl -> tcoUrl.url /= rtQuote.permalinkUrl) twilog.entitiesTcoUrl }

                Nothing ->
                    twilog
    in
    OptimizedDecoder.succeed Twilog
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" createdAtDecoder)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" createdAtDecoder)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "CreatedAt" (createdAtDecoder |> OptimizedDecoder.map (Date.fromPosix jst)))
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "Text" OptimizedDecoder.string)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "StatusId" (OptimizedDecoder.map TwitterStatusId nonEmptyString))
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "StatusId" nonEmptyString)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserName" nonEmptyString)
        |> OptimizedDecoder.andMap (OptimizedDecoder.field "UserProfileImageUrl" OptimizedDecoder.string)
        |> OptimizedDecoder.andMap (OptimizedDecoder.maybe retweetDecoder)
        |> OptimizedDecoder.andMap (OptimizedDecoder.maybe inReplyToDecoder)
        -- Resolve replies later
        |> OptimizedDecoder.andMap (OptimizedDecoder.succeed [])
        |> OptimizedDecoder.andMap (OptimizedDecoder.maybe quoteDecoder)
        |> OptimizedDecoder.andMap entitiesTcoUrlDecoder
        |> OptimizedDecoder.andMap extendedEntitiesMediaDecoder
        -- Postprocesses
        |> OptimizedDecoder.map removeQuoteUrlFromEntitiesTcoUrls
        |> OptimizedDecoder.map removeRtQuoteUrlFromEntitiesTcoUrls


dailyTwilogsFromOldest : List String -> DataSource (Dict RataDie (List Twilog))
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
            DataSource.andThen
                (\accDict ->
                    DataSource.File.jsonFile
                        -- Make it Maybe, allow decode-failures to be ignored
                        (OptimizedDecoder.list (OptimizedDecoder.maybe twilogDecoder)
                            |> OptimizedDecoder.map (toDailyDictFromNewest accDict)
                            |> OptimizedDecoder.map resolveRepliesWithinDayAndSortFromOldest
                        )
                        path
                )
                accDS
        )
        (DataSource.succeed Dict.empty)
        paths


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


commaSeparatedUrls =
    nonEmptyString
        |> OptimizedDecoder.andThen
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
                    |> OptimizedDecoder.succeed
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
    , siteName = Site.title
    , image =
        { url = Pages.Url.external <| ogpHeaderImageUrl ++ "?w=900&h=300"
        , alt = "Mt. Asama Header Image"
        , dimensions = Just { width = 900, height = 300 }
        , mimeType = Just "image/jpeg"
        }
    , description = Site.tagline
    , locale = Just "ja_JP"
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


view _ page shared sharedTagger pageView =
    { title = makeTitle pageView.title
    , body =
        Html.div []
            [ Html.header []
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

                                            Route.Articles__ArticleId_ _ ->
                                                [ Route.link Route.Articles [] [ Html.text "記事" ] ]

                                            Route.Articles__Draft ->
                                                [ Html.text "記事（下書き）" ]

                                            Route.Twilogs ->
                                                [ Html.text "Twilog" ]

                                            Route.Twilogs__YearMonth_ { yearMonth } ->
                                                [ Route.link Route.Twilogs [] [ Html.text "Twilog" ]
                                                , Html.text yearMonth
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
                , Html.map (SharedMsg >> sharedTagger) scrollButtons
                ]
            , case shared.lightbox of
                Just lbMedia ->
                    Html.map (SharedMsg >> sharedTagger) (lightbox lbMedia)

                Nothing ->
                    Html.text ""
            ]
    }


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
            , Route.link Route.About [] [ Html.text "このサイトについて" ]
            , Route.link Route.Twilogs [] [ Html.text "Twilog" ]
            , Route.link Route.Articles [] [ Html.text "記事" ]
            , Html.text ""
            ]


scrollButtons =
    Html.nav [ Html.Attributes.class "scroll-buttons" ]
        [ Html.button [ Html.Events.onClick ScrollToTop ] [ Html.text "▲" ]
        , Html.button [ Html.Events.onClick ScrollToBottom ] [ Html.text "▼" ]
        ]


lightbox : LightboxMedia -> Html.Html SharedMsg
lightbox lbMedia =
    Html.div
        [ Html.Attributes.class "lightbox"
        , Html.Events.onClick CloseLightbox
        ]
        [ Html.a
            [ Html.Attributes.href lbMedia.href
            , Html.Attributes.target "_blank"
            , Html.Attributes.rel "noopener noreferrer"
            , Html.Attributes.class "has-image"
            , Html.Events.stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True ))
            ]
            [ if lbMedia.type_ == "video" || lbMedia.type_ == "animated_gif" then
                Html.figure [ Html.Attributes.class "video-thumbnail" ]
                    [ View.imgLazy [ Html.Attributes.src lbMedia.src ] [] ]

              else
                View.imgLazy [ Html.Attributes.src lbMedia.src ] []
            ]
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
