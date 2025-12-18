#!/usr/bin/env bash
set -euo pipefail

DEPLOY_URL="$1"
if [ -z "$DEPLOY_URL" ]; then
  echo "Usage: $0 <base-url>"
  exit 2
fi

echo "=== Smoke Test for $DEPLOY_URL ==="

# Wait a bit for server to be ready
echo "[1/6] Waiting for server..."
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
echo "[2/6] Testing index page (/)..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ Index page returned $HTTP"
  exit 1
fi
echo "✓ Index page OK"

# Test 2: Static content route
echo "[3/6] Testing static route (/articles)..."
HTTP=$(curl -s -L -o /dev/null -w '%{http_code}' "$DEPLOY_URL/articles" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ Articles page returned $HTTP"
  exit 1
fi
echo "✓ Static route OK"

# Test 3: Server-render route with SSR content
echo "[4/6] Testing SSR route (/server-test)..."
HTTP=$(curl -s -o /dev/null -w '%{http_code}' "$DEPLOY_URL/server-test" || true)
if [ "$HTTP" != "200" ]; then
  echo "✗ server-test returned $HTTP"
  exit 1
fi
curl -s "$DEPLOY_URL/server-test" | grep -q "Running on Cloudflare Pages" || (echo "✗ SSR content not matched" && exit 1)
echo "✓ SSR route OK"

# Test 4: Response headers (x-elm-pages-cloudflare)
echo "[5/6] Testing Cloudflare runtime detection header..."
curl -s -I "$DEPLOY_URL/server-test" | grep -i 'x-elm-pages-cloudflare: true' || (echo "✗ Header x-elm-pages-cloudflare missing" && exit 1)
echo "✓ Runtime detection header OK"

# Test 5: Static assets availability
echo "[6/6] Testing static assets..."
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
