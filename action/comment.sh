#!/usr/bin/env bash
# Puts the Markdown in the file $1 into the pull request's CodeSpread comment, replacing the one from the last run.
set -euo pipefail
body=$1
comments="repos/$GITHUB_REPOSITORY/issues/$PULL_REQUEST/comments"

existing=$(gh api --paginate "$comments" \
  --jq '.[] | select(.body | startswith("<!-- codespread -->")) | .id' | head -n 1)
if [ -n "$existing" ]; then
  gh api --method PATCH "repos/$GITHUB_REPOSITORY/issues/comments/$existing" -F "body=@$body" > /dev/null
else
  gh api --method POST "$comments" -F "body=@$body" > /dev/null
fi
