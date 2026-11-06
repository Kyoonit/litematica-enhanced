# STATE — read me first (≤ 60 lines, overwrite, don't append)

- **Current phase:** P00 — Bootstrap, fork & baseline preservation — status: in-audit (delta)
- **Branch:** `phase/P00-bootstrap` · base tag: `baseline/sakura-26.3-0.29.2-sakura.1` (= `vendor/sakura-26.3` = `64e74592`)
- **Last verified commit:** `ffd672fa` (earlier ids `981b0593`, `d5820ff3`; history rewritten twice, see `phases/P00/logs/commit-rewrite-map.txt`) — verified by: `./gradlew build` green in a fresh worktree (no tests exist yet) on 2026-11-06 (`phases/P00/logs/build-head.log`). Later P00 commits change only `docs/enhanced/**`, `.claude/**` and `tools/hooks/**`; corrections round 1 re-ran the build (`phases/P00/logs/corrections-1/`).
- **MC / loader / MaLiLib:** 26.3 / Fabric Loader 0.19.5 / 0.30.2 (update when ported)

## Next action (one line)
Delta re-audit of corrections round 1 in a new session: `prompts/correction-template.md` (delta section) with AUDIT_FILE=`phases/P00/audit.md`, BASE_DELTA=`c38f7ef2`, HEAD=`phase/P00-bootstrap` (after the owner's force-push).

## Blockers / waiting on human
- AUD-P00-03 — the rewritten branch must replace the one on `origin`; force-push is blocked for Claude, so the owner runs it (command in `phases/P00/corrections.md`) — since 2026-11-06
- RISK-01 — keep, remove or replace masa's `twitter`/`discord` entries in `fabric.mod.json` (candidate for the P03 identity ADR) — since 2026-11-06

## Open findings carried forward
- All 33 STRATEGY IDs, status `to-verify (P02)`: UX-01..08, PERF-01..09, ARCH-01..07, REL-01..08, SEC-01 (`registers/problems.md`)
- RISK-01..04 open, RISK-05..08 closed (`registers/risks.md`); RISK-02 (non-reproducible jars) → P01; external audit AUD-P00-01..06 (`phases/P00/audit.md`), response in `phases/P00/corrections.md`

## Feature flags currently experimental
- none

## Notes for the next session (≤ 10 lines)
- Jar bytes differ between two builds of the same commit (RISK-02): compare jar contents, not jar hashes (`knowledge/build.md`, `phases/P00/logs/jar-content-compare.txt`).
- Windows: `*.java` is CRLF in the working tree; in Git Bash use `MSYS_NO_PATHCONV=1` for `git show <ref>:.path`. curl cannot reach `masa.dy.fi` here (schannel); Gradle/Java can (`logs/repo-reachability.txt`).
- Python is not installed; tooling is Java (`java tools/inventory/Inventory.java`) and Node for JSON checks.
- The repository is public: before committing a log, replace the Windows user name in home-directory paths (`C:/Users/<name>/…`, either slash) and `ls -l` owner columns with `<user>` — in every commit, not only at HEAD (human decision, AUD-P00-03).
- The hook test is `bash tools/hooks/test-guard-bash.sh` (91 cases, Bash and PowerShell payloads). The hook guards both tools.
- Project agents in `.claude/agents/` load only in a session started after P00; P00 ran them as briefed general-purpose subagents.
