# P00 — Independent audit report

- **Auditor session:** 2026-11-06 · Claude Opus 5.5 (Claude Code, fresh context, no access to the implementation conversation) · **Range audited:** `baseline/sakura-26.3-0.29.2-sakura.1..d5e52747` (`64e74592..d5e5274739044a812c8e7a8b408a2ae4d623d608`, 20 commits) · **Clean checkout:** yes (detached worktree `../audit-bootstrap`, `git status` clean; builds in fresh local clones)
- **Verdict:** **FAIL** — all 11 acceptance criteria are proven, but one MAJOR finding (AUD-P00-01, guard hook bypasses) is open. The audit prompt (§5) classifies any hook bypass as MAJOR, and §2.7 makes any MAJOR a FAIL. No human decision accepting the gap exists yet (RISK-08 is still "open, waiting on human").

All logs cited below are in [`audit-logs/`](audit-logs/), produced by commands run in this session. The Windows user name is masked as `<user>` in them.

## Acceptance criteria (copied from the audit prompt §3 before reading the report)
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

## Reproduction
| Step | Command | Result | Log |
|---|---|---|---|
| Clean state | `git status` in the worktree; `git rev-parse HEAD` | clean; `d5e52747…` | [git-state.txt](audit-logs/git-state.txt) |
| Range | `git log --oneline baseline/sakura-26.3-0.29.2-sakura.1..HEAD` | 20 commits, all `[P00]`, author/committer `Kyoonit <…noreply…>` | [git-state.txt](audit-logs/git-state.txt), [privacy-scan.txt](audit-logs/privacy-scan.txt) |
| Baseline build | fresh `git clone` of the repo, checkout of the tag, `./gradlew clean build` | BUILD SUCCESSFUL in 14s (`:test NO-SOURCE`) | [build-baseline.log](audit-logs/build-baseline.log) |
| HEAD build | fresh `git clone`, checkout `d5e52747`, `./gradlew clean build` | BUILD SUCCESSFUL in 14s (`:test NO-SOURCE`; no tests exist before P01) | [build-head.log](audit-logs/build-head.log) |
| Jar hashes | `sha256sum build/libs/*.jar` in both clones | recorded; differ from the report's hashes, as expected (RISK-02, non-reproducible jar bytes) | [jars.sha256](audit-logs/jars.sha256) |
| Jar contents | own `JarDiff.java` (CRC32 per zip entry) baseline build vs HEAD build; committed baseline jar vs own baseline build | main jar 774 entries, 773 identical, only `fabric.mod.json` differs; sources jar same; committed `docs/enhanced/baseline/*.jar` = own baseline build (774/774 identical) | [jar-content-compare.txt](audit-logs/jar-content-compare.txt) |
| Shipped hook test | `bash tools/hooks/test-guard-bash.sh` | 17/17 PASS | [hook-test-shipped.log](audit-logs/hook-test-shipped.log) |
| Auditor hook probe | own payload file piped as PreToolUse JSON to `guard-bash.sh` | 20 cases, **11 mismatches** (10 real bypasses + 1 not a real git command, see AUD-P00-01) | [hook-probe-auditor.log](audit-logs/hook-probe-auditor.log), [hook-bypass-proof.txt](audit-logs/hook-bypass-proof.txt) |
| settings.json | Node `JSON.parse` (Python absent) | valid; `worktree.baseRef = "head"`; PreToolUse matcher `Bash` → `guard-bash.sh` | [settings-json-check.txt](audit-logs/settings-json-check.txt) |
| Inventory ×2 | `java tools/inventory/Inventory.java --stdout` twice in a clean clone; then write mode + `git status` | identical (same sha256, empty diff); write mode leaves only an EOL-only `M` (AUD-P00-06) | [inventory-reproducibility.txt](audit-logs/inventory-reproducibility.txt) |
| Independent counts | own `grep` on `Configs.java`/`Hotkeys.java`/mixins; BASE vs HEAD config+hotkey ID lists | 168 options, 78 hotkeys, 28 `ConfigBooleanHotkeyed`, 7 commented out, 52 `@Mixin`, 52 JSON entries; ID lists BASE = HEAD (253 incl. commented) | [inventory-crosscheck.txt](audit-logs/inventory-crosscheck.txt) |
| LICENSE | blob ids at BASE and HEAD | identical `65c5ca88…` | [diff-scope.txt](audit-logs/diff-scope.txt) |
| Diff / churn | `git diff --stat`, `--shortstat` with and without `--ignore-all-space --ignore-cr-at-eol`, `--diff-filter=DMR` | 151 files, +9834/−4 both ways (no churn); only `.gitignore` (+5) and `fabric.mod.json` modified; 0 deleted; added blobs are LF (138) or empty (10) | [diff-scope.txt](audit-logs/diff-scope.txt) |
| Upstream | `git ls-remote upstream-sakura refs/heads/26.3` (live), `git rev-list --count vendor ^upstream-sakura/26.3` | upstream `26.3` = `64e74592…` = vendor = tag; 0 extra vendor commits | [git-state.txt](audit-logs/git-state.txt) |
| Fork CI | `gh run view` / `gh run list` (read-only) | run 42206004436 on `c03383a5` success; run 42206273332 on `d5e52747` success | [ci-check.txt](audit-logs/ci-check.txt) |
| Kit fidelity | `diff -rq --strip-trailing-cr` against the owner's `_dossier/` (main clone, read-only) | prompts, `.claude/`, `CLAUDE.md`, templates, 5 programme documents identical | [kit-vs-dossier.txt](audit-logs/kit-vs-dossier.txt) |
| Commit re-authoring | tree id of each old → new pair in `logs/commit-rewrite-map.txt` | 18/18 same tree | [rewrite-map-check.txt](audit-logs/rewrite-map-check.txt) |
| Privacy | `git grep` on the HEAD tree; `git log -p` over the range | HEAD tree clean; user name still in 4 pushed commits (AUD-P00-03) | [privacy-scan.txt](audit-logs/privacy-scan.txt) |

