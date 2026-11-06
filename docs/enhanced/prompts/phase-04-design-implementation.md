# Litematica Enhanced — P04 · Design system and GUI mockups
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P04-design` created from `enhanced/p03-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** M · **Human checkpoint:** YES — approval of the visual direction and of every key screen mockup (iterations allowed) before any GUI implementation

---

## 0. Global context (read carefully)

You are the **lead** of phase **P04** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P04-design` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p03-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P04/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P04/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (M) or needs a decision reserved for the human, **stop and ask**, proposing a split (P04a/P04b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P04/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P04/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P04/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P04] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P04/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P04/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P04 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P04 — Design system and GUI mockups

**Agents for this phase:** lead · `ux-designer` (author) · `ui-engineer` (in-game feasibility spike) · `independent-auditor`

### Goal
Let the human **see** the future interface before any of it is built. Define a coherent design system that fits Minecraft's constraints, redesign the top journeys, and produce realistic mockups of the key screens. Prove feasibility with a small in-game spike.

### Inputs
`phases/P02/synthesis.md` (journeys, step counts, heuristic findings) · `registers/features.md` · ADR-0010 (UI framework, provisional) · ADR-0012 (notifications) · `REFERENCE.md` §1 (principles), §4.5 (UI approach) · game-test screenshots of the current screens.

### Work
1. **UX principles and information architecture** (`design/ux-principles.md`, `design/ia.md`).
   - Task-first navigation, for example:
     - *Home* (recent work, continue building);
     - *Library* (schematics);
     - *Placements*;
     - *Selections*;
     - *Build assistant* (verify + materials + progress);
     - *Tools*;
     - *Settings*;
     - plus a global **command palette** and a contextual **tool HUD / context menu**.
   - Map every existing feature ID to its new home. Nothing may be orphaned. Removals are not allowed in this phase.
2. **Journey redesign** (`design/journeys.md`): for each P02 journey, give the new flow and the step counts before and after.
3. **Design tokens** (`design/tokens.json` + `design/tokens.md`):
   - colour roles (surface, surface-raised, border, text, text-muted, accent, success, warning, danger, info, focus, overlay colours for the in-world verifier);
   - at most two themes ("Classic", close to today; "Modern"), only if both are justified;
   - spacing on the GUI pixel grid; type scale with the vanilla font (no other fonts in game);
   - elevation by shading, icon sizes, motion (minimal; respect reduced motion).
   - **Contrast report computed by a script** (WCAG ratio for each text/background pair), committed with its output.
4. **Component catalogue** (`design/components.md`): button, icon button, toggle, segmented control, text field, search field, number field with stepper, dropdown/combobox, list, **virtual list**, tree, tabs, split pane, panel, card, dialog, toast, tooltip/help bubble, progress (determinate/indeterminate), badge, keybind chip, block/item slot, empty state, error state. For each: anatomy, states (default/hover/focus/pressed/disabled/error/loading), keyboard behaviour, min/max sizes at GUI scale 1–4.
5. **Mockups** (`design/mockups/*.html`). Self-contained HTML/CSS, no external assets. A pixel grid in "scaled GUI units" with toggles for 2×/3×/4×. Two canvas sizes: 427×240 units (1280×720 at scale 3) and 320×240 units (minimum). Placeholder icons are clearly marked. Screens:
   - Home/shell;
   - command palette;
   - Library (list + grid + filters + details panel + empty state);
   - load/convert/save dialogs;
   - job/progress toasts and the jobs screen;
   - placement list + placement editor (transforms, origin, layers);
   - sub-region editor;
   - area selection editor (normal and simple);
   - tool HUD + context menu (in-world overlay);
   - verifier screen + in-world overlay legend;
   - material list / build assistant panel;
   - settings (search, categories, changed-only, profiles placeholder);
   - keymap editor with a conflict display;
   - diagnostics screen.
   Export PNG screenshots with a headless browser if one is available (dev tooling only; document the command). Otherwise list the files for the human to open.
6. **In-game feasibility spike** (`ui-engineer`, branch `spike/P04-ui`, **never merged**). Implement a panel, a button and a 10,000-row virtual list with the tokens, using vanilla `GuiGraphics` through MaLiLib's `GuiContext` (or the approach in ADR-0010). Capture game-test screenshots at GUI scales 1–4. Measure the frame cost (JFR + frame timer) of the virtual list while scrolling. Report what does not translate from HTML to the game (font metrics, pixel snapping, clipping).
7. **Art policy.** Reuse Litematica/vanilla sprites. Any new icon is a **placeholder**, named `*_placeholder`. List which final art is needed (`design/art-needs.md`) for a human artist or a licence-compatible human-made set. AI-generated art must never be presented as final.
8. **Human review loop.** Present the mockups, grouped by screen family. Ask for approval or changes per screen (AskUserQuestion, plus a free-text option). Iterate up to 3 rounds per family. Record the approval of each screen in `DECISIONS.md` with the mockup file hash. Confirm or amend ADR-0010 based on the spike, with human approval.

### Out of scope
Production GUI code (P09+), new features not present in `registers/features.md` (put new ideas in the P05 long-list instead).

### Acceptance criteria (each must be evidenced in the claims ledger)
1. `ia.md` maps **every** feature ID in `registers/features.md` to a place in the new navigation. No orphans, no removals.
2. `journeys.md` gives before/after step counts for ≥ 12 journeys. The "after" counts are consistent with the mockups.
3. `tokens.json` and `tokens.md` exist. The contrast report is produced by a committed script: all body text ≥ 4.5:1, large/bold text and icons ≥ 3:1 against their backgrounds (or justified exceptions).
4. `components.md` specifies all listed components, with states, keyboard behaviour and size constraints at GUI scales 1–4.
5. The 14 mockup files exist, open offline, support 2×/3×/4× and the two canvas sizes, and use only the tokens (checked by a script that flags colours not in `tokens.json`).
6. The spike produced screenshots at GUI scales 1–4 and a measured frame cost for the 10k-row list (raw file). Translation issues are documented. The spike branch is not merged.
7. Placeholder art is clearly marked, and `art-needs.md` lists the final art required.
8. `DECISIONS.md` records human approval for every screen family (with mockup hashes) and the confirmed or amended ADR-0010.
9. No changes under `src/main/**` on the phase branch.

### Mandatory tests and checks
- Contrast script run (output committed).
- Token-usage linter on the mockups (output committed).
- Spike game test (screenshots) and frame-cost measurement (raw file).
- `git diff --stat enhanced/p03-pass..HEAD -- src/main` → empty.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P04/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-04-design-audit.md` with BASE=`enhanced/p03-pass` and HEAD=`phase/P04-design`."
