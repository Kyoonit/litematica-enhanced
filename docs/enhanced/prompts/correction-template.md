# Litematica Enhanced — Correction prompt (template)

> **When:** after an independent audit returns **FAIL**, or **PASS WITH RESERVATIONS** for reservations you want fixed now.
> **How:** fill in the five fields below, start Claude Code on the phase branch (fresh session recommended), and paste the whole prompt. Afterwards, run the **delta re-audit** (end of this file) in a separate session.

```text
PHASE        = PXX                                   (e.g. P07)
BRANCH       = phase/PXX-<slug>
AUDIT_FILE   = docs/enhanced/phases/PXX/audit.md      (or audit-delta-N.md)
FINDINGS     = AUD-PXX-03, AUD-PXX-07                (or: "all BLOCKER and MAJOR")
EXTRA_NOTES  = <optional instructions from the human, e.g. "AUD-PXX-05: accept the risk, do not fix">
```

---

## 0. Context (short)
*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- Upstream is `sakura-ryoko/litematica` / `sakura-ryoko/malilib`. Baseline: MC 26.3, Java 25.
- Project memory and rules live in `docs/enhanced/`: `STATE.md` first, then `REFERENCE.md` (authoritative), `AGENTS.md`, `registers/`, `knowledge/`.
- The phase's own prompt is versioned at `docs/enhanced/prompts/phase-<NN>-<slug>-implementation.md`. Its §3 defines the scope, the acceptance criteria and the mandatory tests.

## 1. Mission
Fix **exactly** the findings listed in `FINDINGS`, at their root cause, with proof. Leave everything else as it is. Work that already passed review must stay untouched.

## 2. Rules
1. **Allowed scope.** Before editing, build the `ALLOWED_PATHS` list: the files cited by the findings, their direct tests, and the tracking docs (`phases/PXX/*`, `STATE.md`, registers). Write it at the top of `docs/enhanced/phases/PXX/corrections.md`. Any edit outside it needs a one-line justification in that file. Edits to subsystems validated in **earlier phases** are forbidden unless a finding is located there.
2. **No refactors, no reformatting, no new features, no "while I'm here" changes.** Hot files remain lead-only (you are the lead in this session).
3. **Failing first.** For each finding, first reproduce it: a failing test, a failing check, or a documented reproduction. Then fix it, then show that the reproduction passes.
4. **Never weaken tests.** No deleted or loosened assertions. Golden files are regenerated only if the finding says the golden is wrong, in a separate commit with a justification.
5. **Disagreement is allowed, silence is not.** If you believe a finding is incorrect, do not skip it quietly. Write a rebuttal with evidence in `corrections.md`, mark it `disputed`, and leave the decision to the human and the re-auditor.
6. **Escalate decisions.** If a fix requires changing an accepted ADR, a human-approved design, the scope of the phase, or a dependency, **stop and ask**.
7. **Evidence and honesty rules** from `REFERENCE.md §5` apply in full: no invented results, measure before and after, compiling proves nothing.
8. **Commits:** one per finding (or a tight group), message `[PXX][fix AUD-PXX-NN] <summary>` with the evidence path in the body.

## 3. Procedure
1. **Orient.** Read `STATE.md`, `AUDIT_FILE` (the listed findings verbatim), the phase `plan.md`, `report.md`, and the phase prompt's §3. Record the current HEAD sha as `BASE_DELTA` in `corrections.md`.
2. **Triage table** in `corrections.md`:

   | Finding | Severity | Restated problem | Reproduction (test/check) | Root cause | Planned fix | Files | Status |
   |---|---|---|---|---|---|---|---|

3. **Loop per finding:** reproduce → root cause → minimal fix → targeted test green → commit. If two serious attempts fail, stop and write a blocker note.
4. **Full verification** after all fixes:
   - `./gradlew clean build test`, plus the phase's mandatory tests and checks (phase prompt §3);
   - benchmark scenarios if any fix touches performance-sensitive code (same protocol and machine, before/after files).
   Save the logs to `docs/enhanced/phases/PXX/logs/corrections-N/`.
5. **Update the records:**
   - `report.md`: a "Corrections round N" section and new claims-ledger rows;
   - `registers/problems.md`: statuses;
   - `STATE.md`: status `in-audit (delta)`, and next action = delta re-audit with `BASE_DELTA..HEAD`.
6. **Final message (≤ 15 lines):** findings fixed, disputed or blocked; verification results; the exact delta re-audit instruction below with the two shas filled in.

---

## Delta re-audit (paste into a NEW session, together with the phase's audit prompt)

```text
DELTA MODE for the PXX audit.
BASE_DELTA = <sha recorded in corrections.md>   HEAD = <current sha of phase/PXX-...>
FINDINGS UNDER REVIEW = <IDs>

In addition to (or instead of) the full protocol, do this:
1. For each finding: re-run its specific check or reproduction and confirm it is resolved, with evidence.
   For "disputed" findings: evaluate the rebuttal on its merits and decide (upheld / withdrawn).
2. Re-run the phase's mandatory tests and checks in full (§4 of the audit prompt). They must all pass.
3. Scope check: `git diff --stat BASE_DELTA..HEAD`. Every file must be in ALLOWED_PATHS or justified in
   corrections.md. Unjustified edits to subsystems validated in earlier phases are MAJOR.
4. Regression check: review the full diff of the touched files for new defects. Run the golden masters.
5. Write docs/enhanced/phases/PXX/audit-delta-N.md and give a verdict (PASS / PASS WITH RESERVATIONS / FAIL)
   using the same rules as the full audit. A full audit is required instead if the delta touches more than
   ~30% of the phase's files or any hot file in a non-trivial way.
6. Commit only that file on a new branch: git switch -c audit/PXX-delta-N, then git add + git commit.
   The human fast-forwards the phase branch to it (git merge --ff-only audit/PXX-delta-N) before merging.
```
Run the delta audit in a detached worktree, exactly like the full audit:
`git worktree add --detach ../audit-PXX-delta-N phase/PXX-<slug>`.
