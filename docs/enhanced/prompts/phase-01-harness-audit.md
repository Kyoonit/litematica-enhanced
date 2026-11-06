# Litematica Enhanced — P01 · Test and measurement harness
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-harness phase/P01-harness` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-harness`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p00-pass` · HEAD = branch `phase/P01-harness` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P01** aimed to deliver: **Test and measurement harness**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P01/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P01/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p00-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P01/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p00-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P01-NN`, with a severity:
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
1. ADR-0001 is written and lists every test-scope dependency with its justification. `fabric.mod.json` and the shipped jar contain **no** new runtime dependency (jar inspected).
2. `./gradlew test` passes and runs meaningful tests covering at least: container behaviour, the 8 transform combinations on representative blocks, `.litematic` round-trip, Sponge v1/v2/v3, vanilla structure and Schematica loading, conversions and v6 downgrade, material counts, and the config-defaults snapshot. Test counts are reported per family.
3. The corpus generator is deterministic (a test proves byte-identical output for the same seed). Committed fixtures are small, and large ones are generated on demand.
4. Golden files exist for every committed fixture and conversion, with a README stating the generating commit and listing the known-bug characterisations (register IDs).
5. The client game-test task boots the client, places a fixture, captures screenshots at GUI scales 2 and 3, asserts verifier counts, and passes locally (log + screenshots committed or linked). CI defines the game-test job.
6. The benchmark harness implements the 11 listed scenarios, writes JSON valid against the schema with a full fingerprint, and the comparison tool produces the threshold verdict table. `PROTOCOL.md` is complete.
7. Seams are listed, disabled by default, and proven within noise of the baseline jar on `fly-M` (raw files for both).
8. Baseline result files exist for the 6 required scenarios, with ≥ 5 measured runs each, from the reference machine.
9. CI is green on the phase branch (build + unit tests).
10. `knowledge/testing.md` exists and the `CLAUDE.md` commands are updated. No production behaviour changed: golden tests run against the baseline jar logic and pass.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` from a clean checkout.
- The client game-test task (exact name in `knowledge/testing.md`), locally.
- Generator determinism test (run twice, compare hashes).
- Bench: `fly-M` with seams disabled vs the baseline jar (≥ 5 runs each) → comparison table.
- Jar inspection: list jar contents and `fabric.mod.json` depends → no Fabric API, no test libraries.
- Schema validation of every committed result JSON.

## 5. Phase-specific audit focus
- **Are the tests meaningful?** In a throwaway worktree, make 3 mutation probes (for example flip a rotation mapping, break the palette resize, change a material count) and confirm that at least one test fails for each. Report probes that survive as MAJOR.
- **Determinism:** run the corpus generator and the golden suite twice yourself.
- **Golden integrity:** check that golden files were produced from code equivalent to the baseline (production diff limited to seams), and that no golden file was hand-edited.
- **Benchmark validity:** check the warm-up and run counts, identical settings across runs, the fingerprint, vsync/FPS cap, and that scenario versions are recorded. Re-run one scenario if a display is available.
- **Seams:** confirm that each seam is a no-op when disabled (read the code; check for per-frame allocations with a short JFR allocation recording, if possible).
- **Dependency leakage:** inspect the built jar and `fabric.mod.json`. Fabric API, JUnit and jqwik must be absent.
- **CI:** check the workflow file. The original build step must still be present. Test reports must be uploaded.
- **Honesty:** if the baseline numbers were produced by the human, the report must say so. If they are missing, the criterion is unproven and the verdict is FAIL.

## 6. Output

- Write `docs/enhanced/phases/P01/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P01` → `git add docs/enhanced/phases/P01/audit.md docs/enhanced/phases/P01/audit-logs` → `git commit -m "[P01] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P01-harness && git merge --ff-only audit/P01
    git switch enhanced/main
    git merge --no-ff phase/P01-harness -m "[P01] merge after independent audit PASS"
    git tag enhanced/p01-pass
    git worktree remove ../audit-harness && git branch -d audit/P01
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P01-harness && git merge --ff-only audit/P01`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P01/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
