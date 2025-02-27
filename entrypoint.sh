#!/bin/bash

mkdir -p new-rules

set +e  
curl -L --silent https://api.github.com/repos/opengrep/opengrep-rules/tarball/main | tar -xz -C new-rules --strip-components=1 2>/dev/null
rm -rf new-rules/.pre-commit-config.yaml new-rules/stats new-rules/.github 2>/dev/null

RULES_DIR="default-rules"
if [ -d "new-rules" ] && [ "$(ls -A new-rules 2>/dev/null)" ]; then
    opengrep scan --metrics=off --validate -f new-rules/ >/dev/null 2>&1
    VALIDATION_SUCCESS=$?
    if [ $VALIDATION_SUCCESS -eq 0 ]; then
        RULES_DIR="new-rules"
    fi
fi
set -e  

echo opengrep scan /src -f "$RULES_DIR" --json --output results.json