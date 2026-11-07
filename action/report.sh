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

# The report names the base as it is given, so give it the branch's own name rather than origin/<base>.
git show-ref --quiet --verify "refs/heads/$CODESPREAD_BASE" ||
  git branch --quiet "$CODESPREAD_BASE" "origin/$CODESPREAD_BASE"

report=$(npx -y "codespread@$CODESPREAD_VERSION" --pending --base "$CODESPREAD_BASE" --limit "$CODESPREAD_LIMIT")
effect=${report%%$'\n\nSpread '*}
page="Spread ${report#*$'\n\nSpread '}"

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
