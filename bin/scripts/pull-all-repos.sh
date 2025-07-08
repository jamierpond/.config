#!/usr/bin/env bash
set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/quick-url-github-repos.txt"

echo "Fetching GitHub repositories..."

# Get all repositories for authenticated user and organizations
{
    gh repo list --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner'
    gh repo list mayk-it --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner'
} | sort -u > "${OUTPUT_FILE}"

echo "Updated ${OUTPUT_FILE} with $(wc -l < "${OUTPUT_FILE}") repositories"