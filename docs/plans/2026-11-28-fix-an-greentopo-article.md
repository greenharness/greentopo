---
status: active
branch: fix/hook-template-article
repos: [aval, decisions]
adrs: [ADR-0076]
plan-id: p-01M8HDEC0312NT68MAH9PZF265
---
# Fix the "an greentopo" article

## Review panel

👉 **Decide:** none — approve if a comment-only 3.0.1 patch, plus decisions' hook, pack and pin, is the whole fix.
📍 aval, decisions · 2 phases · 1 release · next: Phase 1. Panel: backend, lang:rust, platform, tui, unix (opus), codex.
**Changed by review:** wait for the Linux release asset; regenerate decisions' pack (Codex); a regression test and exact grep checks.
**Verdicts:** round 1 5 approve-with-changes; final 3 approve, 2 approve-with-changes; Codex rework, fixed; 6 carried; words 743 → 910 (×1.22); remove 0, merge 0.
📄 Full reviews: [2026-11-28-fix-an-greentopo-article.reviews.md](2026-11-28-fix-an-greentopo-article.reviews.md)

## Picture

```
 greentopo 3.0.0 template            greentopo 3.0.1 template
 "# An greentopo older ..."   --->   "# A greentopo older ..."
          |                                   |
   hook install (3.0.0)                hook install (3.0.1)
          v                                   v
 decisions/.claude/hooks/            decisions/.claude/hooks/
 greentopo-heads.sh: "An" x3         greentopo-heads.sh: "A" x3
 CI pin 3.0.0                        CI pin 3.0.1, --check compares
```

The text moves only through a release: the hook is generated, so the
template is fixed, released, and decisions' copy rewritten by the release.

## Context

Programme topo-spotter-rename, ticket t30 (decisions
`docs/programmes/topo-spotter-rename/t30-greentopo-hook-template-article.md`).
The rename's sed turned "an aval" into "an greentopo" and "an `AVAL_VERSION`"
into "an `GREENTOPO_VERSION`": the new names start with a consonant. The hook
template in `crates/greentopo/src/hook.rs` carries three such lines, so every
`greentopo hook install` writes them into a repository's
`.claude/hooks/greentopo-heads.sh` (decisions lines 17, 103, 133). That file is
generated, and CI's `greentopo hook install --check` refuses a hand edit, so
the fix is in the template and reaches decisions through a release.

Census on `origin/main` (2026-11-28, `git grep -niP "\ban [\`'\"]?green"`):

- `crates/greentopo/src/hook.rs` 83, 169, 199 (template text), 211, 327, 339
  (doc comments);
- `crates/greentopo/src/packfile.rs` 6, 27 (doc comments, "an `greentopo.pack`");
- `crates/greentopo/tests/hook.rs` 312 (doc comment);
- `.adr/packs/decisions.pack` 2245: vendored; fixed at its source by
  decisions#420 (t29) and re-vendored in this branch's first commit;
- `.claude/hooks/greentopo-heads.sh` 17, 103, 133: generated output, see
  Non-goals;
- `docs/plans/2026-11-27-topo3-tool-repos.md` 14: history, quotes the error.

## Goal

greentopo's hook template, messages and doc comments read "a greentopo",
"a `greentopo.pack`", "a `GREENTOPO_VERSION:` pin". greentopo 3.0.1 ships the
template, and decisions' generated hook is rewritten by it, so the grep the
ticket names is empty in decisions outside history.

## Non-goals

- `docs/plans/`, `CHANGELOG.md` history and `scripts/rename.sed` stay.
- aval's own `.claude/hooks/greentopo-heads.sh` is not regenerated here: aval's
  `.github/workflows/adr.yaml` pins 3.0.0, and a 3.0.0 `--check` reads a 3.0.1
  hook as `newer` and skips the comparison; moving that pin and the hook is a
  follow-up like #68. It, and every other
  repository, picks the text up at its next `greentopo hook install` (no
  sweep, per the ticket).
- No change to the hook's behaviour: comment lines only, the script's
  commands are byte-identical.

## Code review

- aval: none — proposed backend, lang:rust, platform, unix, tui; all left out: the diff is comment and doc-comment wording, a version bump and a re-vendored pack, with no logic, no command line output and no workflow change
- decisions: none — proposed backend, platform; left out: a regenerated file, a one-line CI version pin and programme prose, no logic

