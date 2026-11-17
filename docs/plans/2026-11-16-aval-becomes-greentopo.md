---
status: active
branch: feat/aval-becomes-greentopo
repos: [aval, decisions]
adrs: [ADR-0072, ADR-0073, ADR-0074]
plan-id: p-01M7K2V8P2Y2FQCGEVGSD3WWTD
---
# aval becomes greentopo

## Review panel

👉 **Decide:** keep two additions past the ×1.25 growth line: a pre-flight check that npm and crates.io can publish the new names, and a 7-day watch of fleet downloads; else approve.
📍 aval, decisions · Phase 1 done 11-17 (transferred; npm moved to @greenharness, ADR-0074) · next: Phase 2. Panel: backend, lang:rust, architect, po, tui, unix (opus-5-5), codex.
**Changed by review:** old packs warn on stderr and keep loading; CI builds its own binary; Codex caught `hook uninstall --write`, the formula seed, install.ps1 and `relais.toml`.
**Verdicts:** round 2: 3 approve, 3 approve-with-changes; codex rework, fixed, backend approve; 11 carried; words 1309 → 1975 (×1.51); remove 0, merge 0.
📄 Full reviews: [2026-11-16-aval-becomes-greentopo.reviews.md](2026-11-16-aval-becomes-greentopo.reviews.md)

## Picture

```
fredericrous/aval --transfer+rename--> greenharness/greentopo
  |                                     (old URLs redirect)
  +- sed rules + hand edits --> PR --> tag v2.0.0
  |                                      +- crates greentopo(-core)
  |                                      +- npm @greenharness/greentopo(-*)
  |                                      +- tap greentopo.rb (aval.rb
  |                                         renamed)
  +- old packs (`aval:` key, `aval.pack`): one fallback
     read with a warning; the fleet sweep removes it
not here: adr-lint, machine switch, CI images, sweep
```

The picture shows the one repository move, the release it produces, and
the single fallback read that keeps old packs working until the sweep.

## Context

Programme topo-spotter-rename (map `decisions/docs/programmes/topo-spotter-rename/map.md`)
closed all its decisions on 2026-11-16. ADR-0072 renames aval to greentopo at
`greenharness/greentopo`, by sed with no shipped alias (ADR-0073
`harness.renames`). The map's build order is: transfer, then the greentopo
release, then greenspotter, then the machine switch, then CI images, then the
fleet sweep. This plan is the first two steps for aval.

**Start gate (decided, t04):** no step of this plan runs until greenbelay
6.0.0 is released and installed on this machine (`greenbelay --version`
prints 6.x). The plan is written and reviewed now; execution waits.

## Goal

