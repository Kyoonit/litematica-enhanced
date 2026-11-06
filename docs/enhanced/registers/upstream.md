# Upstream register

## Patch inventory (upstream files modified by the fork)
| Upstream file | Reason | Lines changed (approx.) | Seam pattern | Since phase |
|---|---|---|---|---|
| `src/main/resources/fabric.mod.json` | Identity: `contact.homepage/issues/sources` → fork URLs, description + " (unofficial fork)" | 4 | in-place edit (JSON: notice recorded in `NOTICE.md`) | P00 |
| `.gitignore` | Ignore `.claude/worktrees/` and `_dossier/`; un-ignore `docs/enhanced/phases/*/logs/` (upstream ignores every `logs/`) | 5 added | append-only block | P00 |

## PR candidates and PRs
| Topic | Category | Branch | Target repo/branch | Status (draft/ready/sent/merged/declined) | Link | Notes |
|---|---|---|---|---|---|---|

## Upstream changes to watch
| Date | Upstream commit/tag | Relevance | Action |
|---|---|---|---|
| 2026-11-06 | `sakura-ryoko/litematica@26.3` `64e74592` (untagged; newest tag `26.3-0.29.0`) | Baseline of the fork (`baseline/sakura-26.3-0.29.2-sakura.1`) | Sync procedure: `prompts/recurring/upstream-sync.md` |
| 2026-11-06 | `sakura-ryoko/malilib@26.3` `b043d04c` (newest tag `26.3-0.30.1`; build uses 0.30.2 from the masa maven) | MaLiLib dependency | Record the 0.30.2 commit if a mavenLocal fallback is ever needed (RISK-04) |
| 2026-11-06 | `maruohon/litematica@ornithe/1.12.2` `27efd02b`, `maruohon/malilib@ornithe/1.12.2` `a02f90ee` | Design donor (masa's rewrite) | Not fetched in P00; fetch `upstream-masa` when a phase ports a design |
