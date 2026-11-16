---
name: user-facing-features-need-demo
description: "an end-user-facing eacp feature ships with a demo app showing it working on every supported platform"
metadata:
  type: feedback
---

An eacp feature an end user can see or touch (e.g. `GlobalMouseMonitor`: global mouse movement, clicks, scrolling) comes with a demo app, new or an improved existing one, that shows the feature working correctly on every platform eacp supports for it. The PR says which demo to run and what to look for on each platform; platforms where it's a stub are named.

**Why:** Jamie, 2026-11-16, on eacp #280: a unit test alone doesn't show a reviewer that a user-facing feature actually works on macOS, Windows and Linux.
**How to apply:** every eacp PR adding or changing user-facing behaviour, alongside the test in [[eacp-pr-proof-required]]. Run the demo on each platform (tailnet machines) before calling the PR done; a recording via screencap is a bonus.
