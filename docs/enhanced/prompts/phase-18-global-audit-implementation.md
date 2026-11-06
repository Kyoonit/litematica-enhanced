# Litematica Enhanced — P18 · Global adversarial audit and hardening
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P18-global-audit` created from `enhanced/p17-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** L · **Human checkpoint:** Review the global findings; decide on any MAJOR finding that is not fixed (accept the risk or defer the release)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P18** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P18-global-audit` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p17-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P18/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P18/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (L) or needs a decision reserved for the human, **stop and ask**, proposing a split (P18a/P18b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P18/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P18/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P18/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P18] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P18/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P18/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P18 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P18 — Global adversarial audit and hardening

**Agents for this phase:** lead · several `independent-auditor` instances with different lenses (optionally an agent team) · `perf-engineer` · `reliability-engineer` · `test-engineer` · `cartographer` (refresh notes) · `ux-designer` (UX regression pass)

### Goal
Every subsystem has now changed. Before stabilisation, run a **fresh, adversarial, whole-product audit**: hunt regressions against the original behaviour, stress edge cases, re-verify performance and compatibility, check fairness and security, find incomplete features and documentation lies. Then fix what is found, through scoped corrections.

### Independence
The auditing agents must **not** rely on earlier phase reports as truth. They get the REFERENCE, the registers (as claims to check), the code and the test suites. Their briefs ask them to *disprove*.
Optional: enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` for this phase only and run 4–5 teammates with distinct lenses who challenge each other's findings. Turn it off afterwards.

### Lenses (one auditor each; reports in `phases/P18/agents/`)
1. **Regression vs baseline.**
   - Rebuild the baseline jar (from the `baseline/…` tag) and compare against HEAD with the default flags:
     - P01 golden masters;
     - the config-defaults snapshot (expected differences only, each with an ADR);
     - hotkey IDs and defaults;
     - every legacy screen capability (parity checklists);
     - file outputs (schematics, JSON).
   - List every behaviour difference. Classify each one as intended (ADR or card) or a regression.
2. **Edge cases and fault injection.**
   - Corrupt or truncated files of every format; schematics above the limits; XL schematics with `-Xmx` set low (graceful degradation, no crash);
   - kill during save, export or index write;
   - disconnect, dimension change and exit during load, paste, verify, rebuild and save;
   - many placements (≥ 50), many sub-regions, a library of 10,000 files;
   - unicode and long file names, read-only directories, a full disk (simulated).
3. **Performance re-verification.** The full benchmark suite against the P01 baseline and the latest phase results (same machine). The `targets.md` scorecard (met / not met). Re-run 2 scenarios in a second session.
4. **Compatibility.**
   - Sodium, Iris (shaders on/off), Voxy, Bobby, Jade, ModMenu; Syncmatica and the known add-ons (compile-compat + runtime smoke tests where feasible);
   - side-by-side install behaviour with official Litematica (per ADR-0002); data migration from official Litematica.
   - The human runs the manual parts from a checklist.
5. **Fairness and security.**
   - Every packet path with its cause; server-policy bypass attempts; Easy Place cadence; F2 confirmations;
   - command and SNBT escaping; payload limits (Servux, Syncmatica, policy channel); path traversal in every file operation.
6. **UX regression and completeness (`ux-designer`).**
   - Every journey's step count vs `journeys.md`;
   - screens at GUI scale 4 in 320×240;
   - keyboard-only completion of the top 5 journeys;
   - untranslated strings; placeholder art remaining (list it for P19);
   - "dead ends" (features reachable only through legacy screens).
7. **Docs vs behaviour.** Sample ≥ 30 statements across the user guide, the API guide and the README, and verify each.

### Consolidation and hardening
- The lead merges the findings into `phases/P18/findings.md` (ID `G-NN`, severity, evidence, lens), deduplicates them, and asks the human to triage MAJORs that will not be fixed.
- Fix BLOCKERs and MAJORs (and selected MINORs) through **scoped corrections**: one worktree per finding group, a failing test first, the minimal fix, no unrelated edits. Use the rules of `prompts/correction-template.md` (inline, without a separate session).
- Add every new edge-case and fault-injection test to the permanent suites (the CI job for the slow ones).
- Refresh every knowledge note (`cartographer`) and the mixin register.

### Acceptance criteria (each must be evidenced in the claims ledger)
1. Seven lens reports exist. Each one was written without relying on phase reports as evidence (every finding cites code, a test, a measurement or an experiment log).
2. The regression lens produced a complete behaviour-difference list vs baseline. Every difference is classified as intended (with an ADR or card ID) or as a regression with a finding ID.
3. The edge-case and fault-injection suite exists in the repository, runs in CI (slow job) or locally with documented commands, and passes after the fixes.
4. The performance scorecard against `targets.md` is filled in from raw files. Two scenarios were reproduced in a second session. No regression beyond thresholds vs the latest passed phase without a human-accepted justification.
5. The compatibility matrix is fully updated (automated + manual results with versions). Side-by-side install and data migration from official Litematica are tested.
6. Fairness and security: an inventory of every packet path with its cause; bypass and injection attempts documented; every issue found is fixed or human-accepted.
7. UX: the journey step counts meet `journeys.md` or have documented deviations. Keyboard-only completion of the top 5 journeys is proven. The list of untranslated strings and placeholder art is complete.
8. Docs: ≥ 30 statements verified; every false statement is fixed.
9. Every BLOCKER and MAJOR is fixed (failing-first test + fix) or explicitly accepted by the human in `DECISIONS.md`.
10. Knowledge notes and the mixin register are refreshed at HEAD. Full suites green.

### Mandatory tests and checks
- `./gradlew clean build test` + game tests + architecture tests + compat-compile tests + the new edge-case suite.
- The full benchmark suite (≥ 5 runs; 2 scenarios reproduced in a second session).
- Baseline-vs-HEAD comparison scripts (goldens, defaults snapshot, hotkey IDs).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P18/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-18-global-audit-audit.md` with BASE=`enhanced/p17-pass` and HEAD=`phase/P18-global-audit`."
