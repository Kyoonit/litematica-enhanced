# Litematica Enhanced — Recurring procedure: upstream sync (same Minecraft version)

> **When:** Sakura-Ryoko publishes a new Litematica (or MaLiLib) release or a significant fix series for the Minecraft version the fork targets. Run it **between phases**.
> **How:** fill in the fields, start Claude Code at the fork root on a clean `enhanced/main`, and paste the prompt. Then run the audit section in a separate session.

```text
MC            = 26.3
UPSTREAM_REF  = upstream-sakura/26.3   (or a release tag, e.g. 26.3-0.29.3)
MALILIB_BUMP  = yes/no (new MaLiLib version required by upstream?)
```

## 0. Context (short)
*Litematica Enhanced* is an unofficial LGPL-3.0-only fork of `sakura-ryoko/litematica`.
- `vendor/sakura-<MC>` mirrors upstream and receives fast-forwards only. `enhanced/main` integrates the fork.
- The patch inventory in `docs/enhanced/registers/upstream.md` lists every upstream file the fork touches.
- Rules: `docs/enhanced/REFERENCE.md`; strategy: `docs/enhanced/UPSTREAM.md §3`.

## 1. Procedure
1. `git fetch upstream-sakura`. Fast-forward `vendor/sakura-<MC>` to `UPSTREAM_REF`. If a fast-forward is impossible (upstream rewrote history), **stop and ask**.
2. Summarise the incoming changes: `git log --oneline <old vendor>..<new vendor>` and `--stat`. Classify each commit as (a) touches files in the patch inventory → expected conflict; (b) fixes something the fork also fixed → candidate to drop the fork's version; (c) unrelated.
3. Create `sync/<MC>-<upstream version>` from `enhanced/main` and merge the new vendor branch (`--no-ff`, `rerere` on).
4. Resolve conflicts. Upstream behaviour wins unless the fork has a **tested** reason; record each resolution in `docs/enhanced/syncs/<date>/conflicts.md`. Where upstream now fixes a bug the fork fixed:
   - keep upstream's fix;
   - keep the fork's **test**;
   - remove the fork's duplicate code;
   - update `registers/upstream.md` (PR merged or superseded).
5. If `MALILIB_BUMP`: update `gradle.properties`, check the MaLiLib changelog and diff for APIs the fork uses, and run the compile-compat test.
6. Verification:
   - `./gradlew clean build test` + game tests + architecture tests + golden masters + the edge-case suite;
   - benchmarks `fly-M`, `load-L`, `verify-M` vs the previous results (same machine);
   - upstream changes in rendering, IO or networking get targeted manual playtest items.
7. Update the patch inventory (sizes, new seams), the knowledge notes of the subsystems upstream changed, and the mixin register.
8. Report in `docs/enhanced/syncs/<date>/report.md` (≤ 1 page + claims ledger). Update `STATE.md` and the recurring table in `ROADMAP.md`. Ask the human to run the audit. Merge into `enhanced/main` only after PASS. Tag `enhanced/sync-<MC>-<upstream version>`.

## 2. Acceptance criteria
1. `vendor/sakura-<MC>` is an exact fast-forward to `UPSTREAM_REF` (shas recorded).
2. Every conflict is documented. Duplicated fixes are removed while their tests are kept.
3. All suites and the golden masters pass. Benchmarks are within thresholds or explained.
4. The patch inventory, knowledge notes and mixin register are updated.
5. No fork behaviour change except what is required to integrate upstream changes.

---

## Audit (paste into a NEW session at the `sync/...` branch)
Run it in a detached worktree: `git worktree add --detach ../audit-sync sync/<MC>-<upstream version>`. You are an independent auditor of an upstream sync. Do not modify code. Write only `docs/enhanced/syncs/<date>/audit.md`, then commit it alone on a new branch `audit/sync-<date>` (the human fast-forwards the sync branch to it before merging).
1. Check that the vendor branch equals `UPSTREAM_REF` exactly.
2. `git diff <new vendor>..sync/... --stat` vs `git diff <old vendor>..<old enhanced/main> --stat`. The fork-side delta should be about the same size. Large unexplained growth is MAJOR.
3. Sample 5 conflict resolutions. Was any upstream fix silently lost? A lost upstream fix is a BLOCKER.
4. Re-run the suites and one benchmark.
5. Verdict and merge commands on PASS.
