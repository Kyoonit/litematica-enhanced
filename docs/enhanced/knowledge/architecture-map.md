# Subsystem: Architecture map — last verified at commit 64e74592f631cfa5b084bedb0eda5dac8a3b3cb8 (2026-11-06)

## Purpose
Map of the Litematica Enhanced code base at the baseline commit: packages and sizes, entry points, the main runtime flows with `path:line`, and a check of the as-is hypotheses in `docs/enhanced/STRATEGY.md` §3 (lines 84-121).
Source root: `src/main/java/fi/dy/masa/litematica/`. Raw counts: `docs/enhanced/phases/P00/logs/package-line-counts.txt`.
Every `path:line` below was produced by a grep or a line-range read at this commit. Items marked "unverified" were not checked.

## Package map (`.java` files, total lines; subpackages are included in their parent)

Command used (Git Bash, from repo root):
```
B=src/main/java/fi/dy/masa/litematica
find $B -maxdepth 1 -name '*.java' | wc -l; find $B -maxdepth 1 -name '*.java' -exec cat {} + | wc -l
for d in $(find $B -mindepth 1 -maxdepth 1 -type d | sort); do
  echo "$(find "$d" -name '*.java' | wc -l) files $(find "$d" -name '*.java' -exec cat {} + | wc -l) lines $d"; done
for s in render/schematic schematic/placement schematic/container schematic/verifier gui/widgets mixin; do
  d=$B/$s; echo "$(find "$d" -name '*.java' | wc -l) files $(find "$d" -name '*.java' -exec cat {} + | wc -l) lines $d"; done
find $B -name '*.java' | wc -l; find $B -name '*.java' -exec cat {} + | wc -l
```
Output saved to `docs/enhanced/phases/P00/logs/package-line-counts.txt`.

| Package | Files | Lines | Role (one line) |
|---|---|---|---|
| (root: Litematica, InitHandler, Reference) | 3 | 124 | mod entry and init |
| command | 1 | 137 | `PmCommand` client command |
| compat | 6 | 361 | Iris, Voxy, Jade, ModMenu, mixin plugin |
| config | 2 | 801 | `Configs`, `Hotkeys` |
| data | 4 | 2,145 | `DataManager`, `SchematicHolder`, `EntityDataManager`, `CachedTagManager` |
| event | 5 | 1,312 | input, render, world-load, server listeners |
| gui | 49 | 10,956 | screens (includes gui/widgets below) |
| gui/widgets | 21 | 3,664 | widgets (subset of gui) |
| interfaces | 6 | 356 | interfaces |
| materials | 20 | 4,392 | material lists |
| mixin | 53 | 2,032 | Mixins (52 registered, see below) |
| network | 2 | 1,010 | Servux client packets |
| render | 51 | 12,136 | renderer (includes render/schematic) |
| render/schematic | 38 | 8,991 | chunk meshing, VBOs, GPU upload (subset of render) |
| scheduler | 24 | 4,334 | client/server task scheduler and tasks |
| schematic | 39 | 17,381 | model, formats, placement, verifier (includes subpackages) |
| schematic/placement | 14 | 5,115 | placements, daemon threads, placement tasks |
| schematic/container | 6 | 941 | dense block-state storage |
| schematic/verifier | 2 | 1,146 | `SchematicVerifier` |
| selection | 7 | 2,087 | area selections |
| tool | 2 | 187 | tool modes |
| util | 34 | 11,321 | utilities (Easy Place, paste, placing helpers) |
| world | 8 | 2,013 | `WorldSchematic`, `ChunkSchematic`, `ProtoChunkSchematic` |
| **Total** | **316** | **73,085** | recursive, counted once |

Rows overlap (`gui`, `render`, `schematic` include subpackages). The top-level rows alone sum to 316 files.

## Entry points

