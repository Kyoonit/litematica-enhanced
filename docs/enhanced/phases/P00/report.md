# P00 — Phase report (≤ 2 pages + ledger)

- **Branch / commits:** `phase/P00-bootstrap` · `baseline/sakura-26.3-0.29.2-sakura.1..phase/P00-bootstrap` · `git log --oneline baseline/sakura-26.3-0.29.2-sakura.1..phase/P00-bootstrap` (18 commits before the push, re-authored as `Kyoonit` with the GitHub noreply address; old → new ids in `logs/commit-rewrite-map.txt`)
- **Outcome in 5 lines:**
  The fork is bootstrapped. Remotes, branches and the baseline tag are in place, with upstream push disabled.
  The baseline (`64e74592`) and the phase HEAD both build green. The jars differ only in `fabric.mod.json`, which has 4 identity lines changed.
  The Claude Code kit, the `docs/enhanced/` skeleton, NOTICE/AI disclosure/licence notes, the build and architecture notes, and the seeded registers are committed.
  A reproducible Java inventory script lists 168 config options, 78 hotkeys, 9 tool modes, 26 screens, 1 command and 52 mixins. All 33 STRATEGY IDs are in `problems.md`.
  The fork's CI is green on the pushed branch. Still open for the human: the guardrail gaps (RISK-08) and masa's twitter/discord contacts (RISK-01).

## Acceptance criteria
| # | Criterion (verbatim from prompt) | Status | Evidence (link) |
|---|---|---|---|
| 1 | `git remote -v` shows `origin` = the fork, and `upstream-sakura` / `upstream-masa` with push URL `DISABLED` (log saved). `rerere.enabled` is true. | met | [git-remotes.txt](logs/git-remotes.txt) |
| 2 | `vendor/sakura-<mc>` equals the recorded upstream HEAD sha. Tag `baseline/sakura-<mc>-<version>` points to that commit. `enhanced/main` and `phase/P00-bootstrap` exist. | met | [upstream-state.txt](logs/upstream-state.txt), [git-branches-tags.txt](logs/git-branches-tags.txt) |
| 3 | `./gradlew build` succeeds on the baseline commit **and** on the phase branch HEAD. Logs saved; jar names and SHA-256 recorded for both. | met (HEAD = `981b0593`, pre-rewrite `d5820ff3`; later commits touch `docs/` only) | [build-baseline.log](logs/build-baseline.log), [build-baseline-env.txt](logs/build-baseline-env.txt), [baseline-jars.sha256](logs/baseline-jars.sha256), [build-head.log](logs/build-head.log), [build-head-env.txt](logs/build-head-env.txt), [head-jars.sha256](logs/head-jars.sha256), [jar-content-compare.txt](logs/jar-content-compare.txt) |
| 4 | `git diff --stat baseline/sakura-<mc>-<version>..HEAD -- src/` shows **only** `fabric.mod.json`, and that diff touches only contact URLs and the description. | met | [scope-and-licence-checks.txt](logs/scope-and-licence-checks.txt) |
| 5 | `CLAUDE.md`, 12 agent files, 6 rule files, a valid `settings.json` (with `worktree.baseRef = "head"` and the PreToolUse hook) and an executable `guard-bash.sh` are installed. The hook test log shows the expected exit codes for ≥ 6 payloads. | met (12/12 agents loaded by a new session) | [agents-cli-check.txt](logs/agents-cli-check.txt), [agents-listing.txt](logs/agents-listing.txt), [settings-json-validation.log](logs/settings-json-validation.log), [hook-test.log](logs/hook-test.log), [docs-skeleton-check.txt](logs/docs-skeleton-check.txt) |
| 6 | The `docs/enhanced/` skeleton is complete as listed in Step 5. `STATE.md` and `ROADMAP.md` are filled for P00 → P01. | met | [docs-skeleton-check.txt](logs/docs-skeleton-check.txt), [STATE.md](../../STATE.md), [ROADMAP.md](../../ROADMAP.md) |
| 7 | `NOTICE.md`, `AI_DISCLOSURE.md` and `knowledge/licence-and-contribution.md` exist. `LICENSE.txt` is byte-identical to the baseline. | met | [NOTICE.md](../../../../NOTICE.md), [AI_DISCLOSURE.md](../../AI_DISCLOSURE.md), [licence-and-contribution.md](../../knowledge/licence-and-contribution.md), [scope-and-licence-checks.txt](logs/scope-and-licence-checks.txt) |
| 8 | The inventory script is committed, re-runs reproducibly (same output twice), and its counts are reported next to an independent grep cross-check. | met | [Inventory.java](../../../../tools/inventory/Inventory.java), [inventory-reproducibility.txt](logs/inventory-reproducibility.txt), [inventory-crosscheck.txt](logs/inventory-crosscheck.txt) |
| 9 | `architecture-map.md` and `build.md` exist, each with a "last verified at commit" stamp. | met | [architecture-map.md](../../knowledge/architecture-map.md), [build.md](../../knowledge/build.md) |
| 10 | Every STRATEGY finding ID is present in `registers/problems.md` with confidence and status `to-verify (P02)`. | met (33/33) | [problems.md](../../registers/problems.md), [problems-id-check.txt](logs/problems-id-check.txt) |
| 11 | The human's answers (or explicit placeholders) are recorded in `DECISIONS.md`. | met | [DECISIONS.md](../../DECISIONS.md) |

