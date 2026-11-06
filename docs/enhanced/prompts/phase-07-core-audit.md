# Litematica Enhanced — P07 · Core foundations — context, lifecycle, jobs, errors, flags, migrations
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-core phase/P07-core` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-core`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p06-pass` · HEAD = branch `phase/P07-core` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P07** aimed to deliver: **Core foundations — context, lifecycle, jobs, errors, flags, migrations**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P07/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P07/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p06-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P07/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p06-pass..HEAD` and the full diff of every touched area.
   - Whole-file churn: compare `git diff --stat` with `git diff --stat --ignore-all-space --ignore-cr-at-eol`.
   - Scope creep. Edits to hot files that the plan did not assign.
   - Removed or hidden config options, hotkeys or screens: diff the option and hotkey IDs between BASE and HEAD.
   - Mixin register updated for every changed mixin. Licence and modification notices present. No secrets or personal paths committed.
4. **Verify claims.**
   - For each row of the report's claims ledger, re-run the command or at least check that the raw evidence file exists and supports the claim.
   - Re-run **at least one** benchmark scenario yourself when the phase claims performance results, and compare with the reported numbers (same machine and protocol, or say clearly that you could not).
5. **Hunt adversarially.**
   - Apply the phase-specific focus in §5.
   - Apply the generic list: race conditions and live-world access from workers; missing cancellation; lifecycle gaps (disconnect, dimension change, exit); format, config and add-on compatibility breaks; fairness violations (packets without a user cause, F3 behaviour); missing security limits or escaping; weakened or deleted assertions; regenerated golden files without justification; false optimisations (different settings, warm caches, measuring the wrong thing); documentation that contradicts behaviour.
6. **Classify each finding** as `AUD-P07-NN`, with a severity:
   - **BLOCKER**: data loss, crash, an unproven acceptance criterion, a rules violation in REFERENCE §5/§7, or fabricated evidence;
   - **MAJOR**: likely user-visible defect, regression beyond thresholds, missing mandatory test;
   - **MINOR**: localised defect or gap;
   - **NOTE**: suggestion.
   Each finding carries its evidence (`path:line`, command, output file) and a suggested acceptance test.
7. **Verdict.**
   - **PASS**: all criteria are proven and there is no BLOCKER or MAJOR finding.
   - **PASS WITH RESERVATIONS**: all criteria are proven, and MINOR findings remain open (each must be logged in `registers/problems.md` by the human or the correction session).
   - **FAIL**: any BLOCKER, any MAJOR, or any unproven criterion.

## 3. Acceptance criteria to verify (independent copy)
1. The context and services exist as defined in ADR-0006/0007/0003. The static facades delegate to them. The before/after counts of static accesses (`DataManager.*`, `getInstance()`) are reported. New code adds zero static accesses (architecture test).
2. The lifecycle state machine is wired to the existing events. Unit tests cover every legal and illegal transition. A game test exercises join → dimension change → leave without exceptions.
3. Job system tests cover: completion order and priorities, cancellation (before start, while running, during completion), exception propagation to notifications, the frame-budgeted completion queue, and shutdown with no remaining Litematica threads (checked by a thread dump in a test).
4. The pilot task runs as a job behind `core.jobs.pilot`. Both paths are tested and produce identical results.
5. The notification adapter displays existing messages unchanged (game-test screenshot or log comparison). The diagnostics dump works and lists jobs, flags, lifecycle state and memory estimates.
6. The flag registry exists, and a test enumerates every flag with its default and owner phase.
7. The migration framework has tests for v0 → v1, corrupt input recovery (`.corrupt-*` kept, `.bak` used), and atomic write. Legacy user files are never modified (test with read-only fixtures).
8. The architecture tests are implemented and green. Allowlists are committed and their sizes reported.
9. Golden masters, the config-defaults snapshot, unit tests and game tests are green. Benchmarks `fly-M`, `load-L` and `save-L` are within the regression thresholds (raw files).

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests.
- Architecture test task.
- Benchmarks `fly-M`, `load-L`, `save-L` (≥ 5 runs) compared with the latest baseline (comparison table).
- Thread-leak test: after a simulated client stop, no thread named with the Litematica prefix remains.

## 5. Phase-specific audit focus
- **Behaviour equivalence:** run the golden masters and compare game-test screenshots or logs with P01's outputs. Look for message differences (notification adapter), changed defaults, or changed file outputs.
- **Concurrency:** review the job system for races. Check how the completion queue handles a cancelled job; how exceptions are handled in the worker vs on completion; how jobs submitted during shutdown are handled; whether the client thread can deadlock waiting on a worker. Try to write one failing test, in a scratch worktree, for any suspected race.
- **Lifecycle:** what happens to a running job during a dimension change, a disconnect, or a client stop? Check the code against the ADR.
- **Strangler hygiene:** facades are thin, and the old static behaviour is preserved (same instances or equivalent state). There is no duplicate state between the facade and the service.
- **Architecture tests:** confirm that they actually fail on a violation. Add a violation in a scratch worktree and watch the test fail. Allowlists must not have grown.
- **Migration safety:** legacy and official Litematica files are never written. Check with file-modification-time assertions or code reading.
- **Hot files** were edited only by the lead (`git log --format='%an %s' -- <hot files>` together with the integration log).

## 6. Output

- Write `docs/enhanced/phases/P07/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P07` → `git add docs/enhanced/phases/P07/audit.md docs/enhanced/phases/P07/audit-logs` → `git commit -m "[P07] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P07-core && git merge --ff-only audit/P07
    git switch enhanced/main
    git merge --no-ff phase/P07-core -m "[P07] merge after independent audit PASS"
    git tag enhanced/p07-pass
    git worktree remove ../audit-core && git branch -d audit/P07
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P07-core && git merge --ff-only audit/P07`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P07/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