| Item | Location |
|---|---|
| fabric.mod.json: `main` entrypoint `fi.dy.masa.litematica.Litematica` | `src/main/resources/fabric.mod.json:25-27` |
| fabric.mod.json: `modmenu` entrypoint `ModMenuImpl` | `src/main/resources/fabric.mod.json:28-30`; class `compat/modmenu/ModMenuImpl.java:7` |
| fabric.mod.json: mixin config reference | `src/main/resources/fabric.mod.json:32-34` |
| fabric.mod.json: access widener reference | `src/main/resources/fabric.mod.json:35` |
| Main mod class | `Litematica.java:13` (`onInitialize` at `:18`) |
| Init handler (MaLiLib `InitializationHandler`) | registered at `Litematica.java:22`; class `InitHandler.java:24`, `registerModHandlers` at `:27` |
| Compat init called from main class | `Litematica.java:20` (`IrisCompat.register`, `IrisCompat.java:16`), `:21` (`VoxyCompat.register`, `VoxyCompat.java:13`) |
| Mixin config | `src/main/resources/mixins.litematica.json`: package `:3`, plugin `:4` (`LitematicaMixinConfigPlugin.java:9`) |
| Mixins, common | 23 entries, lines `:7-31` |
| Mixins, client | 29 entries, lines `:32-62` |
| Mixins, server | none (`:63`) |
| Mixin source files not registered | 1: `mixin/screen/MixinAbstractContainerScreen.java:3` is fully commented out |
| Access widener | `src/main/resources/litematica.accesswidener:2-10`: 1 field and 9 methods, all on `net/minecraft/client/renderer/block/FluidRenderer` |
| Config registration | `InitHandler.java:29` (`ConfigManager.registerConfigHandler`); `Configs.java:38` (`implements IConfigHandler`) |
| Config load / save | `Configs.java:469` (`loadFromFile`), `:509` (`saveToFile`), `:538` (`load`) |
| Hotkey lists | `config/Hotkeys.java:92` (`HOTKEY_LIST`); `Configs.java:238` (Generic), `:342` (Visuals) |
| Hotkey / keybind registration | `event/InputHandler.java:39` (`addKeysToMap`), `:58-63` (`addHotkeys`); `InitHandler.java:45-47` registers keybind, keyboard and mouse handlers |
| Input key/mouse callbacks | `InitHandler.java:63` calls `KeyCallbacks.init` (`event/KeyCallbacks.java:39`) |
| Render callbacks | `InitHandler.java:49-51` (`RenderHandler`, `event/RenderHandler.java:28`) |
| Server listener | `InitHandler.java:53` (`event/ServerListener.java:7`) |
| Client tick | `InitHandler.java:55-57` (`scheduler/ClientTickHandler.java:12`, `EntityDataManager`, `PlacementManagerDaemonHandler.INSTANCE`) |
| World load | `InitHandler.java:59-61` (`event/WorldLoadListener.java:25`) |
| Server tick | `mixin/server/MixinMinecraftServer.java:18-23` runs `TaskScheduler.getInstanceServer().runTasks()` |
| Render hook | `mixin/render/MixinLevelExtractor.java:29` (`@Mixin`), `:62` (`extract`), `:70` (`piecewisePrepare`), `:80` (`piecewiseUpdate`) |

## Main flows

**(a) Load a schematic file → SchematicHolder**
1. `GuiSchematicLoad.actionPerformedWithButton` (`gui/GuiSchematicLoad.java:202`), on the client thread
2. `LitematicaSchematic.createFromFile(dir, name)` (`schematic/LitematicaSchematic.java:3295`, via `:3289`), called at `GuiSchematicLoad.java:247`
3. `LitematicaSchematic.readFromFile(type)` (`LitematicaSchematic.java:2956`)
4. `LitematicaSchematic.readDataFromFile` (`:2992`) → `DataFileUtils.readCompoundDataFromNbtFile` (`:3008`, MaLiLib)
5. `readFromData(nbt)` (`:2977`; the Litematica branch)
6. `SchematicHolder.addSchematic` (`data/SchematicHolder.java:57`), called at `gui/GuiSchematicLoad.java:275`
7. Optional placement: `SchematicPlacement.createFor` (`gui/GuiSchematicLoad.java:286`) → `SchematicPlacementManager.addSchematicPlacement` (`schematic/placement/SchematicPlacementManager.java:460`)
Alternative entry: `SchematicHolder.getOrLoad` (`data/SchematicHolder.java:30`, `createFromFile` at `:47`).

