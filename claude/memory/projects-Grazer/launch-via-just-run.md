---
name: launch-via-just-run
description: "Launch Rudder/Grazer/CowTerm dev builds only via the repo's `just run`, never hand-rolled open/launch commands"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 03cc098b-b6e9-4c44-9dde-a4dc85f0453d
  modified: 2026-10-14T06:49:15.197Z
---

Always launch dev builds with the repo's `just run` (or other just recipes), never by `open`-ing the bundle or improvised commands — and tell subagents the same.

**Why:** `just run` quits the old instance and resets stale Accessibility (TCC) grants. Hand-launching left an old Rudder running and stale grants around; Jamie called this out as a repeated mistake.

**How to apply:** In every brief that builds/runs Rudder, Grazer or CowTerm, require `just run`; if a recipe lacks something, fix the recipe instead of working around it. Never rebuild an app bundle in place while it runs (revokes its grant mid-session, preceded a system-wide input freeze). See [[no-readme-writes]].
