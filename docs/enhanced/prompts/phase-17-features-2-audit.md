# Litematica Enhanced — P17 · New features — wave 2 (advanced) and add-on API
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-features-2 phase/P17-features-2` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-features-2`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p16-pass` · HEAD = branch `phase/P17-features-2` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P17** aimed to deliver: **New features — wave 2 (advanced) and add-on API**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P17/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P17/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p16-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P17/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p16-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P17-NN`, with a severity:
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
1. Every card with `phase = P17` is implemented or explicitly deferred by a human decision. No unselected feature was implemented.
2. Each feature meets every acceptance criterion in its card (table with evidence), and has interaction tests for every listed interaction.
3. Each feature is behind `feature.<id>`, both states are tested, and new screens have approved addenda.
4. Large-build performance: each feature that touches per-frame or per-tick work, or large data, meets its budget on L/XL scenarios (raw files). The existing scenarios are within thresholds.
5. The diff engine is used by the compare feature (if selected) and its outputs match the golden pairs. Repair/remap (if selected) never modifies the original file unless the user saves explicitly (atomic + `.bak`).
6. The add-on API package exists with Javadoc, `@ApiStatus`, thread contracts and stability levels. The human's approval of the surface is recorded.
7. The example add-on compiles and its tests pass in CI. The legacy facades used by known add-ons still compile (compat test from P08, extended).
8. Fairness classes are confirmed. No F3 behaviour. F0 features send no packets.
9. Docs: a user page per feature, plus an add-on developer guide (`docs/enhanced/api/README.md`) with examples.
10. Full suites, golden masters and game tests are green.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (features, interactions, flags).
- L/XL benchmarks for the selected features + regression scenarios.
- Example add-on build and tests; the add-on compile-compat test.

## 5. Phase-specific audit focus
- **Scope and conformance:** same as P16 (compare with the `phase = P17` cards; verify the criteria of 3 features yourself).
- **API quality:** thread-affinity contracts are documented and enforced (for example events fire on the client thread). Returned views cannot mutate internal state (try a mutation through the API in a scratch test). Experimental vs stable labels are consistent.
- **Add-on compatibility:** the legacy facades still behave as before for the methods listed in `compat/addons.md`.
- **Data safety:** repair, remap and substitution never write without explicit user action, and writes are atomic.
- **Performance:** re-run one XL scenario.
- **Fairness:** large-build tools must not automate world actions.

## 6. Output

- Write `docs/enhanced/phases/P17/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P17` → `git add docs/enhanced/phases/P17/audit.md docs/enhanced/phases/P17/audit-logs` → `git commit -m "[P17] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P17-features-2 && git merge --ff-only audit/P17
    git switch enhanced/main
    git merge --no-ff phase/P17-features-2 -m "[P17] merge after independent audit PASS"
    git tag enhanced/p17-pass
    git worktree remove ../audit-features-2 && git branch -d audit/P17
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P17-features-2 && git merge --ff-only audit/P17`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P17/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
