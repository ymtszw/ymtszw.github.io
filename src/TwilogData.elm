module TwilogData exposing (..)

import BackendTask exposing (BackendTask)
import BackendTask.File
import Date
import Dict exposing (Dict)
import FatalError exposing (FatalError)
import Generated.TwilogArchives exposing (TwilogArchiveYearMonth)
import Helper exposing (dataSourceWith, formatPosix, jst, nonEmptyString, requireEnv)
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Json.Encode
import List.Extra
import Time


twilogArchives : BackendTask FatalError (List TwilogArchiveYearMonth)
twilogArchives =
    -- PERF: このリストはsrc/Generated/TwilogsArchives.elmにハードコードされるようになった。
    -- 予めnewest-firstにソートされている。
    BackendTask.succeed Generated.TwilogArchives.list


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


makeTwilogsJsonPath : String -> String
makeTwilogsJsonPath dateString =
    "data/" ++ String.replace "-" "/" dateString ++ "-twilogs.json"


twilogDecoder : Maybe String -> Decode.Decoder Twilog
twilogDecoder maybeAmazonAssociateTag =
    let
        createdAtDecoder =
            Decode.oneOf
                [ Iso8601.decoder
                , -- Decode date time string formatted with "ddd MMM DD HH:mm:ss Z YYYY" (originates from Twitter API)
                  Decode.andThen
                    (\str ->
                        case String.split " " str of
                            [ _, mon, paddedDay, paddedHourMinSec, zone, year ] ->
                                Iso8601.toTime (year ++ "-" ++ Helper.monthToPaddedNumber mon ++ "-" ++ paddedDay ++ "T" ++ paddedHourMinSec ++ zone)
                                    |> Result.mapError Helper.deadEndsToString
                                    |> Helper.decodeFromResult

                            _ ->
                                Decode.fail ("Failed to parse date: " ++ str)
                    )
                    Decode.string
                ]

        retweetDecoder =
            Decode.field "Retweet" boolString
                |> Decode.andThen
                    (\isRetweet ->
                        if isRetweet then
                            Decode.succeed Retweet
                                |> Decode.andMap (Decode.field "RetweetedStatusFullText" Decode.string)
                                |> Decode.andMap (Decode.field "RetweetedStatusId" (Decode.map TwitterStatusId nonEmptyString))
                                |> Decode.andMap (Decode.field "RetweetedStatusUserName" nonEmptyString)
                                |> Decode.andMap (Decode.field "RetweetedStatusUserProfileImageUrl" Decode.string)
                                |> Decode.andMap (Decode.maybe retweetQuoteDecoder)
                                |> Decode.andMap retweetEntitiesTcoUrlDecoder
                                |> Decode.andMap retweetExtendedEntitiesMediaDecoder
                                -- Postprocesses
                                |> Decode.map removeQuoteUrlFromEntitiesTcoUrls

                        else
                            Decode.fail "Not a retweet"
                    )

        inReplyToDecoder =
            -- アーカイブ由来のデータでは、Retweet: "TRUE"でもInReplyToが入っていることがあるので除く。
            -- つまり両方入っていた場合はRetweetとしての表示を優先。
            Decode.field "Retweet" boolString
                |> Decode.andThen
                    (\isRetweet ->
                        if isRetweet then
                            Decode.fail "Is a retweet"

                        else
                            Decode.succeed InReplyTo
                                |> Decode.andMap (Decode.field "InReplyToStatusId" (Decode.map TwitterStatusId nonEmptyString))
                                |> Decode.andMap (Decode.field "InReplyToUserId" (Decode.map TwitterUserId nonEmptyString))
                    )

        quoteDecoder =
            Decode.succeed Quote
                |> Decode.andMap (Decode.field "QuotedStatusFullText" Decode.string)
                |> Decode.andMap (Decode.field "QuotedStatusId" (Decode.map TwitterStatusId nonEmptyString))
                |> Decode.andMap (Decode.field "QuotedStatusUserName" nonEmptyString)
                |> Decode.andMap (Decode.field "QuotedStatusUserProfileImageUrl" Decode.string)
                |> Decode.andMap (Decode.field "QuotedStatusPermalinkUrl" nonEmptyString)

        entitiesTcoUrlDecoder =
            Decode.oneOf
                [ Decode.succeed (List.map2 TcoUrl)
                    |> Decode.andMap (Decode.field "EntitiesUrlsUrls" commaSeparatedList)
                    |> Decode.andMap (Decode.field "EntitiesUrlsExpandedUrls" (commaSeparatedUrls |> maybeModifyAmazonUrl))
                , Decode.succeed []
                ]

        extendedEntitiesMediaDecoder =
            Decode.oneOf
                [ Decode.succeed (List.map4 Media)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , Decode.succeed (List.map3 (\url sourceUrl type_ -> Media url sourceUrl type_ sourceUrl))
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Decode.andMap (Decode.field "ExtendedEntitiesMediaTypes" commaSeparatedList)
                , Decode.succeed []
                ]

        retweetEntitiesTcoUrlDecoder =
            Decode.oneOf
                [ Decode.succeed (List.map2 TcoUrl)
                    |> Decode.andMap (Decode.field "RetweetedStatusEntitiesUrlsUrls" commaSeparatedList)
                    |> Decode.andMap (Decode.field "RetweetedStatusEntitiesUrlsExpandedUrls" (commaSeparatedUrls |> maybeModifyAmazonUrl))
                , Decode.succeed []
                ]

        retweetExtendedEntitiesMediaDecoder =
            Decode.oneOf
                [ Decode.succeed (List.map4 Media)
                    |> Decode.andMap (Decode.field "RetweetedStatusExtendedEntitiesMediaUrls" commaSeparatedList)
                    |> Decode.andMap (Decode.field "RetweetedStatusExtendedEntitiesMediaSourceUrls" commaSeparatedUrls)
                    |> Decode.andMap (Decode.field "RetweetedStatusExtendedEntitiesMediaTypes" commaSeparatedList)
                    |> Decode.andMap (Decode.field "RetweetedStatusExtendedEntitiesMediaExpandedUrls" commaSeparatedUrls)
                , Decode.succeed []
                ]

        retweetQuoteDecoder =
            Decode.succeed Quote
                |> Decode.andMap (Decode.field "RetweetedStatusQuotedStatusFullText" Decode.string)
                |> Decode.andMap (Decode.field "RetweetedStatusQuotedStatusId" (Decode.map TwitterStatusId nonEmptyString))
                |> Decode.andMap (Decode.field "RetweetedStatusQuotedStatusUserName" nonEmptyString)
                |> Decode.andMap (Decode.field "RetweetedStatusQuotedStatusUserProfileImageUrl" Decode.string)
                |> Decode.andMap (Decode.field "QuotedStatusPermalinkUrl" nonEmptyString)

        removeQuoteUrlFromEntitiesTcoUrls tw =
            case tw.quote of
                Just quote ->
                    -- アーカイブツイートにはQuote情報がないので、TcoUrlをプレビューしてQuote表示の代替としたい。
                    -- 一方、Zapier経由で取得できたツイートにはQuote情報があるので、TcoUrlとして含まれているQuoteのURLは除外する。
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

        maybeModifyAmazonUrl =
            case maybeAmazonAssociateTag of
                Just amazonAssociateTag ->
                    Decode.map (List.map (Helper.makeAmazonUrl amazonAssociateTag))

                Nothing ->
                    identity
    in
    Decode.succeed Twilog
        |> Decode.andMap (Decode.field "CreatedAt" createdAtDecoder)
        |> Decode.andMap (Decode.field "CreatedAt" createdAtDecoder)
        |> Decode.andMap (Decode.field "CreatedAt" (createdAtDecoder |> Decode.map (Date.fromPosix jst)))
        |> Decode.andMap (Decode.field "Text" Decode.string)
        |> Decode.andMap (Decode.field "StatusId" (Decode.map TwitterStatusId nonEmptyString))
        |> Decode.andMap (Decode.field "StatusId" nonEmptyString)
        |> Decode.andMap (Decode.field "UserName" nonEmptyString)
        |> Decode.andMap (Decode.field "UserProfileImageUrl" Decode.string)
        |> Decode.andMap (Decode.maybe retweetDecoder)
        |> Decode.andMap (Decode.maybe inReplyToDecoder)
        -- Resolve replies later
        |> Decode.andMap (Decode.succeed [])
        |> Decode.andMap (Decode.maybe quoteDecoder)
        |> Decode.andMap entitiesTcoUrlDecoder
        |> Decode.andMap extendedEntitiesMediaDecoder
        -- Postprocesses
        |> Decode.map removeQuoteUrlFromEntitiesTcoUrls
        |> Decode.map removeRtQuoteUrlFromEntitiesTcoUrls


type alias RataDie =
    Int


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
    dataSourceWith (requireEnv "AMAZON_ASSOCIATE_TAG") <|
        \amazonAssociateTag ->
            List.foldl
                (\path accDS ->
                    BackendTask.andThen
                        (\accDict ->
                            BackendTask.File.jsonFile
                                -- Make it Maybe, allow decode-failures to be ignored
                                (Decode.list (Decode.maybe (twilogDecoder (Just amazonAssociateTag)))
                                    |> Decode.map (toDailyDictFromNewest accDict)
                                    |> Decode.map resolveRepliesWithinDayAndSortFromOldest
                                )
                                path
                                |> BackendTask.allowFatal
                        )
                        accDS
                )
                (BackendTask.succeed Dict.empty)
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
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "TRUE" ->
                        Decode.succeed True

                    _ ->
                        Decode.succeed False
            )


commaSeparatedList =
    nonEmptyString
        |> Decode.andThen (\s -> Decode.succeed (String.split "," s))


commaSeparatedUrls =
    nonEmptyString
        |> Decode.andThen
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
                    |> Decode.succeed
            )


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
