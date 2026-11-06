#!/usr/bin/env bash
# PreToolUse guard for the Bash tool (Litematica Enhanced).
# Receives the tool call as JSON on stdin. Exit code 2 blocks the call and
# returns the stderr message to Claude. Dependency-free on purpose (no jq),
# so it also works in Git Bash on Windows.

payload="$(cat)"

block() {
  echo "BLOCKED by .claude/hooks/guard-bash.sh: $1. Ask the human owner if this is really needed." >&2
  exit 2
}

# 1. Force pushes of any kind.
if printf '%s' "$payload" | grep -Eq 'git[^"]*push[^"]*(--force|-f( |")|--force-with-lease|\+refs/)'; then
  block "force-push is forbidden"
fi

# 2. Pushes to upstream remotes (fetch-only by policy).
if printf '%s' "$payload" | grep -Eq 'git[^"]*push[^"]*upstream-'; then
  block "pushing to upstream-* remotes is forbidden"
fi

# 3. Destructive history operations.
if printf '%s' "$payload" | grep -Eq 'git[^"]*reset[^"]*--hard'; then
  block "git reset --hard is reserved for the human (use git revert or a new branch)"
fi
if printf '%s' "$payload" | grep -Eq 'git[^"]*(tag (-d|--delete)|push[^"]*:refs/tags/)[^"]*(enhanced/|baseline/)'; then
  block "deleting protected tags (enhanced/*, baseline/*) is forbidden"
fi
if printf '%s' "$payload" | grep -Eq 'git[^"]*branch[^"]*-D[^"]*(enhanced/main|vendor/)'; then
  block "deleting enhanced/main or vendor/* branches is forbidden"
fi
# 4. Committing on the vendor mirror branch.
if printf '%s' "$payload" | grep -Eq '"command"[^}]*git[^"]*commit'; then
  current_branch="$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  case "$current_branch" in
    vendor/*) block "vendor/* branches mirror upstream and must never receive commits" ;;
  esac
fi

# 5. Dangerous deletions outside build outputs.
if printf '%s' "$payload" | grep -Eq 'rm -[a-zA-Z]*r[a-zA-Z]* +(/|~|\.\.|\$HOME|\.git( |"|/))'; then
  block "recursive deletion outside the project build directories is forbidden"
fi

# 6. Line-ending renormalisation causes whole-repo churn.
if printf '%s' "$payload" | grep -Eq 'git[^"]*add[^"]*--renormalize'; then
  block "git add --renormalize causes whole-file churn"
fi

exit 0