## Claims ledger (every claim an auditor can re-check)
| Claim | Command(s) run | Result file / output | Notes |
|---|---|---|---|
| Upstream `sakura-ryoko/litematica@26.3` HEAD is `64e74592f631…`; version `0.29.2-sakura.1` | `git ls-remote`, `git fetch upstream-sakura`, `gradle.properties` read | `logs/upstream-state.txt` | `upstream-masa` not fetched (design donor; fetched when needed) |
| Push to both upstream remotes is disabled; rerere on | `git remote -v`, `git config rerere.enabled` | `logs/git-remotes.txt` | |
| vendor = enhanced/main = baseline tag = `64e74592` at branch creation | `git branch -vv`, `git show-ref` | `logs/git-branches-tags.txt` | `phase/P00-bootstrap` was branched at the same commit |
| Baseline build green, 43 s, Temurin 25.0.5 | `./gradlew build` in a detached worktree of the tag | `logs/build-baseline.log`, `logs/build-baseline-env.txt` | Gradle cache was warm (RISK-05) |
| Baseline jar SHA-256 `d2a9a66d…`, sources `145c7ba6…`; copy kept | `sha256sum` | `logs/baseline-jars.sha256`, `docs/enhanced/baseline/*.jar` | Bytes are not reproducible (RISK-02) |
| HEAD build green, 15 s; jar `1b9769ba…`, sources `c4e9bc1d…` | `./gradlew build` in a fresh detached worktree of `d5820ff3` (now `981b0593`) | `logs/build-head.log`, `logs/build-head-env.txt`, `logs/head-jars.sha256` | |
| Jar contents: 708 entries each; only `fabric.mod.json` differs; version expands to `0.29.2-sakura.1` | `jar xf` both jars, `diff -rq`, Node `JSON.parse` | `logs/jar-content-compare.txt` | |
| `src/` diff = `fabric.mod.json` only: 4 lines (description + 3 contact URLs) | `git diff --stat` / `git diff -- src/` | `logs/scope-and-licence-checks.txt` | `twitter`/`discord` untouched (RISK-01) |
| `LICENSE.txt` identical to baseline | `git diff --quiet`, blob ids, `cmp` against the baseline worktree | `logs/scope-and-licence-checks.txt` | First `cmp` against `git show` output was a CRLF false positive; corrected in the log |
| Kit installed: 12 agents, 6 rules, `settings.json` valid with `baseRef "head"` + PreToolUse hook; hook mode 100755 | file listing, Node `JSON.parse`, `git ls-files -s` | `logs/agents-listing.txt`, `logs/settings-json-validation.log`, `logs/docs-skeleton-check.txt` | |
| Hook blocks 12 dangerous payloads (exit 2) and allows 5 normal ones (exit 0): 17/17 PASS | `bash tools/hooks/test-guard-bash.sh` | `logs/hook-test.log` | |
| Skeleton complete: 29 required paths tracked, 0 missing; templates, prompts, strategy docs and kit identical to the dossier | `git ls-files`, `diff -rq --strip-trailing-cr` | `logs/docs-skeleton-check.txt` | |
| Inventory: 168 options, 78 hotkeys, 7 dormant, 9 tool modes, 26 screens, 1 command, 52 mixins, 47 targets, 50 injectors | `java tools/inventory/Inventory.java` (×2, + `--stdout`) | `logs/inventory-reproducibility.txt` | Two runs and the stdout section are byte-identical (sha256 listed) |
| Independent grep agrees with every inventory count; planning figure 175 = 168 active + 7 commented out | `grep`/`rg` | `logs/inventory-crosscheck.txt` | |
| 33/33 STRATEGY IDs seeded, identical ID sets, every status `to-verify (P02)`, no empty confidence | `grep -o` on STRATEGY §4 and `problems.md`, `comm -3`, status/confidence column checks | `logs/problems-id-check.txt` | |
| Architecture map: 316 files, 73,085 lines; 8 `path:line` references spot-checked by the lead | `find`/`wc`, `sed -n` | `logs/package-line-counts.txt`, `integration-log.md` | |
| Before the push: fork CI had never run and Issues were disabled. After the owner enabled both and approved the push: CI run 42206004436 green, `has_issues=true` | `gh api …`, `git push -u origin phase/P00-bootstrap`, `gh run watch 42206004436` | `logs/ci-and-fork-settings.txt`, `logs/ci-fork-run.txt` | Upstream CI built `26.3` green (run 38255192306) |
| Repositories reachable (HTTP 200): masa maven (MaLiLib 0.30.2), fallenbreath maven (conditional-mixin), TerraformersMC (ModMenu), Modrinth maven (Iris), Fabric maven | Java `HttpClient` probe (curl fails here: schannel) | `logs/repo-reachability.txt` | |

