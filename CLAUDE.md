# Litematica Enhanced — instructions for Claude Code

Unofficial fork of Litematica (client-side Fabric schematic mod, LGPL-3.0-only), based on `sakura-ryoko/litematica` (MC 26.3, Java 25), designed with masa's rewrite (`maruohon/*@ornithe/1.12.2`) as the architectural reference. The programme runs in audited phases; see `docs/enhanced/ROADMAP.md`.

## Read first, every session
1. `docs/enhanced/STATE.md`: current phase, last verified commit, blockers, next action.
2. The phase prompt you were given (it defines scope, owners, acceptance criteria).
3. Only the `docs/enhanced/knowledge/` notes for subsystems in scope. Then source files, **by line range**.
Authoritative rules: `docs/enhanced/REFERENCE.md`. Precedence: human decision > REFERENCE > ADRs > phase prompt.

## Commands
- Build: `./gradlew build` (Windows: `gradlew.bat build`)
- Unit tests: `./gradlew test`
- Client game tests: `<filled in by P01, e.g. ./gradlew runClientGameTest>`
- Benchmarks: `<filled in by P01>`; protocol in `docs/enhanced/benchmarks/PROTOCOL.md`
- Run client (dev): `./gradlew runClient`

## Hard rules (summary of REFERENCE §5, §7)
- Stay inside the phase scope. Out-of-scope findings go into `docs/enhanced/registers/*`, not the diff.
- Never invent results. Every number, test result or screenshot claim links to a file produced by a command you ran.
- A successful compile proves nothing. Acceptance needs behavioural evidence.
- Measure before and after every optimisation (same machine, same protocol).
- No feature removal, no format change, no new runtime dependency without an approved ADR.
- No autonomous world interaction (no printer/auto-build). Every gameplay packet must be caused by a user input or a user-confirmed job.
- Do not reformat code you do not change. Match the file's indentation (tabs or spaces vary per file). `*.java` uses CRLF in the working tree (`.gitattributes`). Whole-file churn is a defect. Never run `git add --renormalize`.
- Hot files are lead-only (list in `docs/enhanced/AGENTS.md` §4.1). Subagents propose changes to them as "change requests" in their report.
- Two failed attempts at the same problem → stop, write a blocker note, report.

## Repo quirks
- MaLiLib comes from `https://masa.dy.fi/maven/sakura-ryoko`. If it is unreachable, see `docs/enhanced/knowledge/build.md` (composite build / mavenLocal fallback).
- Fabric API is **not** a runtime dependency. It may appear only in test/gametest source sets (ADR-recorded).
- Mixins: every mixin needs an entry in `docs/enhanced/knowledge/mixin-register.md` in the same commit.
- Game code is unobfuscated (Mojang names). Do not look for Yarn names.

## Context discipline
- Use the `cartographer` subagent for "where is X / who calls Y". Never sweep the repository or read 3,000-line classes whole.
- Delegate reading-heavy investigations to subagents. Keep their reports ≤ 150 lines in `docs/enhanced/phases/PXX/agents/`.
- Long outputs (logs, test output, JFR summaries) go to files under `docs/enhanced/phases/PXX/logs/`. Link them, don't paste them.
- When compacting, always preserve: the current phase ID, the list of modified files, test/benchmark commands with their last results, open register IDs, and pending change requests.

## Git
- Branches: `vendor/sakura-<mc>` (never commit), `enhanced/main`, `phase/PXX-<slug>`, `upstream-pr/<topic>`. Never push to `upstream-*` remotes. Never force-push.
- Commit messages: `[PXX] <area>: <imperative summary>`, plus a body explaining why and the evidence path. One concern per commit. Mechanical changes (moves, renames) go in separate commits.
- Never merge red. Phase branches merge into `enhanced/main` only after the external audit PASS.

## Where things go
ADRs `docs/enhanced/adr/` · registers `docs/enhanced/registers/` · knowledge `docs/enhanced/knowledge/` · benchmarks `docs/enhanced/benchmarks/` · design `docs/enhanced/design/` · specs `docs/enhanced/specs/` · phase files `docs/enhanced/phases/PXX/` · templates `docs/enhanced/templates/`.
