# Litematica Enhanced — P19 · Stabilisation, release and upstream packaging
## Implementation prompt (for Claude Code)

> **How to use:** start Claude Code at the root of your fork repository, on branch `phase/P19-release` created from `enhanced/p18-pass`, and paste this entire prompt. It is self-contained and does not rely on any earlier conversation.
> **Size class:** M · **Human checkpoint:** YES — go/no-go for the release, version number, distribution channels, disclosure text, final name, and which upstream PRs or proposals to send

---

## 0. Global context (read carefully)

You are the **lead** of phase **P19** of the *Litematica Enhanced* programme. This is an **unofficial fork** of Litematica, the client-side Fabric mod for loading, rendering, placing and verifying schematics. Licence: **LGPL-3.0-only**.

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
   - Check that you are on `phase/P19-release` and that the base is an ancestor: `git merge-base --is-ancestor enhanced/p18-pass HEAD`.
   - Run `./gradlew build` once to confirm a green starting point, and save the log under `docs/enhanced/phases/P19/logs/`.
2. **Plan before editing.**
   - Write `docs/enhanced/phases/P19/plan.md` from `docs/enhanced/templates/phase-plan.md`: tasks, owner agent per task, a **non-overlapping file ownership map**, expected hot-file changes, test plan, benchmark plan, risks.
   - If the plan exceeds the size class (M) or needs a decision reserved for the human, **stop and ask**, proposing a split (P19a/P19b) or options.
3. **Delegate with care** (`docs/enhanced/AGENTS.md`).
   - Use the project subagents in `.claude/agents/` as assigned in §3.
   - Implementing subagents run with `isolation: worktree`. `.claude/settings.json` sets `worktree.baseRef = "head"` so their worktrees start from this phase branch.
   - At most **3 implementing subagents in parallel**.
   - Give each subagent a self-contained brief: goal, owned paths, inputs, acceptance tests, report path.
   - Subagents write reports (≤ 150 lines) to `docs/enhanced/phases/P19/agents/` and reply in ≤ 25 lines.
   - **Hot files** (AGENTS.md §4.1) are edited by you only, from the subagents' change requests.
4. **Integrate.** For each agent branch: review the diff of owned paths, rebase or merge with `--no-ff`, apply change requests, run build and tests, merge, then append a line to `docs/enhanced/phases/P19/integration-log.md`. **Never merge red.**
5. **Context hygiene.**
   - Never sweep the repository. Use `cartographer` for lookups and read files by line range.
   - Put logs in `docs/enhanced/phases/P19/logs/` and link them.
   - Use `/compact` at milestones, preserving: the phase ID, the modified files, test and benchmark commands with their last results, open register IDs, pending change requests.
6. **Commits.** Format: `[P19] <area>: <imperative summary>`, with a body giving the reason and the evidence path. Commit early and often on the phase branch. Never push to `upstream-*`. Never force-push.
7. **Pre-audit.** Before writing the report, run the `independent-auditor` subagent with the acceptance criteria below and the commit range. It writes `docs/enhanced/phases/P19/pre-audit.md`. Fix BLOCKER and MAJOR findings, or explain why not.
8. **Close the phase.**
   - Write `docs/enhanced/phases/P19/report.md` from the template (≤ 2 pages + claims ledger).
   - Update `STATE.md`: status `in-audit`, last verified commit, next action = "run the P19 audit prompt".
   - Update the `ROADMAP.md` row, the registers, the knowledge notes of touched subsystems (with commit stamp), and `DECISIONS.md` for any human decision.
   - Commit everything.

## 3. Phase P19 — Stabilisation, release and upstream packaging

**Agents for this phase:** lead · `test-engineer` (release verification) · `doc-writer` (docs, changelog, release notes) · `upstream-liaison` (PR series, licence/attribution, platform rules) · `reliability-engineer` (release checks) · `independent-auditor`

### Goal
Produce a **release candidate** the human can publish with confidence: verified builds, complete docs, honest disclosure, correct licensing and attribution, a clear version, and a distribution decision based on the platforms' **current** rules. In parallel, package the **upstream contributions**: Category-A PRs ready to send, Category-B proposals written up.

### Work packages
1. **Release verification (`test-engineer` + `reliability-engineer`).**
   - Clean-clone build on Linux and Windows (CI matrix; macOS if available).
   - Full suites, game tests, the edge-case suite, the benchmark smoke set.
   - Jar inspection:
     - no test dependencies, no Fabric API, no placeholders;
     - `fabric.mod.json` correct (id, `provides`, `breaks`, contact, authors including the original authors, licence);
     - mixin config and access widener consistent.
   - SHA-256 checksums; reproducibility check (build twice, compare hashes; document any nondeterminism).
