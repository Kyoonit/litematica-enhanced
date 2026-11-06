#!/usr/bin/env bash
# Test harness for .claude/hooks/guard-bash.sh (Litematica Enhanced, P00).
# Feeds PreToolUse-style JSON payloads to the hook and checks its exit code:
# 2 = blocked (dangerous), 0 = allowed. Dependency-free (Git Bash on Windows works).
# Covers the shipped cases, the auditor's probes (audit-logs/hook-probe-auditor.log,
# AUD-P00-01/-02/-05), the PowerShell tool and the new rules.
#
# Usage: bash tools/hooks/test-guard-bash.sh            (from the repository root)
# Exit code: 0 if every case matches its expected code, 1 otherwise.

set -u
repo="$(git rev-parse --show-toplevel)"
hook="$repo/.claude/hooks/guard-bash.sh"
fail=0
count=0
tool=Bash

json_escape() {  # backslash and double quote, as a JSON encoder would
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

# run_case <expected exit> <project dir for the hook> <description> <command string>
run_case() {
  local expected="$1" project_dir="$2" desc="$3" cmd="$4"
  local payload actual
  payload="{\"session_id\":\"test\",\"hook_event_name\":\"PreToolUse\",\"tool_name\":\"$tool\",\"tool_input\":{\"command\":\"$(json_escape "$cmd")\",\"description\":\"$(json_escape "$desc")\"}}"
  CLAUDE_PROJECT_DIR="$project_dir" bash "$hook" <<<"$payload" >/dev/null 2>&1
  actual=$?
  count=$((count + 1))
  if [ "$actual" = "$expected" ]; then
    printf 'PASS  %-10s expected=%s actual=%s  %-34s | %s\n' "$tool" "$expected" "$actual" "$desc" "$cmd"
  else
    printf 'FAIL  %-10s expected=%s actual=%s  %-34s | %s\n' "$tool" "$expected" "$actual" "$desc" "$cmd"
    fail=1
  fi
}

echo "# guard-bash.sh hook test — $(date -u +%FT%TZ)"
echo "# hook: .claude/hooks/guard-bash.sh (blob $(git -C "$repo" hash-object "$hook")) @ $(git -C "$repo" rev-parse --short HEAD) (branch $(git -C "$repo" rev-parse --abbrev-ref HEAD))"

echo "## Shipped cases — dangerous (expected 2)"
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

echo "## Auditor probes — bypasses (expected 2)"
run_case 2 "$repo" "+refspec"                        "git push origin +main"
run_case 2 "$repo" "--force-with-lease, no args"     "git push --force-with-lease"
run_case 2 "$repo" "-C before reset --hard"          "git -C . reset --hard"
run_case 2 "$repo" "+HEAD:refspec"                   "git push origin +HEAD:enhanced/main"
run_case 2 "$repo" "-fu cluster"                     "git push -fu origin main"
run_case 2 "$repo" "--force after refspec"           "git push origin main --force"
run_case 2 "$repo" "-f after refspec"                "git push origin main -f"
run_case 2 "$repo" "quoted remote"                   "git push \"origin\" --force"
run_case 2 "$repo" "quoted --hard"                   "git reset \"--hard\" HEAD~1"
run_case 2 "$repo" "--forc prefix"                   "git push --forc origin main"
run_case 2 "$repo" "--har prefix"                    "git reset --har HEAD~1"
run_case 2 "$repo" "push to sakura URL"              "git push https://github.com/sakura-ryoko/litematica.git HEAD:26.3"
run_case 2 "$repo" "branch --delete --force"         "git branch --delete --force enhanced/main"
run_case 2 "$repo" "update-ref -d protected"         "git update-ref -d refs/heads/enhanced/main"
run_case 2 "$repo" "tag -f baseline"                 "git tag -f baseline/sakura-26.3-0.29.2-sakura.1 HEAD"
run_case 2 "$repo" ":refspec deletes tag"            "git push origin :refs/tags/baseline/sakura-26.3-0.29.2-sakura.1"
run_case 2 "$repo" "compound cd && force"            "cd /c/repo && git push --force origin x"

echo "## New rules (expected 2)"
run_case 2 "$repo" "single-quoted --force"           "git push origin 'main' '--force'"
run_case 2 "$repo" "--mirror"                        "git push --mirror origin"
run_case 2 "$repo" "--delete branch"                 "git push origin --delete phase/P00-bootstrap"
run_case 2 "$repo" "--prune"                         "git push --prune origin refs/heads/*:refs/heads/*"
run_case 2 "$repo" "--repo=upstream-masa"            "git push --repo=upstream-masa main"
run_case 2 "$repo" "env wrapper"                     "env GIT_TRACE=1 git push -f origin main"
run_case 2 "$repo" "bash -c wrapper"                 "bash -c 'git reset --hard'"
run_case 2 "$repo" "subshell"                        "(git push --force origin main)"
run_case 2 "$repo" "newline-separated"               $'git status\ngit push -f origin main'
run_case 2 "$repo" "-c alias definition"             "git -c alias.p=push p --force"
run_case 2 "$repo" "config alias"                    "git config alias.yolo 'push --force'"
run_case 2 "$repo" "set pushurl"                     "git config remote.upstream-masa.pushurl https://github.com/maruohon/litematica.git"
run_case 2 "$repo" "remote set-url --push"           "git remote set-url --push upstream-sakura https://github.com/sakura-ryoko/litematica.git"
run_case 2 "$repo" "clean -fdx"                      "git clean -fdx"
run_case 2 "$repo" "clean -X"                        "git clean -fX"
run_case 2 "$repo" "branch -M onto enhanced/main"    "git branch -M enhanced/main"
run_case 2 "$repo" "branch -f vendor"                "git branch -f vendor/sakura-26.3 HEAD"
run_case 2 "$repo" "update-ref baseline tag"         "git update-ref refs/tags/baseline/x HEAD"
run_case 2 "$repo" "rm -rf _dossier"                 "rm -rf _dossier"
run_case 2 "$repo" "rm -rf ~"                        "rm -rf ~"
run_case 2 "$repo" "rm -r .."                        "rm -r .."
run_case 2 "$repo" "rm -rf *"                        "rm -rf *"
run_case 2 "$repo" "rm -rf absolute"                 "rm -rf /c/Users"
run_case 2 "$repo" "redirect into LICENSE"           "echo x > LICENSE.txt"
run_case 2 "$repo" "sed -i LICENSE"                  "sed -i s/LGPL/MIT/ LICENSE.txt"
run_case 2 "$repo" "rm LICENSE"                      "rm LICENSE.txt"
run_case 2 "$repo" "mv over LICENSE"                 "mv other.txt LICENSE.txt"
run_case 2 "$repo" "tee LICENSE"                     "echo x | tee LICENSE.txt"
run_case 2 "$repo" "JSON-escaped backslash path"     "rm -rf C:\\Users"

echo "## Normal commands (expected 0)"
run_case 0 "$repo" "normal build"                    "./gradlew build"
run_case 0 "$repo" "normal commit on phase branch"   "git commit -m '[P00] docs: add phase plan'"
run_case 0 "$repo" "normal push to origin"           "git push origin phase/P00-bootstrap"
run_case 0 "$repo" "push -u to origin"               "git push -u origin phase/P00-bootstrap"
run_case 0 "$repo" "push upstream-pr branch"         "git push origin upstream-pr/fix-x"
run_case 0 "$repo" "normal status"                   "git status --short"
run_case 0 "$repo" "rm -rf build outputs"            "rm -rf build"
run_case 0 "$repo" "rm -rf run/logs"                 "rm -rf run/logs"
run_case 0 "$repo" "read pushurl"                    "git config --get-all remote.upstream-sakura.pushurl"
run_case 0 "$repo" "log range"                       "git log --oneline origin/main..HEAD"
run_case 0 "$repo" "compound read-only (AUD-P00-05)" "git config --get-all remote.upstream-sakura.pushurl; git remote -v | grep upstream-masa; git reset --soft HEAD"
run_case 0 "$repo" "reset --soft"                    "git reset --soft HEAD~1"
run_case 0 "$repo" "create pass tag"                 "git tag enhanced/p00-pass"
run_case 0 "$repo" "list tags"                       "git tag -l baseline/*"
run_case 0 "$repo" "new phase branch"                "git branch phase/P01-harness enhanced/main"
run_case 0 "$repo" "delete phase branch"             "git branch -d phase/old"
run_case 0 "$repo" "clean -n"                        "git clean -nd"
run_case 0 "$repo" "grep for --force text"           "grep -n 'force' docs/enhanced/REFERENCE.md"
run_case 0 "$repo" "read LICENSE"                    "head -n 5 LICENSE.txt"
run_case 0 "$repo" "diff LICENSE"                    "git diff --stat -- LICENSE.txt"
run_case 0 "$repo" "remote add upstream-*"           "git remote add upstream-x https://github.com/sakura-ryoko/litematica.git"

tool=PowerShell
echo "## PowerShell tool (AUD-P00-02)"
run_case 2 "$repo" "PS force push"                   "git push --force origin main"
run_case 2 "$repo" "PS reset --hard; chained"        "git status; if (\$?) { git reset --hard HEAD~1 }"
run_case 2 "$repo" "PS Remove-Item -Recurse .git"    "Remove-Item -Recurse -Force .git"
run_case 2 "$repo" "PS Remove-Item drive path"       "Remove-Item -Recurse C:\\Users\\x"
run_case 2 "$repo" "PS Set-Content LICENSE"          "Set-Content -Path LICENSE.txt -Value x"
run_case 2 "$repo" "PS Out-File LICENSE"             "'x' | Out-File LICENSE.txt"
run_case 2 "$repo" "PS & git call"                   "& git push upstream-masa main"
run_case 0 "$repo" "PS build"                        ".\\gradlew.bat build"
run_case 0 "$repo" "PS Remove-Item build"            "Remove-Item -Recurse -Force build"
run_case 0 "$repo" "PS read LICENSE"                 "Get-Content LICENSE.txt -TotalCount 5"
run_case 0 "$repo" "PS push to origin"               "git push origin phase/P00-bootstrap"
tool=Bash

# Commit while the project dir is on a vendor/* branch (expected 2).
# Uses a temporary worktree checked out on vendor/sakura-<mc>; nothing is committed.
echo "## Vendor branch commit (expected 2)"
vendor_branch="$(git -C "$repo" for-each-ref --format='%(refname:short)' 'refs/heads/vendor/*' | head -n 1)"
if [ -n "$vendor_branch" ]; then
  tmp_wt="$(mktemp -d)/vendor-wt"
  if git -C "$repo" worktree add --quiet "$tmp_wt" "$vendor_branch" 2>/dev/null; then
    run_case 2 "$tmp_wt" "commit on $vendor_branch"  "git commit -m 'should be blocked'"
    run_case 2 "$repo"   "commit via -C on vendor wt" "git -C $tmp_wt commit -m 'should be blocked'"
    git -C "$repo" worktree remove --force "$tmp_wt"
  else
    echo "SKIP  could not create a worktree on $vendor_branch (is it checked out elsewhere?)"
  fi
fi

echo "# cases: $count, result: $([ "$fail" = 0 ] && echo ALL PASS || echo FAILURES)"
exit "$fail"
