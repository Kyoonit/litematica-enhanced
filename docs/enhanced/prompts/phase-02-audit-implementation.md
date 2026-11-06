# Litematica Enhanced — P02 · Deep technical and functional audit
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P02-audit` created from `enhanced/p01-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Review the synthesis (no formal approval needed; the human may add priorities)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P02** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P02-audit` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p01-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P02/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P02/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P02a/P02b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P02/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P02/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P02/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P02] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P02/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P02/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P02 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P02 — Deep technical and functional audit

**Agents for this phase:** lead · `cartographer` (knowledge notes) · `architect` · `perf-engineer` · `reliability-engineer` · `ux-designer` · `feature-designer` · `upstream-liaison` · `independent-auditor` (challenge). Optional: agent team for consolidation (see §Consolidation)

### Goal
Understand the mod deeply **before** redesigning it. Confirm or refute every hypothesis in `docs/enhanced/STRATEGY.md §4` with evidence. Find what the strategy missed. Produce ranked registers that P03–P05 can use without re-reading the code.

### Hard constraint
This phase is **read-only on `src/main/**`**. Experiments (fault injection, mutation, instrumented builds) happen in throwaway worktrees and are never merged. New *tests* that characterise a confirmed bug may be added under `src/test/**` as **disabled or expected-failure tests with a register ID**, so the bug is reproducible for P06. Everything else goes into documents.

### Parallel investigations (run 5–6 subagents concurrently; each writes `docs/enhanced/phases/P02/agents/<agent>.md`)
1. **`architect` — architecture and code quality.**
   - Package dependency graph (`jdeps` from the JDK, no new dependency) and cycles.
   - Static-state coupling: count of `getInstance()` / `DataManager.*` per package.
   - God classes (size, responsibilities), duplicated logic hotspots, dead code (unused classes and methods; commented-out blocks per file).
   - Error-handling patterns (swallowed exceptions), API surface used by add-ons (input from upstream-liaison).
   - Comparison of the design with masa's rewrite (`upstream-masa/ornithe/1.12.2`, read-only).
   - Output: confirm/refute ARCH-01..07, plus new ARCH-* findings.
2. **`perf-engineer` — measured performance.**
   - Run every benchmark scenario with JFR (CPU sampling, allocation, GC, thread states).
   - Attribute frame time and allocations to code: top 10 hotspots with % share and evidence files.
   - Confirm/refute PERF-01..09, with numbers from raw files only.
   - Add scenarios if needed (versioned), for example `chunk-transition-L` for the symptom behind the third-party "Chunk Lag Fix" add-on.
   - Measure memory: retained heap per placed block for S/M/L (heap after GC, with and without a placement), and identify what holds it (schematic container vs schematic world vs meshes vs verifier).
3. **`reliability-engineer` — reliability, security, compatibility.**
   - Fault injection in a scratch worktree:
     - kill the JVM during `save-L` with `override=true` → is the file corrupted? (REL-01);
     - dimensions above 2³¹ cells (REL-02);
     - Servux transmit slice index against Servux's receiving code (REL-03; clone `sakura-ryoko/servux` read-only);
     - malformed NBT (truncated, wrong palette indices, huge lists, deep nesting) → behaviour of readers (REL-04);
     - corrupted JSON data files (REL-05);
     - disconnect, dimension change and exit during paste/save/load (REL-06);
     - `.mcfunction` and command generation with hostile block NBT strings (SEC-01).
   - Thread-safety review of `PlacementManagerDaemonHandler` and the render dispatcher (PERF-08).
   - Compatibility matrix: Sodium, Iris, Voxy, Jade, ModMenu, Bobby. Test what you can automatically, list manual checks for the human.
   - Easy Place fairness review (REL-07): what packets are sent, when, and on what cause.
4. **`ux-designer` — features, journeys, heuristics.**
   - Complete the feature inventory seeded in P00: every config option, hotkey, tool mode, screen, command, and implicit behaviour (mixin-driven) mapped to a feature ID. Record its entry points, the steps to use it, and the related configs.
   - Document **≥ 12 user journeys** (for example J-01 build from a downloaded schematic in survival; J-02 capture an area and save; J-03 align a placement precisely; J-04 work layer by layer; J-05 find and fix mistakes; J-06 gather materials; J-07 manage many schematics; J-08 sub-regions; J-09 paste in creative/server; J-10 use schematic projects; J-11 configure for a strict server; J-12 recover from a crash or mistake).
   - For each journey: step counts (clicks/keys/screens, counted from code and game-test screenshots) and pain points.
   - Heuristic evaluation (Nielsen's 10) of each screen, with screenshots from game tests.
   - Confirm/refute UX-01..08.
5. **`feature-designer` — ecosystem and opportunities.**
   - Add-ons and competitors (Axiom docs, Litematic Downloader, Better List, Syncmatica and forks, printers): what needs they reveal.
   - Upstream issues/PRs/discussions **where accessible** (WebFetch may be blocked on GitHub issue lists: say so; never invent counts).
   - masa rewrite features missing from the 26.3 line.
   - A **long-list** of improvement and new-feature ideas with a one-line rationale. **No selection** (that is P05).
   - Mark F3 (autonomous) ideas as rejected.
6. **`upstream-liaison` — upstream intelligence.**
   - Commit velocity and areas of churn in `upstream-sakura` (last 6 months; `git log --stat`), which predict sync conflict zones.
   - Add-on dependency scan: clone ≥ 4 add-ons read-only into a scratch directory (Syncmatica, a printer, Better List, Litematic Downloader, if public) and grep which Litematica classes, methods and mixins they use → `docs/enhanced/compat/addons.md` (API surface to keep stable).
   - Classify every confirmed finding as A/B/C.
7. **`cartographer` — knowledge notes.** One note per subsystem (≤ 200 lines each, template), stamped with the commit:
   schematic model and formats, containers, placements and sub-regions, schematic world, rendering pipeline, verifier, material lists, selection and area tools, tool modes and input, Easy Place and pick block, paste/command tasks, persistence (DataManager, JSON), networking (Servux/Syncmatica), GUI layer, configs and hotkeys, compat.
   Also fill `knowledge/mixin-register.md` for all existing mixins.

### Consolidation (lead)
- Merge findings into `registers/problems.md`. For each row: severity S1–S4, confidence (observed/measured/hypothesis), evidence link, reach (how many users or journeys), proposed action, target phase, upstream category.
- Rank by severity × likelihood × reach. Explain the scoring.
- `registers/features.md`: every feature gets **keep / improve / replace / remove-candidate**, with a justification. A *remove-candidate* requires the usage analysis (configs, hotkeys, add-ons, journeys) and is **never** removed in this phase.
- `docs/enhanced/phases/P02/synthesis.md` (≤ 4 pages):
  - top-20 problems;
  - keep/improve/replace/remove matrix;
  - journey summary with step counts;
  - performance profile (where time and memory go);
  - compatibility constraints (add-on API surface, mod compat);
  - upstream opportunities;
  - updated risks;
  - what changed versus STRATEGY.md (confirmed / refuted / new).
- **Challenge round**: run `independent-auditor` on the top-20 findings. It must try to refute each one. Record disputes and resolutions in `synthesis.md`. (Optional: if `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is enabled for this phase only, run a 3–4 teammate debate on the top-10 instead. Turn it off afterwards.)

### Out of scope
Fixing anything, designing solutions beyond one-line "proposed action", changing `src/main/**`.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Every STRATEGY finding ID (UX-01..08, PERF-01..09, ARCH-01..07, REL-01..08, SEC-01) has status **confirmed / refuted / unclear**, with evidence: a code reference, a raw benchmark/JFR file, or an experiment log.
2. All P01 scenarios (plus any added ones) were run with JFR. The top-10 hotspots are quantified (share of frame time or allocation) with links to raw files. Retained heap per placed block is measured for S/M/L, with an attribution of what holds it.
3. The fault-injection results for REL-01..06 and SEC-01 are documented with reproducible steps. Every confirmed bug has a disabled/expected-failure test or a precise reproduction recipe, with its register ID.
4. The feature inventory is complete: every config option, hotkey, tool mode, screen and command has a feature ID and a keep/improve/replace/remove-candidate status with justification. Each remove-candidate has a usage analysis.
5. ≥ 12 user journeys are documented with step counts and pain points, backed by game-test screenshots.
6. `compat/addons.md` lists the Litematica API surface used by ≥ 4 add-ons (or documents why one could not be analysed). The mod compatibility matrix has automated results and a manual checklist for the human.
7. Knowledge notes exist for the 16 listed subsystems, each stamped with a commit. `mixin-register.md` covers 100% of the existing mixins (count matches `mixins.litematica.json`).
8. `registers/problems.md` is ranked with an explained scoring model. Every row has an upstream category.
9. `synthesis.md` exists, including the challenge-round record (disputed findings and resolutions).
10. `git diff --stat enhanced/p01-pass..HEAD -- src/main` is **empty**.

### Mandatory tests and checks
- `./gradlew clean build test` (must stay green; added characterisation tests are disabled or expected-failure and documented).
- Game tests used for screenshots (log).
- Benchmarks with JFR: all scenarios (raw files under `docs/enhanced/benchmarks/results/` or compressed artefacts with hashes).
- `git diff --stat enhanced/p01-pass..HEAD -- src/main` → empty.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P02/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-02-audit-audit.md` with BASE=`enhanced/p01-pass` and HEAD=`phase/P02-audit`."
