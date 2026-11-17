# In front of an agent

A corpus that resolves is half the point. The other half is that whatever is
about to write code starts from what was decided. There are two ways in: a
session hook that **pushes** the heads at the start, and an MCP server an agent
**pulls** from when the question comes up.

## The session hook

```console
$ greentopo hook install
  wrote  .claude/hooks/greentopo-heads.sh  (created)
  wrote  .claude/settings.json  (created)

Repo-specific caveats go in .claude/greentopo-hook.local.md — the hook appends that file after the
heads, and installing again leaves it alone.
```

It writes a session-start hook that prints the current heads, the ids of the
active constraints grouped by prefix (`greentopo rule <id>` has each one's text) and
a one-line traits summary, and merges one entry into
`.claude/settings.json` without disturbing what else is there. The hook is
**silent** when `greentopo` is not installed, so committing it cannot fail a
colleague's session, and silent when there is no corpus to report. The text it
prints tells the model that a record's wording is data, not instruction.

Repo-specific caveats go in `.claude/greentopo-hook.local.md`. The hook appends that
file; installing again never touches it. `--check` is the drift detector for
CI: exit 0 wired, exit 1 stale.

The script's second line names the greentopo that wrote it:

```sh
#!/bin/sh
# greentopo-hook: written by greentopo 1.9.0
```

A script from a **newer** greentopo is not stale, and an older greentopo leaves it alone
rather than downgrading it, so a workstation that upgrades first does not
redden a CI job pinned to the release before. Both modes also print a `note`
for every `GREENTOPO_VERSION:` pin under `.github/workflows` or `.forgejo/workflows`
that is behind or ahead of the running greentopo — advisory, never an exit code,
never an edit to the workflow.

### Vendored packs that fell behind

Where the repository [vendors packs](sharing.md), the hook also asks whether
they are still what their sources publish — at most once an hour per
repository, under a five-second budget that kills the remote call rather than
waiting on it, and speaking only when a pack is behind or edited:

```text
VENDORED DECISIONS ARE BEHIND THEIR SOURCE. The fleet has decided something
this repository has not adopted yet, so the heads below may be superseded:
  behind    fleet has 1bb600e, main now names e73638d

1 pack(s) behind. Run `greentopo add <source>` for each, read the diff, then `greentopo heads --write`.
```

Offline, a slow remote, lost access: silence, on purpose. A notice that fired
on every flaky network would be the one nobody read on the day a decision
changed. The stamp that rates the hour lives under `$XDG_CACHE_HOME/greentopo`
(default `~/.cache/greentopo`), never in the repository. `greentopo add --check` by hand
always answers in full.

### Removing the hook

```console
$ greentopo hook uninstall            # previews what would be removed
$ greentopo hook uninstall --write    # removes it
$ greentopo hook uninstall --check    # exit 0 nothing left, 1 something is
```

It removes exactly what `install` wrote: `.claude/hooks/greentopo-heads.sh`, only
when it carries greentopo's `# greentopo-hook: written by greentopo` marker (a script without
it is somebody else's and is left alone), and the `SessionStart` entry that runs
it in `.claude/settings.json`. Every other settings key, the file's indentation
and its final newline stay as they were; keys are written in sorted order, as
`install` writes them. So `hook uninstall` restores the settings file byte for
byte only when it was in the shape `hook install` writes (sorted keys,
two-space indent, final newline); any other file keeps its indentation and
final newline and differs from the original only in key order.
`.claude/greentopo-hook.local.md` is yours and is never
touched.

## The MCP server

The hook pushes; **`greentopo mcp` lets an agent pull** — the same answers as native
tools, asked at the moment the question comes up rather than only at the top of
a session:

```console
$ claude mcp add greentopo -- greentopo mcp
```

or let greentopo do it, at Claude Code user scope, with the absolute path of the
binary that is running:

```console
$ greentopo mcp install               # shows the `claude mcp add --scope user …` it would run
$ greentopo mcp install --write       # runs it
$ greentopo mcp install --check       # exit 0 registered, 1 not, 3 `claude` absent or could not answer
$ greentopo mcp uninstall --write     # claude mcp remove --scope user greentopo
```

`--check` asks `claude mcp get greentopo`. With no `claude` on PATH, `--check`
prints one line on stderr and exits 3 (unknown, never 0, which means
registered); `--write` and the preview print it on stderr and exit 0: there is
nothing to register with. Messages that are not the answer asked for go to
stderr. The registered path is the first `greentopo` on PATH when it is the running
binary (a Homebrew link rather than the Cellar path), else the running binary.

Ten read-only tools: `greentopo_resolve`, `greentopo_relevant`, `greentopo_keys`,
`greentopo_traits`, `greentopo_heads`, `greentopo_show`, `greentopo_history`, `greentopo_rules`,
`greentopo_rule` and `greentopo_repos`, and three resources: `greentopo://heads`,
`greentopo://keys` and `greentopo://repos`. They resolve through the same graph the CLI
does and return the same bytes `--json` would, so the two surfaces cannot drift
apart.

With no `scope` argument, `greentopo_resolve`, `greentopo_relevant` and `greentopo_history`
answer at the scopes the repository declares in `in_scopes` in `.adr.yaml`
(an explicit `"*"` asks the default scope alone), and JSON answers carry
`scope_source`: `flag`, `in_scopes` or `default`. The session hook's traits line
also names the declared scopes.

`greentopo_relevant` is the one whose result is **not** an answer, and its
description says so where a model will read it: the ranking is advisory, what
is authoritative is the verdict beside each key, and an `undecided` row is the
reason to have called it.

The distinction that matters: **a verdict is not an error**. `undecided`,
`retired`, `unknown` and `contradiction` all come back as ordinary results with
`isError: false`, because each is an answer. Reporting `contradiction` as a tool
failure would teach an agent to retry or work around the one verdict that means
*stop and ask a human* — so the flag is reserved for a corpus that would not
load, or a name it does not carry.

Nothing on that surface writes. Resolving answers a question; deciding is not
something to do on an agent's behalf.

## From the parent of all your projects

Where there is no corpus above and several below, the same server is a
**workspace**: every tool takes `repo` to name one. `resolve` and `history`
answer for all of them when it is omitted — a map keyed by name, which is the
cross-repository question in a single call — while `keys`, `heads` and `show`
ask for a name, because every repository's heads at once is a lot of context to
fetch by forgetting an argument. `greentopo repos` says what was found, and
`--all-repos` renders the same map from the shell:

```console
$ greentopo resolve stack.sql-layer --scope effect-stack --all-repos
== amont ==
active   decisions:ADR-0002   @effect/sql
  scope: effect-stack
  vendored: from the `decisions` pack; change it there, not here

…

== decisions ==
active   ADR-0002   @effect/sql
  scope: effect-stack
…
```

A linked worktree is detected and left out when its parent is also there, so
one corpus never answers twice; `greentopo repos` still lists it, and it stays
addressable by name.
