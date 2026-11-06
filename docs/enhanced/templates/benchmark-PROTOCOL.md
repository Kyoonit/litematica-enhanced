# Benchmark protocol (filled in by P01; changes need an ADR)

## Machine fingerprint (recorded in every result file)
cpu, gpu+driver, ram, os, java vendor/version, jvm args, mc version, mod list+versions, render distance, gui scale, window size, fork commit, scenario id+version

## Scenarios (versioned in benchmarks/scenarios/)
| ID | Version | Description | Schematic (corpus id) | Camera path / actions | Metrics |
|---|---|---|---|---|---|

## Procedure
1. Fresh game start (or documented warm state) · 2. ≥ 1 warm-up run discarded · 3. ≥ 5 measured runs · 4. JFR recording settings: <file> · 5. Export summary JSON via <script>

## Metrics
frame time p50/p95/p99/max · stutters > 50 ms · time to first render · load time · mesh build time/section · peak + post-GC heap · allocation rate · GC pause total · engine throughput · save time

## Thresholds (REFERENCE §6.2)
Regression: median > +5% or p99 > +10% → fail unless ADR + human approval. Improvement claim: median gain > max(5%, 2×relative IQR), reproduced in 2 sessions.
