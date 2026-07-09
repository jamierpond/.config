## Bell Notification

User has `bell` zsh alias triggering system notification/sound. Use when
long-running task done, need user attention/input, finished significant work.

How: run `bell`, sleep 2, then `say` with `<project>, <branch>, <status/task>`.
Don't use `printf '\a'` or other terminal bell methods.

```bash
bell && sleep 2 && say "tamber-web, feature-login, CI now green"
```

Examples: `"tamber-web, fix-auth, tests passed"`, `"dotfiles, main, need your
input"`, `"tamber-api, add-webhooks, build failed"`. Both shell commands, not
Claude Code tools.

