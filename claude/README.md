# Claude Code config, shared across machines

- `settings.json` — the repo-managed part of `~/.claude/settings.json`
  (model, subagent model, plugins, no AI attribution on commits/PRs). Merged in,
  repo wins; machine-local keys (theme, voice, …) are left alone.
- `memory/<repo>/` — Claude's auto memory per repo. `<repo>` is the checkout's
  path relative to `$HOME` with `/` → `-` (`projects-Cows`, `eacp`). Claude
  writes to `~/.claude/projects/<slug>/memory/`; `claude-sync` symlinks that
  to here, so memories commit with this repo.
- `memory/.gitignore` — allowlist: only memory for public repos is committed.
  Private-repo memory stays local (still symlinked) and does not sync between
  machines.
- `../private/GLOBAL_AGENTS.private.md` — hostnames, keychain passwords.
  Gitignored, imported from `GLOBAL_AGENTS.md`; copy it to each machine by hand.
- `../GLOBAL_AGENTS.md` → `~/.claude/CLAUDE.md`.
- `../git/hooks/commit-msg` strips AI attribution from every commit.

Run `just claude-sync` (= `bin/scripts/claude-sync`) after cloning, and again
whenever a new repo starts accumulating memory; it migrates anything Claude
wrote locally into `memory/` and links it. Commit `claude/memory` like any
other file; `memory/.gitignore` keeps private-repo memory out.

Why not `autoMemoryDirectory`: in 2.1.288 it replaces the whole path with no
per-repo subdirectory, so one user-scope value would merge every repo's
memory into one index.
