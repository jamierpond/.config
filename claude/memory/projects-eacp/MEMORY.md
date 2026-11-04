# Memory Index

- [eacp repo workflow](eacp-repo-workflow.md) — push branches and PRs straight to eyalamirmusic/eacp, never the fork; Jamie commits concurrently in the same checkout; never `git add -A`
- [Never merge PRs](never-merge-prs.md) — never merge to eacp develop (Eyal's repo); "merge back" means rebase onto develop; nowhere else without "merge it" on that PR
- [Ubuntu VM](ubuntu-vm.md) — Parallels Ubuntu 26.04 ARM64 on the Mac, `ssh ubuntu-vm` (parallels@10.211.55.4), 2 cores/3 GB, docker+cmake+ninja+g++
- [Windows 11 VM](windows-vm.md) — Parallels Windows 11 ARM64 on the Mac, `ssh windows-vm` (jamiepond@10.211.55.3); the only ARM64 Windows box, for the ARM64 lane issues
- [No hand-rolled utilities](no-hand-rolled-utilities.md) — no file-local string/path/hex/time helpers; eacp Core or tamber_common, add to eacp when missing; reuse audit in every brief and a reviewer pass before showing Jamie
- [Crash reporting handoff](crash-reporting-handoff.md) — 2026-10-27 state: PRs (eacp #177 + docs pending; tamber-web #1407/#1408/#1409 open), worktrees, agents, ingest contract, open dv threads, running e2e stack, next steps
- [Test fixes stay out of framework](test-fixes-stay-out-of-framework.md) — a zoo/test/demo fix never lands in Lib/eacp code every consumer runs; "harmless" is not a reason
- [Write plain technical prose](write-plain-technical-prose.md) — concrete thing first, then what it does, then why; short paragraphs; no aphoristic openers, bold labels or stacked assertions
- [Questions are not instructions](questions-are-not-instructions.md) — "kinda think"/"why is this" dv notes get a factual reply and stay open; no code change
- [Miro macro over custom reflect](miro-macro-over-custom-reflect.md) — hand-written reflect() only where a field serialises differently from its value
- [PR description style](pr-description-style.md) — value, interface code block, ≤4 sentences of how, honest gaps, 2 lines testing, 1 line stack position; never the default verbose style