**(b) Create a placement → SchematicPlacementManager → daemon → WorldSchematic**
1. `SchematicPlacementManager.addSchematicPlacement` (`SchematicPlacementManager.java:460`) → `addTouchedChunksFor` (`:626`)
2. `markChunkForRebuild(int cx, int cz)` (`:856`) → `PlacementManagerDaemonHandler.INSTANCE.addTask(new PlacementManagerTaskRebuild(...))` (`:859`)
3. Per tick: `SchematicPlacementManager.onClientTick` (`:152`) drains `pendingTasks` into the daemon (`:163`)
4. `PlacementManagerDaemonHandler.addTask` (`schematic/placement/PlacementManagerDaemonHandler.java:255`, `synchronized`) → `queueRebuild` / `deferredQueue`
5. `PlacementManagerDaemonHandler.ensureThreadsAreAlive` (`:389`, from `onClientTick` at `:362`) starts the thread pool
6. `PlacementManagerDaemonExecutor.run` (`PlacementManagerDaemonExecutor.java:136`) → `processTask` (`:222`) → `task.run()`
7. `PlacementManagerTaskRebuild.run` (`PlacementManagerTaskRebuild.java:27`) runs the lambda from `buildTask` (`:33`)
8. `new ProtoChunkSchematic(new ChunkSchematic(worldSchematic, pos))` (`PlacementManagerTaskRebuild.java:71`)
9. `WorldPlacingUtils.placeToProtoChunk` per enabled placement (`:82`, defined at `util/WorldPlacingUtils.java:50`)
10. `worldSchematic.getChunkSource().replaceChunk(...)` (`:88`), then `scheduleChunkRenders` (`:97`) to hand the chunk to the renderer
`WorldSchematic` is a `Level` (`world/WorldSchematic.java:74`). Chunks are `ChunkSchematic extends LevelChunk` (`world/ChunkSchematic.java:22`). The world is created by `SchematicWorldHandler.createSchematicWorld` (`world/SchematicWorldHandler.java:65`) with the renderer supplier at `:18`.

**(c) Render: WorldRendererSchematic → dispatcher → mesh build → upload**
1. `MixinLevelExtractor.extract` (`mixin/render/MixinLevelExtractor.java:62`) calls `LitematicaRenderer.piecewisePrepare` (`render/LitematicaRenderer.java:200`, `:70` of the mixin) → `WorldRendererSchematic.setupTerrain` (`render/LitematicaRenderer.java:229`; `render/schematic/WorldRendererSchematic.java:422`)
2. Same mixin, `piecewiseUpdate` (`LitematicaRenderer.java:249`, mixin `:80`) → `WorldRendererSchematic.updateChunks` (`LitematicaRenderer.java:256`; `WorldRendererSchematic.java:578`)
3. `ChunkRenderDispatcherLitematica.runChunkUploads(finishTimeNano)` (`WorldRendererSchematic.java:583`; `render/schematic/ChunkRenderDispatcherLitematica.java:68`)
4. Inside it: `renderWorker.processTask(generator)` (`ChunkRenderDispatcherLitematica.java:84`) → `ChunkRenderWorkerLitematica.processTask` (`ChunkRenderWorkerLitematica.java:34`) → `ChunkRendererSchematicVbo.rebuildChunk` (`ChunkRenderWorkerLitematica.java:85`; `ChunkRendererSchematicVbo.java:333`)
5. Upload: `PendingUpload.uploadTask.run()` in the same `runChunkUploads` loop; `uploadChunkBlocks` (`ChunkRenderDispatcherLitematica.java:226`) returns a `ListenableFuture`; `ChunkRenderGpuUploader.java:26` is the GPU side.
The dispatcher has no thread of its own. The only executor in `render/schematic` is `MoreExecutors.directExecutor()` (`ChunkRenderWorkerLitematica.java:233`). `ChunkRenderDispatcherSchematic.java:46` asserts `RenderSystem.assertOnRenderThread()`.

