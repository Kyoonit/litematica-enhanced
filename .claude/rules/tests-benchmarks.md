---
paths:
  - "src/test/**"
  - "src/gametest/**"
  - "docs/enhanced/benchmarks/**"
---
# Test and benchmark rules
- Deterministic tests only (fixed seeds, no wall-clock assertions, no network). Flaky tests are quarantined with an issue ID, never deleted silently.
- Never weaken an assertion or regenerate a golden file to make a test pass. Golden-file updates happen in their own commit with a justification and the phase prompt's or an ADR's approval.
- Test-only dependencies must be listed in an ADR. Fabric API is allowed in the gametest source set only.
- Benchmarks follow `docs/enhanced/benchmarks/PROTOCOL.md`: machine fingerprint, warm-up, ≥ 5 runs, median + IQR, raw JSON committed, scenario version recorded. Never compare across machines or settings.
