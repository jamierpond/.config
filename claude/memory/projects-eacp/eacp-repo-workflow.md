---
name: eacp-repo-workflow
description: "eacp branches and PRs go straight to eyalamirmusic/eacp (never Jamie's fork jamierpond/eacp); Jamie works concurrently in the same checkout"
metadata:
  type: project
---

The eacp checkout has two remotes: `origin` = jamierpond/eacp (Jamie's fork)
and `upstream` = eyalamirmusic/eacp. **Push branches to `upstream`
(eyalamirmusic/eacp) and open PRs there as same-repo branches
(`gh pr create --repo eyalamirmusic/eacp --base develop --head <branch>`).
Never push to the fork or open a PR from it.** Jamie, 2026-10-27: "DONT USE MY
FORK PUSH TO THE NORMAL eyalamirmusic/eacp repo." The default branch is
`develop`; compare and rebase against `upstream/develop`.

**Why:** the fork is a leftover; PRs from it confuse review and downstream pins
(tamber-web's Findeacp.cmake pins eyalamirmusic/eacp).
**How to apply:** `git push upstream <branch>`; a consumer pinning an unmerged
eacp branch pins `eyalamirmusic/eacp` at the sha, marked temporary.

Jamie actively commits and pushes in the same working copy while Claude works.
**Why:** long git operations can interleave with his changes. **How to apply:**
re-check `git log`/`git status`/reflog before any history rewrite or push;
never `git add -A` (it once swept untracked build artifacts into a commit);
prefer additive commits over force-pushes unless he asks.

CI (`.github/workflows/build.yml`) runs macOS, Windows (x64 and ARM64, MSVC and
clang-cl), Linux (three lanes, one on lavapipe), iOS and Android builds. Reproduce
the Linux lanes locally with the `eacp-ci-linux` Docker image and the commands in
CLAUDE.md; `-DEACP_CI_BUILD=ON` reproduces the unity configuration.
