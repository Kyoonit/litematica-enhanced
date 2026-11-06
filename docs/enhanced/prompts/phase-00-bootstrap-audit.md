# Litematica Enhanced — P00 · Bootstrap, fork and baseline preservation
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-bootstrap phase/P00-bootstrap` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-bootstrap`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `baseline/sakura-26.3-0.29.2-sakura.1` (created by this phase; use the actual upstream MC/version if upstream has moved) · HEAD = branch `phase/P00-bootstrap` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P00** aimed to deliver: **Bootstrap, fork and baseline preservation**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P00/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P00/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline baseline/sakura-26.3-0.29.2-sakura.1..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P00/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat baseline/sakura-26.3-0.29.2-sakura.1..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P00-NN`, with a severity:
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
1. `git remote -v` shows `origin` = the fork, and `upstream-sakura` / `upstream-masa` with push URL `DISABLED` (log saved). `rerere.enabled` is true.
2. `vendor/sakura-<mc>` equals the recorded upstream HEAD sha. Tag `baseline/sakura-<mc>-<version>` points to that commit. `enhanced/main` and `phase/P00-bootstrap` exist.
3. `./gradlew build` succeeds on the baseline commit **and** on the phase branch HEAD. Logs saved; jar names and SHA-256 recorded for both.
4. `git diff --stat baseline/sakura-<mc>-<version>..HEAD -- src/` shows **only** `fabric.mod.json`, and that diff touches only contact URLs and the description.
5. `CLAUDE.md`, 12 agent files, 6 rule files, a valid `settings.json` (with `worktree.baseRef = "head"` and the PreToolUse hook) and an executable `guard-bash.sh` are installed. The hook test log shows the expected exit codes for ≥ 6 payloads.
6. The `docs/enhanced/` skeleton is complete as listed in Step 5. `STATE.md` and `ROADMAP.md` are filled for P00 → P01.
7. `NOTICE.md`, `AI_DISCLOSURE.md` and `knowledge/licence-and-contribution.md` exist. `LICENSE.txt` is byte-identical to the baseline.
8. The inventory script is committed, re-runs reproducibly (same output twice), and its counts are reported next to an independent grep cross-check.
9. `architecture-map.md` and `build.md` exist, each with a "last verified at commit" stamp.
10. Every STRATEGY finding ID is present in `registers/problems.md` with confidence and status `to-verify (P02)`.
11. The human's answers (or explicit placeholders) are recorded in `DECISIONS.md`.

## 4. Mandatory re-runs and checks
- `./gradlew build` on the baseline commit and on HEAD (fresh clone or `git clean -xfd` first).
- Hook test script with ≥ 6 payloads (exit codes logged).
- `python -m json.tool .claude/settings.json` (or equivalent) succeeds.
- Inventory script run twice → identical output (`diff` empty).
- `cmp LICENSE.txt` against the baseline → identical.

## 5. Phase-specific audit focus
- Fetch `upstream-sakura` yourself and confirm that the vendor branch and baseline tag match the upstream commit the report claims. Confirm that the vendor branch has **no** extra commits.
- Confirm that **no functional change** exists: the `src/` diff is limited to `fabric.mod.json` contact/description. Check that `issues`/`sources` no longer point to `maruohon/litematica`.
- Run the hook yourself with your own dangerous payloads (variations: `git push origin +main`, `git push --force-with-lease`, `git -C . reset --hard`). Report any bypass as MAJOR, with a suggested regex fix.
- Check that `settings.json` really contains `worktree.baseRef: "head"`. If it is missing, later subagent worktrees would branch from the wrong base.
- Recount config options and hotkeys with your own grep, and compare with the inventory. Unexplained differences are MINOR.
- Check that nothing private is committed (tokens, absolute personal paths, the `_dossier/` folder, large binaries).
- Check that NOTICE.md credits the original authors and that LICENSE.txt is untouched.
- Check that `architecture-map.md` statements are true at the stamped commit. Sample 5 statements.

## 6. Output

- Write `docs/enhanced/phases/P00/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P00` → `git add docs/enhanced/phases/P00/audit.md docs/enhanced/phases/P00/audit-logs` → `git commit -m "[P00] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P00-bootstrap && git merge --ff-only audit/P00
    git switch enhanced/main
    git merge --no-ff phase/P00-bootstrap -m "[P00] merge after independent audit PASS"
    git tag enhanced/p00-pass
    git worktree remove ../audit-bootstrap && git branch -d audit/P00
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P00-bootstrap && git merge --ff-only audit/P00`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P00/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
