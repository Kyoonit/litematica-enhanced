# Litematica Enhanced — P03 · Target architecture and migration plan
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-architecture phase/P03-architecture` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-architecture`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p02-pass` · HEAD = branch `phase/P03-architecture` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P03** aimed to deliver: **Target architecture and migration plan**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P03/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P03/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p02-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P03/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p02-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P03-NN`, with a severity:
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
1. ADR-0002 to ADR-0015 exist. Each has ≥ 2 genuine options with pros, cons, cost and risk; evidence links (P02 findings, measurements, code references); a decision; consequences; migration and rollback; and verification.
2. Every ADR has a human decision recorded in `DECISIONS.md` (accepted/amended/rejected, with date). ADR statuses match those decisions.
3. `architecture/target.md` maps **each** P02 top-20 problem to the ADR and step that addresses it, or to an explicit "won't address" with a reason.
4. `architecture/migration-plan.md` lists every strangler step with phase, flag, parity test, benchmark gate, rollback and upstream category. Any change to `ROADMAP-PLAN.md` is explained.
5. `architecture/targets.md` gives numeric targets, each citing a baseline result file, or a defined measurement method where no baseline exists yet.
6. The threading ADR explicitly handles: GPU uploads on the render thread, the placement daemon, snapshot consistency, cancellation on lifecycle events, and kill switches.
7. The identity ADR defines coexistence and data migration with official Litematica without ever modifying the user's original files.
8. The architecture test rules are specified (rule, rationale, how it will be tested).
9. No changes under `src/main/**` on the phase branch. Spikes live only on `spike/*` branches and are documented.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` stays green (sanity).
- `git diff --stat enhanced/p02-pass..HEAD -- src/main` → empty.
- Link check: every evidence link in the ADRs resolves to an existing file or line (a small script; log the result).

## 5. Phase-specific audit focus
- **Consistency:** ADRs must not contradict `REFERENCE.md` (for example no new runtime dependency without saying so, and format compatibility preserved) or each other. Example: the threading ADR must match the job-system ADR.
- **Real alternatives:** flag ADRs whose "options" are straw men.
- **Feasibility in Minecraft:** check the threading ADR against reality. GL/GPU work must stay on the render thread. Vanilla section compilation runs on worker threads using snapshots: does the ADR rely on the same guarantees for Litematica's block model renderers? Is the evidence (spike) real?
- **Upstream friendliness:** estimate whether the migration plan keeps the number of upstream lines touched small. Flag big-bang moves.
- **Targets:** every numeric target cites a baseline file that exists and contains that metric. Targets must be measurable by the existing harness.
- **Human approval:** `DECISIONS.md` entries exist for every ADR. An ADR marked accepted without a recorded decision is a BLOCKER.
- **Compatibility:** the identity ADR handles add-ons (`provides`), side-by-side installs and data migration safely.

## 6. Output

- Write `docs/enhanced/phases/P03/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P03` → `git add docs/enhanced/phases/P03/audit.md docs/enhanced/phases/P03/audit-logs` → `git commit -m "[P03] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P03-architecture && git merge --ff-only audit/P03
    git switch enhanced/main
    git merge --no-ff phase/P03-architecture -m "[P03] merge after independent audit PASS"
    git tag enhanced/p03-pass
    git worktree remove ../audit-architecture && git branch -d audit/P03
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P03-architecture && git merge --ff-only audit/P03`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P03/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
