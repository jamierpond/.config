# Claude Code config, shared across machines

This directory is Claude Code's config dir: shellrc exports
`CLAUDE_CONFIG_DIR=$HOME/.config/claude`, and `~/.claude` and `~/.claude.json`
are symlinks into it for tools and GUI apps that don't read shellrc. Claude
Code also keeps credentials, transcripts, history, plugins and caches here;
`.gitignore` ignores everything except the files below.

- `CLAUDE.md` — global instructions.
- `settings.json` — user settings, the same on every machine (model, subagent
  model, plugins, hooks, tui fullscreen, theme, notifications, no AI
  attribution). Claude Code writes to it when you change a setting in the
  app: commit or revert that diff.
- `memory/<repo>/` — Claude's auto memory per repo. `<repo>` is the checkout's
  path relative to `$HOME` with `/` → `-` (`projects-Cows`, `eacp`). Claude
  writes to `projects/<slug>/memory/`; `claude-sync` symlinks that to here.
- `memory/.gitignore` — allowlist: only memory for public repos is committed.
  Private-repo memory stays local (still symlinked) and does not sync.
- `../private/GLOBAL_AGENTS.private.md` — hostnames, keychain passwords.
  Gitignored, imported from `CLAUDE.md`; copy it to each machine by hand.
- `../git/hooks/commit-msg` strips AI attribution from every commit.

Run `just claude-sync` after cloning, and again whenever a new repo starts
accumulating memory. It runs `bin/scripts/claude-config-dir-migrate` (moves an
existing `~/.claude` and `~/.claude.json` in here and links them back; does
nothing once done), then links each repo's memory.

On macOS the login lives in the Keychain under a name tied to the config dir,
so the first `claude` after migrating asks you to log in again. Over ssh
(no Keychain) and on Linux/Windows it is `.credentials.json` here, which moves
with the directory.

Why not `autoMemoryDirectory`: in 2.1.288 it replaces the whole path with no
per-repo subdirectory, so one user-scope value would merge every repo's
memory into one index.
