# Litematica Enhanced — P05 · Feature specification and backlog
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-features phase/P05-features` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-features`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p04-pass` (or enhanced/p03-pass if you run P05 in parallel with P04) · HEAD = branch `phase/P05-features` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P05** aimed to deliver: **Feature specification and backlog**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P05/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P05/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p04-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P05/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p04-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P05-NN`, with a severity:
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
1. Every *improve/replace* feature from P02 and every long-list idea has a complete card (all template fields filled) or an explicit merge into another card.
2. Every card has a fairness class. All F3 ideas are listed in `specs/REJECTED.md` with reasons, and none appears in an allocation.
3. Every card has a cost class with a justification, the foundations it requires, the subsystems it touches, and risks agreed with the architect (noted in the card).
4. `specs/interactions.md` covers every selected card against every subsystem it touches, and names the conflicts with their resolutions.
5. `specs/scoring.md` defines the model, and the scores can be recomputed from card fields (a script or a table with formulas).
6. The allocation for P15/P16/P17 fits L-size budgets (justified) and states upstream categories.
7. The human selection is recorded in `DECISIONS.md`. `registers/features.md` reflects it (phase, status).
8. Each selected card has testable acceptance criteria and a test plan.
9. No changes under `src/main/**`.

## 4. Mandatory re-runs and checks
- Score recomputation script/table matches the card values (log).
- Consistency check: every selected card ID exists in `registers/features.md` with the right phase (script or manual table).
- `git diff --stat <base>..HEAD -- src/main` → empty.

## 5. Phase-specific audit focus
- **Evidence for value:** sample 6 cards. Value and reach claims must cite journeys, P02 findings or add-on evidence, never invented numbers.
- **Fairness:** scrutinise every F1/F2 card for hidden autonomy (timers, loops, "auto" anything that sends packets). Anything that acts on the world without a per-action user input or a confirmed F2 job is a BLOCKER if it is selected.
- **Cost realism:** compare 4 cost estimates with the foundations they depend on. Flag cards that silently assume unbuilt foundations.
- **Interactions:** find at least 2 interaction conflicts the matrix missed, if any exist.
- **Budget:** check that each wave fits an L size class. Suggest a split if not.
- **Upstream categories:** check that they are plausible against `UPSTREAM.md §4`.
- **Selection record:** a human decision exists for each wave. Missing is a BLOCKER.

## 6. Output

- Write `docs/enhanced/phases/P05/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P05` → `git add docs/enhanced/phases/P05/audit.md docs/enhanced/phases/P05/audit-logs` → `git commit -m "[P05] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P05-features && git merge --ff-only audit/P05
    git switch enhanced/main
    git merge --no-ff phase/P05-features -m "[P05] merge after independent audit PASS"
    git tag enhanced/p05-pass
    git worktree remove ../audit-features && git branch -d audit/P05
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P05-features && git merge --ff-only audit/P05`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P05/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
