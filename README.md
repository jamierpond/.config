# Hello this is my config

Remember to manually add the files you're adding to the .gitignore.
We by default keep all files ignored for security and keeping the git repo clean.

## Zsh Setup

This config uses a **native zsh setup without oh-my-zsh** for fast startup (~0.3s).

### Modular configs:
- `prompt.zsh` - robbyrussell-style prompt with git status
- `vi-mode.zsh` - vi-mode with cursor shape changes
- `completion.zsh` - native zsh completion system

### Shell scripts:
Functions have been extracted to standalone scripts in `bin/scripts/` with descriptive names.
Short aliases in `zshrc` point to these scripts (e.g., `mf` -> `makefile-target-fzf`).

### Performance:
- nvm, pyenv, and openclaw are lazy-loaded (only initialized when first used)
- Startup time: ~0.3s (down from ~11s with oh-my-zsh)

## MacOS Notes
- Remember to set the key repeat time to max and the key repeat start time to max (max fast!)
- Make sure to tell iterm2 that it needs to look in ~/.config/iterm2 for its config
- You need to manually download and install JetBrains Mono at the moment
