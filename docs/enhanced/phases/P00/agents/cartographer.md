# cartographer — P00 — architecture map (≤ 150 lines)

## Summary
- Wrote `docs/enhanced/knowledge/architecture-map.md` (200 lines): package map, entry points, flows (a)-(h), hypothesis check, threading, known problems.
- Source tree at commit 64e74592f631cfa5b084bedb0eda5dac8a3b3cb8: 316 `.java` files, 73,085 lines under `src/main/java/fi/dy/masa/litematica/`.
- Mixins: 52 registered (23 common, 29 client, 0 server) of 53 files; `mixin/screen/MixinAbstractContainerScreen.java` is fully commented out.
- Access widener: 10 `accessible` lines (1 field, 9 methods on `FluidRenderer`).
- Hypotheses from STRATEGY §3: 4 confirmed, 3 corrected (Easy Place, DataManager persistence, schematic-file material list is synchronous), 0 unverified among the 8 claims checked.
- No source file was modified. No git state-changing command was run.

## Branch / commits (if code)
Not applicable (docs only, no commit made).

## Files changed (owned paths only)
- `docs/enhanced/knowledge/architecture-map.md` (new, 200 lines)
- `docs/enhanced/phases/P00/logs/package-line-counts.txt` (new, raw find/wc output, package totals and grand total)
- `docs/enhanced/phases/P00/agents/cartographer.md` (this report)

## Commands run → results
- Package counts: find + wc -l over each package and the six extra subpackages. Output in `logs/package-line-counts.txt`. Totals: 316 files, 73,085 lines. Top-level rows sum to the same total.
- Grep and read-range checks on `Litematica.java`, `InitHandler.java`, `fabric.mod.json`, `mixins.litematica.json`, `litematica.accesswidener`, `SchematicPlacementManager`, `PlacementManagerDaemonHandler`, `PlacementManagerTaskRebuild`, `ChunkRenderDispatcherLitematica`, `ChunkRenderWorkerLitematica`, `WorldRendererSchematic`, `LitematicaRenderer`, `MixinLevelExtractor`, `SchematicVerifier`, `ClientTickHandler`, `TaskScheduler`, `MaterialList*`, `EasyPlaceUtils`, `WorldUtils`, Easy Place mixins, `DataManager`, `Configs`.
- Mixin list vs source files: `comm` check, one unregistered file found.
- No test suite exists (`src/test` absent), so no test results.
- A temporary comparison file was written to the system temp dir and deleted.

## Evidence
- Hypothesis 1 (sync load): `gui/GuiSchematicLoad.java:247` → `schematic/LitematicaSchematic.java:3295, 2956, 2992, 3008`.
- Hypothesis 2 (daemon threads): `PlacementManagerDaemonHandler.java:40-44` (max = cores/4, min 2), `Configs.java:127` (configured default 2).
- Hypothesis 3 (fake Level): `world/WorldSchematic.java:74`, `world/ChunkSchematic.java:22`, `PlacementManagerTaskRebuild.java:71-97`.
- Hypothesis 4 (render-thread meshing): `WorldRendererSchematic.java:583` → `ChunkRenderDispatcherLitematica.java:84` → `ChunkRenderWorkerLitematica.java:85` → `ChunkRendererSchematicVbo.java:333`. The render hook is `mixin/render/MixinLevelExtractor.java:80`.
- Hypothesis 5 (tick tasks): `SchematicVerifier.java:315`, `ClientTickHandler.java:40`, `MaterialListPlacement.java:55`, `MaterialListAreaAnalyzer.java:37`; schematic-file list computed in `MaterialListSchematic.java:27`.
- Hypothesis 6 (Easy Place): `ClientTickHandler.java:28-35`; `mixin/easyplace/MixinClientPlayerInteractionManager_easyPlace.java:22` gated by `EASY_PLACE_POST_REWRITE` (`Configs.java:84`, default `false`).
- Hypothesis 7 (paste): `SchematicPlacementManager.java:1116, 1124-1146, 1152, 1163`.
- Hypothesis 8 (DataManager): `data/DataManager.java:46-48, 301, 404-413, 636-651`.

## Hypothesis check (verdicts)
| Claim | Verdict |
|---|---|
| Sync load from GUI | confirmed |
| Placement daemon threads | confirmed, with detail (cores/4, min 2) |
| WorldSchematic fake Level + ChunkSchematic | confirmed |
| Mesh build on render thread | confirmed (no worker pool exists in `render/schematic`) |
| Verifier and material lists as client tick tasks | confirmed for verifier, placement and area lists; **corrected** for the schematic-file list (synchronous) |
| Easy Place intercepts `useItemOn` per click | **corrected**: default path is per tick; `useItemOn` injection only with `EASY_PLACE_POST_REWRITE` |
| Paste via commands / Servux / mcfunction | confirmed |
| `DataManager` static per-world JSON | **corrected**: singleton with static accessors; one global JSON plus one per-dimension JSON |

Unverified items in the note: the per-world key inside `StringUtils.getStorageFileName` (MaLiLib), Sodium compatibility path, which caller reaches `updateChunkNow`, and the locking of `SchematicPlacementManager` collections.

## Open questions for the lead
1. Is `mixin/screen/MixinAbstractContainerScreen.java` to be deleted in a cleanup phase (it is commented out and unregistered)? Not changed here.
2. Easy Place: the note assumes the per-tick path is the default. Confirm this is the intended baseline behaviour before P-phases touch Easy Place.
3. Who calls `ChunkRenderDispatcherLitematica.updateChunkNow` (line 166, synchronous rebuild)? Needs a grep of callers in a later pass.

## Risks / follow-ups (register IDs referenced, none created)
- PERF-01, PERF-02, PERF-04, PERF-05, PERF-06, PERF-07, PERF-08 cited in the note.
- ARCH-01, ARCH-03, REL-06, REL-07, SEC-01 cited in the note.
- Hot-file change requests: none (no source edits).
