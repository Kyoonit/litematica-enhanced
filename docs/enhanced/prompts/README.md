# Prompts — index

Every phase has two self-contained prompts:
- **implementation**: paste it into Claude Code on the phase branch;
- **audit**: paste it into a **new** session, ideally in a separate worktree, after the implementation finishes.

If an audit fails, use `correction-template.md`, then the delta re-audit at its end.

| Phase | Title | Size | Human checkpoint | Implementation | Audit |
|---|---|---|---|---|---|
| P00 | Bootstrap, fork and baseline preservation | S | **Yes**: identity, owner, contact | [impl](phase-00-bootstrap-implementation.md) | [audit](phase-00-bootstrap-audit.md) |
| P01 | Test and measurement harness | L | Benchmarks on your PC if needed | [impl](phase-01-harness-implementation.md) | [audit](phase-01-harness-audit.md) |
| P02 | Deep technical and functional audit | L | Review the synthesis | [impl](phase-02-audit-implementation.md) | [audit](phase-02-audit-audit.md) |
| P03 | Target architecture and migration plan | M | **Yes**: ADR approval | [impl](phase-03-architecture-implementation.md) | [audit](phase-03-architecture-audit.md) |
| P04 | Design system and GUI mockups | M | **Yes**: mockup approval | [impl](phase-04-design-implementation.md) | [audit](phase-04-design-audit.md) |
| P05 | Feature specification and backlog | M | **Yes**: feature selection | [impl](phase-05-features-implementation.md) | [audit](phase-05-features-audit.md) |
| P06 | Upstream-ready fixes (Category A) | M | **Yes**: fix list, PR drafts | [impl](phase-06-quickwins-implementation.md) | [audit](phase-06-quickwins-audit.md) |
| P07 | Core foundations | L | — | [impl](phase-07-core-implementation.md) | [audit](phase-07-core-audit.md) |
| P08 | Schematic model and I/O | L | Playtest (recommended) | [impl](phase-08-data-io-implementation.md) | [audit](phase-08-data-io-audit.md) |
| P09 | UI framework and pilot screen | L | Playtest + reference screenshots | [impl](phase-09-ui-kit-implementation.md) | [audit](phase-09-ui-kit-audit.md) |
| P10 | Shell, command palette, library | L | Playtest | [impl](phase-10-ui-library-implementation.md) | [audit](phase-10-ui-library-audit.md) |
| P11 | Placement, selection, tools, HUD | L | Playtest | [impl](phase-11-ui-placement-implementation.md) | [audit](phase-11-ui-placement-audit.md) |
| P12 | Rendering performance (split a/b) | XL | Playtest + numbers | [impl](phase-12-perf-render-implementation.md) | [audit](phase-12-perf-render-audit.md) |
| P13 | Analysis engines | L | — | [impl](phase-13-engines-implementation.md) | [audit](phase-13-engines-audit.md) |
| P14 | Analysis and settings UI | L | Playtest | [impl](phase-14-ui-analysis-implementation.md) | [audit](phase-14-ui-analysis-audit.md) |
| P15 | Existing feature improvements | L | Playtest (server) | [impl](phase-15-existing-implementation.md) | [audit](phase-15-existing-audit.md) |
| P16 | New features, wave 1 | L | Playtest + flag defaults | [impl](phase-16-features-1-implementation.md) | [audit](phase-16-features-1-audit.md) |
| P17 | New features, wave 2 + add-on API | L | Playtest + API approval | [impl](phase-17-features-2-implementation.md) | [audit](phase-17-features-2-audit.md) |
| P18 | Global adversarial audit | L | Triage MAJORs | [impl](phase-18-global-audit-implementation.md) | [audit](phase-18-global-audit-audit.md) |
| P19 | Stabilisation, release, upstream packaging | M | **Yes**: go/no-go, channels, PRs | [impl](phase-19-release-implementation.md) | [audit](phase-19-release-audit.md) |

**Templates and recurring procedures**
- [`correction-template.md`](correction-template.md): fix audit findings without touching validated work, plus the delta re-audit
- [`recurring/mc-version-port.md`](recurring/mc-version-port.md): port to a new Minecraft version (after each game drop)
- [`recurring/upstream-sync.md`](recurring/upstream-sync.md): merge a new Sakura-Ryoko release
- [`recurring/pr-extraction.md`](recurring/pr-extraction.md): turn a fork change into a minimal upstream PR draft

**Placeholders to fill** before pasting: the audit prompts ask for the HEAD sha. The recurring prompts and the correction template have a small field block at the top. Everything else is already filled in.
