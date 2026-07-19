#!/usr/bin/env bash
set -euo pipefail

DEPLOY_URL="$1"
if [ -z "$DEPLOY_URL" ]; then
  echo "Usage: $0 <base-url>"
  exit 2
fi

MAX_ATTEMPTS="${SMOKE_MAX_ATTEMPTS:-10}"
RETRY_DELAY_SECONDS="${SMOKE_RETRY_DELAY_SECONDS:-2}"

request_status() {
  local path="$1"
  local curl_args=()
  if [ "${2:-}" = "follow" ]; then
    curl_args+=(-L)
  fi
  curl -s "${curl_args[@]}" -o /dev/null -w '%{http_code}' "$DEPLOY_URL$path" || true
}

wait_for_http_200() {
  local label="$1"
  local path="$2"
  local follow_redirects="${3:-}"
  local http=""
  local attempt

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    http=$(request_status "$path" "$follow_redirects")
    if [ "$http" = "200" ]; then
      return 0
    fi
    echo "  waiting for $label, attempt $attempt/$MAX_ATTEMPTS got $http" >&2
    sleep "$RETRY_DELAY_SECONDS"
  done

  echo "✗ $label returned $http after $MAX_ATTEMPTS attempts" >&2
  return 1
}

wait_for_body_match() {
  local label="$1"
  local path="$2"
  local expected="$3"
  local body=""
  local attempt

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    body=$(curl -s "$DEPLOY_URL$path" || true)
    if printf '%s' "$body" | grep -q "$expected"; then
      return 0
    fi
    echo "  waiting for $label body, attempt $attempt/$MAX_ATTEMPTS" >&2
    sleep "$RETRY_DELAY_SECONDS"
  done

  echo "✗ $label body did not contain expected text after $MAX_ATTEMPTS attempts" >&2
  echo "Last response: $body" >&2
  return 1
}

wait_for_header_match() {
  local label="$1"
  local path="$2"
  local expected="$3"
  local headers=""
  local attempt

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    headers=$(curl -s -D - -o /dev/null "$DEPLOY_URL$path" || true)
    if printf '%s' "$headers" | grep -iq "$expected"; then
      return 0
    fi
    echo "  waiting for $label header, attempt $attempt/$MAX_ATTEMPTS" >&2
    sleep "$RETRY_DELAY_SECONDS"
  done

  echo "✗ Header $expected missing on $label after $MAX_ATTEMPTS attempts" >&2
  echo "Last headers:" >&2
  printf '%s\n' "$headers" >&2
  return 1
}

wait_for_json_expression() {
  local label="$1"
  local path="$2"
  local jq_expression="$3"
  local body=""
  local attempt

  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    body=$(curl -s "$DEPLOY_URL$path" || true)
    if printf '%s' "$body" | jq -e "$jq_expression" >/dev/null 2>&1; then
      printf '%s\n' "$body"
      return 0
    fi
    echo "  waiting for $label JSON, attempt $attempt/$MAX_ATTEMPTS" >&2
    sleep "$RETRY_DELAY_SECONDS"
  done

  echo "✗ $label JSON validation failed after $MAX_ATTEMPTS attempts" >&2
  echo "Last response: $body" >&2
  return 1
}

echo "=== Smoke Test for $DEPLOY_URL ==="

# Test 1: Index page (static route) — also serves as server readiness check
echo "[1/6] Testing index page (/)..."
wait_for_http_200 "index page" "/" || exit 1
echo "✓ Index page OK"

# Test 2: Static content route
echo "[2/6] Testing static route (/articles)..."
wait_for_http_200 "static route /articles" "/articles" "follow" || exit 1
echo "✓ Static route OK"

# Test 3: Server-render route with SSR content
echo "[3/6] Testing SSR route (/server-test)..."
wait_for_http_200 "SSR route /server-test" "/server-test" || exit 1
wait_for_body_match "SSR route /server-test" "/server-test" "Running on Cloudflare Pages" || exit 1
echo "✓ SSR route OK"

# Test 4: Response headers (x-elm-pages-cloudflare)
echo "[4/6] Testing Cloudflare runtime detection header..."
# Use GET and print headers instead of HEAD to avoid servers that error on HEAD
wait_for_header_match "/server-test" "/server-test" 'x-elm-pages-cloudflare: true' || exit 1
echo "✓ Runtime detection header OK"

# Test 5: API route (/api/test) returns JSON and indicates adapter runtime
echo "[5/6] Testing API route (/api/test)..."
# Check JSON contains runtime.isCloudflare using jq
if ! command -v jq >/dev/null 2>&1; then
  echo "✗ jq is required for JSON assertions but not installed"
  exit 2
fi
# wait_for_json_expression outputs the JSON body on success via stdout
API_JSON=$(wait_for_json_expression "/api/test" "/api/test" '. | ( .runtime and .runtime.isCloudflare )') || exit 1
IS_CF=$(echo "$API_JSON" | jq -r '.runtime.isCloudflare')
echo "✓ API route JSON OK (runtime.isCloudflare = $IS_CF)"

# Also assert the runtime header is present on the API response
wait_for_header_match "/api/test" "/api/test" 'x-elm-pages-cloudflare: true' || exit 1
echo "✓ API response header x-elm-pages-cloudflare OK"

# Test 6: Static assets availability
echo "[6/6] Testing static assets..."
wait_for_http_200 "static asset /robots.txt" "/robots.txt" || exit 1
# Verify robots.txt content is not empty
ROBOTS_SIZE=$(curl -s "$DEPLOY_URL/robots.txt" | wc -c | tr -d ' ')
if [ "$ROBOTS_SIZE" -lt 10 ]; then
  echo "✗ robots.txt is too small ($ROBOTS_SIZE bytes)"
  exit 1
fi
echo "✓ Static assets OK"

echo ""
echo "=== All smoke checks passed ✓ ==="
