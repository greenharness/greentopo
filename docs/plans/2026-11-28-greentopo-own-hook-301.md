---
status: active
branch: prog/topo-spotter-rename/t31-greentopo-own-hook-301
repos: [aval]
adrs: []
plan-id: p-01M8HGA0J0QCQ885Z7D63AQD1F
---
# Move greentopo's own hook and CI pin to 3.0.1

## Review panel

👉 **Decide:** none — approve if a pin bump plus a regenerated hook is all t31 needs.
📍 aval · 1 phase · next: Phase 1. Panel: backend (opus-5-5), platform (opus-5-5); codex: not installed.
**Changed by review:** full paths in Phase 1; whole-tree diff row; linux 3.0.1 asset row; no pin `note` in CI.
**Verdicts:** 2 approve-with-changes; 1 carried (diff row excludes `docs/plans`); words 309 → 345 (×1.12); remove 0, merge 0.
📄 Full reviews: [2026-11-28-greentopo-own-hook-301.reviews.md](2026-11-28-greentopo-own-hook-301.reviews.md)

## Picture

```
adr.yaml pin  3.0.0 ──► 3.0.1
                          │ CI runs: greentopo hook install --check
                          ▼
greentopo-heads.sh (3.0.0) ──► rewritten by 3.0.1 ──► check: ok
```

The pin and the hook move in one commit, so CI's check compares the hook
with the version that wrote it.

topo-spotter-rename t31 (decisions `docs/programmes/topo-spotter-rename/t31-greentopo-own-hook-301.md`).

## Context

greentopo 3.0.1 fixed "An greentopo" in the hook template (#69), but this
repository still vendors the 3.0.0 hook (`.claude/hooks/greentopo-heads.sh`,
three "An greentopo" comments) and `.github/workflows/adr.yaml` pins
`GREENTOPO_VERSION: 3.0.0`. Its CI step `greentopo hook install --check` on a
3.0.0 pin would read a 3.0.1 hook as `newer` and skip the comparison, so the
hook and the pin move together, as decisions#421 did.

## Phases

- [ ] Phase 1: pin `GREENTOPO_VERSION: 3.0.1` in `.github/workflows/adr.yaml`;
  regenerate `.claude/hooks/greentopo-heads.sh` with the installed
  `greentopo hook install` (3.0.1).

## Non-goals

- The vendored decisions pack: `greentopo add --check` reads it `current`
  (decisions HEAD 568942e, same declarations), so it is not re-vendored.
- `CHANGELOG.md`'s v3.0.1 entry, which quotes the old "An greentopo" wording
  on purpose; the ticket's grep is judged outside it as a quotation.
- Any other repository's hook (they move at their next `hook install`).

## Verification

| Input | Expected | Actual |
| --- | --- | --- |
| `greentopo hook install --check` in the worktree | `ok` |
| `git grep -nP -e "\b[Aa]n \x60?greentopo" -e "\b[Aa]n \x60?greenspotter" -- ':!docs/plans' ':!docs/programmes' ':!CHANGELOG.md'` | empty |
| `git diff origin/main -- .claude/hooks` | marker line and the three comment lines only |
| `git diff --stat origin/main` | exactly `.claude/hooks/greentopo-heads.sh` and `.github/workflows/adr.yaml` (`.claude/settings.json` unchanged) |
| `gh release view v3.0.1 --repo greenharness/greentopo --json assets` before the push | lists `greentopo-3.0.1-x86_64-unknown-linux-gnu.tar.gz` |
| CI `adr` job log on the PR | `greentopo 3.0.1`, the hook check reports `ok`, and no `GREENTOPO_VERSION` pin `note` |

## Code review

- aval: platform (backend left out: no service code, a CI pin and a generated hook)

## Decision log

- Ticket afk; the programme's approval is the approval.

<!-- panel: repos=aval adds= reviewers=backend,platform body-sha=a70836fc90b7 -->