## Acceptance criteria verification (criteria taken from the audit prompt, not from the report)
| # | Criterion | Verified? | Evidence | Comment |
|---|---|---|---|---|
| 1 | remotes, push `DISABLED`, rerere | yes | [git-state.txt](audit-logs/git-state.txt) | `origin` = `Kyoonit/litematica-enhanced`; both upstream pushurls `DISABLED`; `rerere.enabled=true` |
| 2 | vendor = upstream HEAD, tag, branches | yes | [git-state.txt](audit-logs/git-state.txt) | live `ls-remote` today still `64e74592`; annotated tag → `64e74592`; `enhanced/main` = `64e74592`; vendor has 0 extra commits |
| 3 | build on BASE and HEAD, jars + SHA-256 | yes | [build-baseline.log](audit-logs/build-baseline.log), [build-head.log](audit-logs/build-head.log), [jars.sha256](audit-logs/jars.sha256), [jar-content-compare.txt](audit-logs/jar-content-compare.txt) | Built at HEAD `d5e52747` itself (the report built `981b0593`; later commits are docs-only, confirmed). Jar bytes not reproducible (known RISK-02); contents differ only in `fabric.mod.json` |
| 4 | `src/` diff only `fabric.mod.json`, contact URLs + description | yes | [diff-scope.txt](audit-logs/diff-scope.txt) | 4 lines: description + `homepage`/`issues`/`sources`; `issues`/`sources` no longer point to `maruohon/litematica`; `twitter`/`discord` untouched (RISK-01) |
| 5 | kit installed, settings valid, hook executable, hook test ≥ 6 | yes | [settings-json-check.txt](audit-logs/settings-json-check.txt), [hook-test-shipped.log](audit-logs/hook-test-shipped.log), [diff-scope.txt](audit-logs/diff-scope.txt) | 12 agents, 6 rules, `guard-bash.sh` mode `100755`; 17/17 shipped cases pass. The criterion is met, but the hook has bypasses (AUD-P00-01) |
| 6 | docs skeleton complete; STATE/ROADMAP filled | yes | [docs-skeleton-check.txt](audit-logs/docs-skeleton-check.txt), `STATE.md`, `ROADMAP.md` | 21 instances, 20 templates, 10 `.gitkeep` dirs, 45 prompts tracked; `_dossier/` and `.claude/worktrees/` ignored; STATE/ROADMAP show P00 in-audit → P01 |
| 7 | NOTICE, AI disclosure, licence note; LICENSE identical | yes | `NOTICE.md`, `AI_DISCLOSURE.md`, `knowledge/licence-and-contribution.md`, [diff-scope.txt](audit-logs/diff-scope.txt) | NOTICE credits masa, Sakura-Ryoko and all 44 `git shortlog` names (each checked), states modification, links sources; modified-files table lists both upstream files |
| 8 | inventory reproducible + grep cross-check | yes | [inventory-reproducibility.txt](audit-logs/inventory-reproducibility.txt), [inventory-crosscheck.txt](audit-logs/inventory-crosscheck.txt) | every count matches my own grep; planning figure 175 = 168 + 7 commented |
| 9 | stamps in architecture-map and build.md | yes | `knowledge/architecture-map.md:1,200`, `knowledge/build.md:61` | stamped `64e74592…`; 6 sampled statements true ([architecture-map-sample.txt](audit-logs/architecture-map-sample.txt)) |
| 10 | 33 STRATEGY IDs, confidence, `to-verify (P02)` | yes | [problems-id-check.txt](audit-logs/problems-id-check.txt) | 33/33, one row each, all `to-verify (P02)`; confidence copied faithfully (PERF = hypothesis per §4.B heading; ARCH has no confidence column → "not stated") |
| 11 | human answers in DECISIONS.md | yes | `DECISIONS.md:6-14` | 5 Step-0 answers + 4 later owner decisions, all dated and attributed |

