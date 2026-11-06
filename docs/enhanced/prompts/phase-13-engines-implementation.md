# Litematica Enhanced — P13 · Analysis engines — verifier, materials, diff
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P13-engines` created from `enhanced/p12-pass` (P12 must be merged first: overlays share the render path), and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** No (numbers reviewed in the report; playtest comes with P14)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P13** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

- **Upstreams.**
  - The modern line is maintained by Sakura-Ryoko: `sakura-ryoko/litematica` and `sakura-ryoko/malilib`, default branch `26.3` at planning time.
  - The original author, masa (`maruohon`), does not maintain 1.20.5+ versions. He works on a rewrite on `maruohon/litematica` and `maruohon/malilib`, branch `ornithe/1.12.2`.
  - That rewrite is the **design donor**: port designs and interfaces, never 1.12-era code. Credit masa.
- **Baseline (2026-11-06).**
  - Minecraft 26.3, unobfuscated, so the code uses Mojang names (no Yarn).
  - Java 25, Fabric Loader 0.19.5, Loom 1.18, MaLiLib 0.30.2, Litematica 0.29.2-sakura.1.
  - About 316 Java files and 73k lines. **No automated tests at baseline** (P01 adds them). CI only builds.
  - Fabric API is not a runtime dependency.
- **Programme goal.** A much more powerful, modern, fast and intuitive Litematica, built in short audited phases, with small upstream-friendly improvements extracted as PRs. It must stay compatible with existing schematics, configs and add-ons, and fair on every server.
- **Persistent project memory** lives in the repository (created in P00). Read only what you need:
  - `docs/enhanced/STATE.md` — **read first**
  - `docs/enhanced/REFERENCE.md` — authoritative rules and technical strategy
  - `docs/enhanced/ROADMAP.md` (status) and `ROADMAP-PLAN.md` (plan)
  - `docs/enhanced/AGENTS.md` (multi-agent model) and `UPSTREAM.md` (fork and PR strategy)
  - `docs/enhanced/DECISIONS.md` and `adr/`
  - `registers/` (problems, features, risks, upstream), `knowledge/` (architecture map, subsystem notes, mixin register), `benchmarks/`, `design/`, `specs/`, `phases/`, `templates/`
- **Precedence** when sources disagree: the human owner's explicit decision > `REFERENCE.md` > accepted ADRs > this prompt > your own judgement.

## 1. Non-negotiable rules

1. **Stability first.** Never trade stability for speed of feature delivery. Never leave the build or tests red.
2. **No feature removal or hiding** without a documented usage and dependency analysis plus an approved ADR.
3. **Schematic compatibility.** No change to how existing files are read or written without golden tests proving equivalence or an approved ADR.
4. **No new runtime dependency** without an approved ADR. Test-scope tools also need an ADR entry.
5. **Never invent results.** No fabricated test outputs, benchmark numbers, screenshots, issue numbers or quotes. Every number links to a raw file produced by a command you list. Estimates are labelled *estimate* and kept out of results tables.
6. **Measure before and after** every optimisation, on the same machine with the same protocol (`docs/enhanced/benchmarks/PROTOCOL.md`).
7. **A successful compile proves nothing.** Each acceptance criterion needs behavioural evidence.
8. **No massive refactor without a migration path.** Use facades, feature flags and steps that each leave the mod working.
9. **One concern per commit series.** Mechanical changes (moves, renames) go in separate commits. Never reformat code you do not change. Match each file's indentation and line endings: `*.java` is CRLF in the working tree via `.gitattributes`.
10. **Always keep a way back.** Tags, flags, legacy paths until parity, and a rollback plan in your report.
11. **Document decisions.** ADRs for structural choices, `DECISIONS.md` for human decisions.
12. **Check interactions.** List the subsystems your change touches and prove they still work.
13. **Fairness.** No autonomous world interaction (no printer, auto-build, auto-restock). Every gameplay packet must be caused by a user input or a user-confirmed job (REFERENCE §7).
14. **Scope discipline.** Out-of-scope discoveries go into `docs/enhanced/registers/*` with an ID, not into the diff.

## 2. How to work

1. **Orient.**
   - Read `docs/enhanced/STATE.md`, then the registers, ADRs and knowledge notes named in §3.
   - Check that you are on `phase/P13-engines` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p12-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P13/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P13/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P13a/P13b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P13/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P13/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P13/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P13] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P13/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P13/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P13 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P13 — Analysis engines — verifier, materials, diff

**Agents for this phase:** lead · `architect` (engine design) · `perf-engineer` (incremental algorithms, measurements) · `test-engineer` (equivalence and incremental tests) · `reliability-engineer` (snapshot consistency, lifecycle) · `independent-auditor`

### Goal
Rebuild the "brains" behind the verifier, the material lists and a new diff capability as **headless, incremental, snapshot-based engines**. They must produce **the same results** as today, faster and with less memory, and expose clean APIs that the HUD and the new UI (P14) consume.

### Inputs
P02 findings PERF-06, PERF-07 (verifier/material costs), the heap attribution · ADR-0006/0007 (threading, jobs), ADR-0008 (model) · knowledge notes: verifier, material lists, schematic world, placements · the P01 golden masters for verifier and material outputs · features selected in P05 that need an engine (diff/compare, progress tracking, storage-aware materials), so their APIs are anticipated.

### Work packages
1. **Characterise first.** Extend the golden masters if coverage is missing: verifier outputs per category (missing, extra, wrong block, wrong state, diff, correct counts, ignored mismatches) and material lists (placement, area, schematic; per layer; with "ignore state" options) on fixture worlds, **from the current implementation**.
2. **Verifier engine (`architect` + `perf-engineer`).**
   - Per-chunk (or per-section) result units.
   - Positions packed as `long` in primitive collections (fastutil); categories as compact structures.
   - Comparison runs on workers from **snapshots** of schematic sections and client-world sections taken on the client thread. Measure the snapshot cost. If copying client sections is too expensive, use the ADR's alternative (for example a chunk-granular budgeted compare on the client thread with primitive structures) and document the measurements.
   - **Incremental recheck:** a block-change notification (existing hooks such as `markVerifierBlockChanges`) re-verifies only the affected units.
   - Results API: totals, per-category iterators, nearest-N queries for the HUD and "next missing block", per-layer progress.
   - The old `SchematicVerifier` becomes a facade over the engine for compatibility.
3. **Material engine.**
   - Counts per placement, area or schematic; per layer and per sub-region; with "ignore state" mapping.
   - Incremental updates when placements change. Item requirements via the existing item mapping (recipe details as today).
   - **Availability inputs limited to client-observed data**: the player inventory, the ender-chest cache (existing option), containers the player opened (cache with timestamps, opt-in). No remote scanning. F0.
4. **Diff engine.** Compare schematic ↔ schematic and schematic ↔ world region (snapshot), producing the same result structure as the verifier (categories + positions). This is the API for P17 diff/compare features, if they were selected. Golden tests on fixture pairs.
5. **Jobs and lifecycle.** Engines run as P07 jobs with progress and cancellation. Lifecycle events (dimension change, disconnect) cancel them or invalidate their snapshots. Placement moves invalidate the affected units.
6. **Kill switches:** `engines.verifier`, `engines.materials` (legacy path kept and tested).

### Rules
Equivalence with legacy outputs is mandatory on every fixture, except documented legacy bugs: those get an ADR note, a golden update in its own commit, and a register ID. No UI redesign here: the HUD and current screens consume the engine through facades.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The golden masters for verifier and material outputs cover every category and option listed in WP1 (coverage table in the report).
2. The new verifier and material engines produce identical results to the legacy implementations on all fixtures. Any documented exception has an ADR note, a register ID and an isolated golden commit.
3. The incremental recheck is proven by tests: a single block change re-verifies only the affected unit(s) (instrumented count), and the results match a full recompute.
4. Engines run as cancellable jobs. Cancellation at random points leaves consistent state (tests). Dimension change and disconnect invalidate snapshots and jobs (game test).
5. Worker code reads only snapshots (review notes + guard test). The snapshot cost is measured and reported.
6. Before/after benchmarks `verify-M`, a new `verify-L`, `material-list-L` and `incremental-recheck-L` (new; versioned) show improvements beyond the claim threshold on the targeted metrics, or a documented justification where the gain is in memory rather than time. Retained heap for verifier results with many mismatches is measured before/after.
7. The diff engine has golden tests on fixture pairs (schematic ↔ schematic, schematic ↔ world).
8. Material availability uses only client-observed data (code review + test). Opened-container caching is opt-in.
9. Kill switches are tested in both states. Full suites green. `fly-M` within thresholds.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (verifier on prepared worlds, incremental recheck, lifecycle).
- Golden equivalence suites (verifier, materials, diff).
- Benchmarks (≥ 5 runs; claims in 2 sessions): `verify-M`, `verify-L`, `material-list-L`, `incremental-recheck-L`, `fly-M`.
- Randomised cancellation test (seeded).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P13/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-13-engines-audit.md` with BASE=`enhanced/p12-pass` and HEAD=`phase/P13-engines`."
