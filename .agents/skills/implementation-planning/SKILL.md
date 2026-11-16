---
name: implementation-planning
description: >-
  Plan and track large-scale or multi-phase feature implementations, refactorings, or architectural changes.
  Activate when designing new features, decomposing complex tasks into phases, or tracking implementation progress in docs/implementation-plans/.
---

# Implementation Planning & Progress Tracking

Workflow for safely executing multi-phase features, refactorings, or architectural changes in `ymtszw.cc`. Not required for minor or single-file edits.

## Prerequisites

- **No Direct Work on Default Branch (Mandatory)**:
  Before starting multi-phase work, verify the current branch is not `master`. If on `master`, warn the user and prompt creating/checking out a feature branch (e.g., `feat/<name>`, `fix/<name>`).
- **Branch Naming**: Use clear purpose-based names (`feat/cloudflare_adapter`, `fix/bug-123`, `refactor/component-structure`).
- **Commit Hygiene**: Run `git status` regularly and commit in logical units.
- **Editor Settings**: Do not modify `.vscode/settings.json` auto-approve settings; leave those to the user.

## Workflow

1. **Create Plan**: Write `docs/implementation-plans/<FEATURE_NAME>_PLAN.md` covering overview, requirements/design, and phases.
2. **Phased Implementation**: Execute phase by phase, verifying quality after each phase via `elm-workflow`.
3. **Report Blockers**: If a plan proves infeasible, stop and report reasons and alternatives to the user.
4. **Update Progress**: Update the plan's Progress section after each phase, design change, or session end.
5. **Commit**: Create meaningful commits per phase or logical unit.

## Plan Template (`docs/implementation-plans/<FEATURE_NAME>_PLAN.md`)

```markdown
# <Feature Name> Implementation Plan

## 1. Overview & Goals
...

## 2. Requirements & Design
...

## 3. Phases
- Phase 1: ...
- Phase 2: ...

---

## Progress

### Phase 1: Done (YYYY-MM-DD)
**Changes:**
- ✅ <Task 1>
- ✅ Test & build verification

**Commits:**
- `<commit-hash>`: <message>

**Artifacts:**
- `path/to/file`: <description>

### Phase 2: In Progress / Pending
**Remaining:**
- [ ] <Task 1>
```
