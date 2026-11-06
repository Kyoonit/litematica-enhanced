# Litematica Enhanced — P17 · New features — wave 2 (advanced) and add-on API
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P17-features-2` created from `enhanced/p16-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — advanced features on large builds; approve the add-on API surface and its stability promises

---

## 0. Global context (read carefully)

You are the **lead** of phase **P17** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P17-features-2` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p16-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P17/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P17/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P17a/P17b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P17/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P17/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P17/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P17] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P17/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P17/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P17 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P17 — New features — wave 2 (advanced) and add-on API

**Agents for this phase:** lead · `architect` (add-on API, complex features) · `feature-designer` · `ui-engineer` · `perf-engineer` (large-build performance) · `test-engineer` · `ux-designer` (addenda) · `doc-writer` · `independent-auditor`

### Goal
Implement the **advanced** features the human selected for wave 2 in P05, using the same per-feature workflow as P16. Also stabilise a documented **add-on API** so that the ecosystem (Syncmatica, material trackers, downloaders…) can integrate without reaching into internals.

### Inputs (authoritative scope)
`registers/features.md` filtered on `phase = P17` + their specs · `specs/interactions.md` · `compat/addons.md` (API surface currently used by add-ons) · ADR-0014 (compat/deprecation policy) · engines (P13: the diff engine for compare features) · model/IO (P08) · placements (P11) · `design/` addenda.

Typical wave-2 candidates, **for illustration only**; implement what was selected:
- schematic diff/compare (schematic ↔ schematic and schematic ↔ world) with an in-world diff overlay and a change list;
- lightweight version history and backups integrated with projects;
- grid/array placements (masa's rewrite concept);
- schematic health check and repair with a block-state remapping UI for unknown or modded blocks;
- non-destructive material substitution in a placement;
- large-build tools (layer planner, build-order guidance, region partitioning for teams).

### Per-feature workflow
Identical to P16: spec check → UX addendum with human approval (if needed) → tests first → implementation behind `feature.<id>` → interaction tests → performance budget on **L/XL** scenarios → fairness check → docs. At most 3 features in parallel in separate worktrees, merged one at a time.

### Add-on API (`architect`)
1. Define the `api` package (ADR-0004 layer). Candidates:
   - read access to loaded schematics, placements and their transforms;
   - selection state;
   - verifier/material/diff results (read-only views);
   - events (placement added/moved/removed, schematic loaded, verifier finished, lifecycle);
   - registration of extra library metadata providers and of actions in the action registry (with fairness class).
2. Each API element: Javadoc, `@ApiStatus` annotation, thread-affinity contract, stability level (stable/experimental).
3. **Compatibility facades** for the legacy classes used by known add-ons stay in place. Their deprecations point to the API. They are removed no earlier than the policy in ADR-0014.
4. **Example add-on** in a separate source set or module (not shipped) that uses the API: listens to events and reads verifier results. It is compiled and tested in CI.
5. Ask the human to approve the API surface and the stability promises before marking anything "stable".

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Every card with `phase = P17` is implemented or explicitly deferred by a human decision. No unselected feature was implemented.
2. Each feature meets every acceptance criterion in its card (table with evidence), and has interaction tests for every listed interaction.
3. Each feature is behind `feature.<id>`, both states are tested, and new screens have approved addenda.
4. Large-build performance: each feature that touches per-frame or per-tick work, or large data, meets its budget on L/XL scenarios (raw files). The existing scenarios are within thresholds.
5. The diff engine is used by the compare feature (if selected) and its outputs match the golden pairs. Repair/remap (if selected) never modifies the original file unless the user saves explicitly (atomic + `.bak`).
6. The add-on API package exists with Javadoc, `@ApiStatus`, thread contracts and stability levels. The human's approval of the surface is recorded.
7. The example add-on compiles and its tests pass in CI. The legacy facades used by known add-ons still compile (compat test from P08, extended).
8. Fairness classes are confirmed. No F3 behaviour. F0 features send no packets.
9. Docs: a user page per feature, plus an add-on developer guide (`docs/enhanced/api/README.md`) with examples.
10. Full suites, golden masters and game tests are green.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (features, interactions, flags).
- L/XL benchmarks for the selected features + regression scenarios.
- Example add-on build and tests; the add-on compile-compat test.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P17/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-17-features-2-audit.md` with BASE=`enhanced/p16-pass` and HEAD=`phase/P17-features-2`."
