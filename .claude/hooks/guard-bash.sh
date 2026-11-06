#!/usr/bin/env bash
# PreToolUse guard for the Bash and PowerShell tools (Litematica Enhanced).
# Receives the tool call as JSON on stdin. Exit code 2 blocks the call and
# returns the stderr message to Claude. Dependency-free on purpose (no jq),
# so it also works in Git Bash on Windows.
#
# Hardened in P00 after the audit (AUD-P00-01, -02, -05; owner decision in
# docs/enhanced/DECISIONS.md, 2026-11-06). Instead of matching regexes over the
# raw JSON, the hook extracts the command, removes quotes, splits it into simple
# commands and checks each git command on its parsed arguments.
# Test: bash tools/hooks/test-guard-bash.sh

payload="$(cat)"

block() {
  echo "BLOCKED by .claude/hooks/guard-bash.sh: $1. Ask the human owner if this is really needed." >&2
  exit 2
}

# ---------------------------------------------------------------------------
# 1. Extract tool_input.command (a JSON string) and undo the JSON escaping.
raw="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -n 1)"
[ -n "$raw" ] || raw="$payload"   # fail safe: inspect the whole payload
s="$raw"
s="${s//\\\\/$'\001'}"            # protect escaped backslashes
s="${s//\\\"/\"}"
s="${s//\\n/$'\n'}"
s="${s//\\r/}"
s="${s//\\t/ }"
s="${s//\\\//\/}"
s="${s//\\u0026/&}"
s="${s//\\u003e/>}"
s="${s//\\u003c/<}"
s="${s//\\u0027/\'}"
s="${s//$'\001'/\\}"

# 2. Normalise: drop quotes and backslash escapes (so "--hard" == --hard),
#    use forward slashes, then split into simple commands.
s="${s//[\"\'\`]/ }"
s="${s//\\/\/}"
segments="$(printf '%s\n' "$s" | tr ';&|(){}' '\n\n\n\n\n\n\n')"

PROTECTED_TAG_RE='^(refs/tags/)?(enhanced|baseline)/'
PROTECTED_BRANCH_RE='^(refs/heads/)?(enhanced/main|vendor/.+)$'
PROTECTED_REF_RE='^refs/(heads/(enhanced/main|vendor/)|tags/(enhanced|baseline)/)'
UPSTREAM_URL_RE='(github\.com[:/]+)(sakura-ryoko|maruohon)/'

is_short_cluster_with() {  # $1 = token, $2 = letters; true for -xyz clusters containing a letter
  [[ "$1" =~ ^-[A-Za-z0-9]+$ ]] && [[ "$1" =~ [$2] ]]
}

