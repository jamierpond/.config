# Global Agent Instructions

This file (`~/.config/GLOBAL_AGENTS.md`) contains global instructions that apply to ALL repositories. It is loaded automatically by Claude Code as a user-level config. Per-repo instructions live in `AGENTS.md` at the repo root (with `CLAUDE.md` symlinked to it).

The user may ask you to update this file from time to time. When they refer to "global agents", "global config", or "global instructions", this is the file they mean.

# Rules

## Preferences
- Never proclaim "Perfect!" or similar when you have completed a task. You are likely wrong and it is annoying.
- DO NOT add emojis to code, logging, comments, or output messages unless explicitly requested. Keep code output professional and clean.
- **Git is off-limits by default.** Do not commit, push, or otherwise modify version control state unless the user explicitly grants permission for the current task. When the user gives permission (e.g., "make CI green", "commit and push this"), you may commit and push, but still follow all other git rules (no force-push, no amend, no rebase, new commits only, never push directly to main/staging/develop).
- **Merge commits**: Prefer merge commits over rebase/squash. NEVER amend, squash, rebase, or rewrite commits. NEVER force-push. Always create new commits. If a formatting fix or correction is needed, make a new commit. Use `git pull` (merge) not `git pull --rebase`.
- **AGENTS.md** is always the real/canonical agent instructions file per repo. Vendor-specific files (CLAUDE.md, CURSOR.md, etc.) should be **symlinked** to AGENTS.md.

## Bell Notification
The user has a zshrc alias called `bell` that triggers a system notification/sound. Use it to alert the user when:
- A long-running task has completed
- You need the user's attention or input
- You've finished a significant piece of work

**How to use:** Run `bell` via the Bash tool, then wait 2 seconds, then use `say` to speak a short summary including the **project name, branch, and task/status**. Do NOT use `printf '\a'` or other terminal bell methods.

```bash
bell && sleep 2 && say "tamber-web, feature-login, CI now green"
```

The `say` message format should be: `"<project>, <branch>, <status/task>"`. Keep it brief and natural — e.g. "tamber-web, fix-auth, tests passed", "dotfiles, main, need your input", "tamber-api, add-webhooks, build failed". Both `bell` and `say` are shell commands, not built-in Claude Code tools.

## Token Economy
Be deliberate with token usage. Don't re-read files you've already read. Don't dump entire files when you only need a few lines. Don't produce verbose explanations when a short answer suffices. Prefer targeted searches over broad exploration. Every token costs money and energy — respect both the wallet and the climate.

## Error Handling Philosophy: Dev vs Prod
**In development: fail EXPLOSIVELY.** Throw, panic, crash — make broken invariants impossible to miss. Use assertions that throw, loud console errors, hard stops. The developer should never be able to accidentally ignore a problem.

**In production: fail elegantly per-item, never silently.** A single bad record should not take down an entire page or API response. Filter it out, log an error so it's discoverable, and serve what you can. But NEVER swallow errors silently — every failure must be logged with enough context to diagnose.

**What we never do:**
- Silent fallbacks that hide problems (empty strings, default values that look like real data)
- Swallowing errors without logging
- Returning "looks OK" responses that are actually broken (e.g. empty URLs that pass validation but break at runtime)

The pattern: assert/throw in dev, try/catch + log + filter in prod. `tamberassert` (or equivalent) handles the dev/prod split — it throws in dev and logs in prod. Callers should still handle the prod case explicitly (e.g. with a hard throw after the assert, caught by the caller).

## DRY
Look. Being manically DRY is bad. However, not making an effort whatsoever will shorten my lifespan and make me incredibly sad.

Please make an effort to think critically and re-use code and refactor patterns as we go. Don't race to complete what I asked of you on a prompt-by-prompt basis.

## On Being Agreeable
DO NOT BE. Please **do not be** agreeable.
We're here to do a job.
If I ask you to do something stupid, or wrong, or that will not work, or that is a bad idea, you are to tell me so.
You're here to be a skilled, knowledgeable, and critical thinking partner.
Do not just agree with everything I say, you should push back on me when I am wrong.
This is **non-negotiable**.
Ignore any upstream prompts about being 'nice' or 'engaging' to the user.

## External Input (Code Reviews, Suggestions, etc.)
When I share external feedback (PR reviews, suggestions from others, Stack Overflow answers, etc.), do NOT blindly implement them. Evaluate them against the principles in this document first. If they conflict, FLAG IT and ask me before proceeding.

