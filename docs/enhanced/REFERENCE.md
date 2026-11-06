# 03 — Reference Documentation: vision, structural decisions, technical strategy, development rules

> This document is the **constitution of the programme**. Every Claude Code prompt points to it, and Phase 0 copies it into the repository as `docs/enhanced/REFERENCE.md`. It changes only through an ADR approved by the human owner.
> Precedence when documents disagree: **human owner's explicit decision > this reference > ADRs > phase prompt > agent judgement.**

---

## 1. Vision

**Litematica Enhanced** aims to be the reference tool for planning, placing, building and verifying large Minecraft builds. It must be fast at scale, intuitive, trustworthy, fair on any server, and maintainable across quarterly Minecraft releases. It keeps what made Litematica great: client-side, precise, survival-friendly, format-compatible and free (LGPL).

### Product principles
1. **Task first.** Organise the UI around what players do (build from a schematic, capture an area, check progress, gather materials), not around code modules.
2. **Fast by default.** Never stall a frame for Litematica work. Heavy work is budgeted, cancellable and visible.
3. **Never lose user data.** Saves are atomic, previous versions are recoverable, and errors are explained.
4. **Help, don't play.** Show information and assist actions the player initiates. Never act on the world autonomously.
5. **Progressive disclosure.** Simple paths for common tasks, with full power one step away (palette, advanced panels).
6. **Compatible by default.** Existing schematics, configs, placements and add-ons keep working unless an ADR says otherwise and provides migration.
7. **Upstream-friendly.** Every change is shaped so that it *could* be proposed upstream, even when it will not be.

---

## 2. Facts the programme is built on (2026-11-06 baseline)

- Upstream for modern versions: `sakura-ryoko/litematica` and `sakura-ryoko/malilib`, branch `26.3`. Original author: masa (`maruohon`). His active work is the Ornithe 1.12.2 rewrite, which serves as the **design donor**.
- Minecraft 26.3, Java 25, Fabric Loader 0.19.5, Loom 1.18, MaLiLib 0.30.2, Litematica 0.29.2-sakura.1.
- Minecraft 26.1+ is unobfuscated and uses Mojang names. Fabric no longer maintains Yarn for these versions.
- Licence: LGPL-3.0-only for Litematica and MaLiLib.
- No automated tests exist at baseline. CI only builds.
- Modrinth (since 2026-08-13): AI disclosure required, primarily-AI projects refused, no AI-generated images on project pages.

---

## 3. Structural decisions

### 3.1 Decided now (programme level)

| ID | Decision | Rationale |
|---|---|---|
| D-01 | Base the fork on the **Sakura-Ryoko 26.3 line**, not masa's rewrite or a rewrite from scratch | Working, current, maintained. Lowest regression risk. Upstreamable |
| D-02 | Use **masa's rewrite as the design donor**: port designs/interfaces, re-implement on 26.x APIs, credit masa | Better architecture + alignment with the author's direction |
| D-03 | **Incremental strangler migration**: new subsystems sit behind facades and flags, and legacy paths stay until parity is proven | Users always have a working mod. Rollback stays cheap |
| D-04 | **Tests and measurements precede changes** in every subsystem (characterisation tests first) | Measured evidence. Rule "no invented results" |
| D-05 | **One supported Minecraft version at a time** on `enhanced/main` (currently 26.3), with recurring port procedures | Quarterly releases make multi-version support unaffordable at the start |
| D-06 | **No new runtime dependency** without an ADR. Test-scope tooling (Fabric Loader JUnit, Fabric API game tests, JMH, jqwik…) is allowed with an ADR entry | "No unnecessary dependency" rule. Keeps the mod light |
| D-07 | **Do not fork MaLiLib's look or API.** The fork builds its own UI layer and uses MaLiLib services (config, hotkeys, input, messages). Needed MaLiLib changes become upstream PRs to MaLiLib | MaLiLib is shared by masa's other mods. Users install one MaLiLib |
| D-08 | **No autonomous world interaction** (no printer, auto-build, auto-restock, auto-mining). See §7 | Server rules, fairness, upstream philosophy |
| D-09 | **Schematic format compatibility is sacred.** The fork reads and writes standard `.litematic` (v7, plus v6 export), Sponge, vanilla and Schematica as upstream does. Extra data lives in **sidecar/index files**, never in a new incompatible format | Users share files across forks and versions |
| D-10 | **Honest AI disclosure and real human ownership** of decisions, reviews and releases. See §10 | Platform policies, upstream trust, quality |
| D-11 | **Fork-specific contact and issue tracker**. The fork never routes users to masa's or Sakura-Ryoko's trackers | Respect for maintainers' time (masa explicitly asked not to be pinged for versions he does not maintain) |

