# Litematica Enhanced — P11 · Placement, selection, tools and HUD redesign
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-ui-placement phase/P11-ui-placement` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-ui-placement`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p10-pass` · HEAD = branch `phase/P11-ui-placement` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P11** aimed to deliver: **Placement, selection, tools and HUD redesign**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P11/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P11/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p10-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P11/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p10-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P11-NN`, with a severity:
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
1. The new placement list and editor, sub-region editor, area selection editors, tool HUD and context menu match their approved mockups (side-by-side screenshots at scales 2 and 3) and work at scale 4 in a 320×240 window.
2. Parity checklists for every replaced legacy screen are complete: every option, toggle and action is reachable. Verified by a test that enumerates the config options and actions related to placements and selections.
3. The live transform preview shows the same result as applying the transform (test comparing the preview model with the applied placement for all 8 rotation/mirror combinations).
4. Origin tools (snap to looked-at block, move to player, numeric steppers, nudge keys) are tested in game tests.
5. Existing hotkeys keep their IDs and defaults (config-defaults snapshot green). New defaults have no conflicts (conflict test). The context-menu key is configurable.
6. The HUD respects F1/hide-HUD, its position and scale settings work, and its frame cost is within the `targets.md` budget (benchmark `hud-overlay-L`).
7. State mutations happen on the client thread only (code review plus an architecture test, if feasible). No new packets are sent (fairness: the dev cause log shows nothing new for these screens).
8. The journey step counts for J-03, J-04 and J-08 meet the "after" counts from `journeys.md` (screenshots).
9. Full suites, golden masters and game tests are green. `fly-M` and `move-placement-M` are within thresholds.
10. Docs pages exist and match the behaviour.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (editors, preview equivalence, origin tools, HUD toggles, context menu, keyboard navigation, screenshots).
- Benchmarks: `hud-overlay-L` (new; versioned), `fly-M`, `move-placement-M`.
- Hotkey conflict test; config-defaults snapshot.

## 5. Phase-specific audit focus
- **Lost capabilities:** list every placement-, sub-region- and selection-related config option and hotkey at BASE. Find each one in the new UI or a documented equivalent. A missing one is MAJOR.
- **Preview truthfulness:** test unusual blocks (rails, stairs, chests, redstone, rotated entities such as item frames) under rotation and mirror. Compare the preview with the result.
- **Threading:** look for placement/selection mutations from callbacks that may run off-thread (job completions must run on the client thread).
- **Fairness:** the context menu and palette must not trigger F2 actions without a confirmation. No new packets.
- **HUD:** F1, screenshots (F2 key) and the debug screen interplay. The HUD must not render in GUIs where it should not.
- **Keyboard:** the editors are fully usable without a mouse.
- **Journeys:** recount J-03 and J-08.

## 6. Output

- Write `docs/enhanced/phases/P11/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P11` → `git add docs/enhanced/phases/P11/audit.md docs/enhanced/phases/P11/audit-logs` → `git commit -m "[P11] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P11-ui-placement && git merge --ff-only audit/P11
    git switch enhanced/main
    git merge --no-ff phase/P11-ui-placement -m "[P11] merge after independent audit PASS"
    git tag enhanced/p11-pass
    git worktree remove ../audit-ui-placement && git branch -d audit/P11
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P11-ui-placement && git merge --ff-only audit/P11`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P11/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
