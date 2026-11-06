# P00 — Plan

## Objectives (copied from the phase prompt)
Bootstrap the fork: verify upstream, record licence and contribution conditions, set up remotes, branches and the baseline tag, verify and preserve the baseline build, install the Claude Code kit and the `docs/enhanced/` skeleton, apply the minimal identity patch to `fabric.mod.json`, produce a first-pass feature inventory and architecture map, and confirm CI. No functional code change.

## Inputs read (files, register IDs, ADRs)
- `_dossier/prompts/phase-00-bootstrap-implementation.md` (this phase's prompt)
- `_dossier/01-strategic-analysis.md` §1.3, §2, §3, §4 (finding IDs UX-01..08, PERF-01..09, ARCH-01..07, REL-01..08, SEC-01)
- `_dossier/04-agent-operating-model.md` §4.1 (hot files)
- `_dossier/claude-code-kit/**` (CLAUDE.md, settings.json, hook, agents, rules, templates)
- No ADRs exist yet. No registers exist yet (created by this phase).

## Human decisions (Step 0, answered 2026-11-06)
Fork = `Kyoonit/litematica-enhanced` (already created; this clone is it). Contact = the fork's GitHub issues. Working name = "Litematica Enhanced — an unofficial Litematica fork". Maintainer introduction: not now. Modification notice: one comment line in source files; JSON changes recorded in `NOTICE.md`. Recorded in `docs/enhanced/DECISIONS.md`.

## Tasks
| ID | Task | Owner agent | Depends on | Est. size | Worktree? |
|---|---|---|---|---|---|
| T1 | Verify upstream identity and state (Step 1) | lead | — | XS | no |
| T2 | Remotes, branches, baseline tag (Step 3) | lead | T1 | XS | no |
| T3 | Baseline build, jar hashes, `knowledge/build.md` (Step 4) | lead | T2 | S | detached worktree for the baseline build |
| T4 | Install kit + docs skeleton, hook test, settings validation (Step 5) | lead | T2 | S | no |
| T5 | `knowledge/licence-and-contribution.md`, `NOTICE.md`, `AI_DISCLOSURE.md` (Step 2) | upstream-liaison | T4 | S | no (docs only, disjoint paths, no commits; see note) |
| T6 | Identity patch in `fabric.mod.json` (Step 6) | lead (hot file) | T5 | XS | no |
| T7 | Inventory script `tools/inventory/` + `registers/features.md` + cross-check (Step 7) | lead | T4 | S | no |
| T8 | `knowledge/architecture-map.md` (Step 7) | cartographer | T4 | S | no (read-only on source; writes one note) |
| T9 | Seed `registers/problems.md` from STRATEGY §4 (Step 7) | lead | T4 | XS | no |
| T10 | Build on phase HEAD, CI sanity (Step 8) | lead | T6 | XS | no |
| T11 | Pre-audit | independent-auditor | T1–T10 | S | no (read-only) |
| T12 | Report, STATE, ROADMAP, registers, commit | lead | T11 | XS | no |

Note on worktrees: T5 and T8 only write new documentation files at disjoint paths and never commit, so they run in the main checkout. The project agents in `.claude/agents/` are installed by this phase and are not loaded by the running session, so the lead runs them as general-purpose subagents briefed with the agent definition (same model, same rules). This is recorded as a deviation in the report.

## File ownership (no overlaps)
| Path glob | Owner |
|---|---|
| `docs/enhanced/knowledge/licence-and-contribution.md`, `NOTICE.md`, `docs/enhanced/AI_DISCLOSURE.md`, `docs/enhanced/phases/P00/agents/upstream-liaison.md` | upstream-liaison |
| `docs/enhanced/knowledge/architecture-map.md`, `docs/enhanced/phases/P00/agents/cartographer.md` | cartographer |
| `docs/enhanced/phases/P00/pre-audit.md` | independent-auditor |
| everything else (`CLAUDE.md`, `.claude/**`, `.gitignore`, `src/main/resources/fabric.mod.json`, `tools/inventory/**`, the rest of `docs/enhanced/**`) | lead |

## Hot-file changes expected (lead applies)
- `src/main/resources/fabric.mod.json`: `contact.homepage`, `contact.issues`, `contact.sources` → fork URLs; description + " (unofficial fork)". Nothing else.
- `docs/enhanced/STATE.md`, `ROADMAP.md`, `DECISIONS.md`: created and filled by the lead.

## Test plan (mandatory tests from the prompt)
- `./gradlew build` on the baseline commit (fresh detached worktree) and on the phase HEAD (after `git clean -xfd` of build outputs, or a fresh worktree).
- Hook test script, ≥ 6 JSON payloads, exit codes logged.
- `.claude/settings.json` JSON validation (Python is not installed on this machine; an equivalent JSON parser is used and named in the log).
- Inventory script run twice → identical output (`diff` empty).
- `cmp LICENSE.txt` against the baseline blob → identical.
- `git diff --stat baseline..HEAD -- src/` → only `fabric.mod.json`.

## Benchmark plan
Not applicable (no code change). `benchmarks/PROTOCOL.md` is a skeleton filled by P01.

## Risks & mitigations
- Jar hashes are not reproducible across builds (`preserveFileTimestamps = true`, embedded timestamps) → record hashes per build and compare jar *contents* rather than jar bytes.
- Python is unavailable → the inventory script is a single-file Java program run with `java tools/inventory/Inventory.java` (no dependencies, JDK 25 already required).
- `/agents` cannot be run from this non-interactive session → record a text listing of the agent files and ask the human to confirm `/agents` once.
- Pushing to `origin` is outward-facing → only with the human's go-ahead (Step 8).

## Split decision
Fits size class S. No split.
