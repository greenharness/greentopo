# Fix the "an greentopo" article: full reviews

## Round 1 (body cb8144ce13db, all opus)

- backend, approve-with-changes (34k, 47 s): #1 medium piloted grep `^# A greentopo` misses the mid-line comment (accepted); #2 medium Phase 2 needs the Linux release asset first (duplicate of platform#1); #3 medium Non-goal reason wrong, the branch binary is 3.0.1 (accepted).
- lang:rust, approve-with-changes (37k, 49 s): #1 medium regression test on the installed script (accepted); #2 medium diff of the piloted hook against the 3.0.0 hook, 4 lines (accepted, merged by hand into backend#1's row); #3 low both Cargo.toml version lines (accepted).
- platform, approve-with-changes (31k, 38 s): #1 high Phase 2 waits for the release workflow and the x86_64 Linux tarball (accepted); #2 low rollback reverts the whole PR (accepted).
- tui, approve-with-changes (31k, 43 s): #1 high grep anchor (duplicate of backend#1); #2 high `\`` inside code spans, use `\x60` (accepted); #3 high pipe in a table cell, use two `-e` patterns (accepted).
- unix, approve-with-changes (29k, 46 s): #1 medium grep anchor (duplicate of backend#1); #2 low escape the pipe as `\|` (rejected: copied raw it is a literal pipe in PCRE; tui#3 applied instead).

## Round 2 (body a6726542736c)

- backend, approve-with-changes (40k, 19 s): all resolved; low: the aval Code review reason should name the new test (carried into implementation).
- lang:rust, approve (42k, 16 s): all resolved.
- platform, approve (35k, 17 s): all resolved.
- tui, approve-with-changes (38k, 20 s): all resolved; medium: a backtick in the Phase 1 test wording breaks the code spans that follow (carried into implementation).
- unix, approve (33k, 14 s): all resolved.

## Codex final review (gpt, high effort)

- rework: #1 high decisions' `greentopo.pack` records `greentopo: "3.0.0"`, `pack --check` compares it, so Phase 2 must run `pack --write` with 3.0.1 (verified in packfile.rs and pack.rs, accepted); #2 medium the new test's negative needles would make the `crates` census grep non-empty; write them as escaped literals (carried into implementation).

## Backend re-run after Codex (body 389f8a27baac)

- backend, approve-with-changes (51k, 33 s): Codex fix correct; vendoring repositories read `CurrentMoved`, not behind (add.rs:583). Carried: the Code review reasons and the Picture omit the test and the pack; the rollback note omits the pack.
