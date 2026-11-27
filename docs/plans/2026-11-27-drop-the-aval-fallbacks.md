---
status: active
branch: chore/t22-drop-aval-fallbacks
repos: [aval]
adrs: [ADR-0012, ADR-0071, ADR-0076]
plan-id: p-01M8D2AP8D3D5BFZX020TF45JZ
---
# Drop the aval fallbacks

## Review panel

👉 **Decide:** none, approve if a major 3.0.0 (an `aval:` pack exits 3, `greentopo-core` loses public items) is right for no outside users.
📍 aval · 2 phases · 1 release · next: Phase 1. Panel: backend, lang:rust, tui, unix, architect, po (opus).
**Changed by review:** exit 3 for every corpus-loading command; compatibility of vendored packs, not producers; release row and census of working trees.
**Verdicts:** 6 approve-with-changes; 5 carried; words 753 → 1263 (×1.68, mostly corrections); remove 0, merge 0.

## Picture

```
 today (2.0.0)                         after this plan (3.0.0)
 -------------                         -----------------------
 add --> greentopo.pack? --yes--> ok   add --> greentopo.pack? --yes--> ok
            |no                                   |no
            v                                     v
         aval.pack? --yes--> ok+warn           error: has no greentopo.pack
 load --> key aval: --> ok+warn        load --> key aval: --> unknown field
```

A pack fetch or load under the old name used to succeed with a warning;
after this plan it fails like any other missing file or unknown field.

## Context

Programme topo-spotter-rename, ticket t22 (map
`decisions/docs/programmes/topo-spotter-rename/t22-remove-fallbacks.md`),
greentopo slice. greentopo 2.0.0 kept one fallback read for packs written
under the old name: a vendored pack keyed `aval:` loads with a `warning:`
line, and a source that publishes only `aval.pack` is still fetched. The
2.0.0 CHANGELOG said the fleet sweep removes the read. The sweep is done
(t17–t21 closed). A census on 2026-11-27, after `git fetch`, of every
checkout under `~/Developer/Perso` (worktrees excluded) found no `aval:`-keyed
pack on any `origin/HEAD`. decisions, the only producer, publishes
`greentopo.pack` keyed `greentopo:` (it still publishes `aval.pack` beside
it, which the decisions slice of t22 removes).

## Goal

greentopo reads packs under the new name only: the `greentopo:` key and the
`greentopo.pack` file. The legacy reader, its notices and their tests go.
Then release 3.0.0, which also carries the two Unreleased entries already on
main (`heads --write` tables, the `install.ps1` fix).

## Non-goals

- `scripts/rename.sed`, CHANGELOG, `docs/plans/`, `docs/adr/` and the
  `release.yaml` history comment stay: they are history.
- `migrate.rs`'s `LEGACY_FIELDS`/`LEGACY_STATUSES` are about the legacy ADR
  front-matter format, not the old tool name; they stay.
- No `heads --write` or `hook install --write` with the branch binary, and
  `.github/workflows/adr.yaml` keeps `GREENTOPO_VERSION: 2.0.0`: the pin
  moves with the repository's next HEADS refresh, after 3.0.0 exists.
- greentopo 3.0.0 is not installed on the laptop by this slice; the t22
  driver installs it after the other t22 PRs merge. No fleet pin moves here.

## Code review
- aval: backend, lang:rust, unix (tui left out: no screen or prompt change, only two warnings fewer)

## Behaviour

- A vendored pack whose top-level generator key is `aval:` is refused like
  any pack with an unknown field: it is a Layer A `pack-parses` finding
  `unknown pack field \`aval\``, so `check`, `resolve`, `heads`, `mcp`, the
  session hook and every other command that loads the corpus exit 3
  (`E_INVALID`), where 2.0.0 exited 0 with a `warning:`.
- `greentopo add <source>` and `add --check` fetch `greentopo.pack` only. A
  source that publishes only `aval.pack` fails `add` (exit non-zero) with
  `<source>: has no greentopo.pack at <sha>`; under `add --check` that pack
  reads `unknown` with the same message when its commit is unchanged, and
  `behind` when the revision moved (`standing` turns a failed fetch into a
  state, add.rs:663, 707).
- A pack's `greentopo: "<version>"` generator value is never compared with
  the running version (only `declares_the_same_but_generator` drops it), and
  `HEADS.md` carries no version, so vendored packs and `HEADS.md` written by
  2.0.0 stay current under 3.0.0; a test pins this for a vendored pack keyed
  with a version other than the running one, and for a moved revision that
  republishes the same declarations under another generator version
  (`current (moved)`, not `behind`). A producer's own published pack is
  different: `pack-fresh` compares the generator line too (packfile.rs:80,
  pack.rs:169), so `check` and `pack --check` in decisions report
  `pack-fresh` under 3.0.0 until `greentopo pack --write` runs, as on every
  version bump; the CHANGELOG says so.
- No command prints the `uses the old \`aval:\` key` or `publishes aval.pack`
  notices; `check --json` never carries a `pack-legacy-key` entry under
  `warnings` (its other warnings are unchanged).
- `greentopo-core` drops `pack::LEGACY_FILE`, `pack::LEGACY_KEY`,
  `pack::PackWarning` and `Pack::warnings` from its public API.

## Phases

