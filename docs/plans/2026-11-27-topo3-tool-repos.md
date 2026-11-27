---
canonical: decisions:docs/plans/2026-11-27-topo3-tool-repos.md
phases: [1]
status: done
---
Part of [Move the tool repositories to greentopo 3.0.0](https://github.com/fredericrous/decisions/blob/main/docs/plans/2026-11-27-topo3-tool-repos.md)
(topo-spotter-rename t24).

## Code review

- aval: none — CI pin, re-vendored pack, regenerated hook and gate block, no code

## Implementation review
- approve-with-changes (opus, 65k, 52 s); fixed: the pack sha256 and source commit recorded below; low: Phase 1 tick with the Resolution; low: ADR text 'an greenspotter.toml' filed upstream.

Pack: sha256 `ef66e76480492ccd93dc6f042efa00142550d97666d8973f262ecb4b91c662e4`, from decisions `57b484bb50c0`, the same in all seven repositories.
