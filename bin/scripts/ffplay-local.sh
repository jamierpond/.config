set -e

echo "playing locally"
# copy file to jamiepond@ssh.pond.audio:/home/jamiepond/.audiotmp

input_file="$1"
ssh-keygen -f "/home/jamie/.ssh/known_hosts" -R "ssh.pond.audio"
output_file="/Users/jamiepond/.audiotmp/$(basename $input_file)"

ssh_host="jamiepond@ssh.pond.audio"

# Add the host key automatically on first connection
scp -o "StrictHostKeyChecking=accept-new" "$input_file" $ssh_host:$output_file

# Use the same option for SSH
ssh -o "StrictHostKeyChecking=accept-new" $ssh_host -x "/opt/homebrew/bin/ffplay $output_file"
