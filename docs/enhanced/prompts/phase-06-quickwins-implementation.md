# Litematica Enhanced — P06 · Upstream-ready fixes (Category A, batch 1)
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P06-quickwins` created from `enhanced/p05-pass` (or the latest passed tag; this phase only depends on P02/P03), and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** M · **Human checkpoint:** YES — approve the list of fixes before work starts, and approve each PR draft before anything is sent (Claude never sends PRs)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P06** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P06-quickwins` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p05-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P06/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P06/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (M) or needs a decision reserved for the human, **stop and ask**, proposing a split (P06a/P06b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P06/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P06/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P06/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P06] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P06/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P06/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P06 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P06 — Upstream-ready fixes (Category A, batch 1)

**Agents for this phase:** lead · `reliability-engineer` (fixes) · `test-engineer` (failing-first tests) · `upstream-liaison` (upstream-pr branches, PR drafts) · `independent-auditor`

### Goal
Deliver 5–10 **small, independent, high-value fixes**. Each one is protected by a test, merged into the fork, and also prepared as a minimal upstream PR branch with an honest description. This protects users now, validates the PR pipeline, and starts the relationship with the maintainers on a positive footing.

### Inputs
`registers/problems.md` (Category A rows, S1/S2 first) · `phases/P02/synthesis.md` · the P02 reproduction recipes and disabled tests · `UPSTREAM.md` (§4 categories, §5 PR workflow and template) · `knowledge/licence-and-contribution.md`.

### Step 1 — Candidate list (then ask the human)
Propose the batch with, for each item: register ID, problem, evidence, fix outline, target repo (Litematica or MaLiLib), estimated diff size, risk. Expected candidates, **only if P02 confirmed them**:
- **REL-01 atomic schematic save.**
  - Fork fix: inside Litematica's own write path, write to a temp file in the same directory, flush and force, then move atomically. Fall back to a replacing move if `ATOMIC_MOVE` is unsupported. Keep an optional single `.bak`.
  - Upstream: one PR to **MaLiLib** (`DataFileUtils.writeCompoundDataToCompressedNbtFile`) and/or Litematica, whichever the maintainers prefer. Describe both options in the draft.
- **REL-02 region size overflow:** validate dimensions at creation and load, use `long`/`Math.multiplyExact` arithmetic, and show a clear error.
- **REL-03 transmit slice index** (only if the Servux receiver shows it matters; otherwise document and drop).
- **REL-05 JSON data recovery:** keep the last good file, recover on parse failure, keep the broken file as `.corrupt-<ts>`.
- **PERF-02 frame budget:** only if P02 measurements show that `renderThreadNoTimeout=true` causes stutter. The minimal fix replaces the hard-coded 60 FPS with a measured frame budget when the timeout is enabled. Changing the default is **Category B** (needs discussion), so the fork may change it behind a flag while the upstream PR only fixes the budget computation.
- Easy Place or other block-specific bugs confirmed in P02, crash fixes with stack traces, translation key bugs.
Ask the human to approve, remove or reorder items (AskUserQuestion). Record the decision.

### Step 2 — Per-fix workflow (parallel up to 3 fixes; each fix in its own worktree)
1. **Failing test first** (`test-engineer`) in the fork's test suite, reproducing the bug. Save the failing run log.
2. **Fork fix** (`reliability-engineer`) on the agent worktree branch. Make the minimal change in upstream style, keep the modification notice convention, and get the test green. Run the full suite. The golden masters must stay unchanged unless the bug was characterised there, in which case update the golden file **in its own commit** with the register ID.
3. **Upstream branch** (`upstream-liaison`).
   - Create `upstream-pr/<topic>` from `vendor/sakura-<mc>` (fresh `git fetch upstream-sakura` first; if upstream moved, rebase the vendor mirror first and note it).
   - **Re-implement** the minimal fix there, without fork scaffolding.
   - Build exactly as upstream CI does (`./gradlew build`, Java 25).
   - Since upstream has no test source set, write the reproduction steps and evidence for the PR text. Optionally include a tiny test *proposal* in the description.
   - For MaLiLib fixes, use a separate MaLiLib fork with its own `vendor/` and `upstream-pr/` branches (document the setup in `knowledge/build.md`).
4. **PR draft** in `docs/enhanced/upstream-prs/<topic>.md`, using the template in `UPSTREAM.md §5`, **with a truthful AI disclosure** (what Claude Code did, what the human reviewed and tested). Add a row to `registers/upstream.md`, status `draft`.
5. **Manual check by the human** (listed in the playtest checklist): reproduce the bug on the vendor build, then confirm the fix on the PR build.

### Step 3 — Integration and introduction
- Merge all fork fixes into the phase branch. Run the full test suite, the game tests, and the benchmarks affected by any performance-related fix (before/after files).
- Draft (do not send) a short introduction message for the maintainers (`docs/enhanced/upstream-prs/INTRO.md`): who, what the fork is, that it is unofficial, that AI tools are used and disclosed, the offer of small tested fixes, and a question about naming. The human decides whether and when to send it, and in which channel.

### Rules
- **Never push** to upstream remotes, never open PRs and never post comments. The human does this.
- One concern per PR branch. A PR diff is ideally under 200 changed lines. Explain if larger.
- No refactoring "while you're there".

### Acceptance criteria (each must be evidenced in the claims ledger)
1. The approved fix list is recorded in `DECISIONS.md`. Every item maps to a confirmed P02 register ID (Category A).
2. For each fix, a test fails on the parent commit and passes after the fix. Both runs are logged, with the commit shas.
3. All fork fixes are merged into the phase branch. The full unit suite, the game tests and the golden masters are green. Any golden-file change is isolated in its own commit, with a register ID and a justification.
4. Every `upstream-pr/<topic>` branch is based on the current `vendor/sakura-<mc>` and contains only that fix (`git diff vendor...upstream-pr/<topic> --stat` logged). It builds with `./gradlew build`, and its diff is under ~200 lines or justified.
5. Each PR draft follows the template, includes reproduction steps and before/after evidence, and has a truthful AI disclosure.
6. Performance-related fixes have before/after benchmark files under the protocol, and they meet the thresholds.
7. `registers/upstream.md` lists every draft. `registers/problems.md` statuses are updated (fixed-in-fork, PR-draft).
8. `INTRO.md` is drafted and nothing was sent by Claude.
9. A playtest checklist for the human exists (reproduce on the vendor build → verify on the PR build).

### Mandatory tests and checks
- Per fix: the failing-before test run (parent commit) and the passing-after run (logs).
- `./gradlew clean build test` plus game tests on the phase branch.
- Per `upstream-pr/*` branch: `./gradlew build` on a clean checkout of that branch.
- For REL-01: a fault-injection test (kill or simulated crash during write) proving that the original file survives intact. Run it on Windows semantics too, if the machine allows (document otherwise).

### Standard deliverables (every phase)
- `docs/enhanced/phases/P06/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-06-quickwins-audit.md` with BASE=`enhanced/p05-pass` and HEAD=`phase/P06-quickwins`."
