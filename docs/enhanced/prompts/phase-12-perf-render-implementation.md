# Litematica Enhanced — P12 · Rendering performance (off-thread meshing, frame budget, memory)
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P12-perf-render` created from `enhanced/p11-pass` (sequential order) — or enhanced/p08-pass when run in parallel with the UI track (P09–P11) in a separate worktree, since render/** and world/** are disjoint from gui/** and ui/**, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** XL (a split into P12a threading/budget and P12b memory/upload is expected) · **Human checkpoint:** Playtest + numbers — the human runs the benchmark suite on the reference machine and plays with large schematics, with and without Sodium/Iris/Voxy

---

## 0. Global context (read carefully)

You are the **lead** of phase **P12** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P12-perf-render` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p11-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P12/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P12/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (XL (a split into P12a threading/budget and P12b memory/upload is expected)) or needs a decision reserved for the human, **stop and ask**, proposing a split (P12a/P12b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P12/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P12/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P12/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P12] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P12/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P12/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P12 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P12 — Rendering performance (off-thread meshing, frame budget, memory)

**Agents for this phase:** lead · `perf-engineer` (main) · `reliability-engineer` (concurrency review, stress tests, compat) · `architect` (adapter boundaries) · `test-engineer` (visual equivalence, stress harness) · `cartographer` · `independent-auditor`

### Goal
Make schematic rendering **smooth at scale** without changing what is rendered:
- move mesh building off the render thread, using immutable snapshots;
- replace the unbounded or hard-coded frame budget with an adaptive one;
- prioritise and cancel work intelligently;
- reduce memory where P02 showed it matters;
- stay compatible with Sodium, Iris and Voxy.
Every claim must be measured before and after.

### Inputs
P02 performance findings (PERF-01, -02, -03, -05, -08, -09) with their raw files · ADR-0005 (adapters), ADR-0006 (threading), ADR-0011 (flags) · `architecture/targets.md` (render targets) · knowledge notes: rendering pipeline, schematic world, compat · the P01 benchmark scenarios (`fly-*`, `layer-rebuild-L`, `load-*`, `move-placement-M`, `dimension-change-M`, `chunk-transition-L` if added).

### Plan first (mandatory)
Write `phases/P12/plan.md` with the bottleneck evidence, the design, the split decision (P12a/P12b recommended), the risk list, and the exact benchmark plan.
- If you split: implement and report **P12a only** in this session. Write the P12b plan and stop.
- The human then runs the P12a audit, and later re-runs this prompt with "P12b" stated at the top. The same prompt serves both halves.

### Work packages (P12a — threading and budget)
1. **Baseline re-measurement** on the current commit (the UI phases may have shifted numbers): all render scenarios, ≥ 5 runs, JFR.
2. **Snapshot-based meshing.**
   - Build an immutable section snapshot on the client thread: block states, fluid states, block-entity render data needed for meshing, neighbour borders, fake lighting values. This follows the pattern of vanilla's section compile regions and the existing `ChunkCacheSchematic`. Measure the snapshot cost.
   - Mesh on the shared worker pool (P07): **no access to live `WorldSchematic` or client world objects from workers**.
   - Verify the thread-safety of the block model and fluid renderers used (`BlockModelRendererSchematic`, `FluidModelRendererSchematic`, AO, tint cache). Document the argument in an ADR addendum. Add guards where they are not thread-safe (per-worker instances, immutable caches).
   - **GPU uploads stay on the render thread**, drained from a completion queue under the budget.
3. **Adaptive frame budget.** Replace `renderThreadNoTimeout` with a budget derived from the measured frame time and target FPS, keeping a "max throughput" mode for users who want it. Remove the hard-coded 60 FPS. The defaults are chosen from the measurements and recorded in the ADR addendum.
4. **Prioritisation and cancellation.** Order by distance and visibility (frustum). Cancel stale tasks when a placement moves or is removed, the render layer changes, or the dimension changes. Never upload stale meshes (version stamps).
5. **Kill switch:** `render.threadedMeshing` (default on only after the audit; legacy path kept and tested).

