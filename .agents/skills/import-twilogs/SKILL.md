---
name: import-twilogs
description: >-
  End-to-end workflow to download Twilog CSV, import new tweets, run tests/build, and commit & push updates.
  Activate when syncing Twilog data or when invoked by scheduled automation.
---

# Twilog Import & Sync Workflow (`import-twilogs`)

Cross-platform (macOS / Windows) workflow for syncing Twilog (X/Twitter) logs into `ymtszw.cc`.

## Roles

- **User**: Log in to [Twilog](https://twilog.togetter.com/) using the dedicated Chrome profile (`~/.chrome-profiles/twilog-sync`) only initially or when the session expires, then close that browser window.
- **Agent**: Pull `master` -> Download CSV -> Import & index -> Test & build -> Commit & push -> Report.

## Steps

### 1. Sync Repository
```bash
git checkout master
git pull origin master
```

### 2. Download Latest UTF-8 CSV
Uses the dedicated Chrome profile (`~/.chrome-profiles/twilog-sync`, overridable via `TWILOG_CHROME_PROFILE_DIR`) headlessly to save the UTF-8 CSV to `~/Downloads`:
```bash
npm run download_twilogs
# Fallback if .npmrc script-shell=bash is unavailable on Windows:
node script/download-twilog-csv.mjs
```
- `Downloaded: ... (N bytes)` -> Proceed to Step 3.
- `AUTH_REQUIRED` (exit code `2`) or timeout -> Session expired/missing. Ask the user to log in manually using the dedicated Chrome profile and close the window, then exit.

### 3. Import & Build Search Index
```bash
npm run import_twilogs
```
(`script/ImportTwilogCsvAndBuildSearchIndex.elm` automatically picks the latest `~/Downloads/gada_twt-*.csv`; no pre-check needed. Optional explicit path: `npm run import_twilogs -- /path/to/gada_twt-YYMMDD.csv`.)

- `Imported N Twilogs` -> Proceed to Step 4.
- `No new Twilogs to import` -> Already up to date; report to user and stop.
- `No Twilog CSV files found in ...` -> Report missing CSV and stop.

### 4. Test & Build Verification
```bash
npm test
npm run build
```
Requires `.env` variables (`ALGOLIA_APP_ID`, `MICROCMS_API_KEY`, etc.).
- If `direnv` is not active, use `direnv exec . <cmd>` or `mise exec -- <cmd>`.
- On Windows PowerShell without `bash`, load `.env` into process env, set `npm_config_script_shell=cmd.exe` for `npm run` scripts, and run `.\node_modules\.bin\elm-pages.cmd build --strict` (with `node_modules\.bin` in `PATH`) for `build`.

### 5. Commit & Push
Verify `git status` shows `master` and changes under `data/` (and `src/Generated/TwilogArchives.elm` if updated), then run:
```bash
npm run push_recent_twilogs
```
(`script/PushRecentTwilogs.elm` verifies `master`, stages `data/` and `src/Generated/`, commits `feat: imported recent twilogs (<timestamp>)`, and pushes `origin HEAD:master`.)

### 6. Report
Report imported tweet count and commit hash / push status to the user.
