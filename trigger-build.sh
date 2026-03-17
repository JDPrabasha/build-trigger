#!/bin/bash
# Triggers a Choreo build by committing to the buildTest repo via GitHub API.
# Requires GITHUB_TOKEN and optionally GITHUB_REPO env vars.

REPO="${GITHUB_REPO:-JDPrabasha/buildTest}"
BRANCH="main"
FILE_PATH=".build-trigger"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is not set"
  exit 1
fi

API="https://api.github.com/repos/${REPO}/contents/${FILE_PATH}"

# Get current file SHA (if it exists)
RESPONSE=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "${API}?ref=${BRANCH}")

SHA=$(echo "$RESPONSE" | grep '"sha"' | head -1 | sed 's/.*"sha": *"\([^"]*\)".*/\1/')

CONTENT=$(echo -n "Build trigger: ${TIMESTAMP}" | base64)

if [ -n "$SHA" ]; then
  # Update existing file
  PAYLOAD=$(printf '{"message":"trigger build %s","content":"%s","sha":"%s","branch":"%s"}' \
    "$(date -u +%Y%m%d%H%M%S)" "$CONTENT" "$SHA" "$BRANCH")
else
  # Create new file
  PAYLOAD=$(printf '{"message":"trigger build %s","content":"%s","branch":"%s"}' \
    "$(date -u +%Y%m%d%H%M%S)" "$CONTENT" "$BRANCH")
fi

RESULT=$(curl -s -X PUT \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "${API}" \
  -d "${PAYLOAD}")

if echo "$RESULT" | grep -q '"commit"'; then
  echo "Done. Commit pushed to ${REPO} to trigger Choreo build."
else
  echo "Error: Failed to create commit"
  echo "$RESULT"
  exit 1
fi
