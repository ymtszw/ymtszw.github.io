module AddRoute exposing (run)

import BackendTask
import Cli.Option as Option
import Cli.OptionsParser as OptionsParser
import Cli.Program as Program
import Elm
import Elm.Annotation as Type
import Elm.Case
import Elm.Declare
import Elm.Let
import Elm.Op
import Gen.BackendTask
import Gen.Debug
import Gen.Effect as Effect
import Gen.Form as Form
import Gen.Form.FieldView as FieldView
import Gen.Html as Html
import Gen.Html.Attributes as Attr
import Gen.List
import Gen.Pages.Script
import Gen.Platform.Sub
import Gen.Server.Request as Request
import Gen.Server.Response as Response
import Gen.View
import Pages.Script as Script exposing (Script)
import Scaffold.Form
import Scaffold.Route exposing (Type(..))


type alias CliOptions =
    { moduleName : List String
    , fields : List ( String, Scaffold.Form.Kind )
    }


run : Script
run =
    Script.withCliOptions program
        (\cliOptions ->
            cliOptions
                |> createFile
                |> Script.writeFile
                |> BackendTask.allowFatal
        )


program : Program.Config CliOptions
program =
    Program.config
        |> Program.add
            (OptionsParser.build CliOptions
                |> OptionsParser.with (Option.requiredPositionalArg "module" |> Scaffold.Route.moduleNameCliArg)
                |> OptionsParser.withRestArgs Scaffold.Form.restArgsParser
            )


createFile : CliOptions -> { path : String, body : String }
createFile { moduleName, fields } =
    let
        formHelpers :
            Maybe
                { formHandlers : Elm.Expression
                , form : Elm.Expression
                , declarations : List Elm.Declaration
                }
        formHelpers =
            Scaffold.Form.provide
                { fields = fields
                , elmCssView = False
                , view =
                    \{ formState, params } ->
                        Elm.Let.letIn
                            (\fieldView ->
                                Elm.list
                                    ((params
                                        |> List.map
                                            (\{ name, kind, param } ->
                                                fieldView (Elm.string name) param
                                            )
                                     )
                                        ++ [ Elm.ifThen formState.isTransitioning
                                                (Html.button
                                                    [ Attr.disabled True
                                                    ]
                                                    [ Html.text "Submitting..."
                                                    ]
                                                )
                                                (Html.button []
                                                    [ Html.text "Submit"
                                                    ]
                                                )
                                           ]
                                    )
                            )
                            |> Elm.Let.fn2 "fieldView"
                                ( "label", Type.string |> Just )
                                ( "field", Nothing )
                                (\label field ->
                                    Html.div []
                                        [ Html.label []
                                            [ Html.call_.text (Elm.Op.append label (Elm.string " "))
                                            , field |> FieldView.input []
                                            , errorsView.call formState.errors field
                                            ]
                                        ]
                                )
                            |> Elm.Let.toExpression
                }
    in
    Scaffold.Route.serverRender
        { moduleName = moduleName
        , action =
            ( Alias
                (Type.record
                    (case formHelpers of
                        Just _ ->
                            [ ( "errors", Type.namedWith [ "Form" ] "Response" [ Type.string ] )
                            ]

                        Nothing ->
                            []
                    )
                )
            , \routeParams ->
                formHelpers
                    |> Maybe.map
                        (\justFormHelp ->
                            Request.formData justFormHelp.formHandlers
                                |> Request.call_.map
                                    (Elm.fn ( "formData", Nothing )
                                        (\formData ->
                                            Elm.Case.tuple formData
                                                "response"
                                                "parsedForm"
                                                (\response parsedForm ->
                                                    Elm.Case.result parsedForm
                                                        { err =
                                                            ( "error"
                                                            , \error ->
                                                                Gen.Debug.toString error
                                                                    |> Gen.Pages.Script.call_.log
                                                                    |> Gen.BackendTask.call_.map
                                                                        (Elm.fn ( "_", Nothing )
                                                                            (\_ ->
                                                                                Response.render
                                                                                    (Elm.record
                                                                                        [ ( "errors", response )
                                                                                        ]
                                                                                    )
                                                                            )
                                                                        )
                                                            )
                                                        , ok =
                                                            ( "okForm"
                                                            , \okForm ->
                                                                Gen.Debug.toString okForm
                                                                    |> Gen.Pages.Script.call_.log
                                                                    |> Gen.BackendTask.call_.map
                                                                        (Elm.fn ( "_", Nothing )
                                                                            (\_ ->
                                                                                Response.render
                                                                                    (Elm.record
                                                                                        [ ( "errors", response )
                                                                                        ]
                                                                                    )
                                                                            )
                                                                        )
                                                            )
                                                        }
                                                )
                                        )
                                    )
                        )
                    |> Maybe.withDefault
                        (Request.succeed
                            (Gen.BackendTask.succeed
                                (Response.render
                                    (Elm.record [])
                                )
                            )
                        )
            )
        , data =
            ( Alias (Type.record [])
            , \routeParams ->
                Request.succeed
                    (Gen.BackendTask.succeed
                        (Response.render
                            (Elm.record [])
                        )
                    )
            )
        , head = \app -> Elm.list []
        }
        |> Scaffold.Route.addDeclarations
            (formHelpers
                |> Maybe.map .declarations
                |> Maybe.map ((::) errorsView.declaration)
                |> Maybe.withDefault []
            )
        |> Scaffold.Route.buildWithLocalState
            { view =
                \{ shared, model, app } ->
                    Gen.View.make_.view
                        { title = moduleName |> String.join "." |> Elm.string
                        , body =
                            Elm.list
                                (case formHelpers of
                                    Just justFormHelp ->
                                        [ Html.h2 [] [ Html.text "Form" ]
                                        , justFormHelp.form
                                            |> Form.renderHtml "form" [] (Elm.get "errors" >> Elm.just) app Elm.unit
                                        ]

                                    Nothing ->
                                        [ Html.h2 [] [ Html.text "New Page" ]
                                        ]
                                )
                        }
            , update =
                \{ shared, app, msg, model } ->
                    Elm.Case.custom msg
                        (Type.named [] "Msg")
                        [ Elm.Case.branch0 "NoOp"
                            (Elm.tuple model
                                (Effect.none
                                    |> Elm.withType effectType
                                )
                            )
                        ]
            , init =
                \{ shared, app } ->
                    Elm.tuple (Elm.record [])
                        (Effect.none
                            |> Elm.withType effectType
                        )
            , subscriptions =
                \{ routeParams, path, shared, model } ->
                    Gen.Platform.Sub.none
            , model =
                Alias (Type.record [])
            , msg =
                Custom [ Elm.variant "NoOp" ]
            }


