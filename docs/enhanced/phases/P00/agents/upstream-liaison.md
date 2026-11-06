# upstream-liaison — licence, NOTICE and AI disclosure — P00

## Summary
- Wrote the licence/contribution knowledge note, NOTICE.md and the filled AI_DISCLOSURE.md.
- Modrinth/CurseForge statements come from the planning dossier (STRATEGY.md §1.3, 2026-11-06); not re-fetched (no WebFetch used). Marked "re-check at P19".
- masa's no-issues request is also from the dossier, not re-verified.
- Open item: `fabric.mod.json` still has masa's `twitter` and `discord` entries (lines 17-18); out of P00 scope.
- No commits, no branch changes, no fetch.

## Files changed (owned paths only)
- `docs/enhanced/knowledge/licence-and-contribution.md` (new)
- `NOTICE.md` (new; 44 contributor names from `git shortlog -sn` at the baseline tag)
- `docs/enhanced/AI_DISCLOSURE.md` (table filled)
- this report

## Commands run
`git shortlog -sn baseline/sakura-26.3-0.29.2-sakura.1`; read-only greps and sed on inputs. `LICENSE.txt` header confirmed as LGPL v3.

## Open questions for the lead
1. Who removes the `twitter`/`discord` entries in `fabric.mod.json` (hot file)?
2. The NOTICE.md table lists the fabric.mod.json change as done; confirm the actual edit (URLs and "(unofficial fork)") has landed.
3. Shortlog has duplicates for the same people (Starman variants, mms/mms0316); listed as in git history, not merged.

## Risks / follow-ups
- Platform rules may change before P19; re-read them then.
