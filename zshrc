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

alias ddd="rm -rf ~/Library/Developer/Xcode/DerivedData"
alias smu="git submodule update --init --recursive"

alias "new-venv"="python3 -m venv venv"
alias "act-venv"="source venv/bin/activate"

alias "ta"="tmux attach"
alias "va"="source venv/bin/activate"
alias "gpu"="watch -n 0.5 nvidia-smi"
alias "pgpu"="nvidia-smi --query-compute-apps=pid --format=csv,noheader"


alias "lm"="sh ~/projects/lambda-machine/remote.sh"
alias "vie"="sh ~/projects/lambda-machine/vienna-remote.sh"

# gcloud compute instances list
function gssh() {
  instances=$(gcloud compute instances list)
  instance=$(echo "$instances" | fzf --height 40% --reverse --prompt "Select instance: " --header-lines 1)
  chosen_instance=$(echo "$instance" | awk '{print $1}')
  gcloud compute ssh $chosen_instance
}

# clone from github
function cl() {
  repo=$((gh repo list mayk-it --json nameWithOwner | jq ".[].nameWithOwner" && gh repo  list jamierpond --json nameWithOwner | jq ".[].nameWithOwner") | fzf )
  repo=$(echo $repo | tr -d '"')
  echo "Cloning '$repo'"
  gh repo clone $repo
}

