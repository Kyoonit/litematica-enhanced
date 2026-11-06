# Litematica Enhanced — P06 · Upstream-ready fixes (Category A, batch 1)
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-quickwins phase/P06-quickwins` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-quickwins`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p05-pass` (or the latest passed tag; this phase only depends on P02/P03) · HEAD = branch `phase/P06-quickwins` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P06** aimed to deliver: **Upstream-ready fixes (Category A, batch 1)**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P06/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P06/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p05-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P06/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p05-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P06-NN`, with a severity:
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
1. The approved fix list is recorded in `DECISIONS.md`. Every item maps to a confirmed P02 register ID (Category A).
2. For each fix, a test fails on the parent commit and passes after the fix. Both runs are logged, with the commit shas.
3. All fork fixes are merged into the phase branch. The full unit suite, the game tests and the golden masters are green. Any golden-file change is isolated in its own commit, with a register ID and a justification.
4. Every `upstream-pr/<topic>` branch is based on the current `vendor/sakura-<mc>` and contains only that fix (`git diff vendor...upstream-pr/<topic> --stat` logged). It builds with `./gradlew build`, and its diff is under ~200 lines or justified.
5. Each PR draft follows the template, includes reproduction steps and before/after evidence, and has a truthful AI disclosure.
6. Performance-related fixes have before/after benchmark files under the protocol, and they meet the thresholds.
7. `registers/upstream.md` lists every draft. `registers/problems.md` statuses are updated (fixed-in-fork, PR-draft).
8. `INTRO.md` is drafted and nothing was sent by Claude.
9. A playtest checklist for the human exists (reproduce on the vendor build → verify on the PR build).

## 4. Mandatory re-runs and checks
- Per fix: the failing-before test run (parent commit) and the passing-after run (logs).
- `./gradlew clean build test` plus game tests on the phase branch.
- Per `upstream-pr/*` branch: `./gradlew build` on a clean checkout of that branch.
- For REL-01: a fault-injection test (kill or simulated crash during write) proving that the original file survives intact. Run it on Windows semantics too, if the machine allows (document otherwise).

## 5. Phase-specific audit focus
- **PR branch purity:** for each `upstream-pr/*`, diff it against the vendor branch yourself. Any fork scaffolding (fork packages, flags, services, test infrastructure, docs) is MAJOR.
- **Failing-first proof:** check out each fix's parent commit in a scratch worktree, run the test, and confirm that it fails for the right reason.
- **Atomic write correctness (REL-01):** temp file in the same directory, data flushed and forced before the move, `ATOMIC_MOVE` with a replace fallback, no leftover temp files on failure, `.bak` handling, symlink behaviour consistent with upstream's JSON writer.
- **Overflow guard (REL-02):** check the boundaries (2³¹−1, 2³¹, a negative size) and the error path.
- **No behaviour change beyond the fix:** golden masters unchanged except the documented items. Defaults unchanged (config-defaults snapshot test green), except Category-B changes behind a flag and explicitly approved.
- **Disclosure honesty:** each PR draft's AI section describes what actually happened.
- **Nothing sent:** confirm that no push to upstream remotes happened (`git reflog` / remote refs). Claude must not have opened PRs.

## 6. Output

- Write `docs/enhanced/phases/P06/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P06` → `git add docs/enhanced/phases/P06/audit.md docs/enhanced/phases/P06/audit-logs` → `git commit -m "[P06] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P06-quickwins && git merge --ff-only audit/P06
    git switch enhanced/main
    git merge --no-ff phase/P06-quickwins -m "[P06] merge after independent audit PASS"
    git tag enhanced/p06-pass
    git worktree remove ../audit-quickwins && git branch -d audit/P06
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P06-quickwins && git merge --ff-only audit/P06`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P06/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
