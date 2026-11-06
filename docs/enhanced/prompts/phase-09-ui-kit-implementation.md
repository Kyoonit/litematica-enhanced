# Litematica Enhanced — P09 · UI framework and pilot screen
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P09-ui-kit` created from `enhanced/p08-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — compare the pilot screen and the component gallery in game with the approved mockups

---

## 0. Global context (read carefully)

You are the **lead** of phase **P09** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P09-ui-kit` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p08-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P09/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P09/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P09a/P09b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P09/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P09/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P09/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P09] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P09/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P09/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P09 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P09 — UI framework and pilot screen

**Agents for this phase:** lead · `ui-engineer` (toolkit + pilot) · `ux-designer` (fidelity reviews) · `test-engineer` (screenshot harness, logic tests) · `perf-engineer` (frame cost of components) · `independent-auditor`

### Goal
Build the fork's own UI toolkit from the **approved** design system (P04), prove it in game with a component gallery, and migrate **one low-risk screen** as a pilot, behind a flag. Every later GUI phase depends on this toolkit being solid, fast and accessible.

### Inputs
`design/tokens.json`, `tokens.md`, `components.md`, `mockups/*`, the approved list in `DECISIONS.md` · ADR-0010 (UI framework, confirmed in P04) · ADR-0011 (flags), ADR-0012 (notifications) · P04 spike findings (`phases/P04/`) · the P07 job system and notifications.

### Work packages
1. **Toolkit core (`ui-engineer`)** in the package fixed by ADR-0010:
   - token loading from a resource JSON (generated from `design/tokens.json` at build time or kept in sync by a test);
   - a theme object;
   - pixel-snapped drawing helpers on `GuiGraphics` via MaLiLib's `GuiContext` (or as the ADR decides);
   - clipping/scissor stack;
   - text measurement with ellipsis and wrapping for the vanilla font;
   - the sprite/icon atlas with placeholder support.
2. **Layout engine:** row/column/stack with gaps, padding, alignment, grow/shrink, min/max sizes, and scroll containers. Unit tests for the layout math at GUI scales 1–4 and for odd window sizes.
3. **Focus and input:** a focus manager (tab order, arrow navigation in lists and grids, Enter/Space activation, Escape behaviour), visible focus rings, mouse capture for drags, scroll handling, and text input built on vanilla edit boxes (IME and clipboard as vanilla supports them).
4. **Components** (from `components.md`):
   - button, icon button, toggle, segmented control;
   - text, search and number fields;
   - dropdown/combobox, list and **virtual list** (≥ 100,000 rows without per-frame allocation proportional to the row count), tree;
   - tabs, split pane, panel, card, dialog;
   - toast (bound to P07 notifications), tooltip/help bubble;
   - progress (bound to P07 jobs), badge, keybind chip, block/item slot, empty and error states.
5. **Component gallery screen** (dev-only, opened by a debug keybind or command): every component in every state, so the screenshot harness and the human can review them.
6. **Screenshot harness (`test-engineer`).**
   - Client game tests render the gallery and the pilot at GUI scales 1, 2, 3 and 4 and at two window sizes. Screenshots are stored under `docs/enhanced/design/screenshots/P09/`.
   - Compare them with **reference screenshots** approved by the human. The first run produces candidates; the human approves them; later phases detect pixel diffs above a tolerance.
7. **Pilot screen (`ui-engineer`).**
   - Replace the Task Manager with a **Jobs** screen (P07 job registry + legacy tasks through the adapter), as in the approved mockup. Alternatively, pick another low-risk screen, approved in P04.
   - Behind flag `ui.pilot` (plus the global `ui.legacyScreens`).
   - Write a parity checklist against the legacy screen: every action and every piece of information.
8. **Performance (`perf-engineer`).** A scenario `ui-gallery-scroll` (scroll the 100k-row virtual list, open/close dialogs). Measure frame time and allocations per frame with JFR. Target: no regression in the frame-time median versus an empty screen beyond the threshold defined in `targets.md` (record it).
9. **Accessibility checks:** a test that computes token contrast (reuse the P04 script). Keyboard-only navigation of the gallery and the pilot through a game test (key events).

### Rules
No hard-coded colours, sizes or strings in screens (architecture or lint test). Translation keys via change requests to `en_us.json`. Art stays as placeholders. The legacy screen stays reachable.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The toolkit core, layout engine, focus manager and all listed components exist in the ADR-0010 package. Layout and focus logic have unit tests, including GUI scales 1–4 and odd sizes.
2. The virtual list handles ≥ 100,000 rows. The `ui-gallery-scroll` benchmark shows that per-frame allocation does not grow with the row count, and the frame-time budget from `targets.md` is respected (raw files).
3. The gallery renders every component in every state. Screenshots exist at scales 1–4 and two window sizes. The reference set is approved by the human and recorded in `DECISIONS.md`.
4. The pilot Jobs screen matches its approved mockup (side-by-side images in the report), passes its parity checklist, and is reachable behind `ui.pilot`. The legacy screen still works.
5. Keyboard-only operation of the gallery and the pilot is proven by a game test (focus order, activation, Escape).
6. A token-only lint or architecture test shows no hard-coded colours or sizes in screen code. All visible strings use translation keys.
7. Toasts and progress are bound to the P07 notifications and jobs (demonstrated by a test that runs a job and captures the toast/progress).
8. Full suites, golden masters and the config-defaults snapshot are green. `fly-M` is within thresholds (the UI layer must not affect world rendering).

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (gallery, pilot, keyboard navigation, screenshots).
- `ui-gallery-scroll` benchmark (≥ 5 runs) + a JFR allocation profile.
- Lint/architecture test for hard-coded colours and strings.
- `fly-M` regression check.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P09/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-09-ui-kit-audit.md` with BASE=`enhanced/p08-pass` and HEAD=`phase/P09-ui-kit`."
