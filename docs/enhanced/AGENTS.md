# 04 — Agent Operating Model (Claude Code multi-agent organisation)

> Accurate for Claude Code as documented on 2026-11-06 (subagents, worktrees, agent teams, memory). Re-check the docs if your Claude Code version is older or newer: https://code.claude.com/docs/en/sub-agents.md · https://code.claude.com/docs/en/worktrees.md · https://code.claude.com/docs/en/agent-teams.md

## 1. Principles
1. **Few agents, real independence.** An agent exists only when its work can proceed without waiting for, or editing the same files as, another agent. Most phases activate 2–4 agents, not 10.
2. **Files are the interface.** Agents exchange results through short files in `docs/enhanced/` (reports, registers, knowledge notes), not through long chat messages. The lead reads summaries and opens details only when needed.
3. **The lead session orchestrates; subagents execute.** The main Claude Code session (the "lead", on the strongest model) plans, assigns file ownership, integrates, runs the full test suite and writes the phase report.
4. **Fresh eyes verify.** Work is never graded by the agent that produced it. Inside a phase, an `independent-auditor` subagent pre-audits. Between phases, a **separate session** runs the audit prompt.
5. **Default to subagents; use agent teams only where debate helps** (P02 audit consolidation and P18 adversarial audit). Agent teams are experimental, cost significantly more tokens, and cannot be resumed with in-process teammates.

## 2. Roster

Definitions are in `claude-code-kit/.claude/agents/` (copied into the repo in P00). Model aliases follow the Claude Code docs (`opus`, `sonnet`, `haiku`, `inherit`). Adjust them to your plan and budget.

| Agent | Purpose | Model / effort | Tools | Isolation | Writes to |
|---|---|---|---|---|---|
| *lead* (main session) | Plan, assign, integrate, merge, report | opus / high | all | phase branch | everything, sole owner of "hot files" |
| `cartographer` | Find code, maintain knowledge maps, answer "where/how is X" cheaply | haiku / low | Read, Grep, Glob, Bash, Write | none | `docs/enhanced/knowledge/**` |
| `architect` | Architecture analysis, ADRs, foundation refactors | opus / high | all | worktree when editing code | `adr/`, `knowledge/`, owned code paths |
| `perf-engineer` | Benchmarks, profiling (JFR), rendering and data-path optimisation | opus / high | all | worktree | `benchmarks/`, owned code paths |
| `ux-designer` | Journeys, IA, design system, mockups, UX reviews | sonnet / medium | Read, Grep, Glob, Bash, Write, Edit | none | `docs/enhanced/design/**` |
| `ui-engineer` | Implements the UI toolkit and screens | sonnet / medium | all | worktree | `client/ui/**`, `gui/**` (as assigned) |
| `feature-designer` | Feature research, specs, prioritisation, add-on/market scan | sonnet / medium | Read, Grep, Glob, Write, WebSearch, WebFetch | none | `specs/`, `registers/features.md` |
| `reliability-engineer` | IO safety, lifecycle, concurrency review, compat, security, fairness | opus / high | all | worktree | owned code paths, `registers/problems.md` |
| `test-engineer` | Test harness, characterisation/golden tests, game tests, CI | sonnet / medium | all | worktree | `src/test/**`, `src/gametest/**`, CI |
| `doc-writer` | User/technical docs, changelogs, translation key lists | haiku / low | Read, Grep, Glob, Write, Edit | none | `docs/**` (not code) |
| `independent-auditor` | Adversarial verification inside a phase | opus / high | Read, Grep, Glob, Bash, Write | none (read-only by instruction) | `phases/PXX/pre-audit.md` only |
| `upstream-liaison` | Upstream intel, PR extraction, sync, licence/attribution | sonnet / medium | Read, Grep, Glob, Bash, Write, WebFetch | worktree for `upstream-pr/*` | `registers/upstream.md`, `upstream-pr/*` branches |

Cheap exploration: also pin the built-in `Explore` agent to `haiku` with a project subagent named `Explore` (`model: haiku`), as the docs suggest.

## 3. Activation matrix (● main, ○ support)

