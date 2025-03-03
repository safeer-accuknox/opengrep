# OpenGrep Docker Image

This repository provides a Docker-based setup for running OpenGrep

## Environment Variables

The following environment variables can be set to provide repository and commit metadata:

- `REPOSITORY_URL` - URL of the repository being scanned (optional, fetched from Git if not provided).
- `COMMIT_SHA` - SHA of the commit being scanned (optional, fetched from Git if not provided).
- `COMMIT_REF` - Branch or tag reference of the commit (optional, fetched from Git if not provided).
- `PIPELINE_ID` - CI/CD pipeline ID.
- `JOB_URL` - URL of the job executing the scan.

If `REPOSITORY_URL`, `COMMIT_SHA`, or `COMMIT_REF` are not passed as environment variables, they will be automatically retrieved from the Git repository.

## How It Works

1. It checks if the latest rules need to be updated by comparing the current rules commit SHA with the fetched SHA from the opergrep-rules repository.
2. If it is not the latest, then the container fetches and extracts the latest OpenGrep rules from GitHub.
  2.1 It validates the downloaded rules.
  2.2 If validation is successful, the new rules are used; otherwise, default rules are retained.
4. OpenGrep scans the `/app` directory with the selected rules. (Scans the `/app` directory, ensure proper repository mounting.)
5. Results are saved in `results.json` with metadata appended.

## Usage

To run OpenGrep with Docker:

```bash
      - name: Run OpenGrep Test
        env:
          PIPELINE_ID: "${{ github.run_id }}"
          JOB_URL: "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
        run: |
          docker run --rm -v "$PWD:/app" \
            -e REPOSITORY_URL="$REPOSITORY_URL" \
            -e COMMIT_SHA="$COMMIT_SHA" \
            -e COMMIT_REF="$COMMIT_REF" \
            -e PIPELINE_ID="$PIPELINE_ID" \
            -e JOB_URL="$JOB_URL" \
            safeeraccuknox/demo:opengreptest-1.2
```

## Versions
- Opengrep CLI Version: v1.0.0-alpha.14
- Default Rules: https://github.com/opengrep/opengrep-rules/commits/main/, f1d2b562b414783763fd02a6ed2736eaed622efa 

## Updating Rules in Dockerfile

To ensure the latest rules are used in the Docker image, the build process now:

1. Fetches the latest commit SHA from the OpenGrep rules repository.
2. Compares it with the saved SHA to determine if an update is needed.
3. Download the latest rules if an update is required.
```
curl -L --silent https://api.github.com/repos/opengrep/opengrep-rules/tarball/main | tar -xz -C new-rules --strip-components=1 2>/dev/null
```
4. Removes unnecessary files.
```
rm -rf new-rules/.pre-commit-config.yaml new-rules/stats new-rules/.github 2>/dev/null
```
5. Validates the rules.
```
opengrep scan --metrics=off --validate -f new-rules/ >/dev/null 2>&1
```
6. Updates the commit SHA in the `Dockerfile`.
7. Uses the validated rules in the OpenGrep scan.
```
rm -rf opengrep-rules && mv new-rules opengrep-rules
```