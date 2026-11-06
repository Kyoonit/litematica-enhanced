# Litematica Enhanced — P18 · Global adversarial audit and hardening
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-global-audit phase/P18-global-audit` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-global-audit`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p17-pass` · HEAD = branch `phase/P18-global-audit` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P18** aimed to deliver: **Global adversarial audit and hardening**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P18/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P18/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p17-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P18/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p17-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P18-NN`, with a severity:
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

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests + architecture tests + compat-compile tests + the new edge-case suite.
- The full benchmark suite (≥ 5 runs; 2 scenarios reproduced in a second session).
- Baseline-vs-HEAD comparison scripts (goldens, defaults snapshot, hotkey IDs).

## 5. Phase-specific audit focus
This audit checks the **audit**. Use a different model or session than the one that ran P18, if possible.
- **Independence:** sample 10 findings. Do they cite primary evidence, or phase reports? Reports used as evidence are MAJOR.
- **Coverage:** were all seven lenses actually executed with real experiments (logs present)? A lens that only read code where experiments were required is MAJOR.
- **Fix quality:** for 5 fixed findings, re-run the failing-first test at the parent commit and the fix commit. Check that each fix stayed in scope.
- **Accepted risks:** every unfixed MAJOR has a human decision. Missing is a BLOCKER.
- **Regression list:** spot-check 5 "intended" differences against their ADR or card.
- **Performance:** check the scorecard numbers against the raw files. Re-run one scenario.

## 6. Output

- Write `docs/enhanced/phases/P18/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P18` → `git add docs/enhanced/phases/P18/audit.md docs/enhanced/phases/P18/audit-logs` → `git commit -m "[P18] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P18-global-audit && git merge --ff-only audit/P18
    git switch enhanced/main
    git merge --no-ff phase/P18-global-audit -m "[P18] merge after independent audit PASS"
    git tag enhanced/p18-pass
    git worktree remove ../audit-global-audit && git branch -d audit/P18
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P18-global-audit && git merge --ff-only audit/P18`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P18/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