| Phase | lead | cart. | arch. | perf | ux | ui | feat. | rel. | test | doc | audit | upstr. |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| P00 | ● | ○ | | | | | | | | | | ○ |
| P01 | ● | ○ | | ● | | | | | ● | | ○ | |
| P02 | ● | ● | ● | ● | ● | | ● | ● | | | ● | ● |
| P03 | ● | | ● | ○ | ○ | | | ○ | | | ○ | ○ |
| P04 | ● | | | | ● | ○ | | | | | ○ | |
| P05 | ● | | ○ | | ○ | | ● | ○ | | | ○ | ○ |
| P06 | ● | | | | | | | ● | ● | | ○ | ● |
| P07 | ● | ○ | ● | | | | | ○ | ● | | ○ | |
| P08 | ● | ○ | ● | ○ | | | | ● | ● | | ○ | |
| P09 | ● | | | | ○ | ● | | | ● | | ○ | |
| P10 | ● | | | | ○ | ● | | | ● | ○ | ○ | |
| P11 | ● | | | | ○ | ● | | | ● | ○ | ○ | |
| P12 | ● | ○ | ○ | ● | | | | ● | ● | | ○ | |
| P13 | ● | | ● | ● | | | | | ● | | ○ | |
| P14 | ● | | | | ○ | ● | | | ● | ○ | ○ | |
| P15 | ● | | | | ○ | ● | ○ | ● | ● | ○ | ○ | |
| P16 | ● | | ○ | | ○ | ● | ● | | ● | ○ | ○ | |
| P17 | ● | | ● | ○ | ○ | ● | ● | | ● | ○ | ○ | |
| P18 | ● | ○ | ○ | ● | ○ | | | ● | ● | | ●● (team) | |
| P19 | ● | | | | | | | ○ | ● | ● | ○ | ● |

## 4. File ownership and conflict avoidance

### 4.1 Hot files (lead-only, or one designated owner per phase)
`build.gradle`, `gradle.properties`, `settings.gradle`, `fabric.mod.json`, `mixins.litematica.json`, `litematica.accesswidener`, `config/Configs.java`, `config/Hotkeys.java`, `assets/litematica/lang/en_us.json`, `data/DataManager.java`, `render/LitematicaRenderer.java`, `render/schematic/WorldRendererSchematic.java`, `event/KeyCallbacks.java`, `Litematica.java`/init handlers, `docs/enhanced/STATE.md`, `ROADMAP.md`, `DECISIONS.md`.

Other agents never edit these. They write a **change request** block in their agent report (exact diff hunk plus reason), and the lead applies it once at integration time. This removes the most common merge conflicts: config registration, lang keys, mixin lists.

### 4.2 Ownership map in every plan
Each `phases/PXX/plan.md` contains a table `path glob → owner agent`. Two agents never own overlapping globs in the same phase. The lead resolves ownership disputes before spawning.

### 4.3 Worktree workflow
- `.claude/settings.json` sets `"worktree": { "baseRef": "head" }`. **This matters**: without it, subagent worktrees branch from the repository's *default* branch, not from the current phase branch.
- Implementing agents have `isolation: worktree`. Each one commits on its own worktree branch and reports the branch name (`git branch --show-current`) and the commit range.
- Gradle: each worktree builds independently. The shared `~/.gradle` caches keep this affordable. Never run two Gradle builds on the *same* worktree concurrently.
- **Merge procedure (lead):**
  1. `git worktree list` → identify the agent's branch.
  2. Review `git diff phase/PXX...agent-branch --stat`, then the full diff of owned paths only.
  3. Rebase the agent branch onto the current phase branch, or merge with `--no-ff`.
  4. Apply the change requests for hot files.
  5. Run `./gradlew build test` (plus game tests if the phase requires them).
  6. Merge into the phase branch, remove the worktree, and append one line to `phases/PXX/integration-log.md`.
  - **Never merge red.** If the build breaks after a merge, revert that merge first, then investigate.
- `.gitignore` includes `.claude/worktrees/`.

### 4.4 Sequencing inside a phase
`plan → (parallel) independent tasks in worktrees → integration → pre-audit (independent-auditor) → fixes → phase report`. Dependent tasks run in sequence, never "in parallel with hope".

## 5. Communication protocol
- **Agent report file**: `docs/enhanced/phases/PXX/agents/<agent>-<task>.md`, ≤ 150 lines, with fixed sections: *Summary (≤ 10 lines) · Files changed · Commands run + results · Evidence links · Change requests for hot files · Open questions · Risks/follow-ups (register IDs)*.
- **Return message to the lead**: ≤ 25 lines (status, branch, report path, blocking questions). No pasted logs. Logs go to files under `phases/PXX/logs/`.
- **Registers are append-mostly**: agents add rows with new IDs. Only the lead renumbers or merges duplicates.