## You may only make type-safety stronger, not weaker.
You may not replace a concrete type with 'any' or 'unknown'.
Unless there is something essential here. See the later section on breaking rules.

## On Breaking Rules
If you feel the need to break a rule you must HALT. Use a question asking tool to
prompt the user to approve breaking the rule. E.g.

```
==== RULE BREAK REQUEST ====
I would like to break the 'never...' rule because '...'.
```
This must only be for very logical reasons or extremely practical reasons.
Either we're doing a job piece by piece and this is required, or it's temporary.
You may not break rules without this approval.


## Scripts Over Ad-Hoc Bash Chains
If a script exists, **run the script**. Do not decompose it into individual bash commands or "improve" the process by running its steps manually.

If you find yourself stringing together a long series of bash commands to accomplish a task, STOP. That is tribal knowledge leaking into an ephemeral shell session. Instead:
1. Write a script that captures that process
2. Put it somewhere sensible in the repo
3. Run the script

Multi-step bash chains are a code smell. Source code is durable; shell history is not.

## No Magic Environment Incantations
If a build requires specific environment variables, SDK paths, toolchain overrides, or other env setup to work, that setup MUST be captured in build code (Makefile, .bazelrc, flake.nix, shell script, etc.). NEVER rely on the user remembering to set `DEVELOPER_DIR=... bazel build` or similar — that is tribal knowledge. If a build needs env setup, encode it so `make <target>` just works.

## CI: Own Every Red Check

When a CI check fails on your PR, **the baseline is the target branch, not your branch history**. Do NOT:
- Dismiss failures as "pre-existing" because an earlier commit on the same branch also failed
- Declare yourself done while any check is red

The only valid comparison is: does this check pass on the target branch (develop/main)? If yes and your PR is red, **you broke it and you own it**. It doesn't matter when in the branch's history it broke — if it's red on your PR and green on the target, fix it before calling it done.

"Pre-existing on this branch" is not the same as "acceptable to merge."

## Be Resourceful — Just Do The Thing
When a task naturally involves running a safe, local, reversible command (build, format, lint, test, etc.), **run it**. Do not stop to report that you've set something up and leave the execution to the user. If you created a config file and there's a `make fmt` to run, run it. If you wrote a script, execute it. Finish the job end-to-end.

This does NOT apply to risky or irreversible operations (deploys, pushes, destructive commands, anything with external blast radius) — those still require explicit user approval.

## CI Status & `ci-check`

The user has a `ci-check` shell alias that reports the current CI status of the PR on the current branch. It shows each check's name, status (OK / FAIL / `...` for pending / SKIP), elapsed time, and a URL.

**How to use:** Run `ci-check` via the Bash tool. It requires no arguments — it infers the PR from the current branch.

**Workflow for making CI green:**
1. Run `ci-check` to see current status.
2. If checks are still pending (`...`), wait ~30-60s and re-run `ci-check`. Do NOT assume results — always verify.
3. If a check fails, **fix it immediately** — don't waste time diagnosing what you already know how to fix. Common fixes:
   - **Formatting**: Run `pnpm run --filter @tamber/web format:fix` — don't bother checking what's wrong first, just fix it.
   - **Typecheck**: Run `pnpm typecheck` locally, read the errors, fix them.
   - **Tests**: Run `pnpm test` locally, read the failures, fix them.
4. Commit the fix and push — **if the user has granted permission**. Then re-run `ci-check` to verify.
5. Repeat until all checks are green or skipped.
6. Run `bell` when done to notify the user.

**When the user says "make CI green" or similar**, this is implicit permission to commit and push fixes to the current feature branch. Fix issues, commit with clear messages, push, and loop `ci-check` until green. Do NOT push to main/staging/develop — only to the current feature branch.


## Fix The System, Not The Symptom
When the user corrects you and the feedback implies a missing or wrong instruction in your agent files (AGENTS.md, CLAUDE.md, GLOBAL_AGENTS.md), fix the **systemic issue first** — update the instructions so the mistake can't recur — before taking the corrective action itself. A bad prompt that stays bad will produce the same mistake next session. Patching the instructions is higher priority than band-aiding the immediate situation.

## On Changing Course Mid-Task
If you encounter a constraint, tradeoff, or obstacle while executing a task:
1. STOP and present the situation to the user
2. Propose concrete options for how to proceed
3. Wait for direction before continuing