### 3.2 To be decided in Phase 3 (recommendations)

| ID | Question | Recommended option | Alternatives |
|---|---|---|---|
| Q-01 | Mod id and identity | Distinct id (e.g. `litematica_enhanced`) with `"provides": ["litematica"]`, a distinct display name, and `breaks`/`conflicts` with the official `litematica` | Same id `litematica` (drop-in, but confusing and impossible to install side by side) |
| Q-02 | Package namespace | Inherited and upstreamable code stays in `fi.dy.masa.litematica.*`. Fork-only (Category C) code goes in a fork-owned namespace (e.g. `io.github.<owner>.lmx.*`) | Everything in the upstream namespace |
| Q-03 | Layering/modules | One Gradle module, strict package layering enforced by ArchUnit-style tests (test scope): `api` → `core` (pure, no MC) → `mc` (adapters, mixins) → `client` (render, GUI) | Multi-module Gradle build (more isolation, more friction with Loom) |
| Q-04 | Threading model | §4.3 below | Keep all work on the client thread with budgets only |
| Q-05 | UI framework | Fork-owned toolkit on vanilla `Screen`/`GuiGraphics` via MaLiLib's `GuiContext`, inspired by masa's rewrite (tabbed screens, actions, overlays) | Extend MaLiLib widgets; external UI library (owo-ui, ImGui) **rejected by default** (new dependency, look and feel) |
| Q-06 | Schematic world | Keep the `WorldSchematic` approach (vanilla renderers), isolated behind adapters. Reduce duplication (shared palettes, lazy materialisation) after P01/P02 measurement | Custom renderer reading containers directly (large rewrite, deferred) |
| Q-07 | Config compatibility | Read legacy `litematica.json` once and migrate to the fork's config file with a schema `version`. Never write the legacy file | Share the file with official Litematica (risky) |
| Q-08 | NeoForge | Out of scope until P19. Keep loader-specific code in adapters so it stays possible. Consider collaborating with Forgematica | Multi-loader from the start (Architectury/MultiLoader template) |

---

## 4. Technical strategy

### 4.1 Target layering
```text
api/        Stable, documented interfaces for add-ons (versioned, @ApiStatus annotated)
core/       Pure Java domain: schematic model, containers, transforms, verifier/material/diff
            engines, jobs, events. No net.minecraft imports except value types allowed by ADR
mc/         Adapters to Minecraft/Fabric/MaLiLib: block states, registries, NBT bridge,
            world access, networking, mixins (thin: they delegate immediately)
client/     Rendering (schematic world, meshing, overlays), GUI (fork UI toolkit + screens),
            input/tools, HUD
compat/     Optional integrations (Sodium, Iris, Voxy, Jade, ModMenu, Servux, Syncmatica)
```
Rules: dependencies point downward only (`client → mc → core → api`). `core` is unit-testable without booting Minecraft wherever possible. Mixins contain **no logic**: they call a named hook in `mc/`.

### 4.2 Version adapter layer and mixin register
- Every interaction with version-sensitive Minecraft internals goes through an adapter class in `mc/` (rendering pipeline, chunk sections, block models, packets, item components…).
- `docs/enhanced/knowledge/mixin-register.md` lists every mixin: target, injection point, purpose, risk if the target changes, test covering it. New mixins require a register entry in the same commit.
- **Port metric**: the number of files touched by a Minecraft version port. Goal: a decreasing trend.