2. **Feature flags.** Apply the human's per-feature default decisions (P16/P17), the defaults confirmed by audits (P09–P15), and the legacy-path removals that satisfy REFERENCE §4.7 (parity ✔, one release with the new default ✔ — usually **not yet** for a first release: keep the legacy paths). Generate a flags table for the release notes.
3. **Release checks script** (`tools/release-check`), which fails if:
   - any `*_placeholder` asset is shipped;
   - any translation key is missing in `en_us.json`;
   - `LICENSE.txt` differs from upstream;
   - `NOTICE.md` or `AI_DISCLOSURE.md` is missing;
   - the version strings are inconsistent;
   - a `-SNAPSHOT`/dev flag is enabled.
4. **Docs (`doc-writer`).**
   - README (what the fork is, that it is unofficial, installation, compatibility, differences from official Litematica, support channel);
   - user guide index;
   - migration guide from official Litematica (what is imported, what stays untouched, how to go back);
   - add-on API guide;
   - server-owner guide (fairness, policy channel);
   - known issues;
   - CHANGELOG (Added/Changed/Fixed/Deprecated/Removed/Security, linked to register IDs).
5. **Versioning.** Apply the scheme from UPSTREAM §7 (e.g. `1.0.0-rc.1+mc26.3`). Record the upstream base version in the release notes and the custom metadata. Tag `enhanced/v<version>` only after the human's go.
6. **Disclosure and platform rules (`upstream-liaison`).**
   - Re-read the **current** Modrinth content rules and AI policy, and the CurseForge moderation policies (fetch them; quote short passages; date them).
   - Write `docs/enhanced/release/distribution-analysis.md`: GitHub Releases (ready), Modrinth (eligibility given the share of AI-generated code, the human's authorship role, disclosure fields, the image rules), CurseForge (policy, AI disclosure).
   - Recommend, and let the human decide.
   - Finalise `AI_DISCLOSURE.md` and the release-notes disclosure paragraph.
7. **Name and identity.** If the maintainers answered the naming question, apply their answer. Otherwise use the working name with "(unofficial Litematica fork)". The human decides.
8. **Upstream packaging (`upstream-liaison`).**
   - Refresh every `upstream-pr/*` branch onto the current vendor branch. Rebuild them. Update the drafts with any new evidence.
   - Order them in a series (independent first, A before B).
   - For Category-B items (threading, `Schematic` interface, job system, test infrastructure, command palette…), write **one-page proposals** in `docs/enhanced/upstream-prs/proposals/`: problem, measurements, design, migration steps, fork link.
   - Update `registers/upstream.md`. **Nothing is sent by Claude.**
9. **GitHub release draft.** The release-notes text, the asset list (jar, sources jar, checksums), the compat matrix summary and the disclosure. A draft only: the human publishes it.

### Acceptance criteria (each must be evidenced in the claims ledger)
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

### Mandatory tests and checks
- CI matrix builds + all suites + the release-check script (pass and a deliberate fail).
- Jar inspection script (contents, metadata).
- Reproducible-build comparison.
- Per `upstream-pr/*`: a clean build.

### Standard deliverables (every phase)
- `docs/enhanced/phases/P19/plan.md`, `report.md`, `pre-audit.md`, `integration-log.md`, `agents/*.md`, `logs/`
- Updated `STATE.md`, `ROADMAP.md`, registers, knowledge notes, `DECISIONS.md` (if applicable)

## 4. Stop conditions — stop, write a blocker note in STATE.md, and ask the human when:
- a decision reserved for the human is needed (identity, ADR approval, design approval, feature selection, release, contacting maintainers);
- the build cannot be made green without changing dependencies or repositories;
- the same problem has resisted two serious attempts;
- you discover something that invalidates an accepted ADR or a previous phase's result;
- the work would exceed the size class by roughly 50% or more.

## 5. Final message to the human (≤ 20 lines)
Give the outcome, the pre-audit verdict, the 3 most important things to look at, any manual playtest to run (with the checklist path), and the exact next step:
"Open a new session and run `prompts/phase-19-release-audit.md` with BASE=`enhanced/p18-pass` and HEAD=`phase/P19-release`."
