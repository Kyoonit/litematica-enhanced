# STATE — read me first (≤ 60 lines, overwrite, don't append)

- **Current phase:** P00 — Bootstrap, fork & baseline preservation — status: in-audit
- **Branch:** `phase/P00-bootstrap` · base tag: `baseline/sakura-26.3-0.29.2-sakura.1` (= `vendor/sakura-26.3` = `64e74592`)
- **Last verified commit:** `981b0593` (pre-rewrite id `d5820ff3`, see `phases/P00/logs/commit-rewrite-map.txt`) — verified by: `./gradlew build` green in a fresh worktree (no tests exist yet) on 2026-11-06 (`phases/P00/logs/build-head.log`). Later P00 commits change only `docs/enhanced/**`.
- **MC / loader / MaLiLib:** 26.3 / Fabric Loader 0.19.5 / 0.30.2 (update when ported)

## Next action (one line)
Run `prompts/phase-00-bootstrap-audit.md` in a new session with BASE=`baseline/sakura-26.3-0.29.2-sakura.1` and HEAD=`phase/P00-bootstrap`.

## Blockers / waiting on human
- RISK-08 — guardrail gaps (hook patterns; PowerShell tool not covered; the `LICENSE.txt` deny rule is ignored): harden the kit or accept the risk — since 2026-11-06
- RISK-01 — keep, remove or replace masa's `twitter`/`discord` entries in `fabric.mod.json` (candidate for the P03 identity ADR) — since 2026-11-06

## Open findings carried forward
- All 33 STRATEGY IDs, status `to-verify (P02)`: UX-01..08, PERF-01..09, ARCH-01..07, REL-01..08, SEC-01 (`registers/problems.md`)
- RISK-01..04 and RISK-08 open, RISK-05..07 closed (`registers/risks.md`); RISK-02 (non-reproducible jars) → P01; pre-audit findings AUD-P00-01..10 (`phases/P00/pre-audit.md`, response in `report.md`)

## Feature flags currently experimental
- none

## Notes for the next session (≤ 10 lines)
- Jar bytes differ between two builds of the same commit (RISK-02): compare jar contents, not jar hashes (`knowledge/build.md`, `phases/P00/logs/jar-content-compare.txt`).
- Windows: `*.java` is CRLF in the working tree; in Git Bash use `MSYS_NO_PATHCONV=1` for `git show <ref>:.path`. curl cannot reach `masa.dy.fi` here (schannel); Gradle/Java can (`logs/repo-reachability.txt`).
- Python is not installed; tooling is Java (`java tools/inventory/Inventory.java`) and Node for JSON checks.
- The repository is public: before committing a log, replace the Windows user name in home-directory paths (`C:/Users/<name>/…`, either slash) and `ls -l` owner columns with `<user>` (human decision, AUD-P00-06).
- The hook test is `bash tools/hooks/test-guard-bash.sh` (17 cases).
- Project agents in `.claude/agents/` load only in a session started after P00; P00 ran them as briefed general-purpose subagents.