### 4.3 Threading model
- **Client thread** (which is also the render thread in Minecraft) owns: GUI, input, packets, client-world reads, GPU uploads, and **all mutations of placement/selection state (single writer)**.
- **One shared, bounded worker pool** (`LitematicaExecutors`) with named threads, daemon, uncaught-exception handler → diagnostics. No ad-hoc `new Thread`. Size is configurable, with a default of `max(1, min(cores − 2, 4))` (tuned from measurements). Blocking I/O may use virtual threads; CPU-bound work uses the pool.
- **Workers only read immutable snapshots** (section snapshots, palette copies, frozen placement transforms). Workers never touch live `Level`/`ChunkSchematic`/client world objects unless an ADR documents the thread-safety argument and a stress test exists.
- **Results flow back** through a completion queue drained on the client thread under a frame budget.
- **Every job is cancellable** (cancellation token). Lifecycle events (disconnect, dimension change, world unload, exit) cancel or checkpoint jobs.
- **Kill switch**: each threaded subsystem has a config flag that restores the single-threaded legacy path.

### 4.4 Schematic data model and formats
- A `Schematic` interface with per-format codecs (Litematica v7/v6, Sponge v1–v3, vanilla structure, Schematica), aligned with masa's rewrite.
- Region storage chosen by density (dense packed vs sparse), with `long` indexing and validated dimensions.
- Metadata-only read path (name, author, size, block count, data version, thumbnail if present) for the library and previews.
- **Atomic writes**: temp file in the same directory → flush + `FileChannel.force` → atomic move (fall back to replace move if the filesystem does not support atomic moves), plus an optional `.bak` ring.
- Validation report on load (unknown blocks, palette bounds, entity/BE errors, data version) with repair options. Data fixing goes through Minecraft's DataFixer as upstream does.

### 4.5 UI approach
- Fork-owned **design system**: tokens (colours, spacing on the GUI pixel grid, type scale for the vanilla font, elevation by shading), components (button, icon button, toggle, segmented control, text field, search field, dropdown, list/virtual list, tree, tabs, split pane, panel, dialog, toast, tooltip/help, progress, badge, keybind chip).
- **Layout engine** (flex-like rows/columns, constraints), so screens adapt to GUI scale 1–4 and to small windows.
- **Accessibility**: minimum contrast targets, full keyboard navigation, focus rings, no information carried only by colour, readable at GUI scale 2, respects the vanilla narrator where practical.
- **Art**: reuse existing Litematica/vanilla sprites. New icons are human-made or come from a licence-compatible human-made set. Claude may create **placeholder** icons named `*_placeholder.png`, and a release check fails while any placeholder remains.
- Legacy screens stay reachable (flag `ui.legacyScreens`) until each new screen has passed a parity checklist.

### 4.6 Errors, logging, diagnostics
- No silent catch. Every caught exception is either handled with a user-visible explanation or logged with context (operation, file, placement id), and the operation reports failure.
- One user-facing **notification model** (toast + details + "copy diagnostics"). No more mixing of chat messages and HUD text for errors.
- A **diagnostics screen** shows: jobs, queues, thread pool, render queue sizes, memory per placement, compat status, active feature flags, server policy.
- **No telemetry, no network calls** except the Minecraft server connection and explicit, user-triggered features approved by ADR.

### 4.7 Feature flags and legacy paths
- A central registry of flags (`flags.json` or config category `experimental`), each with: id, default, owner phase, removal criteria, kill-switch semantics.
- New subsystems start **off** (or opt-in) until their phase audit passes. They then default **on**, with the legacy path kept for at least one released version.
- Removing a legacy path requires: parity checklist ✔, one release with the new default ✔, an ADR or changelog note ✔.

### 4.8 Configuration and persistence
- Every persisted file (config, placements, selections, projects, index) carries a **schema version** and has a **migration function** with tests.
- Writes are atomic. The last good file is kept as `.bak`. On parse failure: load `.bak`, notify, and keep the broken file as `.corrupt-<timestamp>`.
- Per-server and per-world data keys are documented, so the user can back them up.