### Work packages (P12b — memory and upload)
6. **Dirty granularity:** rebuild only the affected sections on block or placement changes (verify what upstream does today, and measure).
7. **Buffer pooling and GPU memory accounting:** reuse buffers, free them on unload and dimension change, expose the counts in diagnostics, and check for leaks.
8. **Schematic-world memory:** implement the option chosen in ADR-0008 (shared palettes, lazy materialisation, or dropping redundant copies). Measure retained heap per block before and after on S/M/L.

### Visual equivalence and stress (both halves)
- **Visual equivalence:** for fixture scenes (opaque, cutout, translucent incl. water and glass, block entities, entities, AO on/off, layer modes), capture game-test screenshots with the legacy path and the new path. Compare them with a pixel tolerance. Translucent sorting must stay correct.
- **Stress test** (≥ 10 minutes, scripted):
  - rapid layer-mode changes;
  - placement moves and rotations;
  - loading and unloading 3 L schematics;
  - dimension changes;
  - disconnect/reconnect in single player.
  It must produce no exceptions and no thread leaks, and post-GC heap must be stable (trend recorded).
- **Compat matrix:** vanilla, Sodium, Sodium + Iris (shaders off and on), Voxy (with its compat toggle). Automate what you can; give the human a manual checklist for the rest. Record the results in `compat/mods.md`.

### Rules
Before/after numbers come from the same machine, settings and scenario versions. Improvements must meet REFERENCE §6.2 (median gain > max(5%, 2 × relative IQR), reproduced in 2 sessions). No regression beyond thresholds in any other scenario. No GL/GPU calls off the render thread.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. `plan.md` contains the bottleneck evidence (raw files) and the split decision. If split, the report covers exactly the half implemented, and the other half's plan exists.
2. (P12a) Meshing runs on the shared pool from immutable snapshots. No worker reads live world objects (code review notes plus an architecture or guard test). GPU uploads happen on the render thread only.
3. (P12a) The adaptive budget replaces the hard-coded one. The defaults are justified by measurements. The legacy behaviour is reachable through config.
4. (P12a) Stale work is cancelled on move, remove, layer change and dimension change, and stale meshes are never uploaded (tests with version stamps).
5. (P12b) Dirty granularity, buffer pooling and the schematic-world memory option are implemented as planned. Retained heap per block before/after is measured on S/M/L.
6. Before/after comparison tables for `fly-M`, `fly-L`, `layer-rebuild-L`, `load-L`, `move-placement-M` and `dimension-change-M`: the targeted metrics (p99 frame time, stutters > 50 ms, time to first render) improve beyond the claim threshold, reproduced in 2 sessions. No other metric regresses beyond thresholds.
7. Visual equivalence: screenshots from the legacy and new paths match within tolerance for every fixture scene (diff images committed), including translucent sorting.
8. The ≥ 10-minute stress test passes: no exceptions, no leaked threads or buffers, stable post-GC heap (trend file).
9. `render.threadedMeshing` (and any other new flag) is tested in both states. The legacy path still passes the golden render tests.
10. The compat matrix in `compat/mods.md` is filled in (automated and manual results, with versions).

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (visual equivalence, cancellation, kill switch).
- Benchmarks (≥ 5 runs, 2 sessions for claimed improvements): `fly-M`, `fly-L`, `layer-rebuild-L`, `load-L`, `move-placement-M`, `dimension-change-M`, plus `chunk-transition-L` if it exists.
- Stress test script (≥ 10 min) with log, thread dump and heap trend.
- Compat checks (automated part) + the manual checklist file for the human.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P12/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-12-perf-render-audit.md` with BASE=`enhanced/p11-pass` and HEAD=`phase/P12-perf-render`."
