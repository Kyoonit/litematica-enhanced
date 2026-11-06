# Problem register

Severity: S1 critical (data loss/crash) · S2 major · S3 minor · S4 cosmetic. Confidence: observed | measured | hypothesis.
| ID | Title | Severity | Confidence | Evidence (path:line / result file) | Impact | Proposed action | Phase | Upstream cat. | Status |
|---|---|---|---|---|---|---|---|---|---|
| REL-01 | Non-atomic schematic writes | S1 | observed | LitematicaSchematic.writeToFile → MaLiLib DataFileUtils:69 | Crash during override can corrupt file | Atomic write + .bak | P06 | A (MaLiLib) | open |
