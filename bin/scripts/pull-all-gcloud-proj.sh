#!/usr/bin/env bash
set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/quick-url-gcloud-projects.txt"

echo "Fetching Google Cloud projects..."

# Get all accessible projects
gcloud projects list --format="value(projectId)" > "${OUTPUT_FILE}"

echo "Updated ${OUTPUT_FILE} with $(wc -l < "${OUTPUT_FILE}") projects"