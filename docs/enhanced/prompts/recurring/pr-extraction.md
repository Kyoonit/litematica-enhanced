# Litematica Enhanced — Recurring procedure: extract an upstream Pull Request

> **When:** a fork change classified **Category A** (or a Category-B item that the maintainers *asked* for) should be offered upstream.
> **How:** fill in the fields, start Claude Code at the fork root, and paste the prompt. **Claude never pushes to upstream or opens a PR.** You review the result and send it yourself.

```text
TOPIC        = atomic-schematic-save         (short slug)
SOURCE       = register ID(s) and/or fork commit range, e.g. REL-01, a1b2c3d..d4e5f6a
TARGET_REPO  = sakura-ryoko/litematica | sakura-ryoko/malilib
TARGET_BRANCH= 26.3                          (upstream default branch at the time)
```

## 0. Context (short)
*Litematica Enhanced* is an unofficial LGPL-3.0-only fork of `sakura-ryoko/litematica`, which is maintained by Sakura-Ryoko. masa (`maruohon`) is the original author and does not maintain modern versions.
- Upstream has **no test source set** and a PR template with an **AI disclosure** section.
- Strategy and template: `docs/enhanced/UPSTREAM.md §4–§6`.

## 1. Procedure
1. **Re-check the target.** `git ls-remote --symref https://github.com/<TARGET_REPO>.git HEAD`. If the default branch differs from `TARGET_BRANCH`, stop and ask. Re-read the upstream `.github/pull_request_template.md`, which may have changed.
2. **Is it still needed?** Search the upstream log since the fork's base for an equivalent fix (`git log upstream-sakura/<branch> -S '<key symbol>'`). If upstream already fixed it, stop, report, and update `registers/upstream.md`.
3. **Fresh base.** `git fetch upstream-sakura`. Fast-forward `vendor/sakura-<mc>`. Create `upstream-pr/<TOPIC>` from it. For MaLiLib, use the separate MaLiLib fork's vendor branch.
4. **Re-implement minimally** in upstream style:
   - same indentation, line endings and naming;
   - no fork packages, flags, services, test infrastructure or docs;
   - preserve upstream behaviour except the fix;
   - keep the diff ideally under 200 lines; if it is larger, propose a split.
5. **Build like upstream CI:** `./gradlew build` (Java version as upstream). Then test the scenario manually and **write the reproduction steps for the human**. The human performs the before/after manual check on the vendor build and on the PR build, and records the result.
6. **Evidence for the PR text:**
   - steps to reproduce;
   - before/after logs, screenshots or timings (with protocol and machine for timings);
   - environment (MC, loader, MaLiLib, mods);
   - optionally, a short description of the automated test the fork uses (as information, not as a demand that upstream adopt the test infrastructure).
7. **Draft** `docs/enhanced/upstream-prs/<TOPIC>.md` using the template in `UPSTREAM.md §5`. Fill in the **AI disclosure truthfully**: what Claude Code generated, what the human reviewed, tested and changed. Add a `registers/upstream.md` row with status `ready`.
8. **Self-check** (write the results into the draft's footer, which the human removes before sending):
   - `git diff vendor/sakura-<mc>..upstream-pr/<TOPIC> --stat` contains only the intended files;
   - no whitespace or line-ending churn (`--ignore-all-space --ignore-cr-at-eol` diff ≈ normal diff);
   - the build passes;
   - the disclosure is complete;
   - one concern only.

## 2. What the human does next (Claude does not)
Read the draft. Push `upstream-pr/<TOPIC>` to **your fork** (`origin`). Open the PR on GitHub against `TARGET_REPO:TARGET_BRANCH`, paste the description, and answer the review comments. If the PR is declined: thank the maintainer, mark it `declined` in the register, and keep the change in the fork.

## 3. Acceptance criteria
1. The PR branch is based on the current upstream default branch and contains only the fix.
2. Upstream's own build passes on it.
3. The draft has reproduction steps, evidence, the environment, and an honest AI disclosure.
4. The register is updated. Nothing was pushed to upstream and no PR was opened by Claude.
