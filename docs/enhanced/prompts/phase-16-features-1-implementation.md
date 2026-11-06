# Litematica Enhanced — P16 · New features — wave 1
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P16-features-1` created from `enhanced/p15-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — each new feature in a real build session; confirm whether each feature flag may default to on

---

## 0. Global context (read carefully)

You are the **lead** of phase **P16** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P16-features-1` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p15-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P16/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P16/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P16a/P16b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P16/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P16/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P16/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P16] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P16/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P16/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P16 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P16 — New features — wave 1

**Agents for this phase:** lead · `feature-designer` (spec conformance, interaction review) · `ui-engineer` · `architect` (fit with foundations) · `test-engineer` · `ux-designer` (addendum mockups when a screen is new) · `doc-writer` · `independent-auditor`

### Goal
Implement **only** the new features the human selected for wave 1 in P05. Each one is spec-conformant, tested, integrated into the UI, documented, behind a flag until audited, and checked for interactions with existing features.

### Inputs (authoritative scope)
`registers/features.md` filtered on `phase = P16` and the corresponding `docs/enhanced/specs/FEAT-*.md` · `specs/interactions.md` · `DECISIONS.md` (P05 selection) · ADRs · `design/` (mockups; addenda for new screens) · engines (P13), library and index (P08/P10), jobs/notifications/flags (P07).

Typical wave-1 candidates, **for illustration only**; implement what was selected:
- build progress and ETA per layer/material;
- render-layer auto-advance (UI state only);
- storage-aware material planning (client-observed sources);
- shopping-list and layer-sheet export (PNG/CSV);
- crash-safe autosave of placements/selections with a recovery dialog;
- onboarding and contextual help.

### Per-feature workflow (repeat for each selected card; at most 3 features in parallel in separate worktrees)
1. **Spec check (`feature-designer`).** Re-read the card. Confirm that the foundations it needs exist. List the interactions from `specs/interactions.md`. If something is missing or contradictory, stop that feature and report it.
2. **UX addendum (`ux-designer`, only if the feature needs a screen or panel without an approved mockup).** Produce a mockup addendum in `design/mockups/addenda/` and get **human approval before implementation** (AskUserQuestion with the image or file path).
3. **Tests first (`test-engineer`).** Write the acceptance tests from the card (unit + game tests + golden outputs for exports).
4. **Implementation (`ui-engineer`/`architect`)** behind the flag `feature.<id>` (default **off** until this phase's audit and the human's decision).
5. **Interaction tests.** One test per listed interaction (for example "auto-advance layers does not fight manual layer hotkeys"; "autosave recovery does not duplicate placements"; "the export uses the same counts as the material engine").
6. **Performance budget.** If the feature runs per frame or per tick, measure it (new versioned scenario if needed) against `targets.md` budgets.
7. **Fairness check.** Confirm the class (F0/F1/F2) and that the cause log shows nothing new for F0 features.
8. **Docs (`doc-writer`).** A user guide page plus a changelog entry. Translation keys go through a change request.

### Integration
Merge features one at a time into the phase branch, running the full suites after each merge. At the end, ask the human, feature by feature, whether its flag may default to **on** after the audit. Record the answers.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Every card with `phase = P16` is implemented, or explicitly deferred by a human decision (recorded). No unselected feature was implemented.
2. Each feature meets every acceptance criterion in its card (table: card → criterion → test/evidence).
3. Each feature has interaction tests for every interaction listed in `specs/interactions.md`, all green.
4. Each feature is behind `feature.<id>` with a documented default. Both flag states are tested.
5. New screens and panels have approved mockup addenda (`DECISIONS.md`) and matching screenshots.
6. Per-frame or per-tick features meet their performance budgets (raw benchmark files). `fly-M` and the relevant existing scenarios are within thresholds.
7. Fairness classes are confirmed. F0 features send no packets (cause log). No F3 behaviour.
8. Exports are deterministic (golden). Autosave and recovery (if selected) never lose or duplicate data (fault-injection test).
9. A user guide page and a changelog entry exist per feature. Translation keys are listed.
10. Full suites, golden masters and game tests are green.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (per feature, per interaction, both flag states).
- Feature-specific benchmarks (new, versioned) and the regression scenarios.
- Fault-injection tests for any persistence feature.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P16/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-16-features-1-audit.md` with BASE=`enhanced/p15-pass` and HEAD=`phase/P16-features-1`."