## Changes
- Subsystems touched: none (no Java change). Upstream files touched: 2 (`src/main/resources/fabric.mod.json` 4 lines, `.gitignore` 5 lines added). New files: 146 (kit, docs, logs, tools, baseline jar; `git diff --name-only --diff-filter=A` at close-out). Deleted: 0.
- Feature flags: none. Mixins: none (the mixin register is an empty table, filled in P02). Translation keys: none.

## Tests
- No test sources exist (`:test NO-SOURCE`). Checks run: two builds, the hook test (17/17), JSON validation, inventory reproducibility, LICENSE comparison, jar content comparison, skeleton check.
- Benchmarks: none (the harness arrives in P01).

## Compatibility & fairness
- Mod id, version, packages and code are unchanged. The jar content differs only in `fabric.mod.json` metadata. No gameplay behaviour changed.

## Deviations from the prompt (and why)
- The project agents (`upstream-liaison`, `cartographer`, `independent-auditor`) ran as general-purpose subagents briefed with their `.claude/agents/*.md` definition and the same model. `.claude/agents/` is installed by this phase, so the running session does not load it.
- The doc agents worked in the main checkout without worktrees: they wrote only new docs at disjoint paths and never committed (`plan.md`).
- `/agents` cannot run in this non-interactive session. Instead, a new non-interactive session (`claude -p … --model haiku`) in the project folder listed its agent types, and all 12 project agents were loaded (`logs/agents-cli-check.txt`).
- Python is absent, so JSON was validated with Node `JSON.parse` and the inventory script is Java (the prompt allows either).
- The upstream `.gitignore` ignores every `logs/` directory, so P00 adds an un-ignore line for `docs/enhanced/phases/*/logs/` (`registers/upstream.md`).
- The hook test harness lives in `tools/hooks/test-guard-bash.sh` (not named by the prompt).
- `knowledge/build.md` was written by the lead, not a subagent (Step 4 names no owner).
- Step 8: the branch was pushed only after the human agreed and had enabled Issues and Actions. The first fork CI run (`build`, run 42206004436, on `c03383a5`) is green (`logs/ci-fork-run.txt`).

