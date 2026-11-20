# Memory Index

- [eacp repo workflow](eacp-repo-workflow.md) — which CI lanes run and how to reproduce the Linux ones locally
- [Bit-flag literals](bit-flag-literals.md) — flags as 0b0001/0b0010…, hex only for wide masks
- [Prefer less code](prefer-less-code.md) — refactors aim for net fewer lines; report net LOC; direct and dry, never terse names
- [No metric gaming](no-metric-gaming.md) — no aliases/wrappers just to raise CodeScene scores; files ≥9.5 are left alone; fix only below 9.5
- [Finish tasks, unblock yourself](finish-tasks-unblock-yourself.md) — never stop part way to ask 'continue?'; work around blockers
- [eacp PRs need proof](eacp-pr-proof-required.md) — failing-without test or demo app showing the behaviour; description says what was wrong and how to verify
- [Fix needs a failing test](fix-needs-failing-test.md) — every fix PR has a test CI runs that fails without the fix; sanitizer-only proof doesn't count
- [Push freely, PRs with care](push-freely-prs-carefully.md) — push without asking; open draft PRs when clearly wanted; no obvious questions
- [using only in .cpp](using-only-in-cpp.md) — no `using` of any kind in headers
- [User-facing features need a demo](user-facing-features-need-demo.md) — end-user-facing eacp features ship with a demo app shown working on every supported platform