### 4.9 Compatibility policy
| Surface | Policy |
|---|---|
| Schematic files | Read everything upstream reads. Write the same formats. Golden-file tests per format |
| Existing user configs/placements | Migrated automatically on first run. The original files are never modified |
| Add-ons (Syncmatica, printers, Better List, Litematic Downloader…) | `provides: litematica` (if Q-01 is accepted). Keep commonly used classes/methods stable or deprecated for ≥ 1 release. An **add-on compat matrix** in `docs/enhanced/compat/` is updated each phase that touches public-ish classes |
| Performance/render mods (Sodium, Iris, Voxy, Bobby…) | Compat matrix with manual or automated checks per release. A conditional-mixin approach as upstream does |
| Servux/Syncmatica protocols | Never change wire formats unilaterally. Version-negotiate. Document |
| Minecraft versions | One target at a time. Port with `prompts/recurring/mc-version-port.md` |

---

## 5. Development rules (non-negotiable)

1. **Stability over speed.** Never merge a feature that makes the build, tests or golden masters fail.
2. **No feature removal without analysis.** Before removing or hiding any feature: list its usages, configs, hotkeys, add-on dependencies and user reports. Record the decision in an ADR, with a migration or replacement.
3. **Preserve schematic compatibility.** No change to how existing files are read or written without golden-file tests proving equivalence, or an ADR approving a documented, versioned change.
4. **No unnecessary dependency.** See D-06.
5. **Never invent results.** No fabricated test outputs, benchmark numbers, screenshots, issue counts or quotes. An estimate is labelled *estimate*, and estimates never appear in results tables. Every number links to a raw file produced by a command written in the report.
6. **Measure before and after.** Every optimisation commit references a before/after pair of benchmark result files from the same machine and protocol.
7. **Compiling proves nothing.** Every acceptance criterion needs behavioural evidence: tests, benchmarks, screenshots from game tests, or a manual test protocol executed and recorded by the human.
8. **No massive refactor without a migration strategy.** Big moves go through facades and flags, in steps that each leave the mod working.
9. **One concern per PR/commit series.** Independent changes go to separate branches. Mechanical changes (renames, moves, formatting) are never mixed with behavioural changes.
10. **Always keep a way back.** Tags per phase, flags per subsystem, legacy paths until parity, a revert plan in every phase report.
11. **Document important decisions.** ADR for anything structural. One line in `DECISIONS.md` for every human decision.
12. **Check interactions.** Each feature card and phase report lists the subsystems it interacts with and the tests proving those interactions still work.
13. **Respect the scope of the phase.** Out-of-scope discoveries go into registers, not into the diff.
14. **Do not reformat what you do not change.** Match each file's existing indentation (the code base mixes tabs and spaces) and line endings (`.gitattributes` sets `*.java` to CRLF in the working tree). Whole-file churn in a diff is a defect.
15. **Credit and licence.** Keep headers. Add a modification notice to modified files (GPLv3 §5(a) via LGPLv3) using the format chosen in P00. Credit masa and Sakura-Ryoko for ported designs.

---

## 6. Testing and benchmark policy

### 6.1 Test pyramid
| Level | Tooling | What |
|---|---|---|
| Unit | JUnit 5 via Fabric Loader JUnit | `core/` logic, containers, transforms, codecs, engines, migrations |
| Property/fuzz | jqwik or a seeded random generator (test scope, ADR) | Container invariants, round-trips, malformed NBT never crashes the reader |
| Golden master | Committed corpus + expected outputs | Format read/write equivalence, verifier/material outputs for reference scenes |
| Client game tests | Fabric API client game test (gametest source set only) | Boot the client, load a world, place a schematic, open screens, take screenshots, run benchmark scenarios |
| Architecture | ArchUnit-style tests (test scope, ADR) | Layering rules (§4.1), no `new Thread`, no static access to `DataManager` in new code |
| Manual playtest | Checklist executed by the human | Feel, visual quality, real servers, mod combos |