## Claims ledger spot-checks
| Claim (report.md) | Re-run? | Matches? | Evidence |
|---|---|---|---|
| Upstream `26.3` HEAD `64e74592`, version `0.29.2-sakura.1` (l.29) | yes (live `ls-remote`) | yes | [git-state.txt](audit-logs/git-state.txt); jar names carry `0.29.2-sakura.1` |
| Push disabled, rerere on (l.30) | yes | yes | [git-state.txt](audit-logs/git-state.txt) |
| vendor = enhanced/main = tag (l.31) | yes | yes | [git-state.txt](audit-logs/git-state.txt) |
| Baseline and HEAD builds green (l.32, l.34) | yes, fresh clones | yes (14 s each here, warm cache) | build logs |
| Jar contents: 708 entries each, only `fabric.mod.json` differs (l.35) | yes, CRC per entry | yes: 708 file entries + 66 directory entries = 774 zip entries | [jar-content-compare.txt](audit-logs/jar-content-compare.txt) |
| Baseline jar copy kept (l.33) | yes | yes: content identical to my baseline build; 1.98 MB (< 5 MB rule) | [jar-content-compare.txt](audit-logs/jar-content-compare.txt) |
| `src/` diff = `fabric.mod.json` only (l.36); LICENSE identical (l.37) | yes | yes | [diff-scope.txt](audit-logs/diff-scope.txt) |
| Hook 17/17 PASS (l.39) | yes | yes, but coverage is incomplete (AUD-P00-01) | [hook-test-shipped.log](audit-logs/hook-test-shipped.log) |
| Skeleton complete; kit identical to dossier (l.40) | yes | yes | [docs-skeleton-check.txt](audit-logs/docs-skeleton-check.txt), [kit-vs-dossier.txt](audit-logs/kit-vs-dossier.txt) |
| Inventory counts; reproducible (l.41-42) | yes | yes | inventory logs |
| 33/33 IDs seeded (l.43) | yes | yes | [problems-id-check.txt](audit-logs/problems-id-check.txt) |
| Architecture map statements (l.44) | 6 sampled | yes (S3 wording slightly loose: an empty `@Deprecated` class shell without `@Mixin` remains; true in substance) | [architecture-map-sample.txt](audit-logs/architecture-map-sample.txt) |
| Fork CI green, run 42206004436 (l.45) | yes (`gh`) | yes; HEAD `d5e52747` also green (run 42206273332) | [ci-check.txt](audit-logs/ci-check.txt) |
| Re-authoring kept every tree (l.69) | yes | yes, 18/18 | [rewrite-map-check.txt](audit-logs/rewrite-map-check.txt) |
| Rollback: branch "never pushed" (l.76) | yes | **no**: the branch is on `origin` (AUD-P00-04) | [git-state.txt](audit-logs/git-state.txt) (`ls-remote origin`) |
| Repo reachability (l.46) | no (not needed: both builds resolved dependencies) | n/a | build logs |
| Benchmarks | n/a | P00 makes no performance claim | — |