errorsView :
    { declaration : Elm.Declaration
    , call : Elm.Expression -> Elm.Expression -> Elm.Expression
    , callFrom : List String -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , value : List String -> Elm.Expression
    }
errorsView =
    Elm.Declare.fn2 "errorsView"
        ( "errors", Type.namedWith [ "Form" ] "Errors" [ Type.string ] |> Just )
        ( "field"
        , Type.namedWith [ "Form", "Validation" ]
            "Field"
            [ Type.string
            , Type.var "parsed"
            , Type.var "kind"
            ]
            |> Just
        )
        (\errors field ->
            Elm.ifThen
                (Gen.List.call_.isEmpty (Form.errorsForField field errors))
                (Html.div [] [])
                (Html.div
                    []
                    [ Html.call_.ul (Elm.list [])
                        (Gen.List.call_.map
                            (Elm.fn ( "error", Nothing )
                                (\error ->
                                    Html.li
                                        [ Attr.style "color" "red"
                                        ]
                                        [ Html.call_.text error
                                        ]
                                )
                            )
                            (Form.errorsForField field errors)
                        )
                    ]
                )
                |> Elm.withType
                    (Type.namedWith [ "Html" ]
                        "Html"
                        [ Type.namedWith
                            [ "PagesMsg" ]
                            "PagesMsg"
                            [ Type.named [] "Msg" ]
                        ]
                    )
        )


effectType : Type.Annotation
effectType =
    Type.namedWith [ "Effect" ] "Effect" [ Type.var "msg" ]
