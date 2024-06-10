alias ll="ls -alF"
alias la="ls -A"

alias bwon="shortcuts run \"bw-on\""
alias bwoff="shortcuts run \"bw-off\""

alias cpp-compile="~/.config/bin/scripts/cpp-compile"
alias cppc="~/.config/bin/scripts/cpp-compile"

alias "pipi"="pip install -r requirements.txt"


alias ddd="rm -rf ~/Library/Developer/Xcode/DerivedData"
alias smu="git submodule update --init --recursive"

alias "new-venv"="python3 -m venv venv"
alias "act-venv"="source venv/bin/activate"

if [ -f ~/.zshrc ]; then
   alias so="source ~/.zshrc && source ~/.bashrc"
else
   echo "No zshrc file found"
   alias so="source ~/.bashrc"
fi