## 6. Context and token strategy
1. **Read order for every session**: `CLAUDE.md` (auto) → `docs/enhanced/STATE.md` → the phase prompt → `ROADMAP.md` row → the knowledge notes for subsystems in scope → only then source files.
2. **Never sweep the repository.** Use `cartographer` (haiku) for "where is X / who calls Y". Read file *ranges*, not whole 3,000-line classes. The knowledge maps exist so nobody re-reads `util/` every phase.
3. **Delegate reading-heavy work to subagents.** Their file reads stay in their own context. Only the summary returns.
4. **Match model to task**:
   - opus: architecture, concurrency, audits.
   - sonnet: implementation, UI, tests, specs.
   - haiku: exploration, documentation, summarising logs.
   - Optionally set `CLAUDE_CODE_SUBAGENT_MODEL` for a cheap default, and keep explicit `model:` in the definitions that need opus.
5. **Effort**: `high` only for architect, perf, reliability and auditor. `low` for cartographer and doc-writer.
6. **Compaction**: CLAUDE.md contains *"When compacting, always preserve: current phase ID, list of modified files, test commands and their last results, open register IDs."* Use `/compact <focus>` at natural milestones and `/clear` between unrelated tasks.
7. **Small reports**: ≤ 2 pages per phase report, ≤ 150 lines per agent report. Raw data lives in files.
8. **Reuse results**: phases cite register IDs and ADRs instead of re-deriving them. The audit prompts embed acceptance criteria, so auditors don't need the implementation chat.
9. **Stop rule**: after two failed attempts at the same problem, an agent stops and writes a blocker note. It does not loop. The lead decides whether to re-plan, split or escalate to the human.
10. **Prompt caching**: long-lived context (CLAUDE.md, REFERENCE.md, knowledge notes) stays stable during a phase, so do not rewrite it mid-phase without need.

## 7. Agent teams (optional, experimental)
- Enable with `"env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }` in `.claude/settings.json` **only for P02 consolidation and P18**. Turn it back to `"0"` afterwards. While teams are enabled, subagents that Claude *names* launch as teammates.
- Pattern: 3–5 teammates, each with a different lens and a mandate to **disprove** the others' findings. The lead synthesises into the registers.
- Limits to remember:
  - no resumption of in-process teammates;
  - one team per session;
  - no nested teams;
  - permission prompts bubble up to the lead;
  - token use scales with the number of teammates.
- Not available in non-interactive `-p` runs.

## 8. Guardrails
- **Permissions** (`.claude/settings.json`): allow `./gradlew *`, read-only git commands, `git add/commit/switch/worktree/merge/rebase` on local branches. Deny `git push --force*`, pushes to upstream remotes, `rm -rf` outside the build directories, and edits to `LICENSE.txt`.
- **PreToolUse hook** `.claude/hooks/guard-bash.sh`: blocks force-pushes, pushes to `upstream-*` remotes, `git reset --hard` on `enhanced/main`, and deletion of tags matching `enhanced/*` and `baseline/*`. Exit code 2 returns the reason to Claude.
- **Path-scoped rules** (`.claude/rules/*.md` with `paths:` frontmatter) load extra rules only when relevant files are touched: rendering/threading, schematic IO, GUI, mixins, tests.
- **Human gates**: phases P00, P03, P04, P05 and P19 stop and ask for the owner's decision. Their prompts say so explicitly.

## 9. Independent verification layers
1. **Agent self-check**: tests and evidence in its report.
2. **In-phase pre-audit**: `independent-auditor` subagent with a fresh context. It reads the diff, the plan and the acceptance criteria, re-runs the tests and samples a benchmark.
3. **External audit**: a new Claude Code session (separate worktree/clone) using the phase's audit prompt. It does not read the implementation conversation.
4. **Human playtest** where the roadmap lists one: a checklist provided in the phase report.

## 10. Cost controls (practical)
- Run P02 and P18 (the most expensive) at the start of a fresh usage window.
- Keep implementing subagents to ≤ 3 in parallel. Each extra worktree adds a Gradle build.
- Prefer `claude -p` scripted loops for mechanical, file-by-file tasks (for example removing commented-out code in owned files). Use `--allowedTools` and `--permission-mode dontAsk` for unattended batches, and test on 2–3 files first.
- Check usage regularly. If a phase overruns its size class by more than about 50%, stop, write the state and split the phase.