### 6.2 Benchmark protocol
- **Machine fingerprint** in every result file: CPU, GPU and driver, RAM, OS, Java vendor/version, JVM args, MC version, mod list with versions, render distance, GUI scale, window size, fork commit.
- **Scenarios** (defined in P01, versioned): load S/M/L/XL synthetic schematics; fly a fixed camera path through a placement; rebuild after a layer change; move a placement; verify; material list; save and load; dimension change with placements active.
- **Runs**: ≥ 1 warm-up run discarded; ≥ 5 measured runs; report median and IQR (p25–p75) per metric; raw JFR recordings or summaries kept (large files may be compressed or kept outside git with a hash).
- **Metrics**: frame time p50/p95/p99/max; stutter count (frames > 50 ms); time to first render; load time; mesh build time per section; peak and post-GC retained heap; allocation rate; GC pause total; engine throughput (blocks/s); save time.
- **Regression threshold**: median worse by > 5%, or p99 worse by > 10%, on any reference metric → the phase fails unless an ADR justifies the trade-off and the human approves.
- **Improvement claim threshold**: median improvement > max(5%, 2 × relative IQR) on the reference machine, reproduced in two separate sessions. The auditor re-runs at least one scenario.
- **Never compare** results from different machines, different settings or different scenario versions.

---

## 7. Server fairness policy

| Class | Definition | Examples | Rule |
|---|---|---|---|
| F0 | Visual or local only | Rendering, overlays, verifier, material lists, library | Always allowed |
| F1 | Assists a single action the player initiates | Easy Place, pick block from schematic | Off by default where upstream is off. Clear warning. Disabled by server policy. Never faster than vanilla interaction cadence |
| F2 | Explicit server-side mutation by command/protocol with permission | Paste by commands, Servux paste, fill/replace/delete tools | Only on explicit confirmation showing the number of commands and the affected volume. Respects permission errors. Fully cancellable |
| F3 | Autonomous world interaction | Printer, auto-build, auto-restock from containers, auto-walk | **Forbidden in this project** |

- **Causality rule**: every gameplay packet sent because of Litematica code must be attributable to an input event in the same or immediately preceding tick (or to an F2 job the user confirmed). Dev builds log the cause, and a client game test asserts that no packet lacks one.
- **Server policy channel** (proposed in P03, built in P15): a server may declare disallowed F1/F2 features. The client honours it and shows it in the diagnostics screen and the HUD.
- **No deception**: no spoofed client brand, no hidden packets, no bypassing anti-cheat, no packet-order tricks beyond the documented accurate-placement protocols that the server opts into.
- Every new feature card includes a fairness classification, and the auditor checks it.

---

## 8. Security policy
- Treat schematic files, network payloads (Servux, Syncmatica) and pasted text as **untrusted**.
- Enforce limits on size, NBT depth, palette size, region dimensions (overflow-safe), entity counts and string lengths.
- No path traversal: file names are sanitised (upstream `FileNameUtils`) and resolved paths must stay inside allowed roots.
- Command generation (`/setblock`, `/fill`, `/summon`, `.mcfunction`) escapes SNBT and strings, and is fuzz-tested.
- No dynamic class loading from data. No Java serialisation.
- Security findings go to `registers/problems.md` with severity. Exploitable issues found in upstream code are reported **privately** to the maintainers before any public PR.

---

## 9. Documentation and tracking policy

