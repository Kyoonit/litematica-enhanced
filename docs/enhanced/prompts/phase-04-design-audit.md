# Litematica Enhanced — P04 · Design system and GUI mockups
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-design phase/P04-design` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-design`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p03-pass` · HEAD = branch `phase/P04-design` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P04** aimed to deliver: **Design system and GUI mockups**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P04/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P04/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p03-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P04/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p03-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P04-NN`, with a severity:
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
1. `ia.md` maps **every** feature ID in `registers/features.md` to a place in the new navigation. No orphans, no removals.
2. `journeys.md` gives before/after step counts for ≥ 12 journeys. The "after" counts are consistent with the mockups.
3. `tokens.json` and `tokens.md` exist. The contrast report is produced by a committed script: all body text ≥ 4.5:1, large/bold text and icons ≥ 3:1 against their backgrounds (or justified exceptions).
4. `components.md` specifies all listed components, with states, keyboard behaviour and size constraints at GUI scales 1–4.
5. The 14 mockup files exist, open offline, support 2×/3×/4× and the two canvas sizes, and use only the tokens (checked by a script that flags colours not in `tokens.json`).
6. The spike produced screenshots at GUI scales 1–4 and a measured frame cost for the 10k-row list (raw file). Translation issues are documented. The spike branch is not merged.
7. Placeholder art is clearly marked, and `art-needs.md` lists the final art required.
8. `DECISIONS.md` records human approval for every screen family (with mockup hashes) and the confirmed or amended ADR-0010.
9. No changes under `src/main/**` on the phase branch.

## 4. Mandatory re-runs and checks
- Contrast script run (output committed).
- Token-usage linter on the mockups (output committed).
- Spike game test (screenshots) and frame-cost measurement (raw file).
- `git diff --stat enhanced/p03-pass..HEAD -- src/main` → empty.

## 5. Phase-specific audit focus
- **Minecraft realism:** do the mockups respect the vanilla font size (≈ 9 px line height at scale 1), integer pixel snapping, the minimum canvas of 320×240 units, and no hover-only critical information? Compare with the spike screenshots: does the HTML promise something the game cannot render?
- **Completeness:** sample 10 feature IDs and find them in the IA and the mockups. Every existing configuration option must remain reachable (via settings at least).
- **Journey honesty:** recount 3 "after" step counts against the mockups.
- **Accessibility:** re-run the contrast script. Check keyboard paths for 3 screens (focus order defined, a visible focus style exists).
- **Token discipline:** re-run the linter. Hard-coded colours outside the tokens are MINOR (MAJOR if widespread).
- **Approvals:** every screen family has an approval with a hash matching the committed file. Missing approval is a BLOCKER.
- **Art:** no AI-generated art presented as final. Placeholders are named.
- **Scope:** no new features beyond the inventory (new ideas belong in the P05 long-list).

## 6. Output

- Write `docs/enhanced/phases/P04/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P04` → `git add docs/enhanced/phases/P04/audit.md docs/enhanced/phases/P04/audit-logs` → `git commit -m "[P04] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P04-design && git merge --ff-only audit/P04
    git switch enhanced/main
    git merge --no-ff phase/P04-design -m "[P04] merge after independent audit PASS"
    git tag enhanced/p04-pass
    git worktree remove ../audit-design && git branch -d audit/P04
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P04-design && git merge --ff-only audit/P04`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P04/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
