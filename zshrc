[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if is linux
if [[ "$(uname)" == "Linux" ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

alias ll="ls -alF"
alias la="ls -A"
alias ls='ls -a --color=auto'

alias bwon="shortcuts run \"bw-on\""
alias bwoff="shortcuts run \"bw-off\""

alias cpp-compile="~/.config/bin/scripts/cpp-compile"
alias cppc="~/.config/bin/scripts/cpp-compile"

alias so="source ~/.zshrc"

alias "pipi"="pip install -r requirements.txt"

alias "gpu"="while [ 1 ] ; do nvidia-smi ; sleep 0.5; clear ;  done"

alias ddd="rm -rf ~/Library/Developer/Xcode/DerivedData"
alias smu="git submodule update --init --recursive"

alias "new-venv"="python3 -m venv venv"
alias "act-venv"="source venv/bin/activate"

