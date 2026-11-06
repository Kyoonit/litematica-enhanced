---
paths:
  - "src/main/java/**/network/**"
  - "src/main/java/**/mixin/easyplace/**"
  - "src/main/java/**/mixin/network/**"
  - "src/main/java/**/util/EasyPlace*.java"
  - "src/main/java/**/util/WorldUtils.java"
  - "src/main/java/**/scheduler/tasks/**"
  - "src/main/java/**/util/PickBlockUtils.java"
  - "src/main/java/**/util/InventoryUtils.java"
---
# Network and server-fairness rules
- Classify every behaviour: F0 visual/local, F1 assists one user-initiated action, F2 explicit server mutation (commands/Servux) with confirmation, F3 autonomous world interaction (**forbidden**).
- Causality rule: every gameplay packet sent by Litematica code is caused by an input event in the same/previous tick or by a user-confirmed F2 job. Keep the dev-mode cause log and its game test green.
- Never exceed vanilla interaction cadence. No hidden packets, no brand spoofing, no anti-cheat evasion.
- Honour the server feature policy (once implemented) and permission errors. F2 jobs are cancellable and show the command count and affected volume before starting.
- Never change Servux/Syncmatica wire formats unilaterally. Validate and limit all incoming payloads.
- Escape SNBT and strings in generated commands and `.mcfunction` files, with fuzz tests.
