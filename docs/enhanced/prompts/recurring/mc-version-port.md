# Litematica Enhanced — Recurring procedure: Minecraft version port

> **When:** after Mojang ships a new Minecraft version (game drops are roughly quarterly: 26.1, 26.2, 26.3…), **between phases**, never in the middle of one.
> **How:** fill in the fields, start Claude Code at the fork root on `enhanced/main` (clean, last phase merged), and paste the prompt. Then run the audit section at the end in a separate session.

```text
FROM_MC      = 26.3            (current target)
TO_MC        = 26.4            (new version)
STRATEGY     = A               (A = rebase on Sakura-Ryoko's port — recommended; B = port the fork directly)
UPSTREAM_REF = upstream-sakura/<branch-or-tag of the upstream port>   (strategy A only)
```

## 0. Context (short)
*Litematica Enhanced* is an unofficial LGPL-3.0-only fork of Litematica, based on `sakura-ryoko/litematica`.
- Rules: `docs/enhanced/REFERENCE.md` (§4.2 version adapter layer and mixin register; §4.9 compatibility; §5 rules; §6 benchmarks).
- Branch model: `docs/enhanced/UPSTREAM.md §2`. Supported versions policy: ADR-0015.
- Port metric: number of files touched by the port. It should trend down.

## 1. Choose the path
- **Strategy A (recommended)** applies when Sakura-Ryoko has published a port for `TO_MC` (check `git ls-remote upstream-sakura` for a branch named after `TO_MC`, plus the release tags). The upstream maintainer has already solved the vanilla API changes, so the fork only re-applies its own changes on top.
- **Strategy B** applies only if the human wants the new version before upstream ports it. You port the fork directly, and you **re-sync to upstream's port later**, which costs a second merge. Confirm the choice with the human if it is B.

## 2. Procedure — Strategy A
1. `git fetch upstream-sakura`. Create `vendor/sakura-<TO_MC>` from `UPSTREAM_REF` and tag `baseline/sakura-<TO_MC>-<upstream version>`.
2. Create `port/<TO_MC>` from `enhanced/main`.
3. Merge (do not rebase) `vendor/sakura-<TO_MC>` into `port/<TO_MC>`, with `rerere` enabled.
4. Resolve conflicts **using `registers/upstream.md` (patch inventory)**:
   - in upstream files, keep upstream's ported code and re-apply the fork's seams;
   - in fork-only files, adapt them to the new APIs through the **adapter layer** (`mc/`);
   - update `knowledge/mixin-register.md` for every mixin whose target changed;
   - note each conflict and its resolution in `docs/enhanced/ports/<TO_MC>/conflicts.md`.
5. Update the version-specific metadata (`gradle.properties`: MC, loader, MaLiLib for `TO_MC`; `fabric.mod.json` depends range; Java version if it changed). The MaLiLib version must match upstream's port.

## 3. Procedure — Strategy B
1. Create `port/<TO_MC>` from `enhanced/main` and bump `gradle.properties` to `TO_MC` (loader, Loom, Java as required by Fabric's porting notes for `TO_MC`; fetch those notes and cite them).
2. Compile. Fix the errors **in the adapter layer first**, then in mixins (register), then elsewhere. Do not re-architect during a port.
3. MaLiLib: if no MaLiLib build exists for `TO_MC`, stop and ask the human. Never fork MaLiLib silently.

## 4. Verification (both strategies)
- `./gradlew clean build test` + game tests + architecture tests + the add-on compile-compat test + the edge-case suite.
- **Golden masters:** all must pass. Vanilla data-version changes may legitimately change the decoded output of old fixtures through DataFixer. Each such change is isolated in its own commit, explained, and listed in `ports/<TO_MC>/golden-changes.md`.
- **Benchmarks:** `fly-M`, `fly-L`, `layer-rebuild-L`, `load-L`, `verify-M` vs the latest results on `FROM_MC` (same machine). Report differences. Regressions beyond thresholds are investigated: is it vanilla's cost or ours?
- **Compat matrix:** update `compat/mods.md` (Sodium/Iris/Voxy availability for `TO_MC`).
- **Port metric:** `git diff --stat <old enhanced/main>..port/<TO_MC> -- src/ | tail -1`, excluding the upstream merge itself (for strategy A, compute the fork-side diff: `git diff vendor/sakura-<TO_MC>..port/<TO_MC> --stat` compared with the same measure before the port). Record it in `ports/<TO_MC>/report.md`.
- A manual playtest checklist for the human (load/place/verify/render with and without Sodium).

## 5. Finish
`ports/<TO_MC>/report.md` (≤ 2 pages + claims ledger). Update `STATE.md`, `ROADMAP.md` (recurring procedures table), `CLAUDE.md` baseline line, `REFERENCE.md §2` (facts). Then ask the human to run the audit below. Merge `port/<TO_MC>` into `enhanced/main` only after a PASS. Tag `enhanced/port-<TO_MC>-pass`.

## 6. Acceptance criteria
1. The build, all suites and the golden masters pass on `TO_MC`. Every golden change is isolated and explained.
2. Every conflict is listed with its resolution. The patch inventory and the mixin register are up to date.
3. Benchmarks are compared with `FROM_MC`, with raw files and an explanation of the differences.
4. The compat matrix is updated. The port metric is recorded.
5. No behaviour change beyond what the vanilla update requires. No new features. No refactors outside the adapter fixes.

---

## Audit (paste into a NEW session at `port/<TO_MC>`)
Run it in a detached worktree: `git worktree add --detach ../audit-port port/<TO_MC>`. You are an independent auditor of a Minecraft version port of Litematica Enhanced. Do not trust `ports/<TO_MC>/report.md`. Do not modify code. Write only `docs/enhanced/ports/<TO_MC>/audit.md`, then commit it alone on a new branch `audit/port-<TO_MC>` (the human fast-forwards `port/<TO_MC>` to it before merging).
1. Reproduce: clean build, all suites, game tests. Save the logs.
2. For strategy A: `git diff vendor/sakura-<TO_MC>..port/<TO_MC> --stat`. Compare it with the fork-side diff before the port. Unexplained new fork changes are MAJOR. Check that upstream's port was not overwritten by stale fork code in conflict zones: sample 5 conflict resolutions.
3. Golden changes: each one is justified by a vanilla data change. Unexplained changes are BLOCKER.
4. Mixins: every mixin in the JSON exists, applies (mixin audit or startup log without injection failures), and has an updated register row.
5. Benchmarks: re-run one scenario and check the explanation of the differences.
6. Verdict: PASS / PASS WITH RESERVATIONS / FAIL (same rules as the phase audits). Give the merge commands on PASS.
