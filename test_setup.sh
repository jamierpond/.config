docker run --rm -it \
  -v "$(realpath ./ubuntu-setup.sh):/tmp/ubuntu-setup.sh" \
  --entrypoint /bin/bash ubuntu:20.04 -c \
  "apt-get update && apt-get install -y curl sudo && chmod +x /tmp/ubuntu-setup.sh && /tmp/ubuntu-setup.sh"

