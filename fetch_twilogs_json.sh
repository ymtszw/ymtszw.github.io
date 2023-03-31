#!/usr/bin/env bash
set -euo pipefail

curl -sL "$MY_TWILOG_CSV_URL" | npx csvtojson --delimiter=',' > twilogs.json
