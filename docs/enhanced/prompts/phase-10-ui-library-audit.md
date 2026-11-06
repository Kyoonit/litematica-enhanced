# Litematica Enhanced — P10 · Navigation shell, command palette and schematic library
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-ui-library phase/P10-ui-library` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-ui-library`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p09-pass` · HEAD = branch `phase/P10-ui-library` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P10** aimed to deliver: **Navigation shell, command palette and schematic library**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P10/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P10/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p09-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P10/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p09-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P10-NN`, with a severity:
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
1. The action registry covers 100% of existing hotkeys and main-menu entries (a test compares it with the inventory). F2 actions are flagged and require confirmation (test).
2. The shell, palette and library match their approved mockups (side-by-side screenshots in the report) at GUI scales 2 and 3, and work at scale 4 in a 320×240 window.
3. Palette tests: fuzzy search finds every registered action by its title; hotkeys are displayed; unavailable actions show a reason; keyboard-only operation works (game test).
4. Library features work on a 1,000-file fixture set: search, every filter, sorting, tags, favourites, recents, thumbnails, details, rename, trash with undo. Each has a test.
5. Thumbnails are deterministic (the same schematic gives an identical image; test) and generated off the client thread (code plus a JFR thread check).
6. Load/save/convert use jobs with progress and cancel. A cancel leaves no partial state (tests). No synchronous file IO on the client thread in the new screens (architecture test or JFR evidence).
7. The parity checklists for the legacy main menu, load screen and schematic manager are complete. Legacy screens are still reachable behind flags.
8. `library-open-1000`, `library-search` and `thumbnail-build-1000` meet the `targets.md` targets (raw files). `fly-M` is within thresholds.
9. The journey step counts for J-01, J-02 and J-07 (or their equivalents) meet the "after" counts from `journeys.md` (counted on screenshots).
10. User guide pages exist and match the implemented behaviour.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (shell, palette, library flows, keyboard navigation, screenshots).
- Benchmarks: `library-open-1000`, `library-search`, `thumbnail-build-1000`, `fly-M`.
- Registry-vs-inventory coverage test.
- File operation safety tests (names with `../`, reserved Windows names, very long names, unicode).

## 5. Phase-specific audit focus
- **Coverage:** independently list the hotkeys and the legacy main-menu buttons and look them up in the palette. Each missing one is MAJOR.
- **F2 safety:** trigger 2 server-mutating actions from the palette. Confirmation must appear and show what will happen.
- **File safety:** try a malicious rename (`..\..\x`, `CON`, a trailing dot or space on Windows) and a trash restore when the target exists. Permanent deletion must never happen without an explicit action.
- **Index staleness:** add, modify and delete files outside the game while the library is open. The library must recover after a rescan without a crash.
- **Performance:** re-run `library-search` and check the latency claims. Check that thumbnail generation never runs on the client thread.
- **Parity:** sample 5 checklist items in game or in screenshots.
- **Journeys:** recount J-01 in screenshots.
- **Docs vs behaviour:** sample 3 statements of the user guide.

## 6. Output

- Write `docs/enhanced/phases/P10/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P10` → `git add docs/enhanced/phases/P10/audit.md docs/enhanced/phases/P10/audit-logs` → `git commit -m "[P10] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P10-ui-library && git merge --ff-only audit/P10
    git switch enhanced/main
    git merge --no-ff phase/P10-ui-library -m "[P10] merge after independent audit PASS"
    git tag enhanced/p10-pass
    git worktree remove ../audit-ui-library && git branch -d audit/P10
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P10-ui-library && git merge --ff-only audit/P10`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P10/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
