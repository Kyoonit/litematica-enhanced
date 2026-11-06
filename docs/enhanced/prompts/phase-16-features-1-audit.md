# Litematica Enhanced — P16 · New features — wave 1
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-features-1 phase/P16-features-1` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-features-1`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p15-pass` · HEAD = branch `phase/P16-features-1` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P16** aimed to deliver: **New features — wave 1**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P16/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P16/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p15-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P16/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p15-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P16-NN`, with a severity:
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
1. Every card with `phase = P16` is implemented, or explicitly deferred by a human decision (recorded). No unselected feature was implemented.
2. Each feature meets every acceptance criterion in its card (table: card → criterion → test/evidence).
3. Each feature has interaction tests for every interaction listed in `specs/interactions.md`, all green.
4. Each feature is behind `feature.<id>` with a documented default. Both flag states are tested.
5. New screens and panels have approved mockup addenda (`DECISIONS.md`) and matching screenshots.
6. Per-frame or per-tick features meet their performance budgets (raw benchmark files). `fly-M` and the relevant existing scenarios are within thresholds.
7. Fairness classes are confirmed. F0 features send no packets (cause log). No F3 behaviour.
8. Exports are deterministic (golden). Autosave and recovery (if selected) never lose or duplicate data (fault-injection test).
9. A user guide page and a changelog entry exist per feature. Translation keys are listed.
10. Full suites, golden masters and game tests are green.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (per feature, per interaction, both flag states).
- Feature-specific benchmarks (new, versioned) and the regression scenarios.
- Fault-injection tests for any persistence feature.

## 5. Phase-specific audit focus
- **Scope:** compare the implemented features with the `phase = P16` cards. Anything extra is MAJOR (scope creep). Anything missing without a deferral decision is MAJOR.
- **Spec conformance:** for 3 features, verify every acceptance criterion yourself.
- **Interactions:** try at least 2 interaction scenarios not listed in the matrix (for example the feature combined with a profile switch, or with a dimension change).
- **Flags:** with the flag off, behaviour equals P15's.
- **Fairness:** any feature with "auto" in its description gets extra scrutiny. It may automate UI state only.
- **Data safety:** for persistence features, kill the game during the write and check recovery.
- **Docs vs behaviour:** sample 2 statements per feature.

## 6. Output

- Write `docs/enhanced/phases/P16/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P16` → `git add docs/enhanced/phases/P16/audit.md docs/enhanced/phases/P16/audit-logs` → `git commit -m "[P16] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P16-features-1 && git merge --ff-only audit/P16
    git switch enhanced/main
    git merge --no-ff phase/P16-features-1 -m "[P16] merge after independent audit PASS"
    git tag enhanced/p16-pass
    git worktree remove ../audit-features-1 && git branch -d audit/P16
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P16-features-1 && git merge --ff-only audit/P16`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P16/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
