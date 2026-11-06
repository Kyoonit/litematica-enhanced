# Litematica Enhanced — P14 · Verifier, materials, projects and settings UI
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P14-ui-analysis` created from `enhanced/p13-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — verify a real build, plan materials, browse settings, remap keys

---

## 0. Global context (read carefully)

You are the **lead** of phase **P14** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P14-ui-analysis` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p13-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P14/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P14/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P14a/P14b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P14/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P14/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P14/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P14] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P14/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P14/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P14 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P14 — Verifier, materials, projects and settings UI

**Agents for this phase:** lead · `ui-engineer` · `ux-designer` · `test-engineer` · `perf-engineer` (large result lists) · `doc-writer` · `independent-auditor`

### Goal
Give players the analysis tools they need to finish a build: a clear verifier, a planning-oriented material list, a **build-assistant** panel that says *what to do next*, schematic projects (VCS) screens, **searchable settings**, and a **keymap editor** with conflict detection. All of it sits on the P13 engines and the P09 toolkit.

### Inputs
Approved mockups: verifier + in-world overlay legend, material list / build assistant, settings, keymap editor, diagnostics · P13 engine APIs · P10 action registry, P09 toolkit · knowledge notes: verifier, materials, schematic projects, configs and hotkeys · features selected in P05 for this phase (if any).

### Work packages
1. **Verifier screen and overlays.**
   - Categories with counts, filters (category, block type, layer, sub-region), sorting, a virtual list of mismatches (≥ 100,000 rows).
   - Jump-to (highlight in the world + direction hint), "ignore this mismatch / this pair" (existing ignore semantics), re-run/resume/pause, export (CSV/JSON).
   - In-world overlays restyled with the tokens (colour roles from the design system, plus non-colour cues: shapes or patterns, for colour-blind users).
2. **Build-assistant panel** (HUD and screen):
   - overall and per-layer progress;
   - nearest N missing or wrong blocks with distance and direction;
   - "next layer" suggestion.
   Display-only (F0). The optional render-layer auto-advance belongs to P16 if it was selected.
3. **Material list screen.**
   - Needed / available (client-observed sources from P13) / missing.
   - Grouping (by item, by layer, by sub-region), sorting, search, "hide completed", per-item notes or checkboxes if selected in P05.
   - Export CSV/JSON (deterministic). Recipe details as today. HUD material list restyled.
4. **Schematic projects (VCS) screens:** project browser, version list, save/restore version, place a version, with the same capabilities as today and clearer labels. Destructive actions are confirmed.
5. **Settings screen.**
   - All 175+ options grouped into the IA categories, **full-text search** (name, description, key), "changed from default" view, reset per option and per group.
   - Inline help (description, default, range), a profiles placeholder area (profiles come in P15).
   - Options for experimental flags shown in an "Experimental" group.
6. **Keymap editor.**
   - Every hotkey with its current binding and context.
   - **Conflict detection** against other Litematica hotkeys **and** vanilla keybinds, with contextual rules (which contexts can overlap safely).
   - Reset, search, a printable cheat sheet.
7. **Diagnostics screen** (from the P07 data API): jobs, pools, queues, memory per placement, render stats (P12), active flags, lifecycle state, compat status, server policy (placeholder until P15).
8. **Docs:** user guide pages (verifying a build, planning materials, settings and keymap, diagnostics).

### Rules
Legacy screens stay reachable behind `ui.legacyScreens` until their parity checklists pass. The settings screen must expose **every** option (test). No client-thread heavy work: big lists come from engine iterators through the virtual list.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. All screens match their approved mockups (side-by-side screenshots at scales 2 and 3) and work at scale 4 in a 320×240 window.
2. The verifier screen handles ≥ 100,000 mismatches smoothly: `verifier-ui-100k` (new; versioned) meets the `targets.md` budget, with no per-frame allocation proportional to the result count (JFR).
3. The counts displayed equal the engine results (tests on fixtures). Jump-to, ignore and export work (tests). Overlays add non-colour cues.
4. The build-assistant panel shows correct progress and nearest-N results on fixtures (tests). It is display-only: no packets (cause log).
5. The material screen shows needed/available/missing correctly on fixtures, and exports are deterministic (golden).
6. The VCS screens pass their parity checklist against the legacy screens.
7. Settings: a test enumerates every config option and finds it through search and in its category. "Changed only" and reset work.
8. The keymap editor detects conflicts with Litematica and vanilla keybinds (unit tests with crafted conflicts) and respects context rules.
9. The diagnostics screen shows the P07/P12 data (screenshot + test).
10. Full suites, golden masters and game tests are green. `fly-M` and `verify-M` are within thresholds. Docs pages exist.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (each screen, keyboard navigation, screenshots, verifier jump-to).
- Benchmarks: `verifier-ui-100k`, `verify-M`, `fly-M`.
- Settings coverage test; keymap conflict tests; export goldens.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P14/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-14-ui-analysis-audit.md` with BASE=`enhanced/p13-pass` and HEAD=`phase/P14-ui-analysis`."
