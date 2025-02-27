#!/bin/bash
set -e

# copy a file from whever we are onto my local machine and play it >:)

input_file="$1"
if [ -z "$input_file" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

sha=$(sha256sum $input_file | awk '{print $1}')
trimmed_sha=$(echo $sha | cut -c1-8)
extension="${input_file##*.}"

ssh_user="jamiepond"
ssh_host="$ssh_user@ssh.pond.audio"
output_file="/Users/$ssh_user/.audiotmp/$trimmed_sha.$extension"

function cp_file {
  scp -o "StrictHostKeyChecking=accept-new" "$input_file" "$ssh_host:$output_file"
}

ssh -q "$ssh_host" [[ -f "$output_file" ]] && echo "File exists on host" || cp_file

ssh -o "StrictHostKeyChecking=accept-new" "$ssh_host" -x "/opt/homebrew/bin/ffplay $output_file"