## Findings
| ID (AUD-P00-NN) | Severity | Finding | Evidence (path:line / output) | Suggested acceptance test |
|---|---|---|---|---|
| AUD-P00-01 | **MAJOR** (audit prompt §5: "Report any bypass as MAJOR") | `guard-bash.sh` lets through 10 destructive forms. Proven force pushes: `git push origin +main` and `git push -fu origin main` both rewrote a remote branch in a throwaway repo. Also allowed: `+HEAD:enhanced/main`; any quoted argument before the flag (`git push "origin" --force`, `git reset "--hard" HEAD~1`), because `[^"]*` stops at the JSON-escaped `\"`; `git reset --har` (git accepts the abbreviation); `git tag -f baseline/…` (moves the protected tag); `git branch --delete --force enhanced/main`; `git update-ref -d refs/heads/enhanced/main`; push to an upstream by URL. The `+branch`, `-uf`, `branch --delete --force` and `update-ref` forms were already found by the pre-audit (RISK-08, awaiting the human); the quoted-argument, `--har` and `tag -f` forms are new. (`--forc` is not a bypass: git rejects it as ambiguous.) | `.claude/hooks/guard-bash.sh:15,20,25,28,31`; [hook-probe-auditor.log](audit-logs/hook-probe-auditor.log); [hook-bypass-proof.txt](audit-logs/hook-bypass-proof.txt) | Fix, after the human approves departing from the dossier kit: (1) extract `tool_input.command` and strip quotes before matching (e.g. `cmd=$(printf '%s' "$payload" \| sed -n 's/.*"command":"\(\([^"\\]\|\\.\)*\)".*/\1/p' \| sed 's/\\"//g; s/["'\'']//g')`); (2) on `$cmd`: push `git .*push( .*)? (-[a-zA-Z]*f[a-zA-Z]*\|--force[a-z-]*\|--mirror\|--delete\|-d\|\+[^ ]+\|:[^ ]+)( \|$)`; reset `git .*reset .*--ha(r(d)?)?( \|$)`; refs `git .*(tag .*-[a-zA-Z]*[fd]\|update-ref .*-d\|branch .*(-D\|-[a-zA-Z]*d[a-zA-Z]*f\|--delete .*--force\|--force .*--delete)).*(enhanced/\|baseline/\|vendor/)`. Test: add every "expected=2" line of `hook-probe-auditor.log` (except `--forc`) to `tools/hooks/test-guard-bash.sh`; all exit 2, and the existing 6 allow cases still exit 0. Alternative: the human records an explicit acceptance of RISK-08 in `DECISIONS.md` (human decision > phase prompt), and the delta audit re-classifies |
| AUD-P00-02 | MINOR | The guardrails cover only the Bash tool. The PowerShell tool (available on this Windows machine) is matched by neither the hook nor the `deny` rules; `Write(./LICENSE.txt)` is reported ignored. Known (pre-audit AUD-P00-02, RISK-08) | `.claude/settings.json` (`"matcher": "Bash"`, all deny rules `Bash(…)`); `registers/risks.md` RISK-08 | A PowerShell PreToolUse payload with `git push --force` exits 2, or the human records acceptance |
| AUD-P00-03 | MINOR | The owner's Windows user name (in home-directory paths) is still in the public history: 4 commits on the pushed `phase/P00-bootstrap` add it (`cc53d26c`, `6313d91a`, `ed5f2813`, `6d20a9a9`; 12 added lines). `6826bbdc` masks it only at HEAD, while the owner's decision says the name must not be in committed logs. Removing it needs a history rewrite and a force-push, which only the human may do | [privacy-scan.txt](audit-logs/privacy-scan.txt); `DECISIONS.md:12` | Human decision recorded in `DECISIONS.md`: accept the name in history, or rewrite the branch before merge (human-run); then `git log -p BASE..HEAD` has 0 lines with the name |
| AUD-P00-04 | MINOR | Report contradicts reality: the rollback plan says `phase/P00-bootstrap` was "never pushed" and rollback is deleting the local branch, but the branch is on `origin` (pushed in Step 8, same report l.67). A rollback must also handle the remote branch (human action) | `phases/P00/report.md:76` vs `report.md:67`, `git ls-remote origin` in [git-state.txt](audit-logs/git-state.txt) | `report.md` rollback section names the remote branch and who deletes it |
| AUD-P00-05 | NOTE | Hook false positive: patterns span `;`/`&&`, so a read-only compound command was blocked in this session (`git config --get-all remote.upstream-sakura.pushurl; git config --get-all remote.upstream-masa.pushurl` matched rule 2). Single commands pass (probe case 18) | `.claude/hooks/guard-bash.sh:20`; this session's first blocked call | Split `$cmd` on `;`, `&&`, `\|\|`, `\|` before matching; add the compound read-only case as an expected-0 test |
| AUD-P00-06 | NOTE | Inventory write mode writes LF into a `core.autocrlf=true` checkout, so `git status` shows `M docs/enhanced/registers/features.md` with an empty diff. Content is reproducible; this is only status noise | [inventory-reproducibility.txt](audit-logs/inventory-reproducibility.txt) (tail) | After write mode in a clean checkout, `git status --porcelain` is empty (write with `System.lineSeparator()` or document the noise in `knowledge/build.md`) |

