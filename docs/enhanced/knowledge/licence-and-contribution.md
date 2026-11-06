# Licence and contribution rules

Not legal advice. This note summarises obligations as understood by the project; check the licence text and, if in doubt, a lawyer.

## 1. LGPL-3.0-only obligations for this fork
Litematica is under the GNU LGPL v3 (`LICENSE.txt`, unchanged; its header confirms "GNU LESSER GENERAL PUBLIC LICENSE Version 3, 29 June 2007"). LGPLv3 incorporates GPLv3. For a fork this means:

| Obligation | How the fork meets it |
|---|---|
| Keep copyright and licence notices | Existing file headers and `LICENSE.txt` stay untouched; `NOTICE.md` credits masa, Sakura-Ryoko and the contributors |
| Provide the source | Public repository `https://github.com/Kyoonit/litematica-enhanced`; releases also ship a sources jar |
| Mark modified files with a prominent notice and a date (GPLv3 §5(a)) | Convention below |
| Licence the work as LGPL-3.0-only | Fork-authored code is released under the same licence; no relicensing, no extra restrictions |

### Modification-notice convention (decided 2026-11-06)
- The first time the fork modifies an upstream source file, add one comment line: `// Modified by Litematica Enhanced contributors (<year>); see NOTICE.md`.
- JSON files cannot hold comments, so their modifications are listed in the "Modified upstream files" table of `NOTICE.md` (file, change, date, phase).
- `NOTICE.md` also states that the whole project is a modified version and carries the date range, so the notice is prominent and dated even for files touched later.
- Files created by the fork carry no upstream notice; they follow the project's file-header rule.

## 2. Sakura-Ryoko's PR template (`.github/pull_request_template.md`)
It asks for: an overview, related issues ("Closes #..."), and a type of change (bug fix, new content, refactor/optimisation, translation/assets, config/build script). Its section "AI Disclosure & Modrinth Compliance" asks contributors to "accurately disclose the role generative AI tools" played, with a "No AI was used" checkbox and an "AI Assistance Breakdown": code generation, assets and textures, core functionality, documentation/localisation. It ends with "Briefly describe exactly what the AI tool assisted with". Every upstream PR from this fork must fill it truthfully; a PR may be declined for that reason alone.
Source: the file in this repository (inherited from the baseline).

## 3. Distribution platforms (re-check at P19)
### Modrinth (re-check at P19)
Source: planning dossier (2026-11-06), recorded in `docs/enhanced/STRATEGY.md` §1.3; not re-fetched. The dossier says the rules were updated 2026-08-13:
- AI disclosure is mandatory when a substantial portion of the code is AI output.
- Projects whose contents are primarily or entirely AI output may not be published publicly.
- No AI-generated images on project pages.
- Forks must diverge substantially.
- No implying endorsement or affiliation (relevant to the name; see the working name below).
Rules page to re-read: https://modrinth.com/legal/rules (not fetched in P00).

### CurseForge (re-check at P19)
Source: planning dossier (2026-11-06), STRATEGY.md §1.3; not re-fetched. Notes: an "AI Misleading Content Disclosure" moderation policy exists, and reuploads with minimal changes are not allowed. Read the current text before publishing there.

## 4. masa's request about issues, and the fork's response
masa does not maintain 1.20.5+ and asks not to receive issues for versions he does not maintain (STRATEGY.md §1.2; from the planning dossier, not re-verified in P00). The fork therefore:
- uses its own issue tracker (`https://github.com/Kyoonit/litematica-enhanced/issues`) as the sole contact channel;
- never directs users to masa's tracker; `fabric.mod.json` `homepage`, `issues` and `sources` are repointed to the fork in P00;
- sends only vetted, small fixes upstream to Sakura-Ryoko's repositories (see UPSTREAM.md).
Open item: `fabric.mod.json` still lists masa's `twitter` and `discord` contact entries. P00 leaves them untouched by scope; the lead should decide who removes them.
Working name: "Litematica Enhanced — an unofficial Litematica fork". It must not imply endorsement; the final name is decided at P19 after asking the maintainers. Maintainers are not contacted now.

## 5. Checklist for future phases
- [ ] Porting a design from masa's rewrite (`maruohon/*@ornithe/1.12.2`): credit masa and the source file/commit in the code comment, the ADR and the changelog; never copy code between incompatible licences without checking.
- [ ] Every upstream PR: fill the template, tick the AI breakdown truthfully, describe what the AI did, one concern per PR.
- [ ] First modification of an upstream file: add the notice line (or a NOTICE.md table row for JSON).
- [ ] Release notes: link source, state "unofficial fork", update the AI disclosure, list known issues.
- [ ] Each release: `LICENSE.txt` unchanged and shipped in the jar; NOTICE.md refreshed (contributors, modified files); contact URLs point to the fork.
- [ ] Third-party assets: record their licence; no AI-generated art if Modrinth is a target.
- [ ] P19: re-read Modrinth and CurseForge rules, then settle the name.

Last verified at commit 64e74592f631cfa5b084bedb0eda5dac8a3b3cb8 on 2026-11-06
