#!/usr/bin/env bash
# Claude Code statusLine - robbyrussell-style + context info
# Lives in ~/.config/bin/ for version control

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
basename_cwd=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')
session_name=$(echo "$input" | jq -r '.session_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // ""')

# ANSI color codes
bold_green='\033[1;32m'
bold_red='\033[1;31m'
cyan='\033[0;36m'
bold_blue='\033[1;34m'
red='\033[0;31m'
yellow='\033[0;33m'
magenta='\033[0;35m'
bold_magenta='\033[1;35m'
dim='\033[2m'
reset='\033[0m'

# --- Git portion ---
git_part=""
if git_ref=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null); then
  if [[ -n $(git -C "$cwd" status --porcelain 2>/dev/null) ]]; then
    git_part=" $(printf "${bold_blue}git:(${red}${git_ref}${bold_blue}) ${yellow}✗${reset}")"
  else
    git_part=" $(printf "${bold_blue}git:(${red}${git_ref}${bold_blue})${reset}")"
  fi
fi

# --- Context window bar ---
ctx_part=""
if [[ -n "$used_pct" ]]; then
  pct_int=${used_pct%.*}
  # 10-block bar
  filled=$(( pct_int / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  for (( i=0; i<filled; i++ )); do bar+="█"; done
  for (( i=0; i<empty; i++ )); do bar+="░"; done
  # Color: green < 60%, yellow < 85%, red >= 85%
  if (( pct_int >= 85 )); then
    bar_color="$red"
  elif (( pct_int >= 60 )); then
    bar_color="$yellow"
  else
    bar_color="$bold_green"
  fi
  ctx_part=" $(printf "${dim}ctx:${reset}${bar_color}${bar}${reset}${dim}${pct_int}%%${reset}")"
fi

# --- Vim mode indicator ---
vim_part=""
if [[ "$vim_mode" == "NORMAL" ]]; then
  vim_part=" $(printf "${bold_magenta}[N]${reset}")"
elif [[ "$vim_mode" == "INSERT" ]]; then
  vim_part=" $(printf "${magenta}[I]${reset}")"
fi

# --- Model ---
model_part=""
if [[ -n "$model" ]]; then
  model_part=" $(printf "${dim}${model}${reset}")"
fi

# --- Session name ---
session_part=""
if [[ -n "$session_name" ]]; then
  session_part=" $(printf "${dim}\"${session_name}\"${reset}")"
fi

printf "${bold_green}➜${reset}  ${cyan}%s${reset}%s%s%s%s%s" \
  "$basename_cwd" \
  "$git_part" \
  "$ctx_part" \
  "$vim_part" \
  "$model_part" \
  "$session_part"
