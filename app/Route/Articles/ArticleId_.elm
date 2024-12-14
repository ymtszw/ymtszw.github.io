module Route.Articles.ArticleId_ exposing (ActionData, Data, Model, Msg, pages, route)

import BackendTask exposing (BackendTask)
import BackendTask.File
import BackendTask.Glob as Glob
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Html
import Html.Parser
import Iso8601
import Json.Decode as Decode
import Markdown.Block
import Pages
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import Time
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { articleId : String }


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , pages = pages
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    Glob.succeed RouteParams
        |> Glob.match (Glob.literal "articles/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toBackendTask


type alias Data =
    { article : CmsArticle
    }


type alias CmsArticle =
    { contentId : String
    , published : Bool
    , publishedAt : Time.Posix
    , revisedAt : Time.Posix
    , title : String

    -- , image : Maybe Shared.CmsImage
    , body : ExternalView
    , type_ : String
    }


type alias ExternalView =
    { parsed : HtmlOrMarkdown
    , excerpt : String
    , links : List String
    }


type HtmlOrMarkdown
    = Html (List Html.Parser.Node)
    | Markdown (List Markdown.Block.Block)


type alias ActionData =
    {}


data : RouteParams -> BackendTask FatalError Data
data { articleId } =
    let
        cmsArticleDecoder markdownBody =
            Decode.oneOf
                [ Decode.field "publishedAt" Iso8601.decoder
                , -- 未来の日付にfallbackして記事一覧ページに表示させないようにする
                  Decode.succeed (Time.millisToPosix (Time.posixToMillis Pages.builtAt + 72 * 60 * 60 * 1000))
                ]
                |> Decode.andThen
                    (\publishedAt ->
                        Decode.map2
                            (\title revisedAt ->
                                { contentId = articleId
                                , title = title
                                , published = Time.posixToMillis publishedAt <= Time.posixToMillis Pages.builtAt
                                , publishedAt = publishedAt
                                , revisedAt = revisedAt |> Maybe.withDefault publishedAt
                                , body =
                                    { parsed = Markdown []
                                    , excerpt = "TODO: " ++ markdownBody
                                    , links = []
                                    }
                                , type_ = "markdown"
                                }
                            )
                            (Decode.field "title" Decode.string)
                            (Decode.maybe (Decode.field "revisedAt" Iso8601.decoder))
                    )
    in
    BackendTask.File.bodyWithFrontmatter cmsArticleDecoder ("articles/" ++ articleId ++ ".md")
        |> BackendTask.allowFatal
        |> BackendTask.map
            (\article ->
                { article = article
                }
            )


head :
    App Data ActionData RouteParams
    -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    App Data ActionData RouteParams
    -> Shared.Model
    -> View (PagesMsg Msg)
view app sharedModel =
    { title = app.data.article.title
    , body =
        [ Html.text app.data.article.title
        , Html.br [] []
        , Html.text app.data.article.contentId
        ]
    }
