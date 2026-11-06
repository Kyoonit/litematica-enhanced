# Litematica Enhanced — P10 · Navigation shell, command palette and schematic library
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P10-ui-library` created from `enhanced/p09-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — real library of your own schematics, load/save flows, palette

---

## 0. Global context (read carefully)

You are the **lead** of phase **P10** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P10-ui-library` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p09-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P10/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P10/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P10a/P10b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P10/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P10/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P10/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P10] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P10/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P10/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P10 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P10 — Navigation shell, command palette and schematic library

**Agents for this phase:** lead · `ui-engineer` · `ux-designer` (fidelity + journey checks) · `test-engineer` · `perf-engineer` (library/index performance) · `doc-writer` (user guide pages) · `independent-auditor`

### Goal
Replace the module-oriented entry point with the approved **task-first shell**. Add a **command palette** that reaches every action. Deliver the **schematic library** on top of the P08 metadata index, with search, filters, sorting, tags, favourites, recents and thumbnails. Load, save and convert flows run as async jobs.

### Inputs
Approved mockups: Home/shell, command palette, Library, load/convert/save dialogs, jobs (`design/mockups/`, `DECISIONS.md`) · `design/ia.md`, `journeys.md` · P09 toolkit · P08 index, metadata read, async load, atomic save · P07 jobs, notifications and flags · `registers/features.md` (library-related cards selected in P05 that belong to this phase, if any).

### Work packages
1. **Action registry (`ui-engineer`).**
   - A central registry of user actions (id, title key, description key, category, default hotkey link, availability predicate, fairness class, handler), aligned with masa's rewrite "action" concept.
   - **Every existing hotkey and main-menu button is registered** (generated from the inventory, checked by a test).
   - F2 actions (server-mutating) are marked and always confirmed.
2. **Shell / Home screen.**
   - Opened by the main Litematica menu hotkey when `ui.shell` is on.
   - Recent work, continue-building shortcuts, entry points to Library, Placements, Selections, Build assistant, Tools, Settings.
   - A link to the legacy main menu while `ui.legacyScreens` is on.
3. **Command palette.**
   - Global hotkey (configurable, conflict-checked); fuzzy search over actions, screens, settings (navigation to the option) and loaded schematics/placements.
   - Keyboard-first; shows the hotkey of each action; remembers recent commands.
   - Unavailable actions are shown greyed out with the reason.
4. **Library screen.**
   - Driven by the P08 index; list and grid views; details panel (metadata, dimensions, block count, format/version, file info, material summary from metadata if available).
   - Search (name, author, description, tags), filters (format, size ranges, data version, date, tags, favourites), sorting (name, date, size, blocks).
   - Folders and collections; tags/favourites/recents stored in the index sidecar.
   - **Thumbnails:** a deterministic top-down colour map generated off-thread from block map colours (no GPU, cached in the index). Embedded preview images are used when present.
   - Drag-and-drop import (if the platform and MaLiLib support it; otherwise a file-picker flow).
   - File operations: rename; move to an internal **trash** with undo (no immediate permanent delete); open the folder.
   - Path-traversal-safe names (reuse upstream sanitisers).
5. **Load / save / convert flows.**
   - All through jobs with progress, cancel and notifications.
   - The save dialog creates schematics from selections (existing behaviour) with clear options.
   - Conversion (Sponge/vanilla/Schematica → Litematica, v6 export) is available from the library details panel.
6. **Performance (`perf-engineer`).** Scenarios `library-open-1000` (time to interactive with 1,000 indexed files), `library-search` (keystroke-to-results latency), `thumbnail-build-1000`. Targets come from `targets.md`.
7. **Docs (`doc-writer`).** User guide pages: "Using the library", "Command palette", "Where did the old menu go?" (mapping old → new).

### Rules
The legacy main menu and the legacy load/manager screens remain reachable behind flags until parity. Every existing capability of those screens must exist in the new flows (parity checklist). No client-thread IO: the index and file operations run as jobs.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The action registry covers 100% of existing hotkeys and main-menu entries (a test compares it with the inventory). F2 actions are flagged and require confirmation (test).
2. The shell, palette and library match their approved mockups (side-by-side screenshots in the report) at GUI scales 2 and 3, and work at scale 4 in a 320×240 window.
3. Palette tests: fuzzy search finds every registered action by its title; hotkeys are displayed; unavailable actions show a reason; keyboard-only operation works (game test).
4. Library features work on a 1,000-file fixture set: search, every filter, sorting, tags, favourites, recents, thumbnails, details, rename, trash with undo. Each has a test.
5. Thumbnails are deterministic (the same schematic gives an identical image; test) and generated off the client thread (code plus a JFR thread check).
6. Load/save/convert use jobs with progress and cancel. A cancel leaves no partial state (tests). No synchronous file IO on the client thread in the new screens (architecture test or JFR evidence).
7. The parity checklists for the legacy main menu, load screen and schematic manager are complete. Legacy screens are still reachable behind flags.
8. `library-open-1000`, `library-search` and `thumbnail-build-1000` meet the `targets.md` targets (raw files). `fly-M` is within thresholds.
9. The journey step counts for J-01, J-02 and J-07 (or their equivalents) meet the "after" counts from `journeys.md` (counted on screenshots).
10. User guide pages exist and match the implemented behaviour.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (shell, palette, library flows, keyboard navigation, screenshots).
- Benchmarks: `library-open-1000`, `library-search`, `thumbnail-build-1000`, `fly-M`.
- Registry-vs-inventory coverage test.
- File operation safety tests (names with `../`, reserved Windows names, very long names, unicode).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P10/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-10-ui-library-audit.md` with BASE=`enhanced/p09-pass` and HEAD=`phase/P10-ui-library`."
