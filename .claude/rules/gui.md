---
paths:
  - "src/main/java/**/gui/**"
  - "src/main/java/**/ui/**"
  - "docs/enhanced/design/**"
---
# GUI rules
- Implement the **approved** designs in `docs/enhanced/design/`; do not redesign in code. Deviations are written up and sent back to the ux-designer.
- Use design tokens and toolkit components only: no hard-coded colours, paddings or sizes in screens.
- Must work at GUI scale 1–4 and in small windows; full keyboard navigation with visible focus; no information conveyed by colour only; no hover-only critical info.
- Never block the client thread: loading, scanning, counting and saving go through the job system with progress and cancel.
- All visible text uses translation keys (`assets/litematica/lang/en_us.json` is a hot file: use a change request).
- Keep the legacy screen reachable behind `ui.legacyScreens` until the parity checklist passes.
- New art is placeholder-only (`*_placeholder.png`) unless a human supplied it. Record the licence of any third-party asset in `docs/enhanced/compat/assets.md`.
- Each new screen gets client game-test screenshots at GUI scales 2 and 3.
