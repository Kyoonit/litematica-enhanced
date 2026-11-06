#!/usr/bin/env bash
# Test harness for .claude/hooks/guard-bash.sh (Litematica Enhanced, P00).
# Feeds PreToolUse-style JSON payloads to the hook and checks its exit code:
# 2 = blocked (dangerous), 0 = allowed. Dependency-free (Git Bash on Windows works).
#
# Usage: bash tools/hooks/test-guard-bash.sh            (from the repository root)
# Exit code: 0 if every case matches its expected code, 1 otherwise.

set -u
repo="$(git rev-parse --show-toplevel)"
hook="$repo/.claude/hooks/guard-bash.sh"
fail=0
count=0

# run_case <expected exit> <project dir for the hook> <description> <command string>
run_case() {
  local expected="$1" project_dir="$2" desc="$3" cmd="$4"
  local payload actual
  payload="{\"session_id\":\"test\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"$cmd\",\"description\":\"$desc\"}}"
  CLAUDE_PROJECT_DIR="$project_dir" bash "$hook" <<<"$payload" >/dev/null 2>&1
  actual=$?
  count=$((count + 1))
  if [ "$actual" = "$expected" ]; then
    printf 'PASS  expected=%s actual=%s  %-38s | %s\n' "$expected" "$actual" "$desc" "$cmd"
  else
    printf 'FAIL  expected=%s actual=%s  %-38s | %s\n' "$expected" "$actual" "$desc" "$cmd"
    fail=1
  fi
}

echo "# guard-bash.sh hook test — $(date -u +%FT%TZ)"
echo "# hook: .claude/hooks/guard-bash.sh @ $(git -C "$repo" rev-parse --short HEAD) (branch $(git -C "$repo" rev-parse --abbrev-ref HEAD))"

# Dangerous commands (expected 2)
run_case 2 "$repo" "force push (--force)"            "git push --force origin phase/P00-bootstrap"
run_case 2 "$repo" "force push (-f)"                 "git push -f origin phase/P00-bootstrap"
run_case 2 "$repo" "force push (--force-with-lease)" "git push --force-with-lease origin enhanced/main"
run_case 2 "$repo" "push to upstream-sakura"         "git push upstream-sakura phase/P00-bootstrap"
run_case 2 "$repo" "push to upstream-masa"           "git push upstream-masa HEAD:ornithe/1.12.2"
run_case 2 "$repo" "reset --hard"                    "git reset --hard HEAD~1"
run_case 2 "$repo" "tag deletion enhanced/x"         "git tag -d enhanced/x"
run_case 2 "$repo" "tag deletion baseline/*"         "git tag --delete baseline/sakura-26.3-0.29.2-sakura.1"
run_case 2 "$repo" "branch -D vendor/*"              "git branch -D vendor/sakura-26.3"
run_case 2 "$repo" "rm -rf .git"                     "rm -rf .git"
run_case 2 "$repo" "add --renormalize"               "git add --renormalize ."

# Normal commands (expected 0)
run_case 0 "$repo" "normal build"                    "./gradlew build"
run_case 0 "$repo" "normal commit on phase branch"   "git commit -m '[P00] docs: add phase plan'"
run_case 0 "$repo" "normal push to origin"           "git push origin phase/P00-bootstrap"
run_case 0 "$repo" "normal status"                   "git status --short"
run_case 0 "$repo" "rm -rf build outputs"            "rm -rf build"

# Commit while the project dir is on a vendor/* branch (expected 2).
# Uses a temporary worktree checked out on vendor/sakura-<mc>; nothing is committed.
vendor_branch="$(git -C "$repo" for-each-ref --format='%(refname:short)' 'refs/heads/vendor/*' | head -n 1)"
if [ -n "$vendor_branch" ]; then
  tmp_wt="$(mktemp -d)/vendor-wt"
  if git -C "$repo" worktree add --quiet "$tmp_wt" "$vendor_branch" 2>/dev/null; then
    run_case 2 "$tmp_wt" "commit on $vendor_branch"  "git commit -m 'should be blocked'"
    git -C "$repo" worktree remove --force "$tmp_wt"
  else
    echo "SKIP  could not create a worktree on $vendor_branch (is it checked out elsewhere?)"
  fi
fi

echo "# cases: $count, result: $([ "$fail" = 0 ] && echo ALL PASS || echo FAILURES)"
exit "$fail"
