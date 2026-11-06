# Litematica Enhanced — P13 · Analysis engines — verifier, materials, diff
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-engines phase/P13-engines` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-engines`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p12-pass` (P12 must be merged first: overlays share the render path) · HEAD = branch `phase/P13-engines` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P13** aimed to deliver: **Analysis engines — verifier, materials, diff**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P13/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P13/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p12-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P13/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p12-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P13-NN`, with a severity:
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
1. The golden masters for verifier and material outputs cover every category and option listed in WP1 (coverage table in the report).
2. The new verifier and material engines produce identical results to the legacy implementations on all fixtures. Any documented exception has an ADR note, a register ID and an isolated golden commit.
3. The incremental recheck is proven by tests: a single block change re-verifies only the affected unit(s) (instrumented count), and the results match a full recompute.
4. Engines run as cancellable jobs. Cancellation at random points leaves consistent state (tests). Dimension change and disconnect invalidate snapshots and jobs (game test).
5. Worker code reads only snapshots (review notes + guard test). The snapshot cost is measured and reported.
6. Before/after benchmarks `verify-M`, a new `verify-L`, `material-list-L` and `incremental-recheck-L` (new; versioned) show improvements beyond the claim threshold on the targeted metrics, or a documented justification where the gain is in memory rather than time. Retained heap for verifier results with many mismatches is measured before/after.
7. The diff engine has golden tests on fixture pairs (schematic ↔ schematic, schematic ↔ world).
8. Material availability uses only client-observed data (code review + test). Opened-container caching is opt-in.
9. Kill switches are tested in both states. Full suites green. `fly-M` within thresholds.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (verifier on prepared worlds, incremental recheck, lifecycle).
- Golden equivalence suites (verifier, materials, diff).
- Benchmarks (≥ 5 runs; claims in 2 sessions): `verify-M`, `verify-L`, `material-list-L`, `incremental-recheck-L`, `fly-M`.
- Randomised cancellation test (seeded).

## 5. Phase-specific audit focus
- **Equivalence:** run the golden suites yourself. Then build an adversarial fixture world: waterlogged blocks, double slabs, doors and beds (multi-block), fluids, block entities with NBT, entities, ignored mismatches, and the "ignore state" option. Compare legacy vs engine outputs.
- **Incremental correctness:** randomly mutate 100 blocks and compare the incremental results with a full recompute.
- **Snapshot consistency:** can a snapshot mix states from two ticks (tearing)? Is the client-world section copied atomically on the client thread?
- **Memory claims:** check the before/after heap numbers against the raw files.
- **Privacy and fairness:** availability inputs — no scanning of containers the player did not open, and no packets.
- **Kill switches:** the legacy path still produces the legacy outputs.

## 6. Output

- Write `docs/enhanced/phases/P13/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P13` → `git add docs/enhanced/phases/P13/audit.md docs/enhanced/phases/P13/audit-logs` → `git commit -m "[P13] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P13-engines && git merge --ff-only audit/P13
    git switch enhanced/main
    git merge --no-ff phase/P13-engines -m "[P13] merge after independent audit PASS"
    git tag enhanced/p13-pass
    git worktree remove ../audit-engines && git branch -d audit/P13
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P13-engines && git merge --ff-only audit/P13`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P13/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
