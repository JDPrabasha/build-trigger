#!/bin/bash
# Triggers a Choreo build by making a random commit to the buildTest repo.
# Usage: ./trigger-build.sh [path-to-buildTest-repo]

REPO_PATH="${1:-$HOME/Developer/buildTest}"

if [ ! -d "$REPO_PATH/.git" ]; then
  echo "Error: $REPO_PATH is not a git repo"
  exit 1
fi

cd "$REPO_PATH"

# Update a build trigger file with a timestamp
echo "Build trigger: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > .build-trigger

git add .build-trigger
git commit -m "trigger build $(date -u +%Y%m%d%H%M%S)"
git push origin main

echo "Done. Commit pushed to trigger Choreo build."
