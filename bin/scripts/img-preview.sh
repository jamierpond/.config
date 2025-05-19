#!/bin/bash
set -ex

# copy a file from whever we are onto my local machine and play it >:)
ssh_user="jamiepond"
hostname="me.pond.audio"

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

ssh_host="$ssh_user@$hostname"
output_file="/Users/$ssh_user/.imgtemp/$trimmed_sha.$extension"


function cp_file {
  scp "$input_file" "$ssh_host:$output_file"
}

ssh -q "$ssh_host" [[ -f "$output_file" ]] && echo "File exists on host" || cp_file

ssh "$ssh_host" -x "open -a Preview $output_file"

