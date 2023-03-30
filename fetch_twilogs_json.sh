#!/usr/bin/env bash
set -euo pipefail

curl -sL "$MY_TWILOG_TSV_URL" | npx csvtojson --delimiter='\t' > twilogs.json
