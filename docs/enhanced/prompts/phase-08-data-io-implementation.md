# Litematica Enhanced — P08 · Schematic model and I/O foundations
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P08-data-io` created from `enhanced/p07-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** No (playtest recommended: loading and saving many real schematics)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P08** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P08-data-io` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p07-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P08/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P08/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P08a/P08b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P08/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P08/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P08/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P08] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P08/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P08/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P08 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P08 — Schematic model and I/O foundations

**Agents for this phase:** lead · `architect` (model and codecs) · `reliability-engineer` (IO safety, validation, fuzzing) · `perf-engineer` (load/metadata/memory measurements) · `test-engineer` (golden equivalence, fuzz harness) · `cartographer` · `independent-auditor`

### Goal
Give Litematica a clean, safe, fast schematic layer:
- a `Schematic` model with per-format codecs, aligned with masa's rewrite;
- a metadata-only fast read;
- **asynchronous, cancellable loading** (no more client-thread file parsing from GUI handlers);
- atomic saves everywhere;
- validation and repair reports, size guards;
- a **metadata index** for the future library;
- memory accounting.
File formats must stay **exactly** compatible.

### Inputs
ADR-0008 (model and storage), ADR-0009 (persistence), ADR-0006/0007 (threading, jobs) · `knowledge/` notes on the schematic model, formats, containers and persistence · registers: ARCH-02, PERF-04, PERF-05, REL-01, REL-02, REL-04, SEC-01 · P01 golden masters · P02 heap attribution · `compat/addons.md` (which `LitematicaSchematic` methods add-ons use).

### Work packages
1. **Model and codecs (`architect`).**
   - Introduce the `Schematic` interface and supporting types (metadata, regions, block containers, entity/BE data) per ADR-0008.
   - Extract the readers and writers from `LitematicaSchematic` (about 3,400 lines) into **codecs**:
     - Litematica v7 read/write;
     - v6 downgrade export;
     - Sponge v1/v2/v3 read (plus write if upstream supports it);
     - vanilla structure read/write;
     - Schematica read/write.
   - Do it **incrementally**: one codec per commit series, each proven equivalent by the golden masters.
   - `LitematicaSchematic` remains as a **compatibility facade** with its public methods intact (add-on API surface). Deprecate internals only where ADR-0014 allows.
   - Container selection (dense/sparse) per the ADR. Use `long` indexing with validated dimensions (completes REL-02).
2. **Metadata-only read (`architect` + `perf-engineer`).** Read the name, author, description, sizes, region count, total blocks, data version, timestamps and preview image (if present) **without** decoding block arrays. Benchmark it against a full load for S/M/L/XL.
3. **Async loading (`architect` + `reliability-engineer`).**
   - Replace synchronous `createFromFile` calls from GUI handlers (`GuiSchematicLoad`, `GuiSchematicManager`, `SchematicHolder.getOrLoad` callers…) with **load jobs** that report progress (bytes, phase), can be cancelled, and deliver results on the client thread.
   - Keep a synchronous API for add-ons, documented as such.
   - The GUI shows progress through the existing message mechanism for now. The new UI comes later.
   - Behind flag `io.asyncLoad` (default **on** once tests pass; legacy path kept).
4. **Atomic saves everywhere (`reliability-engineer`).** Every writer (schematics in all formats, material-list exports, area selections, placements, projects, index) uses the atomic helper (temp → flush/force → atomic move → optional `.bak`). An architecture test forbids opening an output stream directly on a final target path in schematic/data code.
5. **Validation and repair report (`reliability-engineer`).**
   - On load, collect: unknown blocks/properties, palette index out of range, region dimension problems, entity/BE decoding errors, data-version mismatches and fixer outcomes.
   - Offer repair options (replace unknown with air or a chosen block, clamp, skip entity).
   - Display through notifications, with "copy details".
   - Never crash the client on a malformed file.
6. **Limits and fuzzing (`reliability-engineer` + `test-engineer`).**
   - Limits: size, NBT depth, palette size, region dimensions, entity count, string length, from config with safe defaults.
   - A seeded fuzz harness (≥ 10,000 mutated inputs per format from the corpus): truncation, bit flips, wrong types, huge lengths, deep nesting.
   - Every input must finish within a timeout with a clean error or a successful load. Never a hang, an OOM, or a crash.
7. **Metadata index (`architect` + `perf-engineer`).**
   - A sidecar cache at the location set by ADR-0009, keyed by path + size + mtime (+ content hash on demand), storing the metadata needed by the library (P10).
   - An incremental rescan job, safe with concurrent file changes.
   - Tags, favourites and recents are stored here (empty for now).
   - Benchmark: index build and rescan for 1,000 fixture files.
8. **Memory accounting (`perf-engineer`).** An API returning the estimated bytes per loaded schematic and per placement (containers, palettes, schematic world), exposed through diagnostics. Validate the estimates against measured heap (JFR/heap dumps) on S/M/L. Report the error margin.

### Constraints
- **Golden masters must stay identical** (semantic comparison of decoded content; byte equality for writers where upstream is deterministic, excluding timestamps). Any difference is a defect unless an ADR explains it.
- Placement and rendering behaviour unchanged (only how the schematic object is produced changes).
- Add-on API surface from `compat/addons.md` keeps compiling: write a **compile-only compat test** using the listed methods.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The `Schematic` interface and the codecs for every format exist. `LitematicaSchematic` is a facade. Every golden master is unchanged (semantic equivalence for reads; deterministic writer outputs identical apart from timestamps).
2. Region indexing uses overflow-safe arithmetic. Boundary tests cover the limits (2³¹−1, 2³¹, negative, zero).
3. Metadata-only read works for every format that carries metadata, and it is faster than a full load for M/L/XL by the improvement threshold (raw benchmark files).
4. No GUI handler calls a synchronous file load on the client thread (architecture test plus code search). Load jobs report progress, cancel cleanly (no partial state left in the holder or the placement manager), and deliver on the client thread. Behind `io.asyncLoad`, the legacy path is still tested.
5. Every writer uses the atomic helper (architecture test). A fault-injection test proves that the original file survives a crash during overwrite, for at least `.litematic` and one JSON data file.
6. The validation report covers the listed categories, offers repair options, and is tested with crafted malformed fixtures.
7. The fuzz harness ran ≥ 10,000 inputs per format with zero crashes, hangs or OOMs (summary log with seeds). Limits are configurable and tested.
8. Index correctness tests pass (add, remove, modify, rename, concurrent modification). The 1,000-file build/rescan benchmark is recorded.
9. The memory accounting API is validated against measured heap for S/M/L, with the error margin reported.
10. The add-on compile-compat test is green. Full suites green. `load-*`, `save-L` and `fly-M` are within thresholds or improved (raw files).

### Mandatory tests and checks
- `./gradlew clean build test` + game tests + architecture tests + the add-on compile-compat test.
- Golden masters (full), fuzz harness (seeded; summary log), fault-injection tests.
- Benchmarks: `load-S/M/L/XL` (full vs metadata), `save-L`, the index 1,000-file scenario, `fly-M` (≥ 5 runs each).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P08/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-08-data-io-audit.md` with BASE=`enhanced/p07-pass` and HEAD=`phase/P08-data-io`."
