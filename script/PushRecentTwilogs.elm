module PushRecentTwilogs exposing (run)

import BackendTask exposing (BackendTask)
import BackendTask.Custom
import BackendTask.Do exposing (do)
import BackendTask.Time
import FatalError exposing (FatalError)
import Helper
import Json.Decode as Decode
import Json.Encode
import Pages.Script as Script exposing (Script)


run : Script
run =
    Script.withoutCliOptions task


task : BackendTask FatalError ()
task =
    do (execCommand "git rev-parse --abbrev-ref HEAD") <|
        \currentBranch ->
            if currentBranch /= "master" then
                BackendTask.fail <|
                    FatalError.fromString <|
                        "Error: このスクリプトは master ブランチでのみ実行できます (現在: "
                            ++ currentBranch
                            ++ ")"

            else
                do (execCommand "git status --porcelain data/ src/Generated/") <|
                    \status ->
                        do
                            (if not (String.isEmpty (String.trim status)) then
                                do (Script.log "Committing recent twilogs...") <|
                                    \() ->
                                        do (execCommand "git add data/ src/Generated/") <|
                                            \_ ->
                                                do BackendTask.Time.now <|
                                                    \now ->
                                                        let
                                                            commitMessage =
                                                                "feat: imported recent twilogs (" ++ Helper.formatPosix now ++ ")"
                                                        in
                                                        do (execCommand ("git commit -m \"" ++ commitMessage ++ "\"")) <|
                                                            \_ ->
                                                                Script.log ("Committed: " ++ commitMessage)

                             else
                                Script.log "No changes detected in data/ or src/Generated/ to commit."
                            )
                        <|
                            \() ->
                                do (Script.log "Pushing to origin HEAD:master...") <|
                                    \() ->
                                        do (execCommand "git push origin HEAD:master") <|
                                            \_ ->
                                                Script.log "Successfully pushed recent twilogs."


execCommand : String -> BackendTask FatalError String
execCommand command =
    BackendTask.Custom.run "execCommand" (Json.Encode.string command) Decode.string
        |> BackendTask.allowFatal
