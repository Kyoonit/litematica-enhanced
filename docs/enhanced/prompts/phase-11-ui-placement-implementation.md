# Litematica Enhanced — P11 · Placement, selection, tools and HUD redesign
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P11-ui-placement` created from `enhanced/p10-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — place, align, edit sub-regions, select areas, use tools in survival and creative

---

## 0. Global context (read carefully)

You are the **lead** of phase **P11** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P11-ui-placement` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p10-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P11/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P11/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P11a/P11b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P11/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P11/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P11/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P11] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P11/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P11/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P11 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P11 — Placement, selection, tools and HUD redesign

**Agents for this phase:** lead · `ui-engineer` · `ux-designer` · `test-engineer` · `doc-writer` · `independent-auditor`

### Goal
Make the most frequent in-world work faster and clearer: placing and aligning schematics, editing sub-regions, selecting areas, and switching tools. Deliver the approved placement and selection editors, the **tool HUD**, the **context menu**, and the restyled info overlays. The capabilities stay the same; the steps get fewer.

### Inputs
Approved mockups: placement list + editor, sub-region editor, area selection editors (normal/simple), tool HUD + context menu · `design/journeys.md` (J-03 align, J-04 layers, J-08 sub-regions, J-02 capture) · P09 toolkit, P10 action registry · knowledge notes: placements, selections, tool modes and input, render layers, info overlays · features selected in P05 for this phase (if any).

### Work packages
1. **Placement list and editor (`ui-engineer`).**
   - List with search and grouping (by schematic, dimension, enabled state).
   - Editor with origin (numeric fields with steppers, "snap to looked-at block", "move to player"), rotation/mirror with a **live preview** of the result, render toggles, layer controls inline, sub-region list, lock state, duplicate.
   - Destructive actions use confirm and undo.
   - **Placement edit history (undo/redo)** for transform and origin changes made in the editor, only if the human selected it in P05. Otherwise leave it out.
2. **Sub-region editor:** per-region offset, rotation/mirror, enable/render toggles, reset to schematic defaults, bulk actions.
3. **Area selection editors (normal and simple modes):** corner editing with numeric fields and nudge keys, sub-region boxes, a dimensions display, "grow/shrink by", "fit to blocks", save to schematic (flows from P10).
4. **Tool HUD:** shows the current tool mode, its main option, and the key hints for the current context. Configurable position and scale; compact and expanded modes; hidden when F1 hides the HUD (respect vanilla, as upstream does).
5. **Context menu:** hold a configurable key (default chosen to avoid vanilla and common-mod conflicts, verified by the keymap conflict check) to open a menu of context-relevant actions from the action registry. Mouse and keyboard selection. It never fires F2 actions without a confirmation.
6. **Info overlays:** restyle the existing info overlays (block info, placement info, verifier HUD lines) with the tokens and keep all the information they show today. Positions are configurable as today.
7. **Hotkeys:** keep every existing hotkey working with the same defaults. New actions get unbound defaults or conflict-free defaults (test against the vanilla key list and the keymap).
8. **Docs (`doc-writer`):** guide pages for placing and aligning, sub-regions, selections and tools, plus an old → new mapping.

### Rules
- Placement and selection state is mutated **only on the client thread** through the existing managers or the P07 services (single writer).
- No new world interaction. Tool behaviour that affects the world (fill/replace/paste/delete, F2) keeps its current semantics and confirmations.
- The legacy screens stay reachable behind `ui.legacyScreens`.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The new placement list and editor, sub-region editor, area selection editors, tool HUD and context menu match their approved mockups (side-by-side screenshots at scales 2 and 3) and work at scale 4 in a 320×240 window.
2. Parity checklists for every replaced legacy screen are complete: every option, toggle and action is reachable. Verified by a test that enumerates the config options and actions related to placements and selections.
3. The live transform preview shows the same result as applying the transform (test comparing the preview model with the applied placement for all 8 rotation/mirror combinations).
4. Origin tools (snap to looked-at block, move to player, numeric steppers, nudge keys) are tested in game tests.
5. Existing hotkeys keep their IDs and defaults (config-defaults snapshot green). New defaults have no conflicts (conflict test). The context-menu key is configurable.
6. The HUD respects F1/hide-HUD, its position and scale settings work, and its frame cost is within the `targets.md` budget (benchmark `hud-overlay-L`).
7. State mutations happen on the client thread only (code review plus an architecture test, if feasible). No new packets are sent (fairness: the dev cause log shows nothing new for these screens).
8. The journey step counts for J-03, J-04 and J-08 meet the "after" counts from `journeys.md` (screenshots).
9. Full suites, golden masters and game tests are green. `fly-M` and `move-placement-M` are within thresholds.
10. Docs pages exist and match the behaviour.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (editors, preview equivalence, origin tools, HUD toggles, context menu, keyboard navigation, screenshots).
- Benchmarks: `hud-overlay-L` (new; versioned), `fly-M`, `move-placement-M`.
- Hotkey conflict test; config-defaults snapshot.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P11/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-11-ui-placement-audit.md` with BASE=`enhanced/p10-pass` and HEAD=`phase/P11-ui-placement`."
