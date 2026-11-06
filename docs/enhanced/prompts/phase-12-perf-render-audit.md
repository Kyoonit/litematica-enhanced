# Litematica Enhanced — P12 · Rendering performance (off-thread meshing, frame budget, memory)
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-perf-render phase/P12-perf-render` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-perf-render`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p11-pass` (sequential order) — or enhanced/p08-pass when run in parallel with the UI track (P09–P11) in a separate worktree, since render/** and world/** are disjoint from gui/** and ui/** · HEAD = branch `phase/P12-perf-render` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P12** aimed to deliver: **Rendering performance (off-thread meshing, frame budget, memory)**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P12/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P12/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p11-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P12/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p11-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P12-NN`, with a severity:
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
1. `plan.md` contains the bottleneck evidence (raw files) and the split decision. If split, the report covers exactly the half implemented, and the other half's plan exists.
2. (P12a) Meshing runs on the shared pool from immutable snapshots. No worker reads live world objects (code review notes plus an architecture or guard test). GPU uploads happen on the render thread only.
3. (P12a) The adaptive budget replaces the hard-coded one. The defaults are justified by measurements. The legacy behaviour is reachable through config.
4. (P12a) Stale work is cancelled on move, remove, layer change and dimension change, and stale meshes are never uploaded (tests with version stamps).
5. (P12b) Dirty granularity, buffer pooling and the schematic-world memory option are implemented as planned. Retained heap per block before/after is measured on S/M/L.
6. Before/after comparison tables for `fly-M`, `fly-L`, `layer-rebuild-L`, `load-L`, `move-placement-M` and `dimension-change-M`: the targeted metrics (p99 frame time, stutters > 50 ms, time to first render) improve beyond the claim threshold, reproduced in 2 sessions. No other metric regresses beyond thresholds.
7. Visual equivalence: screenshots from the legacy and new paths match within tolerance for every fixture scene (diff images committed), including translucent sorting.
8. The ≥ 10-minute stress test passes: no exceptions, no leaked threads or buffers, stable post-GC heap (trend file).
9. `render.threadedMeshing` (and any other new flag) is tested in both states. The legacy path still passes the golden render tests.
10. The compat matrix in `compat/mods.md` is filled in (automated and manual results, with versions).

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (visual equivalence, cancellation, kill switch).
- Benchmarks (≥ 5 runs, 2 sessions for claimed improvements): `fly-M`, `fly-L`, `layer-rebuild-L`, `load-L`, `move-placement-M`, `dimension-change-M`, plus `chunk-transition-L` if it exists.
- Stress test script (≥ 10 min) with log, thread dump and heap trend.
- Compat checks (automated part) + the manual checklist file for the human.

## 5. Phase-specific audit focus
- **Measurement integrity:** same machine fingerprint, settings and scenario versions between before and after. Was the "before" re-measured at this phase's base? Re-run `fly-L` and `layer-rebuild-L` yourself if a display is available.
- **False optimisations:** are fewer sections rendered (a culling bug) rather than rendering faster? Check against the visual-equivalence diffs and the section counts in diagnostics. Are there throughput gains with worse latency to the first complete render?
- **Thread safety:** for each renderer used on workers, read the code for shared mutable state (static caches, `BlockPos.MutableBlockPos` statics, tint caches, AO buffers). Search for `static final MutableBlockPos` and similar. A shared mutable static used by workers is a BLOCKER.
- **Off-thread GL:** search worker code paths for GPU buffer and pipeline calls.
- **Stale uploads:** move a placement during a heavy rebuild. Old meshes must never appear at the old position.
- **Leaks:** check buffer frees on unload and dimension change. Check the heap trend file.
- **Kill switch:** with `render.threadedMeshing=false`, behaviour and screenshots match the legacy path.
- **Compat:** Sodium/Iris paths compile and the conditional mixins still apply (mixin audit log if available).

## 6. Output

- Write `docs/enhanced/phases/P12/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P12` → `git add docs/enhanced/phases/P12/audit.md docs/enhanced/phases/P12/audit-logs` → `git commit -m "[P12] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P12-perf-render && git merge --ff-only audit/P12
    git switch enhanced/main
    git merge --no-ff phase/P12-perf-render -m "[P12] merge after independent audit PASS"
    git tag enhanced/p12-pass
    git worktree remove ../audit-perf-render && git branch -d audit/P12
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P12-perf-render && git merge --ff-only audit/P12`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P12/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
