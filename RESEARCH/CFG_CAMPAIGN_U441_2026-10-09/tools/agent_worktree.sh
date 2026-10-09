#!/usr/bin/env bash
# Isolated toolchain copy for one diagnosis agent (2026-10-09 campaign, PITFALLS F: agents work in isolated copies,
# the integrator re-measures). Usage: agent_worktree.sh NAME
# Creates work/agents/NAME as a git worktree of HEAD on branch agent/NAME, copies the untracked compiler binaries the
# pipeline needs (bin/ is gitignored) and builds it with build.bat. Prints the worktree path and its derecomp SHA-256.
set -euo pipefail
name="$1"
repo="$(cd "$(dirname "$0")/../../.." && pwd)"
wt="$repo/work/agents/$name"
if [ ! -d "$wt" ]; then
  git -C "$repo" worktree add -q -b "agent/$name" "$wt" HEAD
fi
mkdir -p "$wt/bin"
for f in luau-compile.exe luau.exe; do cp -n "$repo/bin/$f" "$wt/bin/$f"; done
[ -f "$repo/data/namebase_merged.tsv" ] && [ ! -f "$wt/data/namebase_merged.tsv" ] && cp "$repo/data/namebase_merged.tsv" "$wt/data/" || true
cmd //c "$(cygpath -w "$wt/build.bat")" > "$wt/build.log" 2>&1 || { tail -5 "$wt/build.log"; exit 1; }
echo "worktree $(cygpath -w "$wt")"
sha256sum "$wt/bin/derecomp.exe" | cut -c1-64
