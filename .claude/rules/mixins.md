---
paths:
  - "src/main/java/**/mixin/**"
  - "src/main/resources/mixins.litematica.json"
  - "src/main/resources/*.accesswidener"
  - "src/main/java/**/compat/**"
---
# Mixin and compat rules
- Mixins contain no logic: inject, then call a named hook method in the `mc/` adapter layer.
- One purpose per mixin. Prefix added members with `@Unique` and a project prefix. Prefer MixinExtras injectors (bundled with Fabric Loader) over `@Redirect`/`@Overwrite`. Keep `defaultRequire = 1`.
- Every new or changed mixin updates `docs/enhanced/knowledge/mixin-register.md` in the same commit: target, injection point, purpose, failure impact, covering test.
- `mixins.litematica.json` and the access widener are hot files: change requests only.
- Compat with Sodium, Iris, Voxy and Jade goes through the existing conditional-mixin/compat packages. Never hard-depend on optional mods.