`greenharness/greentopo` exists (transferred from `fredericrous/aval`), and
greentopo 2.0.0 is released under that name: binary `greentopo`, crates
`greentopo` and `greentopo-core`, npm `@greenharness/greentopo` and
`@greenharness/greentopo-<platform>` (ADR-0074, greengate's layout), tap
formula `greentopo`. No live name in the repository says `aval`, except the
one fallback read below and an allowlist named in the PR.

## Non-goals

- adr-lint / greenspotter: its own plan, after this release (adr-lint spawns
  this binary). In this repo, `adr-lint.toml` and the `greengate.conf`
  adr-lint pack block keep their names until that plan; rule 9 does rewrite `adr-lint.toml`'s cli-probe `--bin`/`run` to `greentopo`.
- Switching this machine (`~/.local/bin/aval`, the `aval` MCP entry, hooks,
  `~/.cache/aval`), CI images, and the fleet sweep: later plans.
- Old published crates, npm packages: left as they are (t03).
- Migrating already-installed `.claude/hooks/aval-heads.sh` in other repos:
  the fleet sweep runs `aval hook uninstall --write` (script and settings entry),
  then `greentopo hook install`.

## Code review

- aval: backend, lang:rust, unix, tui, platform (platform added: `release.yaml` and `adr.yaml` change)
- decisions: none — markdown only

## Behaviour

1. **One fallback read for committed packs (decided by the person,
   2026-11-16, under ADR-0073's "one fallback read for committed files until
   a fleet sweep has renamed them"):**
   - `pack::parse` accepts a top-level `aval:` key as `greentopo:`. The
     notice is not a `Finding` in `out` (pack.rs:503 turns any entry into
     `Err`): it goes to a new `Pack.warnings` field and travels the existing
     warnings channel (main.rs:934-941): a `warning: …` line on stderr, a
     `warnings` entry under `--json`, the exit status unchanged, nothing on
     stdout, silenced by `--quiet` (the session hook captures stdout of
     `add --check --quiet`, hook.rs:132).
   - The `aval:` notice names the exact command with the pack's recorded
     source (``run `greentopo add github:fredericrous/decisions` ``); a legacy
     fetch names the fix in the source (``the source publishes aval.pack;
     run `greentopo pack --write` there``). A pack read through the legacy
     fetch gets one notice in all, not a second one for its `aval:` key.
   - `pack --write` never writes `aval:`; `add` vendors the published bytes
     unchanged (so `declares_the_same`, add.rs:614, keeps holding).
   - `fetch::fetch` takes `files: &[&str]` and, after its one `git fetch`, tries
     `git show FETCH_HEAD:greentopo.pack`, then `aval.pack` in the same scratch
     repo, returning which it found; all three call sites (add.rs :112, :568,
     :609) pass both, and a legacy hit warns once. `pack::FILE` is `greentopo.pack`; the old name is a
     separate `LEGACY_FILE` constant, the only `aval` left in code, with a
     comment naming the sweep that removes it.
   - Tests: an `aval:`-keyed pack parses with exactly one warning; a source
     publishing only `aval.pack` is vendored; a source publishing both reads
     `greentopo.pack`; `add --check` against a local git source publishing only
     `aval.pack` reports Current (not Unknown); `greentopo check` with an
     `aval:` pack exits 0 with one warning (CLI test in tests/cli.rs); a
     legacy-fetched `aval:` pack warns once in all; `add --check --quiet`
     against it prints nothing on stdout.
2. Everything else is a rename: same commands, flags, JSON and exit codes.
   The MCP server registers as `greentopo` with tools `greentopo_*` and
   resources `greentopo://…`. The hook writes `.claude/hooks/greentopo-heads.sh`
   with marker `# greentopo-hook: written by greentopo `; the generated cache
   dir is `~/.cache/greentopo`.
3. Version 2.0.0: the binary and the MCP/tool names change.

## Phases

### Phase 1 — transfer (the agent) — [x] done 2026-11-17

Files: none in the tree; the live checkout's `.git/config` remote.

1. `gh api -X POST repos/fredericrous/aval/transfer -f new_owner=greenharness -f new_name=greentopo`
   (secrets `CARGO_REGISTRY_TOKEN`, `NPM_TOKEN`, `TAP_DEPLOY_KEY` and the
   `PUBLISH_*` variables move with it; checked after).
2. `git -C ~/Developer/Perso/aval remote set-url origin git@github.com:greenharness/greentopo.git`
   (the live checkout only; the directory keeps its name until the sweep).
3. Verify redirects that fleet readers depend on, before any edit:
   for each distinct `AVAL_VERSION` pinned in the fleet's `.github/workflows/adr.yaml`
   files (this repo pins 1.10.0), `gh release download v<V> --repo fredericrous/aval --pattern 'aval-<V>-x86_64-unknown-linux-gnu.tar.gz'`
   succeeds, `git ls-remote https://github.com/fredericrous/aval`
   resolves, and the raw `install/install.sh` URL under the old path returns 200.
4. Pre-flight before any tag: `npm view @greenharness/greentopo` returns 404;
   the `@greenharness` scope exists (it does: greengate publishes there) and
   the `NPM_TOKEN` account can publish to it (a release fails only that job,
   re-run once fixed); the
   crates.io token's scope covers `greentopo` and `greentopo-core` (or is
   unscoped). Any failure stops here, because a partial publish cannot be undone.

### Phase 2 — rename in the repository (worktree `aval-wt-greentopo`) — [x] done 2026-11-17

Sed with GNU `sed -E -i` on text files only, NUL-separated (`git grep -Ilz '' | xargs -0`; xargs here is BSD), excluding `.claude/hooks/`, `.claude/settings.json` (regenerated below), `CHANGELOG.md`,
`docs/plans/`, `.adr/packs/` (re-vendored, not edited), in this order:

| # | Expression |
|---|---|
| 0 | `s#fredericrous/aval\b#greenharness/greentopo#g` |
| 1 | `s#@aval-adr/#@greenharness/greentopo-#g; s#\baval-adr\b#@greenharness/greentopo#g` (ADR-0074) |
| 2 | `s/mcp__aval__aval_/mcp__greentopo__greentopo_/g; s/mcp__aval__/mcp__greentopo__/g` |
| 3 | `s/\baval_(resolve\|relevant\|rule\|rules\|keys\|traits\|show\|heads\|history\|repos)\b/greentopo_\1/g` (adds `traits`, missing from t02) |
| 3b | `s/\baval_core\b/greentopo_core/g; s/CARGO_BIN_EXE_aval\b/CARGO_BIN_EXE_greentopo/g` |
| 4 | `s/AVAL/GREENTOPO/g` |
| 8 | `s/\baval\.pack\b/greentopo.pack/g` |
| 9 | `s/\baval\b/greentopo/g`, skipping lines with `aval-fleet` or `aval-agent` (stale names of other tools; left as they are) and `relais.toml`'s `aval = "required"` |

`relais.toml`'s `[integrations] aval` stays: relais denies unknown fields
and knows no `greentopo` key yet (`relais/crates/relais/src/policy/mod.rs:216`).
The relais reader is renamed in its own plan; the fleet sweep renames the key.

The expressions run from a committed `scripts/rename.sed`, where `|` is bare: the table's `\|` is a markdown escape only, and in `sed -E` a `\|` matches a literal pipe. Each rule's hit count is printed before and after; a rule that matched
before and leaves >0 matches after (outside the allowlist) stops the run.

Then `git mv`: `crates/aval-core → crates/greentopo-core`,
`crates/aval → crates/greentopo`, `npm/aval → npm/greentopo` (and
`bin/aval.js → bin/greentopo.js`), `.claude/hooks/aval-heads.sh →
greentopo-heads.sh`.

Hand edits:
- the fallback read (Behaviour 1) in `crates/greentopo-core/src/pack.rs`
  (`FILE`, `LEGACY_FILE`, `PACK_FIELDS` reader at ~:391) and
  `crates/greentopo/src/add.rs` (fetch at :112, :568, :609; `k != "greentopo"`
  at :585 also skips `aval`);
- `scripts/test_bump_tap.py:41` `class Aval` → `class Greentopo`;
- `install/install.ps1`: the loop over `aval.exe`/`aval-fleet.exe` (:130)
  is skipped by rule 9 and would install nothing; it is rewritten by hand
  to install `greentopo.exe` only, failing when the archive lacks it;
- `npm/greentopo/package.json.in` `_comment_name` (npm's `aval` was taken):
  rewritten; `scripts/npm-pack.sh` output directories, which rule 1 would
  turn into scoped paths (`$OUT/aval-adr/`), are set by hand to greengate's
  layout (`amont/scripts/npm-pack.sh` is the model);
- `.github/workflows/adr.yaml`: until 2.0.0 exists, it builds this PR's own
  binary (`cargo build --release --bin greentopo`) and puts it on PATH; a
  1.x binary would fail `hook install --check` against the renamed script
  (`hook.rs:43`). Phase 3 replaces the build with the 2.0.0 download;
- `Cargo.toml` version `2.0.0` (workspace and the `greentopo-core` dep pin);
  `Cargo.lock` regenerated by `cargo build`;
- `.adr/packs/decisions.pack`: left untouched (exercises the fallback read);
- regenerate `conformance/corpora/*/docs/adr/HEADS.md` and
  `tests/fixtures/heads-prettier.md` with the new binary, never sed them;
- `.claude/hooks/` and `.claude/settings.json` are excluded from sed: before
  the sed, the installed 1.x `aval hook uninstall --write` (hook.rs:663; without `--write` it only previews, main.rs:1230) removes the
  old script and its `.claude/settings.json` entry (`install` keeps entries
  that do not name its own `SCRIPT_PATH`, hook.rs:428), then `target/debug/greentopo hook install` writes
  `greentopo-heads.sh` with a 2.0.0 marker; `hook install --check` exits 0.
  Known effect: until the machine switch puts `greentopo` on PATH, sessions
  in this checkout print no decisions preamble (the script exits 0 when the
  binary is missing); noted in the PR;
- `CHANGELOG.md`: a 2.0.0 entry naming the rename and the fallback read.

Run `cargo test --workspace`, `cargo clippy --workspace -- -D warnings`,
`scripts/check-no-deps.sh`, `python3 scripts/test_bump_tap.py`, and
`scripts/npm-pack.sh` into a scratch dir (lists `@greenharness/greentopo` +
six `@greenharness/greentopo-<platform>`). Commit, review (F4b), land, PR, merge on green.

### Phase 3 — release 2.0.0 — [ ] next

Files: `.github/workflows/adr.yaml` (follow-up PR), the tap's `Formula/greentopo.rb`, `Formula/aval.rb`, `formula_renames.json`, and `decisions/docs/programmes/topo-spotter-rename/map.md`.

1. Tag through `tag-release`: `v2.0.0`. Read each job's `conclusion`.
2. Tap: before the tag, seed `Formula/greentopo.rb` in the tap by hand (a copy of `aval.rb` with class, URLs, asset names, `bin.install` and test renamed), since `bump-tap.py` rewrites a formula and never creates one (release.yaml:621); the `publish-tap` job then bumps it, and `verify-brew` must pass. `Formula/aval.rb` stays at 1.12.0; the `formula_renames.json` entry `{"aval": "greentopo"}` and its removal move to the machine-switch plan, so no `brew upgrade` drops `aval` before the switch.
3. Follow-up PR: `adr.yaml` pins `GREENTOPO_VERSION=2.0.0` and the
   `greentopo-2.0.0-…` asset, replacing the source build.
4. Record in decisions: the programme map's Notes get one line (transfer done,
   2.0.0 released, the fallback read and its removal owed by the sweep), via
   a `prog/topo-spotter-rename/build-greentopo` branch and PR.

### 🧑 Your steps

- `greenbelay --version` shows 6.x — because this plan starts only after greenbelay 6.0.0 is installed (t04)

## Verification

| Check | Expected |
|---|---|
| `gh api repos/greenharness/greentopo -q .full_name` | `greenharness/greentopo` |
| old-path release download, `git ls-remote`, raw install URL | all succeed via redirect |
| `gh secret list -R greenharness/greentopo` | the three secrets listed |
| `git grep -ni -e aval -- ':!CHANGELOG.md' ':!docs/plans' ':!.adr/packs'` (no `-w`, so `aval_*` is caught) | only the allowlist: `LEGACY_FILE`, the `aval:` fallback + its tests, `aval-fleet`/`aval-agent`, `relais.toml`'s `[integrations] aval` |
| `cargo test --workspace` | exit 0; the three fallback tests (Behaviour 1) are listed as `ok` |
| clippy `-D warnings`, `scripts/check-no-deps.sh`, `python3 scripts/test_bump_tap.py` | each exits 0 |
| piloted run: `target/debug/greentopo check` in this repo (old `aval:` pack) | exit 0; exactly one `warning:` line on stderr; stdout unchanged; under `--json`, stdout parses and `warnings` holds it |
| piloted run: `greentopo add --check` against `github:fredericrous/decisions` (publishes only `aval.pack`) | reports Current, one `warning:` line on stderr, nothing extra on stdout |
| `jq '.hooks.SessionStart' .claude/settings.json` in the PR tree | one entry, `sh .claude/hooks/greentopo-heads.sh`; no `aval-heads.sh` |
| piloted run: `greentopo mcp` over stdio, `tools/list` | ten `greentopo_*` tools |
| release run `conclusion` | `success` for build, crates, npm, tap |
| `cargo search greentopo`, `npm view @greenharness/greentopo version`, tap `Formula/greentopo.rb` | 2.0.0 |
| `brew info fredericrous/tap/aval` | still 1.12.0 (rename map waits for the machine switch) |


### Results, Phases 1–2 (observed before the push)

| Check | Expected | Actual |
|---|---|---|
| `gh api repos/greenharness/greentopo -q .full_name` | `greenharness/greentopo` | `greenharness/greentopo` |
| old-path `gh release download` for every fleet pin (1.7.1, 1.8.0, 1.9.0, 1.10.0, 1.11.0, 1.12.0), `git ls-remote`, raw `install.sh` | succeed via redirect | 6/6 downloaded; ls-remote `ba91061`; raw 200 |
| `gh secret list` / `gh variable list -R greenharness/greentopo` | 3 secrets, `PUBLISH_*` | 3 secrets, 3 `PUBLISH_*` = true |
| npm/crates pre-flight | names free, scope writable | `greentopo`, `greentopo-core` free on crates.io; `@greentopo` scope absent, so npm moved to `@greenharness` (ADR-0074, decisions#220); token write on `@greenharness` not testable locally, checked at the tag |
| rename.sed before → after, per rule | each > 0 → 0 | 37/20/39/171/92/7/45/29/931 → 0; bare `aval` 931 → 7 (the skipped lines) |
| `git grep -ni -e aval` (exclusions as above) | allowlist only | fallback code + tests, `aval-fleet`/`aval-agent`, `relais.toml` key, the adr.yaml comment naming 1.x |
| `cargo test --workspace` | exit 0, fallback tests `ok` | 473 passed, 0 failed |
| clippy `-D warnings`, `check-no-deps.sh`, `test_bump_tap.py`, `cargo fmt --check` | exit 0 | 0, 0, 0, 0 |
| `greentopo check` here (vendored pack keyed `aval:`) | exit 0, one `warning:`, stdout unchanged | exit 0; stdout `74 decision records, no findings`; one `warning: … uses the old \`aval:\` key; run \`greentopo add github:fredericrous/decisions\`` |
| `greentopo check --json` | `warnings` holds it | 1 entry |
| `greentopo add --check` vs `github:fredericrous/decisions` (only `aval.pack`) | Current, one warning, stdout clean | `current decisions @ 0e655c0`; one `warning: … publishes aval.pack; run \`greentopo pack --write\` there` |
| `add --check --quiet` | nothing on stdout | 0 bytes stdout, 0 bytes stderr |
| `resolve --json` | shape unchanged | no `warnings` key, stderr empty |
| `jq '.hooks.SessionStart' .claude/settings.json` | one `greentopo-heads.sh` entry | one entry; script marker `greentopo 2.0.0`; `hook install --check` exit 0 |
| `greentopo mcp`, `tools/list` | ten `greentopo_*` | server `greentopo` 2.0.0, ten `greentopo_*` |
| `scripts/npm-pack.sh 2.0.0` on stub archives | `@greenharness/greentopo` + six platforms | 7 package.json, root bin `greentopo`, six optionalDependencies |
| `--help` width | ≤ 80 columns | widest 79 (test `no_help_line_is_wider_than_80_columns`) |

## After release

- For 7 days after the transfer: count fleet `adr.yaml` runs that fail at the download step (`gh release download --repo fredericrous/aval`). Expected 0; if any fail and no fix lands within a day, transfer the repo back (Rollback).
- After the machine switch: a new session in this repo prints the heads preamble.

## Rollback

- Transfer: `gh api -X POST repos/greenharness/greentopo/transfer -f new_owner=fredericrous -f new_name=aval`
  (nothing is ever created at the old name, so this stays possible).
- Before the tag: close the PR. After: a 2.0.1 fix; tags are never moved.
  Published crates/npm can be yanked/deprecated only by the person's call.

## Implementation review

- implementation-review (opus): approve-with-changes → approve after 2 deltas; fixed banner, bool helper, false glob comment, results table, plan notes; deliberate: pre-existing stdout/banner/`&mut` violations only renamed by sed (follow-up); 101k+121k+129k, 151+28+17 s.
- backend: approve; fixed fetch absent-vs-error (`cat-file -e`), sweep-path test, npm summary name; 84k+98k. platform: approve; fixed adr.yaml header, `timeout-minutes: 20`; 72k+75k.
- lang:rust: approve; fixed one `Option<OldName>`, path pairing, public `LEGACY_KEY`, `#[non_exhaustive]`, unit tests (relais's new bool flags corrected by hand); 62k+79k.
- unix: approve; deliberate: old `AVAL_VERSION` pins unread until the sweep, noted in CHANGELOG; 64k+80k. tui: approve; fixed 80-column help + test, shorter notice, `--as` kept in the notice; carried: register.rs help-name assertion weakened (low); 56k+74k+76k.

## Decision log

- 2026-11-16: one fallback read for `aval:`-keyed packs and `aval.pack`
  fetch, chosen by the person; removed by the fleet sweep.
- 2026-11-16: transfer only aval here; adr-lint transfers in its own plan,
  since its `greengate.conf` pack pins (`github:fredericrous/adr-lint <sha>`)
  are read by every repo's gate.
- 2026-11-16: version 2.0.0 — the binary and MCP tool names change.
- 2026-11-17: npm moved to `@greenharness/greentopo(-<platform>)` — no `@greentopo` scope exists; the person chose `@greenharness` (ADR-0074, decisions#220). Plan delta reviewed by backend.
- 2026-11-17: `scripts/rename.sed` carries rules the Phase 2 table lacks, found while running it: 3b also renames `aval_nope` and `path_with_aval`; 9b renames `\naval` inside string literals (the escape's `n` defeats `\b`); 9c renames the remaining `aval_` prefixes and `_aval_` infixes. Behaviour 1's CLI tests live in `tests/pack.rs`, not `tests/cli.rs`.
- 2026-11-17: `aval hook uninstall --write` removed `.claude/settings.json` whole (it held only the hook); `greentopo hook install` recreated it.
- 2026-11-17: the fallback read was built by relais (run-6606f1c4a321f-2e95) and its review fixes by relais (run-6606f6443b9a4-46ad); two hand corrections followed (bool flags, `--as` in the notice), recorded as relais feedback.

<!-- panel: repos=aval,decisions adds=contract reviewers=backend,lang:rust,architect,po,tui,unix body-sha=009f48e83526 -->
