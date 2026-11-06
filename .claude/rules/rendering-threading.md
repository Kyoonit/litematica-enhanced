---
paths:
  - "src/main/java/**/render/**"
  - "src/main/java/**/world/**"
  - "src/main/java/**/scheduler/**"
  - "src/main/java/**/jobs/**"
  - "src/main/java/**/schematic/placement/**"
---
# Rendering and threading rules
- The client thread (also the render thread) owns GUI, input, packets, client-world reads, GPU uploads and every mutation of placement/selection state. Single writer.
- Workers (shared `LitematicaExecutors` pool only, never `new Thread`) read **immutable snapshots**. Never pass a live `Level`, `WorldSchematic`, `ChunkSchematic` or client world to a worker without an ADR plus a stress test.
- Results return through the client-thread completion queue, drained under a frame budget derived from measured frame time (no hard-coded 60 FPS).
- Every job is cancellable and reacts to lifecycle events (disconnect, dimension change, world unload, exit).
- Every threaded path has a kill-switch config flag that restores the legacy path. Test both paths.
- Any change here needs before/after benchmark files (`docs/enhanced/benchmarks/results/`) produced with the protocol. No numbers without raw files.
- Check compat with Sodium, Iris and Voxy paths (`compat/**`, conditional mixins) whenever you touch the render pipeline.