No other defects found: no functional change (jar contents prove it), no removed option/hotkey (ID lists identical), no mixin change (mixin register needs no entry), no whole-file churn, no secrets, no `_dossier/` content, the only binary is the 1.98 MB baseline jar that Step 4 asks for, and hot files were edited only by the lead as planned (`plan.md:24,40`).

## Checklist (REFERENCE §12)
- [x] scope (only `.gitignore` + `fabric.mod.json` modified; no churn) · [x] clean build/tests (two fresh-clone builds; no tests exist before P01) · [x] criteria evidenced (11/11) · [x] benchmarks reproducible (n/a: none in P00) · [x] no hidden removals (0 deletions; option/hotkey IDs identical; jar contents identical except metadata) · [x] compat proven (no code or format change; golden tests n/a before P01) · [x] threading rules (n/a: no code) · [x] fairness/causality (n/a: no code) · [ ] security limits (guardrail bypasses AUD-P00-01, PowerShell gap AUD-P00-02) · [ ] docs/registers/STATE (rollback text wrong, AUD-P00-04; otherwise complete) · [x] licence & AI disclosure

## Required corrections (FAIL)
1. **AUD-P00-01** (MAJOR) — either harden `guard-bash.sh` and extend `tools/hooks/test-guard-bash.sh` as suggested (needs the human's OK, because it departs from the dossier kit), or have the human record an explicit, dated acceptance of RISK-08 in `DECISIONS.md` with a target phase for the fix.
2. **AUD-P00-02, -03** (MINOR) — human decisions; log them in `registers/problems.md` or `DECISIONS.md`.
3. **AUD-P00-04** (MINOR) — correct the rollback section of `report.md`.
4. Then re-run this audit in delta mode.

## Merge instructions (if PASS)
Not applicable (FAIL).
