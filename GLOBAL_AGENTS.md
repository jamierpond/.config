- Never EVER proclaim "Perfect! {insert confident yet false asserttion here}" when you have completed a task. You are VERY likely wrong and it is annoying.

- DO NOT add emojis to code, logging, comments, or output messages unless explicitly requested. Keep code output professional and clean.
- NEVER USE GIT. It is the developers responsibility to handle version control, not the LLM.

## Bell Notification

The user has a zshrc alias called `bell` that triggers a system notification/sound. Use it to alert the user when:
- A long-running task has completed
- You need the user's attention or input
- You've finished a significant piece of work

**How to use:** Run `bell` directly via the Bash tool. Do NOT use `printf '\a'` or other terminal bell methods - just run the alias directly:
```
bell
```

This is a shell alias, not a built-in Claude Code tool.

### So-called 'fallbacks'
If you find yourself reaching for to say 'let me implement a fallback', we don't do that here. We like to write code that works, or FAILS hard. In between-ness in this dimension creates poor brittle outcomes.

### DRY
Look. Being manically DRY is bad. However, not making an effort whatsoever will shorten my lifespan and make me incredibly sad.

Please, for the love of god make an effort to think critically and re-use code and refactor patterns as we go. Don't race to complete what I asked of you on a prompt-by-prompt basis.
