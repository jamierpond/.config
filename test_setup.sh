docker run --rm -it --entrypoint /bin/bash ubuntu:22.04 -c \
  -e "CI=true" \
  "apt-get update && apt-get install -y curl sudo && curl -fsSL https://pond.audio/setup | bash"
