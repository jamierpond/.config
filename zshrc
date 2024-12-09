[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# if is linux
if [[ "$(uname)" == "Linux" ]]; then
    # source /usr/share/doc/fzf/examples/key-bindings.zsh
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
fi

PS1='%F{green}%n@%m%f:%F{blue}%~%f$ '

alias ll="ls -alF"
alias la="ls -A"
alias ls='ls -a --color=auto'
alias dec2hex="printf '%x\n'"
alias d2h="printf '%x\n'"

alias dls="lsblk"

alias bwon="shortcuts run \"bw-on\""
alias bwoff="shortcuts run \"bw-off\""
alias t="tmux"

alias cpp-compile="~/.config/bin/scripts/cpp-compile"
alias cppc="~/.config/bin/scripts/cpp-compile"

function sz() {
  if [ -z "$1" ]; then
    du -csh *
    return
  fi

  du -csh "$1"
}

# jump directory
function jd() {
  files=$(git ls-files)
  echo "$files"
  dirs=$(xargs -n 1 dirname <<< "$files" | sort -u)
  echo "===================="
  echo "$dirs"
  dir=$(echo "$dirs" | fzf --reverse --prompt "Select dir: " --header-lines 1)
  cd "$dir"
}

# validate json
function jv() {
  if [ -z "$1" ]; then
    echo "Usage: jv <file> to validate a json file."
    return
  fi
  cat "$1" | jq .
}

function c() {
  while true; do
    current_dir=$(pwd)
    dirs=$(find . -maxdepth 1 -type d)
    dir=$(echo "$dirs" | fzf --reverse --prompt "Select dir: " --header-lines 1)
    if [ -z "$dir" ]; then
      break
    fi
    cd "$dir"
  done
}

function tsh() {
  python -i -c "import torch; t = torch.load('$1'); print('Shape:', t.shape)"
}

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
alias "fgpu"="sudo fuser -v /dev/nvidia*"
alias "kgpu"="fgpu | grep . | tr ' ' '\n' | xargs kill -9"
#
# mercilessly kill all gpu/ai processes
alias "rgpu"="pkill wandb && pgpu | xargs -I {} kill -9 {} && kgpu"

alias "lm"="sh ~/projects/lambda-machine/remote.sh"
alias "vie"="sh ~/projects/lambda-machine/vienna-remote.sh"
alias "gls"="git ls-files"
alias "ka"="killall"
alias "kaf"="killall -9"
alias "pos"="poetry shell"

# Function to select an instance
function select_instance() {
  instances=$(gcloud compute instances list)
  instance=$(echo "$instances" | fzf --height 40% --reverse --prompt "Select instance: " --header-lines 1)
  if [ -z "$instance" ]; then
    return 1
  fi
  echo "$instance" | awk '{print $1}'
}

# Function to execute and save a command
function execute_command() {
  local command="$1"
  # if mac use print -s
  # print -s "$command"
  history -s "$command"

  eval "$command"
}

function e() {
  git_files=$(git ls-files)
  shell_scripts=$(echo "$git_files" | grep -E '\.sh$')
  script=$(echo "$shell_scripts" | fzf --reverse --prompt "Select script: ")
  if [ -z "$script" ]; then
    return
  fi
  shell="/bin/bash"
  echo "$shell $script"
  execute_command "$shell $script"
}

function gssh() {
  chosen_instance=$(select_instance) || return
  execute_command "gcloud compute ssh $chosen_instance"
}

function gstart() {
  chosen_instance=$(select_instance) || return
  execute_command "gcloud compute instances start $chosen_instance"
}

function gstop() {
  chosen_instance=$(select_instance) || return
  execute_command "gcloud compute instances stop $chosen_instance"
}

function gscp() {
  chosen_instance=$(select_instance) || return
  gcloud compute scp "$chosen_instance:$1" "$2"
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
  repo=$(echo $mayk_repos $jamie_repos | fzf --height 40% --reverse --prompt "Select repo: " --header-lines 0)
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

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

set -o vi

# =============================================================================
# bindkey -v
# export KEYTIMEOUT=1

# # Change cursor with support for inside/outside tmux
# function _set_cursor() {
#     if [[ $TMUX = '' ]]; then
#       echo -ne $1
#     else
#       echo -ne "\ePtmux;\e\e$1\e\\"
#     fi
# }
#
# function _set_block_cursor() { _set_cursor '\e[2 q' }
# function _set_beam_cursor() { _set_cursor '\e[6 q' }
#
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
#       _set_block_cursor
#   else
#       _set_beam_cursor
#   fi
# }
# zle -N zle-keymap-select
# # ensure beam cursor when starting new terminal
# precmd_functions+=(_set_beam_cursor) #
# # ensure insert mode and beam cursor when exiting vim
# zle-line-init() { zle -K viins; _set_beam_cursor }
