# Litematica Enhanced — P14 · Verifier, materials, projects and settings UI
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-ui-analysis phase/P14-ui-analysis` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-ui-analysis`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p13-pass` · HEAD = branch `phase/P14-ui-analysis` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P14** aimed to deliver: **Verifier, materials, projects and settings UI**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P14/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P14/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p13-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P14/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p13-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P14-NN`, with a severity:
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
1. All screens match their approved mockups (side-by-side screenshots at scales 2 and 3) and work at scale 4 in a 320×240 window.
2. The verifier screen handles ≥ 100,000 mismatches smoothly: `verifier-ui-100k` (new; versioned) meets the `targets.md` budget, with no per-frame allocation proportional to the result count (JFR).
3. The counts displayed equal the engine results (tests on fixtures). Jump-to, ignore and export work (tests). Overlays add non-colour cues.
4. The build-assistant panel shows correct progress and nearest-N results on fixtures (tests). It is display-only: no packets (cause log).
5. The material screen shows needed/available/missing correctly on fixtures, and exports are deterministic (golden).
6. The VCS screens pass their parity checklist against the legacy screens.
7. Settings: a test enumerates every config option and finds it through search and in its category. "Changed only" and reset work.
8. The keymap editor detects conflicts with Litematica and vanilla keybinds (unit tests with crafted conflicts) and respects context rules.
9. The diagnostics screen shows the P07/P12 data (screenshot + test).
10. Full suites, golden masters and game tests are green. `fly-M` and `verify-M` are within thresholds. Docs pages exist.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (each screen, keyboard navigation, screenshots, verifier jump-to).
- Benchmarks: `verifier-ui-100k`, `verify-M`, `fly-M`.
- Settings coverage test; keymap conflict tests; export goldens.

## 5. Phase-specific audit focus
- **Settings coverage:** independently enumerate all config option IDs at HEAD and search for each in the settings screen (or check the test's list against your enumeration). A missing option is MAJOR.
- **Numbers on screen equal engine numbers:** pick 3 fixture scenes and compare the displayed totals with engine API outputs.
- **Accessibility:** overlays are not colour-only. Keyboard paths exist in all screens.
- **Performance:** re-run `verifier-ui-100k` and check JFR allocations.
- **Fairness:** the build assistant and jump-to send no packets and do not move the player.
- **Parity:** sample 5 VCS and verifier checklist items.
- **Keymap:** craft a conflict with a vanilla key (for example the inventory key) and check that it is reported.

## 6. Output

- Write `docs/enhanced/phases/P14/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P14` → `git add docs/enhanced/phases/P14/audit.md docs/enhanced/phases/P14/audit-logs` → `git commit -m "[P14] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P14-ui-analysis && git merge --ff-only audit/P14
    git switch enhanced/main
    git merge --no-ff phase/P14-ui-analysis -m "[P14] merge after independent audit PASS"
    git tag enhanced/p14-pass
    git worktree remove ../audit-ui-analysis && git branch -d audit/P14
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P14-ui-analysis && git merge --ff-only audit/P14`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P14/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
