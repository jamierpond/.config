#!/bin/bash
echo "Pulling archlinux x86_64..."
docker pull --platform linux/amd64 archlinux
docker run -it --rm --platform linux/amd64 archlinux
