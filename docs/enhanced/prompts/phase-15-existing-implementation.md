# Litematica Enhanced — P15 · Existing feature improvements (Easy Place, paste, edit mode, projects, profiles)
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P15-existing` created from `enhanced/p14-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Playtest — Easy Place on a test server and in single player, paste flows in creative/op, profiles when switching servers

---

## 0. Global context (read carefully)

You are the **lead** of phase **P15** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P15-existing` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p14-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P15/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P15/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P15a/P15b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P15/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P15/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P15/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P15] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P15/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P15/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P15 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P15 — Existing feature improvements (Easy Place, paste, edit mode, projects, profiles)

**Agents for this phase:** lead · `reliability-engineer` (Easy Place correctness and fairness, server policy, command safety) · `ui-engineer` (UX integration) · `feature-designer` (spec conformance) · `test-engineer` · `doc-writer` · `independent-auditor`

### Goal
Improve the **existing** capabilities that P02 marked *improve/replace* and the human selected in P05 for this phase: make them more correct, safer, simpler and fairer. The headline items are Easy Place, paste/command tasks, schematic edit mode, schematic projects, conversions, pick block, and **per-server configuration profiles** with **server policy** support.

### Inputs
`registers/features.md` filtered on `phase = P15` and its specs in `docs/enhanced/specs/` (the **authoritative scope**: implement only selected cards) · ADR-0013 (fairness enforcement, server policy channel) · ADR-0014 (compat) · knowledge notes: Easy Place and pick block, paste/command tasks, tool modes, schematic projects, persistence, networking · `REFERENCE.md §7` (fairness classes) · P02 Easy Place fairness review.

### Work packages (adapt to the selected cards; skip unselected ones and say so)
1. **Causality enforcement (`reliability-engineer`, mandatory for this phase).**
   - Implement the dev-mode **packet cause log** from ADR-0013: every gameplay packet sent from Litematica code paths is tagged with its cause (input event id/tick, or a confirmed F2 job id).
   - A client game test fails on an uncaused packet.
   - Production builds keep only cheap counters (no per-packet allocation when disabled).
2. **Easy Place correctness matrix.**
   - Block families: stairs, slabs (incl. double), doors, trapdoors, beds, rails (all shapes), redstone components (repeater/comparator/observer/piston facing), walls/fences/panes, rotatable blocks (logs, pillars), wall/floor/ceiling attachments, signs and banners, waterlogged blocks, chests (single/double), candles and other multi-count blocks.
   - Protocols: V3, V2, slabs-only, none. Run in single player, plus on a local dedicated test server when its setup is feasible (document Carpet/Servux needs).
   - Record a pass/fail matrix (`docs/enhanced/compat/easyplace-matrix.md`). Fix the failures in scope as small commits (Category A candidates).
3. **Easy Place fairness and UX.**
   - Hold-mode cadence never exceeds the vanilla use-item cooldown.
   - A clear warning on first enable (anti-cheat risk).
   - Per-server enable state through profiles.
   - Respect the **server policy** (WP5).
   - A visible indicator when Easy Place is active.
4. **Per-server configuration profiles.**
   - Profiles (named sets of option overrides) with auto-switch on join by server address or single-player world, including a "strict server" preset (all F1/F2 assists off).
   - Integrated in the P14 settings screen. Persisted with schema version and migration.
   - Never modify official Litematica's files.
5. **Server feature-policy channel (client side).**
   - Implement the protocol chosen in ADR-0013 (plugin channel and/or Servux extension).
   - Parse and validate the payload (limits). The client honours it (disables the listed F1/F2 features while connected) and shows it in diagnostics and on the HUD.
   - Without a signal, behaviour is unchanged.
   - Provide a **reference server-side snippet or spec** in `docs/enhanced/specs/server-policy.md` for server owners. Do not ship server code in this mod unless the ADR says so.
   - Proposing it to Servux is a Category-B discussion item for the human.
6. **Paste / command tasks (F2).**
   - Dry-run summary before starting: volume, command count, estimated duration, permissions needed, entities/BE handling.
   - Explicit confirmation, progress via jobs, pause/resume/cancel, clean handling of permission errors and command failures.
   - **SNBT/string escaping fuzz tests** for `/setblock`, `/fill`, `/summon` and `.mcfunction` output (SEC-01).
   - Servux paste path checked as well.
7. **Schematic edit (rebuild) mode, projects/VCS, conversions, pick block:** implement the selected cards, each with its acceptance criteria and tests.
8. **Docs:** fairness explanation for users and server owners, Easy Place guide with the matrix, profiles guide, paste guide.

### Rules
F3 behaviour is forbidden. Any card that turns out to need autonomy is stopped and reported. Server-mutating actions require confirmation. Never weaken anti-abuse limits to "make it work" on a server.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Every card with `phase = P15` is implemented with its acceptance criteria met (table: card → criteria → evidence), or explicitly deferred with a human decision.
2. The packet cause log exists in dev mode, the game test fails on an uncaused packet (demonstrated with a deliberate test-only violation), and all real Litematica packet paths are tagged.
3. The Easy Place matrix is recorded for every listed family × protocol in single player (and on the test server where feasible). Every failure is fixed or has a register ID with a reason.
4. The hold-mode cadence is ≤ the vanilla cooldown (test). The first-enable warning, the active indicator and per-profile enablement work (tests/screenshots).
5. Profiles: auto-switch by server/world, the strict preset disables all F1/F2 assists, persistence with migration tests, and no writes to official Litematica files.
6. Server policy: payload parsing with limits (fuzz test), honoured while connected (game test with a simulated payload), shown in diagnostics/HUD. Behaviour without a signal is unchanged (test). The server-owner spec is documented.
7. Paste: the dry-run summary and confirmation always appear before F2 jobs; pause/resume/cancel and permission errors are handled (tests). The escaping fuzz tests pass (≥ 10,000 seeded inputs).
8. No F3 behaviour exists (auditable list of every code path that sends gameplay packets, with the cause of each).
9. Full suites, golden masters and game tests are green. The relevant benchmarks are within thresholds.
10. Docs pages exist and match the behaviour.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests (cause log, Easy Place matrix automation where possible, profiles, policy, paste flows).
- Escaping fuzz suite; policy payload fuzz suite.
- A manual playtest checklist for the human: Easy Place on a real server where allowed, the strict preset, a paste in creative/op.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P15/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-15-existing-audit.md` with BASE=`enhanced/p14-pass` and HEAD=`phase/P15-existing`."
