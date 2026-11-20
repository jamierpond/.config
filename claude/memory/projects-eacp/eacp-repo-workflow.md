---
name: eacp-repo-workflow
description: "eacp CI lanes and how to reproduce the Linux ones locally"
metadata:
  type: project
---

CI (`.github/workflows/build.yml`) runs macOS, Windows (x64 and ARM64, MSVC and
clang-cl), Linux (three lanes, one on lavapipe), iOS and Android builds. Reproduce
the Linux lanes locally with the `eacp-ci-linux` Docker image and the commands in
CLAUDE.md; `-DEACP_CI_BUILD=ON` reproduces the unity configuration.
