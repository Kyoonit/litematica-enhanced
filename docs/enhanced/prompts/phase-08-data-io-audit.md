# Litematica Enhanced — P08 · Schematic model and I/O foundations
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-data-io phase/P08-data-io` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-data-io`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p07-pass` · HEAD = branch `phase/P08-data-io` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P08** aimed to deliver: **Schematic model and I/O foundations**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P08/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P08/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p07-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P08/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p07-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P08-NN`, with a severity:
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
1. The `Schematic` interface and the codecs for every format exist. `LitematicaSchematic` is a facade. Every golden master is unchanged (semantic equivalence for reads; deterministic writer outputs identical apart from timestamps).
2. Region indexing uses overflow-safe arithmetic. Boundary tests cover the limits (2³¹−1, 2³¹, negative, zero).
3. Metadata-only read works for every format that carries metadata, and it is faster than a full load for M/L/XL by the improvement threshold (raw benchmark files).
4. No GUI handler calls a synchronous file load on the client thread (architecture test plus code search). Load jobs report progress, cancel cleanly (no partial state left in the holder or the placement manager), and deliver on the client thread. Behind `io.asyncLoad`, the legacy path is still tested.
5. Every writer uses the atomic helper (architecture test). A fault-injection test proves that the original file survives a crash during overwrite, for at least `.litematic` and one JSON data file.
6. The validation report covers the listed categories, offers repair options, and is tested with crafted malformed fixtures.
7. The fuzz harness ran ≥ 10,000 inputs per format with zero crashes, hangs or OOMs (summary log with seeds). Limits are configurable and tested.
8. Index correctness tests pass (add, remove, modify, rename, concurrent modification). The 1,000-file build/rescan benchmark is recorded.
9. The memory accounting API is validated against measured heap for S/M/L, with the error margin reported.
10. The add-on compile-compat test is green. Full suites green. `load-*`, `save-L` and `fly-M` are within thresholds or improved (raw files).

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests + architecture tests + the add-on compile-compat test.
- Golden masters (full), fuzz harness (seeded; summary log), fault-injection tests.
- Benchmarks: `load-S/M/L/XL` (full vs metadata), `save-L`, the index 1,000-file scenario, `fly-M` (≥ 5 runs each).

## 5. Phase-specific audit focus
- **Format equivalence:** independently re-run the golden suite. Then take 5 **real-world** schematics the human provides (or that are licence-cleared) and compare legacy vs new decoding semantically. Any difference is a BLOCKER unless an ADR documents it.
- **Writer determinism:** write a schematic with both the legacy (baseline jar) and the new code, and diff the decoded NBT trees.
- **Async correctness:** cancel a load at 10%, 50% and 99%. Check that no placement or holder entry appears, and that file handles are closed (Windows file-lock symptom). Load the same file twice concurrently.
- **Atomicity:** inspect the helper for `force`/fsync, a temp file in the same directory, the `ATOMIC_MOVE` fallback, cleanup on failure, and symlink handling. Run the fault-injection test yourself.
- **Fuzz honesty:** re-run the harness with a different seed for 1,000 inputs per format.
- **Limits:** try a crafted file just above each limit. You must get a clean error.
- **Index:** concurrent modification during a rescan, and a deleted directory. No crash and no stale entries after the next rescan.
- **Add-ons:** the compile-compat test actually exercises the methods listed in `compat/addons.md`.
- **Memory claims:** check the estimate-vs-measured table against raw files.

## 6. Output

- Write `docs/enhanced/phases/P08/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P08` → `git add docs/enhanced/phases/P08/audit.md docs/enhanced/phases/P08/audit-logs` → `git commit -m "[P08] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P08-data-io && git merge --ff-only audit/P08
    git switch enhanced/main
    git merge --no-ff phase/P08-data-io -m "[P08] merge after independent audit PASS"
    git tag enhanced/p08-pass
    git worktree remove ../audit-data-io && git branch -d audit/P08
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P08-data-io && git merge --ff-only audit/P08`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P08/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
