#!/usr/bin/env bash
set -euo pipefail

#
# Call this script after you have satisfied the results of `npm run import_twilogs <path-to-exported-twilogs-csv-file>`
#

if [ -n "$(git status --porcelain data/)" ]; then
  git add data/ src/Generated/ && git commit -m "feat: imported recent twilogs ($(date))"
fi

git push origin HEAD:master
