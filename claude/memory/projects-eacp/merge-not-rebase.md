---
name: merge-not-rebase
description: "updating a PR branch with develop means merging develop in, never rebasing"
metadata:
  node_type: memory
  type: feedback
  originSessionId: fdf2e23b-4561-46a2-883f-363f0eff5ea4
  modified: 2026-11-09T03:25:58.982Z
---

Superseded 2026-11-16: Jamie now wants PR branches rebased onto develop as clean, linear commits that cherry-pick straight onto develop ("keep the commits rebased nicely so they can be cherrypicked over to eacp develop"), force-pushed with lease, and collected on `jp/develop` (see the eacp section of ~/.config/claude/CLAUDE.md).

Earlier rule (2026-11-09), no longer in force: merge develop into the branch, never rebase.
