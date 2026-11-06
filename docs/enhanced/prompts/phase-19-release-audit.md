# Litematica Enhanced — P19 · Stabilisation, release and upstream packaging
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-release phase/P19-release` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-release`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p18-pass` · HEAD = branch `phase/P19-release` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P19** aimed to deliver: **Stabilisation, release and upstream packaging**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P19/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P19/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p18-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P19/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p18-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P19-NN`, with a severity:
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
1. Clean-clone builds succeed on the CI matrix. All suites pass (logs). The jar inspection report shows no test deps, no Fabric API, no placeholders, and a correct `fabric.mod.json`.
2. The checksums and the reproducibility check are documented. Any nondeterminism is explained.
3. The release-check script exists, runs in CI, and passes on the release commit. It fails on a deliberately bad input (demonstrated in a scratch branch).
4. The feature-flag defaults match the recorded human decisions and audit outcomes. The flags table is in the release notes.
5. The docs set is complete and consistent with behaviour (sampled verification of ≥ 15 statements). The CHANGELOG links register IDs.
6. The version is applied consistently. The upstream base version is recorded.
7. `distribution-analysis.md` quotes the current platform rules with dates and links, and gives a recommendation. The human's channel decision is recorded.
8. `AI_DISCLOSURE.md` and the release-notes disclosure are complete and truthful. NOTICE/LICENSE/attribution are verified.
9. The upstream PR branches are rebased, they build, and they each contain only their change. Drafts are updated. The B proposals are written. Nothing was sent by Claude.
10. The GitHub release draft text and the asset list are prepared. The human's go/no-go is recorded. The tag is created only after the go.

## 4. Mandatory re-runs and checks
- CI matrix builds + all suites + the release-check script (pass and a deliberate fail).
- Jar inspection script (contents, metadata).
- Reproducible-build comparison.
- Per `upstream-pr/*`: a clean build.

## 5. Phase-specific audit focus
- **Jar truth:** download or build the release artefact yourself. Inspect its contents and `fabric.mod.json`. Check for placeholders, test classes and wrong licence files.
- **Release check:** run it yourself. Inject a placeholder asset in a scratch branch; it must fail.
- **Disclosure honesty:** compare `AI_DISCLOSURE.md` with the git history (commit trailers) and the phase reports. Under-disclosure is a BLOCKER.
- **Platform rules:** check that the quoted rules are current (fetch them again) and that the recommendation follows from them.
- **Attribution:** the original authors are credited in NOTICE, `fabric.mod.json` and the README. The modified-files notices follow the P00 convention (sample 10 files).
- **Upstream branches:** each is clean against vendor and builds. No fork scaffolding.
- **Docs:** sample 10 statements.
- **Human decisions:** a go/no-go, a version, channels and a name are recorded. If any is missing, the verdict is FAIL (the release must not be tagged).

## 6. Output

- Write `docs/enhanced/phases/P19/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P19` → `git add docs/enhanced/phases/P19/audit.md docs/enhanced/phases/P19/audit-logs` → `git commit -m "[P19] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P19-release && git merge --ff-only audit/P19
    git switch enhanced/main
    git merge --no-ff phase/P19-release -m "[P19] merge after independent audit PASS"
    git tag enhanced/p19-pass
    git worktree remove ../audit-release && git branch -d audit/P19
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P19-release && git merge --ff-only audit/P19`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P19/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
