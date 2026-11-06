# P00 — Corrections round 1

- **AUDIT_FILE:** `docs/enhanced/phases/P00/audit.md` (external audit, verdict FAIL; commit `a240f1bf` on branch `audit/P00`, based on the pre-rewrite `d5e52747`; copied onto the phase branch as `338b6929`)
- **FINDINGS:** AUD-P00-01..06 (all)
- **EXTRA_NOTES (owner, 2026-11-06):** harden the hook ("Le renforcer"); rewrite the history and replace the remote branch ("Réécrire et remplacer")
- **BASE_DELTA:** `c38f7ef2` (HEAD after the history rewrite for AUD-P00-03, before the other fixes)

## ALLOWED_PATHS
- `.claude/hooks/guard-bash.sh`, `.claude/settings.json`, `tools/hooks/test-guard-bash.sh` (AUD-P00-01, -02, -05)
- `tools/inventory/Inventory.java` (AUD-P00-06)
- History of `docs/enhanced/phases/P00/**` (AUD-P00-03; rewritten blobs only)
- Tracking docs: `docs/enhanced/phases/P00/*`, `docs/enhanced/STATE.md`, `docs/enhanced/DECISIONS.md`, `docs/enhanced/registers/risks.md`

## Triage
| Finding | Severity | Restated problem | Reproduction (test/check) | Root cause | Planned fix | Files | Status |
|---|---|---|---|---|---|---|---|
| AUD-P00-01 | MAJOR | The guard hook lets destructive git forms through (`+refspec`, `-fu`, quoted options, `--forc`/`--har` prefixes, upstream URLs, `branch --delete --force`, `update-ref -d`, `tag -f`) | Auditor: 11/20 mismatches (`audit-logs/hook-probe-auditor.log`). Round-1 harness on the old hook: 35/91 fail (`logs/corrections-1/hook-test-before-fix.log`) | Regexes over the raw JSON payload, with fixed option spellings and positions | Parse the command: JSON-unescape, strip quotes, split on separators, skip wrappers and git global options, check each subcommand on its arguments; add rules for `--mirror`, `--prune`, `--delete`, `:refspec`, aliases, push URL changes, `clean -x/-X`, branch moves | `.claude/hooks/guard-bash.sh`, `tools/hooks/test-guard-bash.sh` | fixed (`3c76b6e9`) |
| AUD-P00-02 | MINOR | The PowerShell tool is not guarded; the `Write(./LICENSE.txt)` deny rule is ignored | `settings-json-check.txt`, `agents-cli-check.txt` | Matcher `Bash` only; Claude Code applies `Edit(...)` rules to file edits | Matcher `Bash\|PowerShell`, `PowerShell(...)` deny rules, hook rules for PowerShell deletion and LICENSE writes, ignored rule removed | `.claude/settings.json`, hook, harness | fixed (`3c76b6e9`) |
| AUD-P00-03 | MINOR | The owner's Windows user name is still in 4 pushed commits | `privacy-scan.txt` | The first masking (`6826bbdc`) changed HEAD only | `git filter-branch --index-filter` over `baseline..phase/P00-bootstrap` with the same masking rules; final tree unchanged; the owner force-pushes | history; `logs/commit-rewrite-map.txt` | fixed locally (0 occurrences in `git log -p`); **force-push pending (owner)** |
| AUD-P00-04 | MINOR | The rollback plan says the branch was never pushed | `audit-logs/git-state.txt` (`ls-remote origin`) | Text written before the push, not updated | Rewrite the rollback plan | `report.md` | fixed |
| AUD-P00-05 | NOTE | A read-only compound command was blocked | harness case "compound read-only" failed on the old hook (`hook-test-before-fix.log`) | Patterns spanned `;` and `&&` | Per-segment checks (same fix as -01) | hook | fixed (`3c76b6e9`) |
| AUD-P00-06 | NOTE | Inventory write mode leaves `features.md` as modified (LF vs CRLF) | `logs/corrections-1/inventory-eol.txt` (before: `M`, 0 content lines changed) | `Files.writeString` with LF in a `core.autocrlf=true` checkout | Write back with the line ending the file already uses | `tools/inventory/Inventory.java` | fixed (`89e84ad6`) |

## Verification
- Hook harness: 91 cases, all pass (`logs/hook-test-hardened.log`); the same cases on the old hook: 35 fail (`logs/corrections-1/hook-test-before-fix.log`).
- `./gradlew clean build test --no-daemon` in a fresh detached worktree of `3c76b6e9`: BUILD SUCCESSFUL, 14 s (`logs/corrections-1/build.log`, `jars.sha256`). No test sources exist yet. The round changes no file that goes into the jar; jar bytes are not reproducible (RISK-02).
- Inventory: write mode twice, `git status` clean (`logs/corrections-1/inventory-eol.txt`).
- History: 20 commits rewritten, final tree `3c321430` unchanged, 0 occurrences of the user name (`logs/commit-rewrite-map.txt`, second section).

## Human actions
1. Replace the remote branch (the hook blocks force-push for Claude, by design):
   `git push --force-with-lease=phase/P00-bootstrap:d5e5274739044a812c8e7a8b408a2ae4d623d608 origin phase/P00-bootstrap`
   GitHub may keep the old commits reachable by direct link (cached views, forks); only GitHub support can purge them.
2. Then run the delta re-audit in a new session (below).

## Delta re-audit instruction
Run the delta section of `docs/enhanced/prompts/correction-template.md` in a new session, in a detached worktree `../audit-P00-delta-1`, with AUDIT_FILE=`docs/enhanced/phases/P00/audit.md`, BASE_DELTA=`c38f7ef2`, HEAD=`phase/P00-bootstrap`. Note: AUD-P00-03 was fixed by rewriting `baseline..c38f7ef2` itself; check it over the whole range, not only the delta.