- At the human's request, the commits were re-authored before the first push (`git rebase --exec 'git commit --amend --author=…'`, no force-push). Every tree is unchanged. Logs and `pre-audit.md` written earlier cite the old ids; see `logs/commit-rewrite-map.txt`.

## Known limitations / open items (register IDs)
- RISK-01 masa's twitter/discord contacts · RISK-02 non-reproducible jars (P01) · RISK-03 Gradle 10 deprecation · RISK-04 MaLiLib 0.30.2 untagged · RISK-05/06/07 closed (cold CI build green, Issues enabled) · RISK-08 guardrail gaps (hook patterns, PowerShell tool).
- All 33 problem IDs are `to-verify (P02)`. Licence-portal rules (Modrinth/CurseForge) were taken from the dossier, not re-fetched; re-check at P19.

## Rollback plan
Nothing is merged. To roll back, delete the local branch `phase/P00-bootstrap` (never pushed); `enhanced/main` and `vendor/sakura-26.3` stay at `64e74592`. The one functional file can be restored with `git checkout baseline/sakura-26.3-0.29.2-sakura.1 -- src/main/resources/fabric.mod.json`.

## Manual playtest checklist for the human (if the roadmap requires one)
Not required for P00. Optional: launch the HEAD jar with MaLiLib 0.30.2 and check that Mod Menu shows "(unofficial fork)" and the fork links.

## Upstream candidates produced (A/B/C, branch names)
None.

## Pre-audit
Verdict **PASS WITH RESERVATIONS**: 0 BLOCKER, 0 MAJOR, 4 MINOR, 6 NOTE ([pre-audit.md](pre-audit.md)). The auditor re-ran the HEAD build (and a baseline build) in fresh worktrees, compared the jar contents, the hook test and the inventory, and re-verified all 11 criteria with its own commands. Response:

| Finding | Severity | Action | Where |
|---|---|---|---|
| AUD-P00-01 hook misses some destructive forms | MINOR | Not fixed: the hook is a verbatim kit copy, and changing it departs from the dossier, so this is a human decision. Recorded as RISK-08 | `registers/risks.md` |
| AUD-P00-02 guardrails cover only the Bash tool, not PowerShell | MINOR | Same as above (RISK-08) | `registers/risks.md` |
| AUD-P00-03 build.md says Fabric API is absent at runtime | MINOR | Fixed: MaLiLib bundles three Fabric API modules, and upstream code already uses `ClientPlayNetworking` (verified in the MaLiLib 0.30.2 jar) | `knowledge/build.md` |
| AUD-P00-04 Gradle 10 deprecation "source not identified" | MINOR | Fixed: the source is `build.gradle:79`; RISK-03 updated | `knowledge/build.md`, `registers/risks.md` |
| AUD-P00-05 new-file count | NOTE | Fixed (146 at close-out) | this report |
| AUD-P00-06 local user name and temp paths in committed logs | NOTE | Fixed at the human's request (2026-11-06): the Windows user name is replaced with `<user>` in home-directory paths and `ls -l` owner columns, in 4 logs and `pre-audit.md`; nothing else changed | `logs/`, `pre-audit.md` |
| AUD-P00-07 NOTICE/AI disclosure gaps | NOTE | Fixed: `.gitignore` row added to NOTICE; AI disclosure lists every AI-made artefact class | `NOTICE.md`, `AI_DISCLOSURE.md` |
| AUD-P00-08 pending human actions | NOTE | Already in STATE (no change) | `STATE.md` |
| AUD-P00-09 identity patch checked statically only | NOTE | Optional playtest listed above | this report |
| AUD-P00-10 working-tree line endings | NOTE | No action (blobs are LF) | — |
