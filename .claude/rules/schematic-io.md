---
paths:
  - "src/main/java/**/schematic/**"
  - "src/main/java/**/data/**"
  - "src/main/java/**/materials/**"
  - "src/main/java/**/selection/**"
---
# Schematic data and IO rules
- Format compatibility is sacred: reading and writing of `.litematic` (v7, v6 export), Sponge `.schem` v1–v3, vanilla `.nbt` and Schematica `.schematic` must stay byte- or semantically-equivalent, proven by the golden-file tests in `src/test/resources/corpus/`.
- Writes are atomic: temp file in the same directory → flush + force → atomic move (fallback: replace move) → optional `.bak` rotation. Never truncate the target in place.
- Treat files as untrusted: enforce size, NBT depth, palette size and region-dimension limits with overflow-safe (`long`/`Math.multiplyExact`) arithmetic; produce a validation report, not a crash.
- Every persisted JSON (placements, selections, projects, index, config) carries a schema version and a tested migration.
- Extra metadata (tags, thumbnails, index) goes into sidecar/index files, never into the schematic format.
- Long operations (load, save, convert, count) run as cancellable jobs with progress, off the client thread where snapshot-safe.
