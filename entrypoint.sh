#!/bin/bash

# Load Git environment variables
source /set_git_env.sh

# Default directory for rules (fallback in case new rules fail validation)
RULES_DIR="/rules/default-rules"

mkdir -p /rules/new-rules

############## Download and extract the latest OpenGrep rules from GitHub: START ############## 
## Fallback added as default-rules
# set +e  
curl -L --silent https://api.github.com/repos/opengrep/opengrep-rules/tarball/main | tar -xz -C /rules/new-rules --strip-components=1 2>/dev/null
rm -rf /rules/new-rules/.pre-commit-config.yaml /rules/new-rules/stats /rules/new-rules/.github 2>/dev/null

if [ -d "/rules/new-rules" ] && [ "$(ls -A /rules/new-rules 2>/dev/null)" ]; then
    opengrep scan --metrics=off --validate -f /rules/new-rules/ >/dev/null 2>&1
    VALIDATION_SUCCESS=$?
    if [ $VALIDATION_SUCCESS -eq 0 ]; then
        RULES_DIR="/rules/new-rules"
    fi
fi
# set -e  
############## Download and extract the latest OpenGrep rules from GitHub: END ############## 

# Run opengrep with CMD arguments passed from Docker
echo opengrep scan . -f "$RULES_DIR" --json --output results.json "$@"
opengrep scan . -f "$RULES_DIR" --json --output results.json "$@"

if [[ -f results.json ]]; then
  # Append metadata to the results JSON file using jq
  jq --arg repo "$REPO_NAME" \
    --arg sha "$COMMIT_SHA" \
    --arg ref "$COMMIT_REF" \
    --arg run_id "$PIPELINE_ID" \
    --arg repo_url "$REPOSITORY_URL" \
    --arg repo_run_url "$JOB_URL" \
    '. + {
      repo: $repo,
      sha: $sha,
      ref: $ref,
      run_id: $run_id,
      repo_url: $repo_url,
      repo_run_url: $repo_run_url
    }' results.json > tmp.json && mv tmp.json results.json
fi