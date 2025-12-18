#!/usr/bin/env bash
set -euo pipefail

DEPLOY_URL="$1"
if [ -z "$DEPLOY_URL" ]; then
  echo "Usage: $0 <base-url>"
  exit 2
fi

# Wait a bit for server to be ready
for i in 1 2 3 4 5; do
  HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/" || true)
  if [ "$HTTP" = "200" ]; then
    break
  fi
  echo "waiting for server, attempt $i got $HTTP"
  sleep 2
done

# Check server-test route
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/server-test" || true)
if [ "$HTTP" != "200" ]; then
  echo "server-test returned $HTTP"
  exit 1
fi

# Body content check
curl -s "$DEPLOY_URL/server-test" | grep -q "Running on Cloudflare Pages" || (echo "SSR content not matched" && exit 1)

# Header check
curl -s -I "$DEPLOY_URL/server-test" | grep -i 'x-elm-pages-cloudflare: true' || (echo "Header x-elm-pages-cloudflare missing" && exit 1)

echo "smoke checks OK"
