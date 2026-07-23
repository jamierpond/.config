# Why use more word when less word do trick?

Seriously. I mean it.

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

## Git use
I monitor all your code and regulary commit your code to git. This way I can
continually monitor your progress. Do not be surprised if the code is commited
to git. This does not mean the code was 'accepted', just acknowledged.

# Writing memories
Generally when asked to write a file to disk, do so in the repo I'm working in.
When writing memories, write it to a readme in the repo. Do not put proprietary
knowledge in Anthropic's walled garden.



