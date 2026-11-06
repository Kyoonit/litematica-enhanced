# Litematica Enhanced — P09 · UI framework and pilot screen
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-ui-kit phase/P09-ui-kit` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-ui-kit`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p08-pass` · HEAD = branch `phase/P09-ui-kit` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P09** aimed to deliver: **UI framework and pilot screen**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P09/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P09/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p08-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P09/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p08-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P09-NN`, with a severity:
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
1. The toolkit core, layout engine, focus manager and all listed components exist in the ADR-0010 package. Layout and focus logic have unit tests, including GUI scales 1–4 and odd sizes.
2. The virtual list handles ≥ 100,000 rows. The `ui-gallery-scroll` benchmark shows that per-frame allocation does not grow with the row count, and the frame-time budget from `targets.md` is respected (raw files).
3. The gallery renders every component in every state. Screenshots exist at scales 1–4 and two window sizes. The reference set is approved by the human and recorded in `DECISIONS.md`.
4. The pilot Jobs screen matches its approved mockup (side-by-side images in the report), passes its parity checklist, and is reachable behind `ui.pilot`. The legacy screen still works.
5. Keyboard-only operation of the gallery and the pilot is proven by a game test (focus order, activation, Escape).
6. A token-only lint or architecture test shows no hard-coded colours or sizes in screen code. All visible strings use translation keys.
7. Toasts and progress are bound to the P07 notifications and jobs (demonstrated by a test that runs a job and captures the toast/progress).
8. Full suites, golden masters and the config-defaults snapshot are green. `fly-M` is within thresholds (the UI layer must not affect world rendering).

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (gallery, pilot, keyboard navigation, screenshots).
- `ui-gallery-scroll` benchmark (≥ 5 runs) + a JFR allocation profile.
- Lint/architecture test for hard-coded colours and strings.
- `fly-M` regression check.

## 5. Phase-specific audit focus
- **Fidelity:** compare the screenshots at scales 2 and 3 with the approved mockups for 5 components and the pilot. Material deviations without an approved addendum are MAJOR.
- **Pixel and text correctness:** text clipping, ellipsis at small widths, alignment at odd scales, overlap at scale 4 in a 320×240 window.
- **Per-frame cost:** read the virtual-list code for allocation in render paths (new strings, lists or lambdas per row per frame). Check the JFR allocation profile.
- **Focus traps and Escape behaviour:** can the user always leave a dialog, text field or list with the keyboard?
- **Parity:** sample 3 items of the pilot parity checklist in game (or in the game-test screenshots).
- **Flags:** with `ui.pilot` off, the legacy screen opens. With it on, the new one does.
- **Hard-coded values:** grep screen code for colour literals and numeric sizes outside the tokens.
- **Art:** only placeholders or existing sprites.

## 6. Output

- Write `docs/enhanced/phases/P09/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P09` → `git add docs/enhanced/phases/P09/audit.md docs/enhanced/phases/P09/audit-logs` → `git commit -m "[P09] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P09-ui-kit && git merge --ff-only audit/P09
    git switch enhanced/main
    git merge --no-ff phase/P09-ui-kit -m "[P09] merge after independent audit PASS"
    git tag enhanced/p09-pass
    git worktree remove ../audit-ui-kit && git branch -d audit/P09
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P09-ui-kit && git merge --ff-only audit/P09`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P09/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
