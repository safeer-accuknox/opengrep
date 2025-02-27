#!/bin/bash

# Skip execution if all variables are already set
if [[ -n "$REPOSITORY_NAME" && -n "$REPOSITORY_URL" && -n "$COMMIT_SHA" && -n "$COMMIT_REF" ]]; then
    echo "All environment variables are already set. Skipping detection."
    exit 0
fi

# Allow Git to access the repo inside a container
git config --global --add safe.directory "$(pwd)"

# Ensure we are inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not inside a Git repository. Please set the following environment variables:"
    echo "REPOSITORY_NAME, REPOSITORY_URL, COMMIT_SHA and COMMIT_REF"
    exit 1
fi

# Set variables only if they are not already set
export REPOSITORY_NAME=${REPOSITORY_NAME:-$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)")}
export REPOSITORY_URL=${REPOSITORY_URL:-$(git config --get remote.origin.url 2>/dev/null)}
export COMMIT_SHA=${COMMIT_SHA:-$(git rev-parse HEAD 2>/dev/null)}
export COMMIT_REF=${COMMIT_REF:-$(git symbolic-ref -q HEAD || git rev-parse --short HEAD 2>/dev/null)}

# Extract the repository name from the REPOSITORY_URL
export REPO_NAME=$(basename $(dirname "$REPOSITORY_URL"))/$(basename -s .git "$REPOSITORY_URL")