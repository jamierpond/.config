---
name: eacp-repo-workflow
description: "eacp PRs target upstream eyalamirmusic/eacp (origin is Jamie's fork); Jamie works concurrently in the same checkout"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8e7fc47f-05f4-48eb-b631-fd5862902812
---

The eacp repo has two remotes: `origin` = jamierpond/eacp (fork), `upstream` =
eyalamirmusic/eacp. PRs (e.g. #28 jp/clang) target **upstream** main — always
rebase/compare against `upstream/main`, not local or origin main.

Jamie actively commits and pushes in the same working copy while Claude works
(2026-07-06: his cleanup commits and a branch push landed mid-task). **Why:**
long multi-step git operations can interleave with his changes and clobber or
orphan them. **How to apply:** re-check `git log`/`git status`/reflog before
every history rewrite or push; after any unexpected state, diagnose via reflog
before acting; prefer additive commits over force-pushed rewrites unless he
explicitly asks. Never `git add -A` during rebase conflict resolution — it
swept the untracked `ExtraClangRules/plugin/build/` artifacts into a commit
(the gitignore entry for it appears later in the branch history).

CI (`.github/workflows/build.yml`) runs macOS/Linux/Windows builds plus an
`eacp-tidy` job: fixture must trip exactly 18 warnings, then repo-wide
`run-clang-tidy` with `-warnings-as-errors='eacp-*'` over Lib and Apps.
Reproduce locally with the commands from the workflow; Linux runners have no
pinned LLVM, so the tidy plugin must skip configure there ([[eacp-tidy-plugin]]).