**(d) Schematic verifier**
1. `GuiSchematicVerifier` (`gui/GuiSchematicVerifier.java:462`) → `SchematicVerifier.startVerification` (`schematic/verifier/SchematicVerifier.java:300`)
2. `TaskScheduler.getInstanceClient().scheduleTask(this, 10)` (`SchematicVerifier.java:315`)
3. Each client tick: `ClientTickHandler.onClientTick` (`scheduler/ClientTickHandler.java:15`) → `TaskScheduler.runTasks` (`ClientTickHandler.java:40`, `TaskScheduler.java:53`)
4. `SchematicVerifier.execute` (`SchematicVerifier.java:287`) → `verifyChunks`, `checkChangedPositions`
`SchematicVerifier extends TaskBase` (`SchematicVerifier.java:42`).

**(e) Material lists**
- Schematic file list: `MaterialListSchematic` constructor calls `reCreateMaterialList()` synchronously (`materials/MaterialListSchematic.java:27`, body at `:32`). No tick task.
- Placement list: `MaterialListPlacement.reCreateMaterialList` (`materials/MaterialListPlacement.java:55`) schedules `TaskCountBlocksPlacement` on the client scheduler, interval 20.
- Area list: `MaterialListAreaAnalyzer.reCreateMaterialList` (`materials/MaterialListAreaAnalyzer.java:37`) schedules `TaskCountBlocksArea`, interval 20.
- Both are `TaskCountBlocksBase` subclasses in `scheduler/tasks/`.

**(f) Easy Place**
- Per tick (default path): `ClientTickHandler.java:28-35`. If `EASY_PLACE_POST_REWRITE` is on, `EasyPlaceUtils.easyPlaceOnUseTick` (`util/EasyPlaceUtils.java:124`); otherwise `WorldUtils.easyPlaceOnUseTick(mc)` (`util/WorldUtils.java:695`).
- Mixins: `MixinClientPlayerInteractionManager_easyPlace.useItemOn` HEAD injection (`mixin/easyplace/MixinClientPlayerInteractionManager_easyPlace.java:22`) runs only when `EASY_PLACE_MODE` and `EASY_PLACE_POST_REWRITE` are both on (`:25-26`). `performUseItemOn` injection at `:53`. `MixinMinecraft_easyPlace` hooks `startUseItem` (`:18`, `:48`) and `handleKeybinds` (`:36`). `MixinBlockItem_easyPlace.getPlacementState` (`mixin/easyplace/MixinBlockItem_easyPlace.java:29`).
- `EASY_PLACE_POST_REWRITE` defaults to `false` (`config/Configs.java:84`).

**(g) Paste (commands / Servux / mcfunction)**
Entry: `SchematicPlacementManager.pastePlacementToWorld(placement, changedBlocksOnly, printMessage, mc)` (`SchematicPlacementManager.java:1096`). Creative mode is required (`:1098`).
1. `PASTE_TO_MCFUNCTION` on (`:1116`, default `false`, `config/Configs.java:116`): confirmation `GuiConfirmAction` (`:1118-1120`) → `PasteToCommandsListener.onActionConfirmed` (`:1081`) schedules `TaskPasteSchematicSetblockToMcfunction` on the client scheduler (`:1084-1085`).
2. Else, if not singleplayer or `PASTE_USING_COMMANDS_IN_SP` (`:1122`): Servux if `EntityDataManager.hasServuxServer()` and `PASTE_USING_SERVUX` (`:1124-1125`, default `true`, `Configs.java:119`), which sends `ServuxLitematicaPacket.ResponseC2SStart` via `ServuxLitematicaHandler.encodeClientData` (`:1146`). Otherwise `TaskPasteSchematicPerChunkCommand` on the client scheduler (`:1152`).
3. Singleplayer direct: `TaskPasteSchematicPerChunkDirect` on the server scheduler (`:1163`).
Task classes: `scheduler/tasks/TaskPasteSchematicPerChunk*.java`, `TaskPasteSchematicSetblockToMcfunction.java`.