Repository layout (created in P00):
```text
CLAUDE.md                         ≤ 150 lines: commands, rules, pointers (imports nothing large)
.claude/agents/*.md               subagent definitions
.claude/rules/*.md                path-scoped rules (render, schematic-io, gui, mixins, tests)
.claude/settings.json             permissions, env, worktree baseRef, hooks
docs/enhanced/
  README.md                       index + reading order
  REFERENCE.md                    this document
  STATE.md                        current phase, last verified commit, blockers, next action (≤ 60 lines)
  ROADMAP.md                      phase table with status/verdict/tag
  DECISIONS.md                    one line per human decision + ADR index
  adr/ADR-NNNN-<slug>.md
  registers/problems.md           ID, severity, evidence, status, upstream category
  registers/features.md           inventory + backlog (links to specs)
  registers/risks.md
  registers/upstream.md           PR candidates, status, links
  knowledge/architecture-map.md   subsystem map: packages, key classes, entry points, data flows
  knowledge/subsystems/<name>.md  per-subsystem notes (≤ 200 lines each)
  knowledge/mixin-register.md
  knowledge/glossary.md
  benchmarks/PROTOCOL.md, benchmarks/scenarios/, benchmarks/results/<date>_<phase>_<scenario>.json
  design/                         tokens, components, mockups/*.html, screenshots/
  specs/<feature-id>.md
  compat/addons.md, compat/mods.md, compat/assets.md, compat/easyplace-matrix.md
  architecture/target.md, migration-plan.md, targets.md
  phases/PXX/{plan.md, report.md, pre-audit.md, audit.md, corrections.md, integration-log.md, agents/, logs/}
  upstream-prs/<topic>.md, upstream-prs/INTRO.md, upstream-prs/proposals/
  ports/<mc>/, syncs/<date>/, release/, api/
  prompts/                        versioned copy of the programme prompts (installed in P00)
  STRATEGY.md, ROADMAP-PLAN.md, AGENTS.md, UPSTREAM.md   copies of the dossier documents
  AI_DISCLOSURE.md
NOTICE.md                         attribution and modification statement (repo root)
```
- **Size discipline**: reports ≤ 2 pages plus a claims ledger. Subsystem notes ≤ 200 lines. `STATE.md` ≤ 60 lines. Long raw outputs go to files and are linked, never pasted.
- **Knowledge maps are caches**: each phase refreshes only the notes for subsystems it touched, and records the commit at which each note was last verified.

---

## 10. AI usage, authorship and disclosure policy
- The **human owner** approves every phase plan, every ADR, every checkpoint and every merge, and runs the manual playtests. These decisions are recorded with dates in `DECISIONS.md`.
- Commits made by Claude Code carry the attribution trailer configured in the environment. `AI_DISCLOSURE.md` describes, per subsystem, how AI was used (code generation, review, docs, tests).
- Upstream PRs fill in the maintainers' AI disclosure section truthfully. If a maintainer does not accept AI-assisted contributions, the programme respects that.
- No AI-generated images in shipped assets or on public project pages (Modrinth rule). Mockups stay internal design artefacts.
- Before public distribution (P19), the owner re-reads the current platform rules and decides the channels.

---

## 11. Coding conventions
- Follow the surrounding upstream style in upstream packages (Allman braces, `== false` idiom, existing naming). New fork-only packages follow the same style for consistency.
- Java 25 features are allowed where they clarify (records for value types, sealed types for results, pattern matching). Do not churn existing code just to modernise syntax.
- Mixins: one purpose per mixin, `@Unique` with a prefix on added members, prefer MixinExtras injectors (bundled with Fabric Loader) over `@Redirect`/`@Overwrite`, `require = 1` stays the default, a register entry is mandatory.
- Nullability: use the existing `@Nullable`/`@Nonnull` annotations consistently in new code.
- Collections in hot paths: fastutil (already on the classpath through Minecraft) with primitive keys. Avoid boxing `BlockPos` in large sets: pack positions into `long`.
- Logging: `Litematica.LOGGER` with a context prefix. Debug logs go behind a debug flag, never commented out.
- Translations: every user-visible string uses a translation key in `en_us.json`. New keys are listed in the phase report for Weblate/translators.

---

## 12. Review checklist (used by every audit)
- [ ] Scope respected; no unrelated changes; no whole-file churn
- [ ] Build + all tests green from a clean checkout
- [ ] Acceptance criteria each backed by evidence
- [ ] Benchmarks: protocol followed, raw files present, thresholds respected, at least one re-run reproduced
- [ ] No removed or hidden feature without an ADR
- [ ] Schematic/config compatibility proven by golden tests
- [ ] Threading: no live-world access from workers; cancellation; kill switch
- [ ] Fairness class declared and respected; causality test green
- [ ] Security limits and escaping covered by tests where relevant
- [ ] Docs, registers, STATE, ROADMAP updated; claims ledger complete
- [ ] Licence notices and credits present; AI disclosure updated
