---
name: merge-dependabot-prs
description: >-
  Merge open Dependabot PRs into master sequentially, resolve lockfile conflicts, verify tests/build, and push to GitHub.
  Activate when batch-merging or individually merging Dependabot dependency update PRs.
---

# Merge & Verify Dependabot PRs (`merge-dependabot-prs`)

Workflow to safely merge Dependabot PRs into `master`, validate tests/build, and push so GitHub marks them `MERGED`.

## Steps

### 1. Fetch & Identify Open Dependabot PRs
```bash
git fetch --all --prune
gh pr list
git status
```
Identify Dependabot PR numbers and branch names (`chore(deps...): bump ...`). Ensure local `master` is clean and matches `origin/master`.

### 2. Merge Sequentially into `master`
```bash
git merge --no-edit origin/<dependabot-branch-name>
```
**Lockfile conflicts**: Do not hand-edit `package-lock.json`. Keep `package.json` updates, regenerate the lockfile, and commit:
```bash
npm install
git add package.json package-lock.json
git commit --no-edit
```

### 3. Sanity Check
1. **Sync dependencies & codegen**:
   ```bash
   npm install
   ```
   Verify `postinstall` (`elm-tooling install && elm-pages gen`) succeeds.
2. **Run tests**:
   ```bash
   npm test
   ```
   Verify `TEST RUN PASSED`.
3. **Production build** (requires `.env` vars such as `MICROCMS_API_KEY`):
   ```bash
   direnv exec . npm run build
   # or
   mise exec -- npm run build
   ```
   Verify static generation and Cloudflare Pages adapter complete without errors.

### 4. Diff & Constraint Check
```bash
git log -n 5 --graph --oneline
git diff origin/master..HEAD
```
- **Critical check**: Ensure `README.md` is NOT modified (it affects the public `/about` page).
- Confirm diffs are limited to `package.json`, `package-lock.json`, and any minimal required fixes.

### 5. Push & Verify PR State
```bash
git push origin master
gh pr view <PR-number> --json state,mergedAt,title
gh pr list
```
Confirm merged PRs transitioned to `MERGED` and no longer appear in open PRs.

### 6. Report
Report merged PRs, test/build results, and `master` push / `MERGED` status confirmation.
