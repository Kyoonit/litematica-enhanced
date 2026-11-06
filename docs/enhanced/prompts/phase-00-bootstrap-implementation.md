# Litematica Enhanced — P00 · Bootstrap, fork and baseline preservation
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P00-bootstrap` created from `baseline/sakura-26.3-0.29.2-sakura.1` (created by this phase; use the actual upstream MC/version if upstream has moved), and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** S · **Human checkpoint:** YES — fork owner/organisation, fork repository name, working project name, contact/issue channel, whether to contact the maintainers now (asked at the start of the phase)

---

## 0. Global context (read carefully)

You are the **lead** of phase **P00** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

- **Upstreams.**
  - The modern line is maintained by Sakura-Ryoko: `sakura-ryoko/litematica` and `sakura-ryoko/malilib`, default branch `26.3` at planning time.
  - The original author, masa (`maruohon`), does not maintain 1.20.5+ versions. He works on a rewrite on `maruohon/litematica` and `maruohon/malilib`, branch `ornithe/1.12.2`.
  - That rewrite is the **design donor**: port designs and interfaces, never 1.12-era code. Credit masa.
- **Baseline (2026-11-06).**
  - Minecraft 26.3, unobfuscated, so the code uses Mojang names (no Yarn).
  - Java 25, Fabric Loader 0.19.5, Loom 1.18, MaLiLib 0.30.2, Litematica 0.29.2-sakura.1.
  - About 316 Java files and 73k lines. **No automated tests at baseline** (P01 adds them). CI only builds.
  - Fabric API is not a runtime dependency.
- **Programme goal.** A much more powerful, modern, fast and intuitive Litematica, built in short audited phases, with small upstream-friendly improvements extracted as PRs. It must stay compatible with existing schematics, configs and add-ons, and fair on every server.
- **Persistent project memory** lives in the repository (created in P00). Read only what you need:
  - `docs/enhanced/STATE.md` — **read first**
  - `docs/enhanced/REFERENCE.md` — authoritative rules and technical strategy
  - `docs/enhanced/ROADMAP.md` (status) and `ROADMAP-PLAN.md` (plan)
  - `docs/enhanced/AGENTS.md` (multi-agent model) and `UPSTREAM.md` (fork and PR strategy)
  - `docs/enhanced/DECISIONS.md` and `adr/`
  - `registers/` (problems, features, risks, upstream), `knowledge/` (architecture map, subsystem notes, mixin register), `benchmarks/`, `design/`, `specs/`, `phases/`, `templates/`
- **Precedence** when sources disagree: the human owner's explicit decision > `REFERENCE.md` > accepted ADRs > this prompt > your own judgement.

## 1. Non-negotiable rules

1. **Stability first.** Never trade stability for speed of feature delivery. Never leave the build or tests red.
2. **No feature removal or hiding** without a documented usage and dependency analysis plus an approved ADR.
3. **Schematic compatibility.** No change to how existing files are read or written without golden tests proving equivalence or an approved ADR.
4. **No new runtime dependency** without an approved ADR. Test-scope tools also need an ADR entry.
5. **Never invent results.** No fabricated test outputs, benchmark numbers, screenshots, issue numbers or quotes. Every number links to a raw file produced by a command you list. Estimates are labelled *estimate* and kept out of results tables.
6. **Measure before and after** every optimisation, on the same machine with the same protocol (`docs/enhanced/benchmarks/PROTOCOL.md`).
7. **A successful compile proves nothing.** Each acceptance criterion needs behavioural evidence.
8. **No massive refactor without a migration path.** Use facades, feature flags and steps that each leave the mod working.
9. **One concern per commit series.** Mechanical changes (moves, renames) go in separate commits. Never reformat code you do not change. Match each file's indentation and line endings: `*.java` is CRLF in the working tree via `.gitattributes`.
10. **Always keep a way back.** Tags, flags, legacy paths until parity, and a rollback plan in your report.
11. **Document decisions.** ADRs for structural choices, `DECISIONS.md` for human decisions.
12. **Check interactions.** List the subsystems your change touches and prove they still work.
13. **Fairness.** No autonomous world interaction (no printer, auto-build, auto-restock). Every gameplay packet must be caused by a user input or a user-confirmed job (REFERENCE §7).
14. **Scope discipline.** Out-of-scope discoveries go into `docs/enhanced/registers/*` with an ID, not into the diff.

## 2. How to work

1. **Orient.**
   - Read `docs/enhanced/STATE.md`, then the registers, ADRs and knowledge notes named in §3.
   - Check that you are on `phase/P00-bootstrap` and that the base is an ancestor: `git merge-base --is-ancestor baseline/sakura-26.3-0.29.2-sakura.1 HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P00/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P00/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (S) or needs a decision reserved for the human, **stop and ask**, proposing a split (P00a/P00b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P00/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P00/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P00/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P00] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P00/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P00/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P00 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P00 — Bootstrap, fork and baseline preservation

**Agents for this phase:** lead (you) · `cartographer` (architecture map, build notes) · `upstream-liaison` (licence and contribution conditions)

### Special note for P00
The `docs/enhanced/` tree, `CLAUDE.md` and `.claude/` **do not exist yet**: you create them in this phase. Your **inputs** are the planning dossier's files, which the human will copy into a folder `_dossier/` at the repository root (or give you a path):
- `01-strategic-analysis.md`, `02-roadmap.md`, `03-reference-documentation.md`, `04-agent-operating-model.md`, `05-github-contribution-strategy.md`
- `claude-code-kit/` (CLAUDE.md, `.claude/`, `docs/enhanced/templates/`)

If `_dossier/` is missing, stop and ask for it. Do not reconstruct it from memory.

Because the branches and the baseline tag do not exist yet, start on the default branch of your fresh clone. Skip the ancestor check of §2.1 until Step 3 has created them, then switch to `phase/P00-bootstrap` and continue.

### Step 0 — Ask the human (one AskUserQuestion round, then proceed)
1. GitHub owner/organisation and name of the fork (e.g. `<you>/litematica-enhanced`). Has the fork already been created on GitHub, and is this clone it?
2. Working project name. Recommend a name that does not imply endorsement, e.g. "<Name> — an unofficial Litematica fork". The final name is decided after asking the maintainers.
3. Contact/issue channel for the fork (the fork's GitHub issues by default).
4. Contact Sakura-Ryoko/masa now with an introduction (draft only; the human sends it) — yes or no.
5. Per-file modification-notice convention (recommended: one comment line, `// Modified by <project> contributors (<year>); see NOTICE.md`, added to an upstream file the first time the fork modifies it).

Record the answers in `docs/enhanced/DECISIONS.md`. If nobody answers, use clearly marked placeholders, continue, and list the open decisions in STATE.md.

### Step 1 — Verify upstream identity and current state
- `git ls-remote --symref https://github.com/sakura-ryoko/litematica.git HEAD`, plus the branch list, plus the same for `sakura-ryoko/malilib`.
- **If the default branch is no longer `26.3`**, stop and ask the human which Minecraft version to base on. Recommend the newest version Sakura-Ryoko has tagged as a release.
- Record: upstream default branch, HEAD sha, latest tags, `gradle.properties` versions (MC, loader, MaLiLib, mod version), and the required Java version.

### Step 2 — Licence and contribution conditions (`upstream-liaison`)
Write `docs/enhanced/knowledge/licence-and-contribution.md` covering:
- LGPL-3.0-only obligations for a fork: keep notices, provide source, mark modifications with a date (GPLv3 §5(a) via LGPLv3), license the fork under LGPL. State that this is not legal advice.
- Sakura-Ryoko's `.github/pull_request_template.md`, quoted only as needed, including the AI disclosure section.
- The Modrinth AI rules (disclosure; primarily-AI projects refused; no AI images) and CurseForge moderation notes. Mark both as "re-check at P19".
- masa's request not to receive issues about versions he does not maintain.
- Create `NOTICE.md` (original authors masa and Sakura-Ryoko plus the contributors from `git shortlog -sn`, a statement that this is a modified version, a link to the source) and `docs/enhanced/AI_DISCLOSURE.md` from the template.
- Never modify `LICENSE.txt`.

### Step 3 — Fork, remotes, branches, baseline tag
- Remotes: `origin` (the fork), `upstream-sakura` → `sakura-ryoko/litematica`, `upstream-masa` → `maruohon/litematica`.
- Disable pushing to the upstream remotes: `git remote set-url --push <remote> DISABLED`.
- `git config rerere.enabled true`.
- Branches: `vendor/sakura-<mc>` equal to the upstream HEAD, `enhanced/main` from it, `phase/P00-bootstrap` from `enhanced/main`.
- Tag `baseline/sakura-<mc>-<upstream mod version>` on the vendor commit.
- Save the output of `git remote -v`, `git branch -vv` and `git tag` to logs.

### Step 4 — Build verification and baseline preservation
- `java -version` (must be 25 or as required). Run `./gradlew build` on the **baseline commit** (a detached worktree is fine). Record duration, warning count, produced jars and their **SHA-256**.
- Copy the baseline jar to `docs/enhanced/baseline/` **only if** it is under 5 MB. Otherwise record the hash and the exact rebuild command.
- If the MaLiLib maven (`masa.dy.fi`) is unreachable: **do not edit build.gradle**. Document the problem and the fallbacks (mavenLocal build of `sakura-ryoko/malilib` at the matching tag, or jitpack) in `docs/enhanced/knowledge/build.md`, then stop and ask.
- Write `docs/enhanced/knowledge/build.md`: toolchain, commands, repositories, artifacts, known quirks (CRLF `*.java`, mixed indentation, no Fabric API at runtime).

### Step 5 — Install the Claude Code kit and the docs skeleton
Copy:
- `_dossier/claude-code-kit/CLAUDE.md` → `CLAUDE.md`
- `_dossier/claude-code-kit/.claude/` → `.claude/` (agents, rules, settings.json, hooks). Make `guard-bash.sh` executable.
- `_dossier/claude-code-kit/docs/enhanced/templates/` → `docs/enhanced/templates/`
- Instantiate from the templates (template → instance):

  | Template (`docs/enhanced/templates/`) | Instance |
  |---|---|
  | `STATE.md`, `ROADMAP.md`, `DECISIONS.md`, `AI_DISCLOSURE.md` | `docs/enhanced/` (same names) |
  | `docs-README.md` | `docs/enhanced/README.md` |
  | `problems-register.md`, `features-register.md`, `risks-register.md`, `upstream-register.md` | `docs/enhanced/registers/problems.md`, `features.md`, `risks.md`, `upstream.md` |
  | `mixin-register.md` | `docs/enhanced/knowledge/mixin-register.md` (empty table; filled in P02) |
  | `benchmark-PROTOCOL.md` | `docs/enhanced/benchmarks/PROTOCOL.md` (skeleton; filled in P01) |

  The other templates (`adr.md`, `phase-plan.md`, `phase-report.md`, `agent-report.md`, `audit-report.md`, `feature-card.md`, `knowledge-note.md`, `playtest-checklist.md`, `benchmark-result.schema.json`) stay in `templates/` and are copied when needed.
- Create the empty directories (with a `.gitkeep`): `adr/`, `knowledge/subsystems/`, `benchmarks/scenarios/`, `benchmarks/results/`, `design/`, `specs/`, `compat/`, `phases/`, `upstream-prs/`, `architecture/`.
- `01-strategic-analysis.md` → `docs/enhanced/STRATEGY.md`, `02-roadmap.md` → `docs/enhanced/ROADMAP-PLAN.md`, `03-reference-documentation.md` → `docs/enhanced/REFERENCE.md`, `04-agent-operating-model.md` → `docs/enhanced/AGENTS.md`, `05-github-contribution-strategy.md` → `docs/enhanced/UPSTREAM.md`
- Copy the `prompts/` folder from the dossier to `docs/enhanced/prompts/` so prompts are versioned with the code.

Add `.claude/worktrees/` to `.gitignore`, and keep `_dossier/` out of git (ignored).

Test the hook: feed it at least 6 sample JSON payloads (force push, push to `upstream-sakura`, `reset --hard`, tag deletion `enhanced/x`, a normal build command, a normal commit) and log the exit codes. Expected: 2 for the dangerous ones, 0 for the others.

Validate `.claude/settings.json` as JSON. Check that `/agents` (or the agents listing) shows the 12 project agents. Record a screenshot or the text output.

### Step 6 — Identity patch (minimal)
- In `src/main/resources/fabric.mod.json`, change **only** the `contact` URLs (`issues`, `sources`, `homepage`) to the fork's, and append "(unofficial fork)" to the description.
- **Do not change the mod id, version scheme, package names or code.** The mod id is decided by ADR in P03.
- Add the modification notice to `fabric.mod.json` only if the chosen convention requires it for JSON (otherwise record the change in NOTICE.md).

### Step 7 — First-pass feature inventory and knowledge map
- Write a small, committed, dependency-free script (Python or Java under `tools/inventory/`) that extracts:
  - every config option ID (with category),
  - every hotkey ID,
  - every tool mode,
  - every GUI screen class,
  - every command,
  - every mixin target.
- It writes `docs/enhanced/registers/features.md` rows with kind `existing`, status `unassessed`, and source location.
- Cross-check the counts with an independent grep and report both. At planning time there were about 175 config options and 78 hotkeys. Report the actual numbers; do not force them to match.
- `cartographer`: write `docs/enhanced/knowledge/architecture-map.md` (package map with file/line counts, entry points, main flows: load → placement → schematic world → render; verifier; material lists; Easy Place; paste; persistence). Stamp it "last verified at commit <sha>". Use `STRATEGY.md §3` as a starting hypothesis and verify it against the code.
- Seed `registers/problems.md` with every finding ID from `STRATEGY.md §4` (UX-*, PERF-*, ARCH-*, REL-*, SEC-*). Keep their stated confidence and set status `to-verify (P02)`.

### Step 8 — CI sanity
- Confirm that the existing GitHub Actions workflow still builds on the fork (push the phase branch to `origin` if the human agrees, or explain how to trigger it). Do not modify the workflow in P00.

### Out of scope
Any functional code change, dependency or repository changes, reformatting, test infrastructure (P01), architecture decisions (P03).

### Phase-specific deliverables
`NOTICE.md` · `CLAUDE.md` · `.claude/**` · `docs/enhanced/**` skeleton · `knowledge/licence-and-contribution.md`, `knowledge/build.md`, `knowledge/architecture-map.md` · seeded registers · `tools/inventory/*` · baseline hashes · logs.

### Acceptance criteria (each must be evidenced in the claims ledger)
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

### Mandatory tests and checks
- `./gradlew build` on the baseline commit and on HEAD (fresh clone or `git clean -xfd` first).
- Hook test script with ≥ 6 payloads (exit codes logged).
- `python -m json.tool .claude/settings.json` (or equivalent) succeeds.
- Inventory script run twice → identical output (`diff` empty).
- `cmp LICENSE.txt` against the baseline → identical.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P00/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-00-bootstrap-audit.md` with BASE=`baseline/sakura-26.3-0.29.2-sakura.1` and HEAD=`phase/P00-bootstrap`."