**(h) Persistence**
- Global data JSON: `DataManager.load` (`data/DataManager.java:301`, file from `getCurrentStorageFile(true)`), `DataManager.save` (`:355-360`).
- Per-dimension JSON: `DataManager.savePerDimensionData` (`:404-413`) writes placements, selections and entity data; `loadPerDimensionData` (`:415`).
- Storage path: `getCurrentConfigDirectory` (`:519-521`) = config dir + `litematica`; file name from `getCurrentStorageFile` (`:636-651`) via `StringUtils.getStorageFileName` (`:650`, MaLiLib; the per-world key is unverified).
- Config file: `Configs.saveToFile` (`config/Configs.java:509`); MaLiLib `ConfigManager` handles the file itself (unverified).

## Hypothesis check (STRATEGY §3, lines 84-121)

| # | Claim | Verdict | Evidence / correction |
|---|---|---|---|
| 1 | Sync load from GUI (`LitematicaSchematic.createFromFile`) | **confirmed** | `gui/GuiSchematicLoad.java:247`, `schematic/LitematicaSchematic.java:3295, 2956, 2992`. Decompress, parse and convert run on the calling (client) thread, no async path. See PERF-04. |
| 2 | Placement daemon threads | **confirmed, detail** | `schematic/placement/PlacementManagerDaemonHandler.java:40-44`: max = cores/4, min 2 (`:24`). Configured default 2 (`config/Configs.java:127`). Thread map built at `:62-77`. Tasks queued at `:255`. |
| 3 | `WorldSchematic` fake Level + `ChunkSchematic` | **confirmed** | `world/WorldSchematic.java:74` (`extends Level`); `world/ChunkSchematic.java:22` (`extends LevelChunk`); created on the daemon in `PlacementManagerTaskRebuild.java:71-97`. |
| 4 | Mesh build on the render thread | **confirmed** | `ChunkRenderWorkerLitematica.java:85` → `ChunkRendererSchematicVbo.java:333`, called from `WorldRendererSchematic.java:583` on the render hook (`MixinLevelExtractor.java:80`). No worker threads in `render/schematic`. This is PERF-01. |
| 5 | Verifier and material lists as client tick tasks | **confirmed, corrected for one list** | Verifier: `SchematicVerifier.java:315` → `ClientTickHandler.java:40`. Placement and area lists: `MaterialListPlacement.java:55`, `MaterialListAreaAnalyzer.java:37`. Correction: the schematic-file list is computed synchronously (`MaterialListSchematic.java:27`). PERF-07. |
| 6 | Easy Place intercepts `useItemOn` per click | **corrected** | Default path is per tick (`ClientTickHandler.java:28-35`). The `useItemOn` HEAD injection (`MixinClientPlayerInteractionManager_easyPlace.java:22`) only runs with `EASY_PLACE_POST_REWRITE` on (`Configs.java:84`, default `false`). Other hooks: `performUseItemOn` (`:53`), `startUseItem` (`MixinMinecraft_easyPlace.java:48`). |
| 7 | Paste via commands / Servux / mcfunction | **confirmed** | `SchematicPlacementManager.java:1116` (mcfunction), `:1124-1146` (Servux), `:1152` (commands), `:1163` (singleplayer direct). |
| 8 | `DataManager` static per-world JSON | **corrected** | `DataManager` is a singleton (`data/DataManager.java:46-48`) with static accessors. Its per-world managers are instance fields (`:64-68`). Persistence is one global JSON (`:301`) plus one per-dimension JSON (`:404`). The static fields hold flags and tool state (`:54-62`). |

## Threading (owner thread of each mutable structure)

