# aval -> greentopo (ADR-0072, ADR-0074). GNU sed -E; run once over the
# tracked text files, minus CHANGELOG.md, docs/plans/, .adr/packs/,
# .claude/hooks/ and .claude/settings.json (regenerated, never edited).
# The rules run in order; each line is one rule of the plan
# docs/plans/2026-11-16-aval-becomes-greentopo.md.

# 0. the repository moved by transfer
s#fredericrous/aval\b#greenharness/greentopo#g
# 1. npm: the @greenharness scope, greengate's layout (ADR-0074)
s#@aval-adr/#@greenharness/greentopo-#g
s#\baval-adr\b#@greenharness/greentopo#g
# 2. MCP tool ids as Claude Code names them
s/mcp__aval__aval_/mcp__greentopo__greentopo_/g
s/mcp__aval__/mcp__greentopo__/g
# 3. MCP tool names
s/\baval_(resolve|relevant|rule|rules|keys|traits|show|heads|history|repos)\b/greentopo_\1/g
# 3b. identifiers where `_` defeats \b
s/\baval_core\b/greentopo_core/g
s/CARGO_BIN_EXE_aval\b/CARGO_BIN_EXE_greentopo/g
s/\baval_nope\b/greentopo_nope/g
s/\bpath_with_aval\b/path_with_greentopo/g
# 4. environment and constants (no AVAL occurs inside another word)
s/AVAL/GREENTOPO/g
# 8. the pack file
s/\baval\.pack\b/greentopo.pack/g
# 9. the bare name, except the stale names of other tools and relais's
#    integration key, which relais still reads as `aval`
/aval-fleet|aval-agent|^aval = "required"/!s/\baval\b/greentopo/g
# 9b. after a `\n` escape inside a string literal, where the `n` defeats \b
s/\\naval\b/\\ngreentopo/g
# 9c. the remaining `aval_` prefixes and `_aval_` infixes (test names, the
#     `aval_*` tool glob, the "aval_" prefix assertion)
s/\baval_/greentopo_/g
s/_aval_/_greentopo_/g
