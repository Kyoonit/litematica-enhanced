# Litematica Enhanced — P05 · Feature specification and backlog
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P05-features` created from `enhanced/p04-pass` (or enhanced/p03-pass if you run P05 in parallel with P04), and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** M · **Human checkpoint:** YES — selection of the features to implement in P15 (improvements), P16 and P17 (new features), and confirmation of rejected ideas

---

## 0. Global context (read carefully)

You are the **lead** of phase **P05** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P05-features` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p04-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P05/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P05/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (M) or needs a decision reserved for the human, **stop and ask**, proposing a split (P05a/P05b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P05/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P05/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P05/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P05] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P05/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P05/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P05 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P05 — Feature specification and backlog

**Agents for this phase:** lead · `feature-designer` (author) · `architect` (cost and interactions) · `reliability-engineer` (fairness, risks) · `ux-designer` (UX fit) · `upstream-liaison` (category) · `independent-auditor`

### Goal
Turn the inventory, the improvement findings and the idea long-list into **specified, costed, prioritised feature cards**. The human then chooses what gets built.

### Inputs
`registers/features.md` (inventory + keep/improve/replace statuses) · `phases/P02/synthesis.md` (journeys, pain points, ecosystem, long-list) · `STRATEGY.md §11` (ideas) · ADRs (especially ADR-0006 threading, ADR-0008 model, ADR-0013 fairness, ADR-0014 compat) · `design/` (IA, mockups) · `compat/addons.md`.

### Work
1. **Card every candidate** (`docs/enhanced/specs/FEAT-NNN-<slug>.md`, template `feature-card.md`):
   - every existing feature marked *improve* or *replace* in P02;
   - every idea from the P02 long-list and STRATEGY §11.
   Ideas to examine include, but are not limited to:
   - indexed library with tags, collections and thumbnails;
   - command palette;
   - per-server configuration profiles with a "strict server" preset;
   - crash-safe autosave and a recovery dialog;
   - build progress per layer and material, with an ETA;
   - render-layer auto-advance when a layer is complete (UI state only);
   - storage-aware material planning (player inventory, ender chest cache, containers the player has **opened**; no remote scanning);
   - shopping list and layer-sheet export (PNG/CSV);
   - schematic diff/compare (schematic ↔ schematic, schematic ↔ world);
   - lightweight version history/backups;
   - grid/array placements (from masa's rewrite);
   - schematic health check and repair, with a block-state remapping UI for unknown or modded blocks;
   - material substitution in a placement (non-destructive);
   - keymap profiles and a conflict detector;
   - onboarding and contextual help;
   - a diagnostics screen;
   - a server feature-policy channel;
   - add-on API stabilisation.
2. **Fairness gate.** Classify every card F0/F1/F2. Any F3 idea (autonomous interaction such as a printer, auto-placing, auto-restocking or auto-walking) is **rejected**, with a one-line reason, in `specs/REJECTED.md`.
3. **Costing with the architect.** For each card:
   - S/M/L/XL with a justification;
   - the foundations it needs (P07/P08/P12/P13 outputs);
   - the subsystems it touches;
   - its risk level.
4. **Interactions matrix** (`specs/interactions.md`): card × subsystem/feature, marking conflicts (for example "auto-advance layers" vs "manual render layer hotkeys"; "material substitution" vs "verifier expectations"; "profiles" vs "per-world configs").
5. **Scoring** (`specs/scoring.md`): an explicit, reproducible model such as value × reach × confidence ÷ cost, with the definitions of each scale. Do not invent usage data: reach and value are justified qualitatively, from journeys and evidence.
6. **Proposed allocation**: P15 (improvements to existing features), P16 (wave 1) and P17 (wave 2), each within an L size budget, plus a cut line and a "later/parking lot". Mark upstream category A/B/C per card.
7. **Human selection.** Present the proposed allocation with the top alternatives. Let the human move items across the cut line (AskUserQuestion, then free text). Record the selection in `DECISIONS.md`. Set `phase` and `status` in `registers/features.md`.
8. **Final specs for selected cards.** Testable acceptance criteria, UX references (mockup or a design addendum to produce in the implementing phase), test plan, flags, documentation needs.

### Out of scope
Implementation. Redesigning the approved mockups (an addendum may be requested for new screens; it is produced in the implementing phase and approved there).

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Every *improve/replace* feature from P02 and every long-list idea has a complete card (all template fields filled) or an explicit merge into another card.
2. Every card has a fairness class. All F3 ideas are listed in `specs/REJECTED.md` with reasons, and none appears in an allocation.
3. Every card has a cost class with a justification, the foundations it requires, the subsystems it touches, and risks agreed with the architect (noted in the card).
4. `specs/interactions.md` covers every selected card against every subsystem it touches, and names the conflicts with their resolutions.
5. `specs/scoring.md` defines the model, and the scores can be recomputed from card fields (a script or a table with formulas).
6. The allocation for P15/P16/P17 fits L-size budgets (justified) and states upstream categories.
7. The human selection is recorded in `DECISIONS.md`. `registers/features.md` reflects it (phase, status).
8. Each selected card has testable acceptance criteria and a test plan.
9. No changes under `src/main/**`.

### Mandatory tests and checks
- Score recomputation script/table matches the card values (log).
- Consistency check: every selected card ID exists in `registers/features.md` with the right phase (script or manual table).
- `git diff --stat <base>..HEAD -- src/main` → empty.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P05/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-05-features-audit.md` with BASE=`enhanced/p04-pass` and HEAD=`phase/P05-features`."