- [x] Phase 1 — remove the fallback read and its notices:
  `crates/greentopo-core/src/pack.rs` (constants, `PackWarning`,
  `Pack::warnings`, the key reader, doc comments; the two legacy unit tests
  replaced by one asserting `parse` returns `Err` with `unknown pack field \`aval\``),
  `crates/greentopo/src/add.rs` (`OldName`, `published_old_name`,
  `fetch_published`, `PUBLISHED_AS`, the three notice functions, the
  `OldName` half of `standing`/`moved`/`unedited`, the legacy key in
  `declares_the_same_but_generator`), `crates/greentopo/src/fetch.rs`
  (`fetch` takes one file name), `crates/greentopo/src/main.rs`
  (`has_old_key`, `legacy_key_notices`, the notice block in `loaded`, the
  `pack-legacy-key` entries in `check`, the notices in `add` and
  `add --check`), `crates/greentopo/tests/pack.rs` (the fallback tests
  replaced by regression tests, plus one that a vendored pack keyed with a
  version other than `CARGO_PKG_VERSION` (e.g. `"0.1.0"`, as tests/hook.rs
  does) loads and reads `current`, and the moved-revision case above), `CHANGELOG.md` (a
  `### Removed` entry, marked breaking: an `aval:`-keyed pack exits 3 where
  it exited 0 with a warning, the `pack-legacy-key` entry is gone from
  `check --json` `warnings`, `add` reports `has no greentopo.pack`, and the
  fix is `greentopo add <source>`).
- [ ] Phase 2 — release 3.0.0 in its own PR with the `tag-release` skill:
  `Cargo.toml` (workspace version and the `greentopo-core` dependency),
  `Cargo.lock`, `CHANGELOG.md` (Unreleased becomes `v3.0.0`).

## Verification

| Check | Input | Expected | Actual |
|---|---|---|---|
| build and lint | `make check` (fmt, clippy `-D warnings`, tests) | exit 0 | run 2026-11-27: pass |
| regression: old key | consumer with an `aval:`-keyed vendored pack, `greentopo check` and `greentopo resolve` | exit 3 for each, finding names `aval` on stderr | run 2026-11-27: pass |
| regression: old file | source publishing only `aval.pack`, `greentopo add` | non-zero exit, `has no greentopo.pack` | run 2026-11-27: pass |
| regression: old file under check | vendored pack whose source moved and now publishes only `aval.pack`, `greentopo add --check` | `behind`, exit 1; at the unchanged vendored commit: `unknown` naming `has no greentopo.pack`, exit 0 | run 2026-11-27: pass |
| other-version pack | vendored pack keyed `greentopo: "0.1.0"`, `check` and `add --check` (test `a_vendored_pack_written_by_another_generator_version_is_current`); the moved-revision case is `the_generator_version_is_not_a_declaration`, which already exists | exit 0, `current`; `current (moved)`, not `behind` | run 2026-11-27: pass |
| piloted run | branch binary `check`, `heads --check` and `add --check` in this repository and decisions (producer `pack --check` is expected to report `pack-fresh` once Phase 2 bumps the version); branch binary `check` in the working tree of every checkout under `~/Developer/Perso` with `.adr/packs`, worktrees included | exit 0, no `warning:` or finding naming `aval`; a hit in this repository is re-vendored with `greentopo add <source>`; a hit in another repository is listed in the report (stale worktree, or live checkout behind its origin) and re-vendored only through that repository's own t22 PR | not passed: 21 working trees hold an `aval:` pack (stale worktrees, plus live `customer-vision` and `duro-operator`); each is reported, none re-vendored in this PR |
| no old-name reader left | `git grep -nE 'LEGACY_(KEY|FILE)|PackWarning|OldName|aval\.pack' -- crates ':!crates/*/tests'` (the regression tests write `aval.pack` on purpose) | no hit |
| release published | tag `v3.0.0`; each release job's `conclusion`; crates.io `greentopo-core` max version; release binary `--version` | tag exists on main's release commit; `success`; `3.0.0`; `greentopo 3.0.0` | not run (Phase 2) |

## Decision log

- 2026-11-27 — Version 3.0.0 (major), resolved from `release.version-scheme`
  (ADR-0012, Semantic Versioning 2.0.0: only a MAJOR may break a consumer,
  and reluctance to bump MAJOR is the failure the record forbids). An
  `aval:`-keyed pack goes from loading to refused, which changes its exit
  status; and `greentopo-core`, published on crates.io, loses public items.
  `cli.compat.interface-is-public` asks for a warning one release before a
  non-additive change: 2.0.0's `warning:` lines were that warning. The
  census above is the `migration.expand-migrate-contract` evidence that no
  consumer still reads the old form.
- 2026-11-27 — The release is its own PR (`chore(release): 3.0.0`), as
  1.10.0–1.12.0 were.

## After release

- Measure: once the driver installs 3.0.0, `greentopo check` in every checkout and worktree with `.adr/packs`; target 0 exits of 3 naming `aval`. Fallback: reinstall 2.0.0 (CI pins stay 2.0.0), re-vendor, install again; the tag is never moved.

## Carried into implementation

Medium and low findings of round 2, not edited in: widen the census to every remote branch (architect#1, found 2026-11-27: only stale feature branches and worktrees, plus live checkouts `customer-vision` and `duro-operator`, still carry `aval:`); session-hook line check (tui#1); `add --check` exit codes, 0 for unknown and 1 for behind (unix#1); cite ADR-0071 `harness.renames` (architect#2); name `E_FAIL` for the `add` failure (unix#2).

<!-- panel: repos=aval adds=contract reviewers=backend,lang:rust,tui,unix,architect,po body-sha=641e6aad3bc3 -->