## Behaviour

- `greentopo hook install` (3.0.1) writes a script whose comments read
  "A greentopo older than ...", "A greentopo older than this hook has no
  `--index`", "A greentopo without `traits` prints nothing." Every command
  line of the script is as in 3.0.0; only the marker version and those three
  comment lines differ.
- `greentopo --version` prints `greentopo 3.0.1`.
- In decisions, `git grep -nP -e "\b[Aa]n \x60?greentopo" -e "\b[Aa]n \x60?greenspotter"` matches only
  under `docs/plans/` and `docs/programmes/` (history), and CI's
  `greentopo hook install --check` passes with the pin at 3.0.1.

## Phases

- [ ] Phase 1 — fix the article, bump to 3.0.1: `crates/greentopo/src/hook.rs`,
  `crates/greentopo/src/packfile.rs`, `crates/greentopo/tests/hook.rs` (doc
  comment, plus a new test: an installed script contains `# A greentopo older than`
  and no `An greentopo` / "an `GREENTOPO"; it fails on origin/main),
  `Cargo.toml` (workspace `version` line 9 and the `greentopo-core` dep
  `version` line 41), `Cargo.lock`, `CHANGELOG.md`; one PR, merged, then tag
  `v3.0.1` (`tag-release`), install it on this machine, print
  `greentopo --version`.
- [ ] Phase 2 — decisions, started only once the v3.0.1 release workflow's
  `conclusion` is `success` and `gh release view v3.0.1 --repo
  greenharness/greentopo` lists `greentopo-3.0.1-x86_64-unknown-linux-gnu.tar.gz`
  (CI downloads it, ci.yaml:37-46): `greentopo hook install` with 3.0.1 rewrites
  `.claude/hooks/greentopo-heads.sh`; `.github/workflows/ci.yaml` pins
  `GREENTOPO_VERSION: 3.0.1`; `greentopo pack --write` with 3.0.1 rewrites
  `greentopo.pack` (its `greentopo:` version line is compared by CI's
  `pack --check`; expected diff: that line only); ticket Resolution and map line in
  `docs/programmes/topo-spotter-rename/`; `AGENTS.md` via `amont agents-md`;
  pointer plan `docs/plans/2026-11-28-fix-an-greentopo-article.md`.
  Rollback: revert the whole decisions PR (hook and pin together); never the
  pin alone, which leaves a 3.0.1 hook that a 3.0.0 `--check` skips as `newer`.

## Decision log

- 2026-11-28 — the version bump rides the fix PR instead of a separate
  release PR, because the fix is the whole release (few PRs).
- 2026-11-28 — decisions' CI pin moves to 3.0.1 with the regenerated hook,
  because a 3.0.0 `--check` reads a 3.0.1 hook as `newer` and skips the
  comparison, so the gate would stop checking the file.

## Verification

| Check | Input | Expected | Actual |
| --- | --- | --- | --- |
| replacements landed | `git grep -niP "\ban [\x60'\"]?green" -- crates` | empty | |
| suites | `cargo test`, `cargo clippy --all-targets -- -D warnings`, `cargo fmt --all --check` | pass | |
| piloted hook | branch binary `hook install --write` in a scratch repo, `grep -c "A greentopo" .claude/hooks/greentopo-heads.sh`; `grep -c "An greentopo" .claude/hooks/greentopo-heads.sh` | 3 (lines 17, 103, 133); 0; `diff` against aval's committed 3.0.0 `.claude/hooks/greentopo-heads.sh` changes exactly 4 lines (marker + 3 comments) | |
| release | `greentopo --version` after install | `greentopo 3.0.1` | |
| release asset | `gh release view v3.0.1 --repo greenharness/greentopo --json assets` | lists the x86_64-unknown-linux-gnu tarball | |
| decisions | `git grep -nP -e "\b[Aa]n \x60?greentopo" -e "\b[Aa]n \x60?greenspotter" -- ':!docs/plans' ':!docs/programmes'`; with 3.0.1, `greentopo check`, `greentopo heads --check`, `greentopo pack --check`, `greentopo hook install --check` | grep empty; all four exit 0 | |

<!-- panel: repos=aval,decisions reviewers=backend,lang:rust,platform,tui,unix,codex body-sha=389f8a27baac -->
