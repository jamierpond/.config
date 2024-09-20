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
alias "nv"="python3 -m venv venv"
alias "cv"="python3 -m venv venv"
alias "act-venv"="source venv/bin/activate"

alias "ta"="tmux attach"
alias "va"="source venv/bin/activate"
alias "gpu"="watch -n 0.5 nvidia-smi"
alias "pgpu"="nvidia-smi --query-compute-apps=pid --format=csv,noheader"


alias "lm"="sh ~/projects/lambda-machine/remote.sh"
alias "vie"="sh ~/projects/lambda-machine/vienna-remote.sh"
alias "ka"="killall"
alias "kaf"="killall -9"

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

function co() {
  git checkout $(git branch -r | fzf | sed "s|origin/||")
  git status
}

function port() {
  port="$1"
  lsof -i tcp:"$port"
}

function npmf() {
  # Extract scripts from package.json
  scripts=$(cat package.json | jq -r '.scripts | to_entries[] | .key + "- " + .value')

  # Use fzf to select a script
  selected=$(echo "$scripts" | fzf --height 40% --border --prompt="Select a script to run: ")

  # Extract the script name (everything before the first dash)
  script_name=$(echo "$selected" | cut -d'-' -f1)

  # Run the selected script
  if [ -n "$script_name" ]; then
      echo "Running: npm run $script_name"
      npm run "$script_name"
  else
      echo "No script selected. Exiting."
  fi
}

function npf() {
  npmf
}



export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
