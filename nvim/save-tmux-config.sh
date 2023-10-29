# Copy the tmux conf from the home dir to this dir 
#

currentDir=$(pwd)
targetFile="$currentDir/.tmux.conf"

echo "$targetFile"

cp ~/.tmux.conf "$targetFile" 
