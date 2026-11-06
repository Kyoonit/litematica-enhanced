# Litematica Enhanced — P03 · Target architecture and migration plan
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P03-architecture` created from `enhanced/p02-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** M · **Human checkpoint:** YES — approval of each ADR (accept / amend / reject), of the metric targets and of the migration plan

---

## 0. Global context (read carefully)

You are the **lead** of phase **P03** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P03-architecture` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p02-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P03/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P03/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (M) or needs a decision reserved for the human, **stop and ask**, proposing a split (P03a/P03b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P03/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P03/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P03/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P03] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P03/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P03/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P03 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P03 — Target architecture and migration plan

**Agents for this phase:** lead · `architect` (author) · `perf-engineer` and `reliability-engineer` (review threading, data and IO decisions) · `ux-designer` (review the UI framework ADR) · `upstream-liaison` (upstream impact, identity) · `independent-auditor`

### Goal
Turn the P02 evidence into **decisions**. Produce a target architecture, ADRs with real alternatives, a strangler migration plan mapped onto P07–P17, and measurable targets. No production code changes.

### Inputs
`docs/enhanced/phases/P02/synthesis.md` · `registers/*` · `knowledge/*` · `compat/addons.md` · `REFERENCE.md` §3.2 (open questions Q-01..Q-08 with recommendations) and §4 (strategy) · masa's rewrite (read-only, design donor) · baseline benchmark results.

### ADRs to write (template `docs/enhanced/templates/adr.md`; ≥ 2 real options each; evidence links; migration + rollback; verification)
| ADR | Topic | Must decide |
|---|---|---|
| ADR-0002 | Fork identity | Mod id (recommend a distinct id + `"provides": ["litematica"]`, plus `breaks` on official `litematica`), display name (pending the maintainers' answer), version scheme, data/config directory names, coexistence with official Litematica installs, migration of user data from official Litematica (copy-on-first-run, never modify the originals) |
| ADR-0003 | Package namespaces | Where upstreamable code lives (upstream packages) vs fork-only code (fork namespace); rules for new files |
| ADR-0004 | Layering and enforcement | `api → core → mc → client → compat`. What may import `net.minecraft` in `core`. Architecture tests (test scope) that enforce the rules |
| ADR-0005 | Version adapter layer and mixin policy | Adapter boundaries (rendering, chunks, block models, packets, items/components, GUI primitives), mixin rules, port metric |
| ADR-0006 | Threading model | Client-thread ownership, shared bounded pool, snapshot rules, completion queue + budget, cancellation, lifecycle hooks, kill switches. Must address the GPU upload constraint (render thread only) and the placement daemon (PERF-08) |
| ADR-0007 | Job system | Job API (id, title, progress, cancel, priority, affinity), budgets, user-visible jobs, relation to the existing `TaskScheduler`/`ITask` (adapter, not big-bang) |
| ADR-0008 | Schematic model and storage | `Schematic` interface + codecs (rewrite-aligned); dense/sparse containers chosen by density; `long` indexing and limits; schematic-world memory strategy (based on the P02 heap attribution); add-on facade for `LitematicaSchematic` |
| ADR-0009 | Persistence and migrations | Atomic writes, `.bak`, `.corrupt-*`, schema versions, config migration (Q-07), per-server/world keys, metadata index location and invalidation |
| ADR-0010 | UI framework | Fork-owned toolkit on vanilla primitives + MaLiLib services (recommended) vs extending MaLiLib widgets vs an external library. Component model, layout, focus, theming, art policy. **Provisional** until the P04 spike confirms it |
| ADR-0011 | Feature flags and legacy paths | Registry, defaults, removal criteria |
| ADR-0012 | Diagnostics, logging, notifications | Notification model replacing scattered chat/HUD messages; diagnostics screen data API; no telemetry |
| ADR-0013 | Server fairness enforcement | Causality rule implementation (dev cause log + test); **server feature-policy channel** (draft protocol, Servux extension option, plugin-channel option, behaviour without a server signal); per-server profiles |
| ADR-0014 | Compatibility policy | Add-on API stability list (from `compat/addons.md`), deprecation policy, mod compat (Sodium/Iris/Voxy/Bobby…), Servux/Syncmatica protocol rules |
| ADR-0015 | Supported versions and porting | One MC version at a time; when to port (after Sakura-Ryoko's upstream port vs independently); NeoForge stance (Q-08) |

### Other deliverables
- `docs/enhanced/architecture/target.md`:
  - diagrams (mermaid): layers; runtime threads; main data flows (load, place, render, verify, materials, act);
  - the package map (current → target);
  - API boundaries;
  - how each P02 top-20 problem is addressed (or explicitly not);
  - what is deliberately kept (with reasons).
- `docs/enhanced/architecture/migration-plan.md`. An ordered list of strangler steps. Each step has:
  - target phase (P07–P17), facade/seam, feature flag id, parity test, benchmark gate, rollback, upstream lines touched (estimate), upstream category.
  Update `ROADMAP-PLAN.md` if phases must be split or reordered. Explain every change.
- `docs/enhanced/architecture/targets.md`: north-star metrics with **numeric targets** derived from P01/P02 baselines. Each target cites its baseline file. Examples of metrics:
  - p99 frame time in `fly-L`;
  - stutters in `layer-rebuild-L`;
  - time to first render in `load-L`;
  - retained heap per block;
  - step counts for the top journeys;
  - port effort.
  Do not invent baselines. If a metric has no baseline yet, define how P07+ will measure it first.
- Architecture test specification (rules to be enforced from P07). It is specified now; the tests are implemented in P07.

### Human checkpoint (mandatory)
Present a decision table to the human: ADR, recommendation, main trade-off, alternatives, risk. Use AskUserQuestion in batches of up to 4. Record every answer in `DECISIONS.md` and set the ADR status to accepted, amended or rejected. Amend the ADRs as instructed. **Do not mark the phase complete without these approvals.** If the human is unavailable, stop with status `waiting-human`.

### Allowed experiments
Small throwaway spikes on `spike/P03-*` branches to validate feasibility (for example "can block models be meshed off-thread with the current renderer?"), each documented in the ADR. **Never merged.**

### Out of scope
Production code changes, UI mockups (P04), feature selection (P05).

### Acceptance criteria (each must be evidenced in the claims ledger)
1. ADR-0002 to ADR-0015 exist. Each has ≥ 2 genuine options with pros, cons, cost and risk; evidence links (P02 findings, measurements, code references); a decision; consequences; migration and rollback; and verification.
2. Every ADR has a human decision recorded in `DECISIONS.md` (accepted/amended/rejected, with date). ADR statuses match those decisions.
3. `architecture/target.md` maps **each** P02 top-20 problem to the ADR and step that addresses it, or to an explicit "won't address" with a reason.
4. `architecture/migration-plan.md` lists every strangler step with phase, flag, parity test, benchmark gate, rollback and upstream category. Any change to `ROADMAP-PLAN.md` is explained.
5. `architecture/targets.md` gives numeric targets, each citing a baseline result file, or a defined measurement method where no baseline exists yet.
6. The threading ADR explicitly handles: GPU uploads on the render thread, the placement daemon, snapshot consistency, cancellation on lifecycle events, and kill switches.
7. The identity ADR defines coexistence and data migration with official Litematica without ever modifying the user's original files.
8. The architecture test rules are specified (rule, rationale, how it will be tested).
9. No changes under `src/main/**` on the phase branch. Spikes live only on `spike/*` branches and are documented.

### Mandatory tests and checks
- `./gradlew clean build test` stays green (sanity).
- `git diff --stat enhanced/p02-pass..HEAD -- src/main` → empty.
- Link check: every evidence link in the ADRs resolves to an existing file or line (a small script; log the result).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P03/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-03-architecture-audit.md` with BASE=`enhanced/p02-pass` and HEAD=`phase/P03-architecture`."
