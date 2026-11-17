# Codex configuration

`~/.codex` links to this directory. Only configuration and instructions are
tracked; authentication, sessions, plugins, databases and caches stay ignored.

`AGENTS.md` links to `../claude/CLAUDE.md`, so Codex and Claude read the same
global instructions. Repository instructions still apply separately. The shared
file currently includes Claude-specific workflows; tools only available in
Claude remain specific to Claude. Its `@` private-file import is Claude syntax,
so Codex does not automatically expand that import.

After cloning, run from the repo root:

```sh
python3 bin/scripts/codex-config-dir-migrate.py
```

On Windows (Python 3 required):

```powershell
python bin/scripts/codex-config-dir-migrate.py
```

The script moves an existing `~/.codex` here and leaves a directory symlink
(a junction on Windows). It refuses conflicting settings rather than overwriting
them. Resolve any reported conflicts and rerun. Windows uses a hard link for
the shared prompt, avoiding symlink privileges; rerun after a checkout replaces
either instruction file. On macOS/Linux the prompt uses a relative symlink.

Restart Codex after migration. No shell environment override is needed, so GUI
apps and terminals use the same directory. If `CODEX_HOME` is already set to a
different location, remove that override or point it here.
