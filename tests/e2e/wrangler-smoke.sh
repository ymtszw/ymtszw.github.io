#!/usr/bin/env bash
set -euo pipefail

DEPLOY_URL="$1"
if [ -z "$DEPLOY_URL" ]; then
  echo "Usage: $0 <base-url>"
  exit 2
fi

echo "=== Smoke Test for $DEPLOY_URL ==="

# Wait a bit for server to be ready
echo "[1/7] Waiting for server..."
for i in 1 2 3 4 5; do
  HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/" || true)
  if [ "$HTTP" = "200" ]; then
    echo "✓ Server is ready"
    break
  fi
  echo "  waiting for server, attempt $i got $HTTP"
  sleep 2
done

# Test 1: Index page (static route)
echo "[2/7] Testing index page (/)..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ Index page returned $HTTP"
  exit 1
fi
echo "✓ Index page OK"

# Test 2: Static content route
echo "[3/7] Testing static route (/articles)..."
HTTP=$(curl -s -L -o /dev/null -w '%{http_code}' "$DEPLOY_URL/articles" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ Articles page returned $HTTP"
  exit 1
fi
echo "✓ Static route OK"

# Test 3: Server-render route with SSR content
echo "[4/7] Testing SSR route (/server-test)..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/server-test" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ server-test returned $HTTP"
  exit 1
fi
curl -s "$DEPLOY_URL/server-test" | grep -q "Running on Cloudflare Pages" || (echo "✗ SSR content not matched" && exit 1)
echo "✓ SSR route OK"

# Test 4: Response headers (x-elm-pages-cloudflare)
echo "[5/7] Testing Cloudflare runtime detection header..."
# Use GET and print headers instead of HEAD to avoid servers that error on HEAD
curl -s -D - -o /dev/null "$DEPLOY_URL/server-test" | grep -i 'x-elm-pages-cloudflare: true' || (echo "✗ Header x-elm-pages-cloudflare missing" && exit 1)
echo "✓ Runtime detection header OK"

# Test 5: API route (/api/test) returns JSON and indicates adapter runtime
echo "[6/7] Testing API route (/api/test)..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/api/test" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ /api/test returned $HTTP"
  exit 1
fi
# Check JSON contains runtime.isCloudflare using jq
if ! command -v jq >/dev/null 2>&1; then
  echo "✗ jq is required for JSON assertions but not installed"
  exit 2
fi
API_JSON=$(curl -s "$DEPLOY_URL/api/test")
# Validate it's JSON and has .runtime.isCloudflare boolean
echo "$API_JSON" | jq -e '. | ( .runtime and .runtime.isCloudflare )' >/dev/null 2>&1 || (
  echo "✗ /api/test JSON validation failed (missing or invalid .runtime.isCloudflare)"
  echo "Response: $API_JSON"
  exit 1
)
IS_CF=$(echo "$API_JSON" | jq -r '.runtime.isCloudflare')
echo "✓ API route JSON OK (runtime.isCloudflare = $IS_CF)"

# Also assert the runtime header is present on the API response
API_HEADER_OK=$(curl -s -D - -o /dev/null "$DEPLOY_URL/api/test" | grep -i 'x-elm-pages-cloudflare: true' || true)
if [ -z "$API_HEADER_OK" ]; then
  echo "✗ Header x-elm-pages-cloudflare missing on /api/test response"
  exit 1
fi
echo "✓ API response header x-elm-pages-cloudflare OK"

# Test 6: Static assets availability
echo "[7/7] Testing static assets..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/robots.txt" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ robots.txt returned $HTTP"
  exit 1
fi
# Verify robots.txt content is not empty
ROBOTS_SIZE=$(curl -s "$DEPLOY_URL/robots.txt" | wc -c | tr -d ' ')
if [ "$ROBOTS_SIZE" -lt 10 ]; then
  echo "✗ robots.txt is too small ($ROBOTS_SIZE bytes)"
  exit 1
fi
echo "✓ Static assets OK"

echo ""
echo "=== All smoke checks passed ✓ ==="