# Paths that a recursive deletion must never target.
dangerous_path() {
  local p="$1"
  p="${p#./}"
  case "$p" in
    ""|"/"|"."|"*"|"./"|".."|../*|"~"|"~/"*|'$HOME'*|'$env:USERPROFILE'*|/*) return 0 ;;
  esac
  [[ "$p" =~ ^[A-Za-z]: ]] && return 0
  [[ "$p" =~ (^|/)\.git(/|$) ]] && return 0
  [[ "$p" =~ (^|/)_dossier(/|$) ]] && return 0
  return 1
}

check_git() {  # $@ = tokens after "git"
  local gitdir="" sub="" t
  # Global options before the subcommand.
  while [ $# -gt 0 ]; do
    t="$1"
    case "$t" in
      -C) gitdir="$2"; shift 2; continue ;;
      -c) [[ "$2" == alias.* ]] && block "defining git aliases can hide blocked commands"; shift 2; continue ;;
      --git-dir|--work-tree|--namespace|--super-prefix|--config-env|--exec-path) shift 2; continue ;;
      -*) shift; continue ;;
    esac
    sub="$t"; shift; break
  done
  [ -n "$sub" ] || return 0
  local args=("$@") a positional=() prot=0
  for a in "${args[@]}"; do [[ "$a" != -* ]] && positional+=("$a"); done

  case "$sub" in
    push)
      local remote="" skip=0 i
      for ((i = 0; i < ${#args[@]}; i++)); do
        a="${args[$i]}"
        if [ "$skip" = 1 ]; then skip=0; continue; fi
        case "$a" in
          --force*|--f|--fo|--for|--forc) block "force-push is forbidden" ;;
          --mirror|--prune|--delete) block "deleting or mirroring remote refs is reserved for the human" ;;
          --repo=*) remote="${a#--repo=}" ;;
          --repo|-o|--push-option|--receive-pack|--exec) [ "$a" = --repo ] && remote="${args[$((i + 1))]}"; skip=1 ;;
          --*) ;;
          -*) is_short_cluster_with "$a" 'f' && block "force-push is forbidden"
              is_short_cluster_with "$a" 'd' && block "deleting remote refs is reserved for the human" ;;
          *)  if [ -z "$remote" ]; then remote="$a"
              else
                [[ "$a" == +* ]] && block "force-push (+refspec) is forbidden"
                [[ "$a" == :* ]] && block "deleting remote refs is reserved for the human"
              fi ;;
        esac
      done
      [[ "$remote" == upstream-* ]] && block "pushing to upstream-* remotes is forbidden"
      [[ "$remote" =~ $UPSTREAM_URL_RE ]] && block "pushing to an upstream repository is forbidden"
      ;;
    reset)
      for a in "${args[@]}"; do
        [[ "$a" =~ ^--h(a(r(d)?)?)?$ ]] && block "git reset --hard is reserved for the human (use git revert or a new branch)"
      done ;;
    clean)
      for a in "${args[@]}"; do
        is_short_cluster_with "$a" 'xX' && block "git clean -x/-X deletes ignored files such as _dossier/"
      done ;;
    tag)
      for a in "${positional[@]}"; do [[ "$a" =~ $PROTECTED_TAG_RE ]] && prot=1; done
      if [ "$prot" = 1 ]; then
        for a in "${args[@]}"; do
          case "$a" in --delete|--force) block "deleting or moving protected tags (enhanced/*, baseline/*) is forbidden" ;; esac
          is_short_cluster_with "$a" 'df' && block "deleting or moving protected tags (enhanced/*, baseline/*) is forbidden"
        done
      fi ;;
    branch)
      for a in "${positional[@]}"; do [[ "$a" =~ $PROTECTED_BRANCH_RE ]] && prot=1; done
      if [ "$prot" = 1 ]; then
        for a in "${args[@]}"; do
          case "$a" in --delete|--force|--move|--copy) block "deleting, moving or overwriting enhanced/main or vendor/* is forbidden" ;; esac
          is_short_cluster_with "$a" 'dDfmMC' && block "deleting, moving or overwriting enhanced/main or vendor/* is forbidden"
        done
      fi ;;
    update-ref)
      for a in "${positional[@]}"; do
        [[ "$a" =~ $PROTECTED_REF_RE ]] && block "update-ref on protected refs is forbidden"
      done ;;
    config)
      for a in "${positional[@]}"; do
        [[ "$a" == alias.* ]] && block "defining git aliases can hide blocked commands"
        [[ "$a" =~ ^remote\..*\.pushurl$ ]] && [ "${#positional[@]}" -ge 2 ] && block "changing a remote push URL is reserved for the human"
      done ;;
    remote)
      if [ "${positional[0]}" = set-url ]; then
        for a in "${args[@]}"; do [ "$a" = --push ] && block "changing a remote push URL is reserved for the human"; done
      fi
      if [ "${positional[0]}" = add ] && [[ "${positional[1]}" != upstream-* ]]; then
        for a in "${positional[@]}"; do [[ "$a" =~ $UPSTREAM_URL_RE ]] && block "upstream repositories must be added as upstream-* remotes"; done
      fi ;;
    add)
      for a in "${args[@]}"; do [ "$a" = --renormalize ] && block "git add --renormalize causes whole-file churn"; done ;;
    commit)
      local branch
      branch="$(git -C "${gitdir:-${CLAUDE_PROJECT_DIR:-.}}" rev-parse --abbrev-ref HEAD 2>/dev/null)"
      case "$branch" in
        vendor/*) block "vendor/* branches mirror upstream and must never receive commits" ;;
      esac ;;
  esac
}

check_segment() {  # $@ = tokens of one simple command
  # Skip wrappers (env, sudo, timeout 60, bash -c, pwsh -Command, ...) and VAR=value.
  while [ $# -gt 0 ]; do
    case "${1,,}" in
      env|sudo|command|exec|time|nice|nohup|builtin|eval|xargs|bash|sh|zsh|pwsh|pwsh.exe|powershell|powershell.exe|cmd|cmd.exe|start-process|invoke-expression|iex|\&)
        shift
        while [ $# -gt 0 ] && { [[ "$1" == -* ]] || [[ "$1" == /[cCkK] ]] || [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; }; do shift; done ;;
      timeout) shift; while [ $# -gt 0 ] && [[ "$1" == -* ]]; do shift; done; shift ;;
      *=*) [[ "$1" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && shift || break ;;
      *) break ;;
    esac
  done
  [ $# -gt 0 ] || return 0
  local cmd="${1,,}"; shift
  cmd="${cmd##*/}"
  case "$cmd" in
    git|git.exe) check_git "$@" ;;
    rm|remove-item|ri|del|erase|rd|rmdir)
      local rec=0 a
      for a in "$@"; do
        case "${a,,}" in
          -r|-rf|-fr|--recursive|-rec*|/s) rec=1 ;;
        esac
        [ "${#a}" -le 5 ] && is_short_cluster_with "$a" 'rR' && rec=1
      done
      if [ "$rec" = 1 ]; then
        for a in "$@"; do
          [[ "$a" == -* ]] && continue
          [[ "$a" == /[sSqQ] ]] && continue
          dangerous_path "$a" && block "recursive deletion of '$a' is forbidden (only build outputs inside the project may be deleted)"
        done
      fi ;;
  esac
}

# 3. LICENSE.txt must never be modified (REFERENCE §7); reading it is fine.
check_license() {  # $1 = one segment as text
  local seg="$1" low
  case "$seg" in *LICENSE.txt*) ;; *) return 0 ;; esac
  low="${seg,,}"
  [[ "$seg" =~ \>[[:space:]]*[^[:space:]]*LICENSE\.txt ]] && block "LICENSE.txt must never be modified"
  [[ "$low" =~ (^|[[:space:]/])(rm|mv|cp|tee|truncate|dd|set-content|add-content|clear-content|out-file|remove-item|move-item|copy-item|rename-item|new-item|ri|mi|cpi|rni|ni|sc|ac|clc|del|erase|move|copy|ren)([[:space:]]|$) ]] && block "LICENSE.txt must never be modified"
  [[ "$low" =~ (^|[[:space:]/])(sed|perl)[[:space:]].*-i ]] && block "LICENSE.txt must never be modified"
  return 0
}

while IFS= read -r line; do
  [ -n "${line//[[:space:]]/}" ] || continue
  check_license "$line"
  read -r -a tokens <<<"$line"
  check_segment "${tokens[@]}"
done <<<"$segments"

exit 0
