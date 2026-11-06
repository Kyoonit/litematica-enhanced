# DECISIONS — human decisions log + ADR index

## Human decisions (append; one line each; never edit past lines)
| Date | Phase | Decision | By | Reference |
|---|---|---|---|---|
| 2026-11-06 | P00 | Fork = `Kyoonit/litematica-enhanced` (https://github.com/Kyoonit/litematica-enhanced), already created on GitHub; the working clone is that fork (`origin`) | Kyoonit (owner) | P00 Step 0, `phases/P00/logs/git-remotes.txt` |
| 2026-11-06 | P00 | Working project name = "Litematica Enhanced — an unofficial Litematica fork" (working name only; the final name is decided at P19 after asking the maintainers) | Kyoonit (owner) | P00 Step 0 |
| 2026-11-06 | P00 | Contact/issue channel = the fork's GitHub issues (https://github.com/Kyoonit/litematica-enhanced/issues) | Kyoonit (owner) | P00 Step 0 |
| 2026-11-06 | P00 | Do **not** contact Sakura-Ryoko or masa now; no introduction draft is written in P00 (revisit before the first upstream PR, P06) | Kyoonit (owner) | P00 Step 0 |
| 2026-11-06 | P00 | Modification notice: one comment line `// Modified by Litematica Enhanced contributors (<year>); see NOTICE.md`, added to an upstream source file the first time the fork modifies it. Files that cannot hold comments (JSON) are recorded in the `NOTICE.md` table instead | Kyoonit (owner) | P00 Step 0, `NOTICE.md` |
| 2026-11-06 | P00 | Baseline = `sakura-ryoko/litematica@26.3` HEAD `64e74592f631cfa5b084bedb0eda5dac8a3b3cb8` (MC 26.3, mod 0.29.2-sakura.1); upstream default branch is still `26.3`, so no version question was needed | lead (per prompt rule; no human choice required) | `phases/P00/logs/upstream-state.txt` |
| 2026-11-06 | P00 | Mask the local Windows user name in committed logs (home-directory paths and `ls -l` owner columns → `<user>`), now and in every future log | Kyoonit (owner) | pre-audit AUD-P00-06 |
| 2026-11-06 | P00 | Commit identity for this repository = `Kyoonit <176595771+Kyoonit@users.noreply.github.com>` (repo-local git config); the P00 commits were re-authored before the first push, trees unchanged | Kyoonit (owner) | `phases/P00/logs/commit-rewrite-map.txt` |
| 2026-11-06 | P00 | Push `phase/P00-bootstrap` to `origin` to run the fork's CI (Step 8). The owner enabled Issues and Actions on the fork | Kyoonit (owner) | `phases/P00/logs/ci-fork-run.txt` |

## ADR index
| ADR | Title | Status (proposed/accepted/superseded) | Phase | Upstream cat. |
|---|---|---|---|---|
