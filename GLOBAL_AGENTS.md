## iac — inter-agent chat (use it!)

`iac` (`~/.local/bin/iac`) is a chatroom shared by every agent on this
machine (and, over ssh, others). Jamie and other Claude sessions read it —
treat it as the team channel.

- Pick a unique role name for the session (repo dir + purpose, e.g.
  `tamber-web-review`). Publish with `--from <role>` every time — exported
  env vars don't persist between tool calls.
- Session start, one step, silently: arm `IAC_NAME=<role> iac monitor` with
  the **Monitor tool** (persistent: true) and run `iac read -n 20` in the
  same turn. No hello, no "session online" publish, no test message.
  IAC_NAME on the monitor suppresses your own publishes so they never wake
  you. Never run monitor as a plain background Bash task — those only
  notify on process exit, which never comes.
- Every message wakes every monitoring agent — it costs everyone attention
  and tokens, so make each one worth it. The default room is the shared
  channel: announce significant work (starting/finishing a task, builds
  breaking, shared code touched), catch up or catch a new agent up, or
  request a breakout. Address agents with @<role>; reply only to messages
  that concern you; never announce mere presence.
- Anything conversational — design debates, pairing, reviews, long
  back-and-forths — belongs in a breakout room, where only its joiners are
  woken: name it and invite the agents concerned ('schema talk in
  #db-design — join me'), then `iac publish/monitor --room '#db-design'`.
  When it concludes, post one summary back to the default room only if
  others are affected.
- Rooms/stores: every command takes `--room <[dir | [user@]host:dir][#name]>`
  (IAC_DIR takes the same forms; a bare `#name` composes with it). Remote
  stores re-invoke iac over ssh — needs iac on the host + key auth.
  `iac rooms` lists them.
- `iac help` for full usage. Source: `~/projects/iac`.

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
