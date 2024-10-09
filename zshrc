[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if is linux
if [[ "$(uname)" == "Linux" ]]; then
    # source /usr/share/doc/fzf/examples/key-bindings.zsh
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
alias c='cd $(find . -maxdepth 1 -type d | fzf)'

alias so="source ~/.zshrc"
alias bso="source ~/.bashrc"
alias "pipi"="pip install -r requirements.txt"
alias "tarls"="tar -tvf"
alias "tls"="tar -tvf"

alias ddd="rm -rf ~/Library/Developer/Xcode/DerivedData"
alias smu="git submodule update --init --recursive"

alias "new-venv"="python3 -m venv venv"
alias "nv"="python3 -m venv venv"
alias "cv"="python3 -m venv venv"
alias "act-venv"="source venv/bin/activate"
alias "nv"="python3 -m venv venv"

alias "ta"="tmux attach"
alias "va"="source venv/bin/activate"
alias "nva"="nv && va"
alias "gpu"="watch -n 0.5 nvidia-smi"
alias "pgpu"="nvidia-smi --query-compute-apps=pid --format=csv,noheader"
alias "rgpu"="pkill wandb && pgpu | xargs -I {} kill -9 {}"
alias "fgpu"="sudo fuser -v /dev/nvidia*"
alias "lm"="sh ~/projects/lambda-machine/remote.sh"
alias "vie"="sh ~/projects/lambda-machine/vienna-remote.sh"
alias "gls"="git ls-files"
alias "ka"="killall"
alias "kaf"="killall -9"
alias "pos"="poetry shell"

# gcloud compute instances list
function gssh() {
  instances=$(gcloud compute instances list)
  instance=$(echo "$instances" | fzf --height 40% --reverse --prompt "Select instance: " --header-lines 1)
  chosen_instance=$(echo "$instance" | awk '{print $1}')
  gcloud compute ssh $chosen_instance
}

function gscp() {
  instances=$(gcloud compute instances list)
  instance=$(echo "$instances" | fzf --height 40% --reverse --prompt "Select instance: " --header-lines 1)
  chosen_instance_ip=$(echo "$instance" | awk '{print $1}')
  gcloud compute scp "$chosen_instance_ip:$1" "$2"
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

# clone from github
function cl() {
  mayk_repos=$(gh repo list mayk-it --json nameWithOwner | jq ".[].nameWithOwner")
  jamie_repos=$(gh repo  list jamierpond --json nameWithOwner | jq ".[].nameWithOwner")
  repo=$(echo $mayk_repos $jamie_repos | fzf --height 40% --reverse --prompt "Select repo: " --header-lines 1)
  # replace double quotes
  repo=$(echo $repo | tr -d '"')
  echo "Cloning $repo"
  gh repo clone "$repo"
}

function npf() {
  npmf
}


# Helper function to handle common operations
function tar_helper() {
    local tar="$1"
    local usage="$2"
    local dest="${3:-$(pwd)}"

    if [ -z "$tar" ]; then
        echo "Usage: $usage"
        return 1
    fi

    if [ ! -f "$tar" ]; then
        echo "File '$tar' does not exist"
        echo "Usage: $usage"
        return 1
    fi

    local file=$(tls "$tar" | awk '{ print $6 }' | fzf)
    echo "$file"
}

function tget() {
    local tar="$1"
    local dest="${2:-$(pwd)}"

    local file="$3"
    if [ -z "$file" ]; then
        file=$(tar_helper "$tar" "tget <tarfile> [destination]" "$dest")
    fi

    if [ $? -eq 0 ]; then
        local base=$(basename "$file")
        local dest_file="$dest/$base"
        echo "Extracting $base"
        command="tar -xvf '$tar' '$file' -C '$dest'"
        eval "$command"
        print -s "$command"
    fi
}

function tcat() {
    local tar="$1"
    local file=$(tar_helper "$tar" "tcat <tarfile>")

    if [ $? -eq 0 ]; then
        command="tar -xOf '$tar' '$file'"
        eval "$command"
        print -s "$command"
    fi
}

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

