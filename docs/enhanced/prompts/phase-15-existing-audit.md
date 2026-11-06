# Litematica Enhanced — P15 · Existing feature improvements (Easy Place, paste, edit mode, projects, profiles)
## Independent audit prompt (for a separate Claude session)

> **How to use:** open a **new** Claude Code session with a fresh context, ideally in a separate checkout:
> `git worktree add --detach ../audit-existing phase/P15-existing` (detached, because the branch is already checked out in your main clone) and start Claude Code in `../audit-existing`. Paste this entire prompt. **Do not** paste or summarise the implementation conversation.
> **Inputs:** BASE = `enhanced/p14-pass` · HEAD = branch `phase/P15-existing` (or a specific commit sha, which you should write here: `________`).

---

## 0. Context (short)

*Litematica Enhanced* is an unofficial, LGPL-3.0-only fork of Litematica, a client-side Fabric schematic mod.
- **Upstream:** `sakura-ryoko/litematica` + `sakura-ryoko/malilib`, branch `26.3` at planning time.
- **Baseline:** Minecraft 26.3 (unobfuscated, Mojang names), Java 25, Fabric Loader 0.19.5, MaLiLib 0.30.2. No automated tests existed before P01.
- **How it is built:** in audited phases. Project memory lives in `docs/enhanced/`. `REFERENCE.md` there is authoritative: rules §5, benchmark policy §6, fairness §7, security §8, review checklist §12.
- **Phase P15** aimed to deliver: **Existing feature improvements (Easy Place, paste, edit mode, projects, profiles)**.

## 1. Your role: independent auditor

- You did not write this code, and you **do not trust** `docs/enhanced/phases/P15/report.md` or `pre-audit.md`. You verify everything yourself.
- **Do not modify** source, tests, build files or documentation. The only file you may create is `docs/enhanced/phases/P15/audit.md` (template: `docs/enhanced/templates/audit-report.md`). If you are told to stay fully read-only, put the report in your reply instead.
- **Throwaway experiments** (for example a mutation probe: break one line on purpose and check that a test fails) are allowed **only** in a scratch worktree that you delete afterwards. Never commit them.
- You may use read-only subagents (`independent-auditor`, `cartographer`) to parallelise checks. They follow the same rules.
- Be precise and fair. Report real defects with evidence. Do not inflate minor style preferences into findings.

## 2. Audit protocol

1. **Criteria first.** Copy the acceptance criteria from §3 below into your audit file **before** you read the implementation report.
2. **Reproduce from clean.**
   - `git status` must be clean. Run `git log --oneline enhanced/p14-pass..HEAD` and `./gradlew clean build`, then the full test suite and every mandatory check in §4.
   - Save the logs under `docs/enhanced/phases/P15/audit-logs/`.
   - Record the exact commands and results.
3. **Review the diff.**
   - `git diff --stat enhanced/p14-pass..HEAD` and the full diff of every touched area.
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
6. **Classify each finding** as `AUD-P15-NN`, with a severity:
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
1. Every card with `phase = P15` is implemented with its acceptance criteria met (table: card → criteria → evidence), or explicitly deferred with a human decision.
2. The packet cause log exists in dev mode, the game test fails on an uncaused packet (demonstrated with a deliberate test-only violation), and all real Litematica packet paths are tagged.
3. The Easy Place matrix is recorded for every listed family × protocol in single player (and on the test server where feasible). Every failure is fixed or has a register ID with a reason.
4. The hold-mode cadence is ≤ the vanilla cooldown (test). The first-enable warning, the active indicator and per-profile enablement work (tests/screenshots).
5. Profiles: auto-switch by server/world, the strict preset disables all F1/F2 assists, persistence with migration tests, and no writes to official Litematica files.
6. Server policy: payload parsing with limits (fuzz test), honoured while connected (game test with a simulated payload), shown in diagnostics/HUD. Behaviour without a signal is unchanged (test). The server-owner spec is documented.
7. Paste: the dry-run summary and confirmation always appear before F2 jobs; pause/resume/cancel and permission errors are handled (tests). The escaping fuzz tests pass (≥ 10,000 seeded inputs).
8. No F3 behaviour exists (auditable list of every code path that sends gameplay packets, with the cause of each).
9. Full suites, golden masters and game tests are green. The relevant benchmarks are within thresholds.
10. Docs pages exist and match the behaviour.

## 4. Mandatory re-runs and checks
- `./gradlew clean build test` + game tests (cause log, Easy Place matrix automation where possible, profiles, policy, paste flows).
- Escaping fuzz suite; policy payload fuzz suite.
- A manual playtest checklist for the human: Easy Place on a real server where allowed, the strict preset, a paste in creative/op.

## 5. Phase-specific audit focus
- **Fairness deep-dive:** list every code path that sends gameplay packets (`useItemOn`, `sendCommand`, player actions, custom payloads) at BASE and HEAD. Any new path without a user cause or a confirmed F2 job is a BLOCKER. Look for timers, tick loops and "auto" behaviour.
- **Easy Place cadence:** read the hold-mode code and measure in a game test if possible.
- **Policy bypass:** can a user re-enable a policy-disabled feature through the palette, a hotkey, config editing, or a profile switch while connected? Any bypass is MAJOR.
- **Command injection:** craft block NBT with quotes, braces, backslashes, newlines and unicode. The generated commands and `.mcfunction` lines must be valid and must not escape their context.
- **Profiles:** switching servers quickly or rejoining must not leave a stricter profile partially applied.
- **Matrix honesty:** re-run 5 matrix cells yourself.
- **Scope:** only selected cards were implemented.

## 6. Output

- Write `docs/enhanced/phases/P15/audit.md` with: reproduction table, criteria verification table, claims spot-checks, findings table, the REFERENCE §12 checklist, and the verdict.
- Record it on a dedicated branch, so it reaches the phase branch without you touching anything else:
  `git switch -c audit/P15` → `git add docs/enhanced/phases/P15/audit.md docs/enhanced/phases/P15/audit-logs` → `git commit -m "[P15] independent audit: <VERDICT>"`. Commit nothing else.
- End your reply with at most 20 lines: verdict, top findings (IDs + one line each), and the next step for the human:
  - **PASS / PASS WITH RESERVATIONS:**
    ```bash
    git switch phase/P15-existing && git merge --ff-only audit/P15
    git switch enhanced/main
    git merge --no-ff phase/P15-existing -m "[P15] merge after independent audit PASS"
    git tag enhanced/p15-pass
    git worktree remove ../audit-existing && git branch -d audit/P15
    # then update docs/enhanced/ROADMAP.md (verdict, merge commit, tag) and STATE.md (next phase)
    ```
  - **FAIL:** first bring the audit file onto the phase branch (`git switch phase/P15-existing && git merge --ff-only audit/P15`), then: "Run `prompts/correction-template.md` with AUDIT_FILE=`docs/enhanced/phases/P15/audit.md` and FINDINGS=<IDs>, then run this audit again in **delta mode** (see the end of the correction template)."
