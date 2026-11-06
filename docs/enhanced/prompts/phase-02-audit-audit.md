# Litematica Enhanced — P02 · Deep technical and functional audit
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-audit phase/P02-audit` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-audit`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p01-pass` · HEAD = branch `phase/P02-audit` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P02** aimed to deliver: **Deep technical and functional audit**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P02/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P02/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p01-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P02/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p01-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P02-NN`, with a severity:
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
1. Every STRATEGY finding ID (UX-01..08, PERF-01..09, ARCH-01..07, REL-01..08, SEC-01) has status **confirmed / refuted / unclear**, with evidence: a code reference, a raw benchmark/JFR file, or an experiment log.
2. All P01 scenarios (plus any added ones) were run with JFR. The top-10 hotspots are quantified (share of frame time or allocation) with links to raw files. Retained heap per placed block is measured for S/M/L, with an attribution of what holds it.
3. The fault-injection results for REL-01..06 and SEC-01 are documented with reproducible steps. Every confirmed bug has a disabled/expected-failure test or a precise reproduction recipe, with its register ID.
4. The feature inventory is complete: every config option, hotkey, tool mode, screen and command has a feature ID and a keep/improve/replace/remove-candidate status with justification. Each remove-candidate has a usage analysis.
5. ≥ 12 user journeys are documented with step counts and pain points, backed by game-test screenshots.
6. `compat/addons.md` lists the Litematica API surface used by ≥ 4 add-ons (or documents why one could not be analysed). The mod compatibility matrix has automated results and a manual checklist for the human.
7. Knowledge notes exist for the 16 listed subsystems, each stamped with a commit. `mixin-register.md` covers 100% of the existing mixins (count matches `mixins.litematica.json`).
8. `registers/problems.md` is ranked with an explained scoring model. Every row has an upstream category.
9. `synthesis.md` exists, including the challenge-round record (disputed findings and resolutions).
10. `git diff --stat enhanced/p01-pass..HEAD -- src/main` is **empty**.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` (must stay green; added characterisation tests are disabled or expected-failure and documented).
- Game tests used for screenshots (log).
- Benchmarks with JFR: all scenarios (raw files under `docs/enhanced/benchmarks/results/` or compressed artefacts with hashes).
- `git diff --stat enhanced/p01-pass..HEAD -- src/main` → empty.

## 5. Phase-specific audit focus
- **Sample-verify 6 findings** (2 confirmed performance, 2 confirmed reliability, 1 refuted, 1 new). Reproduce them yourself from the documented evidence. An irreproducible "confirmed" finding is MAJOR.
- **Numbers:** every number in `synthesis.md` must trace to a raw file. Look for rounded or "approximately" values without a source.
- **Invented facts:** check that issue/PR numbers, add-on behaviours and competitor claims have links. Inaccessible sources must be labelled as such.
- **Inventory completeness:** independently extract config and hotkey IDs and diff them against `registers/features.md`. A missing item is MINOR; a whole category missing is MAJOR.
- **Remove-candidates:** each must have its usage analysis. A feature proposed for removal without one is MAJOR.
- **Journeys:** check 3 step counts against the code or screenshots.
- **Read-only rule:** `src/main` untouched. Experiments not merged. Added tests disabled or expected-failure, with IDs.
- **Mixin register:** count rows against the mixin JSON.
- **Bias check:** do the findings over-weight what is easy to measure? Point out important subsystems that received no attention.

## 6. Output

- Write `docs/enhanced/phases/P02/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P02` → `git add docs/enhanced/phases/P02/audit.md docs/enhanced/phases/P02/audit-logs` → `git commit -m "[P02] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P02-audit && git merge --ff-only audit/P02
    git switch enhanced/main
    git merge --no-ff phase/P02-audit -m "[P02] merge after independent audit PASS"
    git tag enhanced/p02-pass
    git worktree remove ../audit-audit && git branch -d audit/P02
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P02-audit && git merge --ff-only audit/P02`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P02/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
