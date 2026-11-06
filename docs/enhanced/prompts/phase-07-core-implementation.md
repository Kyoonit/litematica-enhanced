# Litematica Enhanced — P07 · Core foundations — context, lifecycle, jobs, errors, flags, migrations
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P07-core` created from `enhanced/p06-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** No (playtest optional: the mod must behave exactly as before)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P07** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P07-core` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p06-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P07/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P07/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P07a/P07b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P07/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P07/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P07/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P07] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P07/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P07/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P07 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P07 — Core foundations — context, lifecycle, jobs, errors, flags, migrations

**Agents for this phase:** lead · `architect` (design + core implementation) · `reliability-engineer` (lifecycle, concurrency, shutdown) · `test-engineer` (unit + architecture tests) · `cartographer` (call-site maps) · `independent-auditor`

### Goal
Lay the foundations that every later phase builds on, **with no visible behaviour change**: an explicit context and services, a lifecycle state machine, a job system, a notification and diagnostics model, a feature-flag registry, persisted-schema versioning with migrations, and enforced architecture rules.

### Inputs
ADR-0003 (namespaces), ADR-0004 (layering), ADR-0006 (threading), ADR-0007 (jobs), ADR-0009 (persistence), ADR-0011 (flags), ADR-0012 (diagnostics) · `architecture/migration-plan.md` steps for P07 · knowledge notes: persistence, configs, scheduler, placements · `registers/problems.md` (ARCH-01, PERF-07, PERF-08, REL-05, REL-06).

### Work packages
1. **Context and services (`architect`).**
   - Introduce `LitematicaContext` (or the ADR's name) that owns service instances: schematic holder, placement manager, selection manager, data persistence, job system, notifications, flags, diagnostics.
   - **Strangler approach:** existing static entry points (`DataManager.*`, `getInstance()`) become thin facades delegating to the context. Do **not** rewrite all 81+ call sites.
   - Migrate only the call sites in the files this phase must touch anyway, plus a small pilot set. Report the before/after counts of static accesses.
2. **Lifecycle state machine (`reliability-engineer`).**
   - States as defined in the ADR (e.g. `NO_WORLD → JOINING → IN_WORLD ⇄ CHANGING_DIMENSION → LEAVING → NO_WORLD`, plus `SHUTDOWN`).
   - Wire it to the existing listeners (world load, server join/leave, dimension change, client stop) without changing their current behaviour.
   - Services subscribe to transitions. Jobs get cancelled or checkpointed per the ADR.
   - Unit-test every transition, including illegal ones (logged, not crashing).
3. **Job system (`architect` + `reliability-engineer`).**
   - Job API (id, title key, progress, cancellation token, priority, affinity: worker/client-thread, owner service).
   - **One shared bounded worker pool** (named daemon threads, uncaught-exception handler → diagnostics).
   - Client-thread **completion queue drained under a frame budget** derived from the measured frame time.
   - Registry of active and recent jobs (for the future jobs UI). Clean shutdown on client stop (bounded wait, then interrupt). No thread leaks.
   - **Adapter** for existing `ITask`/`TaskScheduler` tasks so they can be observed as jobs without being rewritten.
   - **Pilot:** migrate one existing task (e.g. `TaskSaveSchematic` or a count task) to a real job **behind a flag** (`core.jobs.pilot`), keeping the legacy path, with tests for both.
4. **Notifications and diagnostics (`architect`).**
   - Notification API (level, title, details, actions, "copy diagnostics"), with an adapter so existing `InfoUtils` messages still display exactly as before.
   - Diagnostics data API: jobs, pool stats, queue sizes, memory estimates per service, active flags, compat status, lifecycle state.
   - A dev/debug command or keybind that dumps diagnostics to the log or a file. The UI comes in P09+.
5. **Feature-flag registry (`architect`).** Central definitions (id, default, owner phase, removal criteria), persisted in the fork config, queryable from diagnostics, plus a test that lists all flags.
6. **Persisted-schema versioning and migrations (`reliability-engineer`).**
   - A framework to read a schema version, apply ordered migrations, and write back atomically with `.bak` and `.corrupt-*` handling (reuse the P06 helpers).
   - Apply it to the fork's own config file as decided in ADR-0009/ADR-0002. Read legacy files without ever modifying the originals.
   - Include a no-op v1 migration and test fixtures for v0 → v1.
7. **Architecture tests (`test-engineer`).** Implement the rules specified in P03. Examples:
   - no `new Thread(` outside the executor package;
   - `core` must not import `client`;
   - new code must not call `DataManager.*` directly (allowlist of legacy files, which may only shrink);
   - mixins must not contain logic beyond delegation (heuristic: method size).
   The allowlists are committed and their sizes reported.

### Constraints
- **No behaviour change.** Golden masters, the config-defaults snapshot and the game tests stay green. The legacy and new paths of the pilot produce identical results.
- No changes to rendering or GUI behaviour. These belong to their own phases.
- Hot files (`Litematica.java`/init, `DataManager.java`, `Configs.java`…) are edited by the lead only, through change requests.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The context and services exist as defined in ADR-0006/0007/0003. The static facades delegate to them. The before/after counts of static accesses (`DataManager.*`, `getInstance()`) are reported. New code adds zero static accesses (architecture test).
2. The lifecycle state machine is wired to the existing events. Unit tests cover every legal and illegal transition. A game test exercises join → dimension change → leave without exceptions.
3. Job system tests cover: completion order and priorities, cancellation (before start, while running, during completion), exception propagation to notifications, the frame-budgeted completion queue, and shutdown with no remaining Litematica threads (checked by a thread dump in a test).
4. The pilot task runs as a job behind `core.jobs.pilot`. Both paths are tested and produce identical results.
5. The notification adapter displays existing messages unchanged (game-test screenshot or log comparison). The diagnostics dump works and lists jobs, flags, lifecycle state and memory estimates.
6. The flag registry exists, and a test enumerates every flag with its default and owner phase.
7. The migration framework has tests for v0 → v1, corrupt input recovery (`.corrupt-*` kept, `.bak` used), and atomic write. Legacy user files are never modified (test with read-only fixtures).
8. The architecture tests are implemented and green. Allowlists are committed and their sizes reported.
9. Golden masters, the config-defaults snapshot, unit tests and game tests are green. Benchmarks `fly-M`, `load-L` and `save-L` are within the regression thresholds (raw files).

### Mandatory tests and checks
- `./gradlew clean build test` + game tests.
- Architecture test task.
- Benchmarks `fly-M`, `load-L`, `save-L` (≥ 5 runs) compared with the latest baseline (comparison table).
- Thread-leak test: after a simulated client stop, no thread named with the Litematica prefix remains.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P07/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-07-core-audit.md` with BASE=`enhanced/p06-pass` and HEAD=`phase/P07-core`."
