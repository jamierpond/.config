#!/bin/bash
docker pull --platform linux/amd64 archlinux && docker run -it --rm --platform linux/amd64 archlinux
