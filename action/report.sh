#!/usr/bin/env bash
# Runs CodeSpread on the pull request's work and writes the comment, in Markdown, to the file in $1.
set -euo pipefail
body=$1

if [ -z "${CODESPREAD_BASE:-}" ]; then
  echo "::error::CodeSpread needs a base branch: run it on pull_request, or set the base input"
  exit 1
fi
if [ "$(git rev-parse --is-shallow-repository)" = true ]; then
  echo "::error::CodeSpread reads the full history: check out with fetch-depth: 0"
  exit 1
fi

report=$(npx -y "codespread@$CODESPREAD_VERSION" --pending --base "origin/$CODESPREAD_BASE" \
  --limit "$CODESPREAD_LIMIT")
effect=${report%%$'\n\n'*}
page=${report#*$'\n\n'}

{
  echo '<!-- codespread -->'
  echo '### CodeSpread by Brutalist Development'
  echo
  echo '```'
  echo "$effect"
  echo '```'
  echo
  echo '<details><summary>The repository with this pull request merged</summary>'
  echo
  echo '```'
  echo "$page"
  echo '```'
  echo
  echo '</details>'
} > "$body"