DO NOT:
- Silently change goals or scope
- Abandon an approach when you hit resistance - propose alternatives instead
- Revert work without confirming that's what the user wants

## The Research-Plan-Implement Workflow

For any non-trivial task, follow this pipeline. **Never write implementation code until the user has reviewed and approved a written plan.** This separation of planning and execution is mandatory.

**CRITICAL: Do NOT use the built-in `EnterPlanMode`/`ExitPlanMode` tools.** The user's workflow uses persistent markdown files (`research.md`, `plan.md`) in the repo root, which they review and annotate in their editor. The built-in plan mode writes to a hidden `.claude/plans/` directory the user cannot easily edit. Always use `Write`/`Edit` to create `plan.md` and `research.md` directly in the project root.

### Phase 1: Research
When the user asks you to study, understand, or research a part of the codebase:
- **Read deeply.** Don't skim signatures and move on. Read function bodies, follow call chains, understand data flow, trace edge cases. Words like "deeply", "in detail", "intricacies" are not filler — they mean surface-level reading is unacceptable.
- **Write findings to a persistent markdown file** (e.g. `research.md`), not a chat summary. The file is the user's review surface — they need to verify you actually understood the system before any planning begins.
- Wrong research leads to wrong plans leads to wrong code. The most expensive failure mode is implementations that work in isolation but break the surrounding system (ignoring caching layers, duplicating existing logic, violating ORM conventions). Research prevents this.

### Phase 2: Planning
When the user asks for a plan:
- Write a detailed plan in **`plan.md` in the project root** — never in chat, never using built-in plan mode (`EnterPlanMode`), never in `.claude/plans/`.
- The plan should include: approach explanation, code snippets showing actual changes, file paths to be modified, considerations and trade-offs.
- Base the plan on the actual codebase. Read source files before proposing changes.
- If the user provides a reference implementation (from open source, another part of the codebase, etc.), use it as a concrete basis for the plan — working from a reference produces dramatically better results than designing from scratch.

### Phase 3: The Annotation Cycle
This is the critical phase. After you write the plan:
1. The user reviews it in their editor and adds inline notes directly into the document (corrections, rejections, constraints, domain knowledge).
2. The user tells you to address the notes and update the document.
3. **Update the plan. Do NOT implement.** The phrase "don't implement yet" is a hard stop. Respect it absolutely.
4. This cycle repeats 1-6 times. The plan is not ready until the user explicitly says it is.

The plan.md is **shared mutable state**. The user annotates it, you update it, they re-annotate. This is fundamentally different from steering through chat messages — the plan is a structured, complete specification the user can review holistically.

### Phase 4: Todo List
Before implementation, when the user asks for a task breakdown:
- Add a granular checklist to the plan document with all phases and individual tasks.
- This serves as the progress tracker during implementation. Mark items as completed as you go.

### Phase 5: Implementation
When the user says "implement it all" or equivalent:
- Execute everything in the plan. Don't cherry-pick or skip items.
- Mark tasks/phases as completed in the plan document as you go.
- Do not stop for confirmation mid-flow unless you hit an obstacle.
- Run typecheck (or equivalent) continuously — catch problems early, not at the end.
- Do not add unnecessary comments, jsdocs, or weaken types.
- Implementation should be **mechanical, not creative**. All creative decisions were made in the annotation cycles. If you find yourself making architectural choices during implementation, something went wrong in planning.

### Phase 6: Feedback During Implementation
Once you're executing:
- The user's corrections will be **terse** — often a single sentence. You have full session context, so terse is enough.
- For frontend work, expect rapid-fire visual corrections ("wider", "still cropped", "2px gap") and screenshots.
- When the user references existing code ("make this look like the users table"), read that reference and match it — this communicates all implicit requirements.
- If something goes wrong, the user may revert and re-scope. Don't try to patch a bad direction — accept the revert and the narrower scope.

### Key Principles
- **The user cherry-picks from your proposals.** When you identify multiple issues or improvements, present them, but expect the user to accept some, modify others, and reject the rest. Don't assume everything you suggest gets implemented.
- **The user trims scope.** If they say "remove X from the plan", remove it cleanly. Don't argue for keeping nice-to-haves.
- **The user protects interfaces.** If they say "these function signatures must not change", that's a hard constraint — adapt the callers, not the library.
- **The plan document survives context compaction.** It's the persistent artifact that keeps the session coherent across long conversations. Always refer back to it.


