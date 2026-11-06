# Litematica Enhanced — P01 · Test and measurement harness
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P01-harness` created from `enhanced/p00-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** No (but the human may need to run benchmarks on the reference machine if this session has no display)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P01** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P01-harness` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p00-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P01/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P01/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P01a/P01b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P01/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P01/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P01/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P01] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P01/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P01/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P01 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P01 — Test and measurement harness

**Agents for this phase:** lead · `test-engineer` (unit/golden/game tests, corpus, CI) · `perf-engineer` (benchmark harness, JFR, protocol, baseline runs) · `cartographer` (support) · `independent-auditor` (pre-audit)

### Why this phase exists
At baseline the project has **zero automated tests** and **no benchmark protocol**. Every later claim ("refactor without regression", "2× faster") depends on what you build here. This phase **characterises current behaviour**. It does not fix it. Known bugs are captured as they are and flagged, not corrected.

### Inputs
`docs/enhanced/STATE.md` · `REFERENCE.md` §6 (testing and benchmark policy) · `knowledge/build.md` · `knowledge/architecture-map.md` · `registers/problems.md` (PERF-*, REL-* to design scenarios around) · Fabric automated-testing docs (https://docs.fabricmc.net/develop/automatic-testing: check the version matching the project's Loom/Loader; do not copy DSL blindly).

### Work packages
**WP1 — Test tooling ADR (lead).** `docs/enhanced/adr/ADR-0001-test-tooling.md` covers:
- Fabric Loader JUnit (testImplementation, same version as the loader) + JUnit 5;
- the Fabric client game-test source set (Fabric API **only** on the gametest classpath, never in `fabric.mod.json` depends or the shipped jar);
- optional jqwik (property tests), JaCoCo (Gradle core plugin, coverage), and an ArchUnit-style library for architecture tests.
Justify each one. Reject what you do not need.

**WP2 — Unit test infrastructure (`test-engineer`).**
- `src/test/java` mirrors the main packages. Registry bootstrap per the Fabric docs, for tests that need block states.
- First test families:
  - container get/set and palette growth, including the bit-width transitions;
  - position and transform utilities (all 8 rotation × mirror combinations on representative block states: stairs, rails, doors, observers, signs, beds);
  - `.litematic` write → read round-trip;
  - Sponge v1/v2/v3 load, vanilla structure load, Schematica load, on fixtures;
  - material-list counting on fixtures;
  - config defaults snapshot (every option ID and default value), so later phases detect accidental default changes.
- `./gradlew test` must stay under ~2 minutes. Slow suites get a separate task.

**WP3 — Deterministic schematic corpus (`test-engineer`).**
- A generator in test sources produces fixtures from a seed. Families:
  - size classes S (32³), M (128×64×128), L (512×128×512); an XL (1024×256×1024) for **local benchmarks only**;
  - density (sparse, dense, hollow shell);
  - palette size (small, ~4,096 states);
  - block-entity-heavy (chests with items, signs);
  - entity-heavy (item frames, armour stands);
  - multi-region with sub-region offsets.
- Small fixtures are committed under `src/test/resources/corpus/`. Large ones are generated on demand into `build/` and never committed.
- Same seed → byte-identical output (prove it with a test). No third-party schematics unless their licence is recorded in `docs/enhanced/compat/assets.md`.

**WP4 — Golden-master (characterisation) tests (`test-engineer`).**
- For each fixture, record semantic outputs: block-state histogram, region dimensions, entity/BE counts, metadata fields, and a stable hash of the decoded content. Exclude timestamps.
- Cover format conversions (Sponge/vanilla/Schematica → Litematica) and the v6 downgrade export.
- Golden files live in `src/test/resources/golden/`, with a README explaining how they were produced (commit sha) and that they **characterise current behaviour, including known bugs** (link register IDs).

**WP5 — Client game tests (`test-engineer`).**
- A gametest source set that boots the client and creates or loads a superflat test world, then:
  - loads a fixture schematic and creates a placement at fixed coordinates;
  - waits until the schematic world reports its chunks built (expose a **read-only, dev-only** status accessor if needed);
  - takes screenshots at GUI scale 2 and 3 of the main menu, the placement list and the verifier screen;
  - runs the verifier on a prepared world state and asserts the mismatch counts.
- Document how to run it locally (window opens) and in CI (Linux + `xvfb-run`). If CI cannot run it reliably, make it a separate, non-blocking CI job, but it **must pass locally** before the audit.

**WP6 — Benchmark harness (`perf-engineer`).**
- Scenarios are versioned in `docs/enhanced/benchmarks/scenarios/*.md` and implemented as client game tests or a dev-only entrypoint enabled by a system property (e.g. `-Dlitematica.enhanced.bench=<scenario>`). Minimum set:
  - `load-S/M/L` (file → placement ready);
  - `fly-M`, `fly-L` (fixed camera path through the placement);
  - `layer-rebuild-L` (switch render layer mode and range);
  - `move-placement-M`;
  - `verify-M`;
  - `material-list-L`;
  - `save-L`;
  - `dimension-change-M` (placements active).
- Recording uses `jdk.jfr` (built into Java 25: no dependency). Frame times come from a lightweight per-frame timestamp collector, enabled only in bench mode. A summary exporter writes JSON matching `docs/enhanced/templates/benchmark-result.schema.json`, with the machine fingerprint.
- A comparison tool (Gradle task or small Java CLI in a non-shipped source set) produces a before/after Markdown table (median, IQR, delta %, threshold verdict per REFERENCE §6.2).
- Fill in `docs/enhanced/benchmarks/PROTOCOL.md`: fingerprint fields, warm-up, run count, settings (render distance, GUI scale, window size, vsync off, FPS cap), and how to run everything with one command.

**WP7 — Measurement seams in production code (`perf-engineer`, minimal).**
- Only where scenarios cannot observe progress otherwise (for example "all schematic chunks built", "verifier finished", per-section mesh build duration).
- Seams are **no-ops unless bench/dev mode is enabled**, add no allocation per frame when disabled, are listed in the report, and carry a modification notice.
- Prove there is no overhead: compare `fly-M` with seams compiled in but disabled against the baseline jar built from the baseline tag. The result must be within noise.

**WP8 — CI (lead).** Extend the GitHub workflow: build + unit tests on push/PR; upload test reports; a separate game-test job (xvfb) as described. Do not remove the existing build step.

**WP9 — Baseline measurements (perf-engineer + human).**
- On the **reference machine** (the human's PC), run at least `load-L`, `fly-L`, `layer-rebuild-L`, `verify-M`, `material-list-L` and `save-L` with the full protocol (≥ 1 warm-up + ≥ 5 runs), with **seams disabled except what the scenario needs**.
- Commit the result JSON files as `docs/enhanced/benchmarks/results/<date>_P01-baseline_<scenario>.json`.
- If this session cannot open a game window, stop and ask the human to run `<one command>` and commit the files. Never fabricate numbers.

**WP10 — Docs.** `docs/enhanced/knowledge/testing.md` (how to run each suite, how to add a fixture, how to regenerate golden files and when that is allowed). Update `CLAUDE.md` § Commands with the real task names.

### Out of scope
Fixing bugs (log them), optimisations, refactors beyond the minimal seams, UI changes.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. ADR-0001 is written and lists every test-scope dependency with its justification. `fabric.mod.json` and the shipped jar contain **no** new runtime dependency (jar inspected).
2. `./gradlew test` passes and runs meaningful tests covering at least: container behaviour, the 8 transform combinations on representative blocks, `.litematic` round-trip, Sponge v1/v2/v3, vanilla structure and Schematica loading, conversions and v6 downgrade, material counts, and the config-defaults snapshot. Test counts are reported per family.
3. The corpus generator is deterministic (a test proves byte-identical output for the same seed). Committed fixtures are small, and large ones are generated on demand.
4. Golden files exist for every committed fixture and conversion, with a README stating the generating commit and listing the known-bug characterisations (register IDs).
5. The client game-test task boots the client, places a fixture, captures screenshots at GUI scales 2 and 3, asserts verifier counts, and passes locally (log + screenshots committed or linked). CI defines the game-test job.
6. The benchmark harness implements the 11 listed scenarios, writes JSON valid against the schema with a full fingerprint, and the comparison tool produces the threshold verdict table. `PROTOCOL.md` is complete.
7. Seams are listed, disabled by default, and proven within noise of the baseline jar on `fly-M` (raw files for both).
8. Baseline result files exist for the 6 required scenarios, with ≥ 5 measured runs each, from the reference machine.
9. CI is green on the phase branch (build + unit tests).
10. `knowledge/testing.md` exists and the `CLAUDE.md` commands are updated. No production behaviour changed: golden tests run against the baseline jar logic and pass.

### Mandatory tests and checks
- `./gradlew clean build test` from a clean checkout.
- The client game-test task (exact name in `knowledge/testing.md`), locally.
- Generator determinism test (run twice, compare hashes).
- Bench: `fly-M` with seams disabled vs the baseline jar (≥ 5 runs each) → comparison table.
- Jar inspection: list jar contents and `fabric.mod.json` depends → no Fabric API, no test libraries.
- Schema validation of every committed result JSON.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P01/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-01-harness-audit.md` with BASE=`enhanced/p00-pass` and HEAD=`phase/P01-harness`."
