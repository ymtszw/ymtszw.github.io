---
name: elm-workflow
description: >-
  Workflows and quality validation steps for editing Elm files in ymtszw.cc.
  Activate when creating, editing, or refactoring Elm source files, or before committing Elm changes.
---

# Elm Workflow & Code Quality

Standard verification steps for Elm changes (`app/`, `src/`, `script/`, etc.) in `ymtszw.cc` before committing.

## Steps

1. **Format (`elm-format`)**
   ```bash
   npx elm-format --yes <edited-files>
   # Or by directory:
   npx elm-format --yes app/ src/ script/
   ```

2. **Check Trailing Comment Relocation (Important)**
   `elm-format` moves trailing `-- ...` comments (e.g., on pipeline lines) to the start of the next line.
   Run `git diff <edited-files>` and move any misplaced comments back to an appropriate line (e.g., before the pipeline or function header).

3. **Code Generation (`elm-pages gen`)**
   Run when adding routes (`app/Route/...`) or changing metadata/routing definitions:
   ```bash
   npx elm-pages gen
   ```

4. **Tests (`npm test`)**
   ```bash
   npm test
   ```
   Generates test fixtures via `script/GenerateTwilogDataCodecTestFixtures` and runs `elm-test-rs`. Confirm `TEST RUN PASSED`.

5. **Production Build (`npm run build`)**
   ```bash
   npm run build
   ```
   Runs `elm-pages build --strict`. Requires `.env` vars (`MICROCMS_API_KEY`, etc.).
   If `direnv` is not active, prefix with `direnv exec .` or `mise exec --`.
   On Windows, `.npmrc` sets `script-shell=bash`; if `bash` is unavailable, load `.env` and run `node_modules\.bin\elm-pages.cmd build --strict`.

6. **Git Status**
   ```bash
   git status
   ```
   Confirm no unintended diffs or missing generated files.