| Structure / work | Owner thread | Evidence |
|---|---|---|
| GUI, schematic load and save, screens | client (render-less) thread | `GuiSchematicLoad.java:202` |
| Client tick: Easy Place, verifier, material and paste command tasks, daemon kick-off | client tick | `ClientTickHandler.java:15-40` |
| Placement tick queue (`pendingTasks`) | client tick | `SchematicPlacementManager.java:152-163` |
| Placement daemon: `ChunkSchematic` build and `WorldSchematic.replaceChunk` | daemon pool threads | `PlacementManagerDaemonExecutor.java:136, 222`; `PlacementManagerTaskRebuild.java:71-97` |
| Daemon queues | `synchronized` `addTask` / `getNextTask` / `hasTasks` plus a `ReentrantLock` | `PlacementManagerDaemonHandler.java:35, 255, 285, 312` |
| Chunk mesh build and dispatch queue (`queueChunkUpdates`) | render thread | `ChunkRenderDispatcherLitematica.java:68-84`, `:166` |
| Chunk upload (`queueChunkUploads`) | render thread | `ChunkRenderDispatcherLitematica.java:68-118` |
| Server scheduler | server tick | `MixinMinecraftServer.java:23` |

Cross-thread reads and writes: daemon writes `WorldSchematic` chunks while the render thread reads chunks for meshing, and the client tick reads them for the verifier. No lock is shown on those reads. Whether `SchematicPlacementManager`'s collections are synchronised is unverified. See PERF-08.

## Invariants & assumptions
- All placement-chunk tasks go through `PlacementManagerDaemonHandler.addTask` (`SchematicPlacementManager.java:163, 228, 859`; `PlacementManagerDaemonHandler.java:356`).
- Chunk meshes are built only in `runChunkUploads`, which only runs from `updateChunks` (`WorldRendererSchematic.java:583`) and `updateChunkNow` (`ChunkRenderDispatcherLitematica.java:166`). Who calls `updateChunkNow` is unverified.

## Known problems (register IDs from STRATEGY)
- PERF-01: mesh build on the render thread (`ChunkRenderWorkerLitematica.java:85`).
- PERF-02: frame budget defaults to unlimited (`renderThreadNoTimeout`); not re-checked here.
- PERF-04: synchronous schematic load (`GuiSchematicLoad.java:247`, `LitematicaSchematic.java:3295`).
- PERF-05: data held several times (`schematic/container/*`, `world/ChunkSchematic.java`, GPU meshes).
- PERF-06: verifier allocations (`SchematicVerifier.java`).
- PERF-07: analysis tasks run on the client tick (`ClientTickHandler.java:40`, `MaterialListPlacement.java:55`).
- PERF-08: placement daemon thread pool, thread-safety undocumented (`PlacementManagerDaemonHandler.java`).
- ARCH-01: global static state; `DataManager` and singletons (`data/DataManager.java:46-68`).
- ARCH-03: `WorldSchematic` is a fake `Level` with fake chunks (`world/WorldSchematic.java:74`).
- REL-06: lifecycle edge cases across dimension change (`PlacementManagerDaemonHandler`).
- REL-07: Easy Place air-click behaviour (`util/EasyPlaceUtils.java`, `util/WorldUtils.java:695`).
- SEC-01: `.mcfunction` generation (`scheduler/tasks/TaskPasteSchematicSetblockToMcfunction.java`).

## Tests covering it
None. There is no `src/test` directory at this commit.

## Gotchas for future agents
- The Easy Place `useItemOn` mixin is inactive by default. Changes to `useItemOn` do nothing unless `EASY_PLACE_POST_REWRITE` is on.
- `MixinAbstractContainerScreen` is fully commented out (`mixin/screen/MixinAbstractContainerScreen.java:3`). It is not in the config.
- `DataManager` statics and the daemon run on different threads. Do not assume the statics are thread-safe.
- `render`, `gui` and `schematic` counts include subpackages. Do not re-add subpackage rows.
- Sodium is referenced in `mixin/client/MixinOptions.java` (unverified beyond grep).

Last verified at commit 64e74592f631cfa5b084bedb0eda5dac8a3b3cb8 (2026-11-06)
