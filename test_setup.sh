
if [ -z "$UBUNTU_VERSION" ]; then
  UBUNTU_VERSION="20.04"
fi

export TZ='America/Los_Angeles'

docker run --rm -it \
   -v "$(pwd):/repo" \
   -e DEBIAN_FRONTEND=noninteractive \
   --entrypoint /bin/bash ubuntu:$UBUNTU_VERSION -c \
   "DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y curl sudo && \
   chmod +x /repo/ubuntu-setup.sh && \
   DEBIAN_FRONTEND=noninteractive /repo/ubuntu-setup.sh && \
   exec zsh -c 'source /repo/zshrc && echo \"✅ zshrc sourced!\" && exec zsh'"

