#!/usr/bin/env bash
set -euo pipefail

#
# Call this script after you have satisfied the results of `npm run import_twilogs <path-to-exported-twilogs-csv-file>`
#

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" != "master" ]; then
  echo "Error: このスクリプトは master ブランチでのみ実行できます (現在: $current_branch)" >&2
  exit 1
fi

if [ -n "$(git status --porcelain data/)" ]; then
  git add data/ src/Generated/ && git commit -m "feat: imported recent twilogs ($(date))"
fi

git push origin HEAD:master
