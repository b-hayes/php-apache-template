#!/bin/bash

set -e

TEMPLATE_GIT_URL="https://github.com/b-hayes/php-apache-template.git"
# Possible locations for the template directory based on my usual workflows
TEMPLATE_DIRS=("$HOME/repo/php-apache-template" "$HOME/repo/b-hayes/php-apache-template" "../php-apache-template")
TEMPLATE_DIR=""

# Find all files tracked or untracked but not ignored by git, excluding README.md
FILES_TO_UPDATE=( $(git ls-files --others --exclude-standard --cached | grep -v -i '^README.md$') )

# Determine possible template directories
for dir in "${TEMPLATE_DIRS[@]}"; do
  if [ -d "$dir/.git" ]; then
    TEMPLATE_DIR="$dir"
    break
  fi
done
if [ -z "$TEMPLATE_DIR" ]; then
  TEMPLATE_DIR="${TEMPLATE_DIRS[0]}"
  git clone "$TEMPLATE_GIT_URL" "$TEMPLATE_DIR"
fi

# Copy updated files
for file in "${FILES_TO_UPDATE[@]}"; do
  src_file="$(pwd)/$file"
  dest_file="$TEMPLATE_DIR/$file"
  mkdir -p "$(dirname "$dest_file")"
  cp -v "$src_file" "$dest_file"
done

# Commit and push changes
cd "$TEMPLATE_DIR"

# Get current folder name for branch
CURR_FOLDER_NAME=$(basename "$(git rev-parse --show-toplevel)")
BRANCH_NAME="update-from-$CURR_FOLDER_NAME"

git fetch origin
if git ls-remote --exit-code --heads origin "$BRANCH_NAME" > /dev/null; then
  git checkout "$BRANCH_NAME"
  git pull origin "$BRANCH_NAME"
else
  git checkout -b "$BRANCH_NAME"
fi

git add .

# Show staged changes and confirm before committing
if ! git diff --cached --quiet; then
  echo -e "\033[0;32mThe following files are staged for commit:\033[0m" >&2
  git diff --cached --name-status | sed $'s/^/\033[0;32m/;s/$/\033[0m/' >&2
  default_msg="Update from downstream project"
  echo -e "\033[1;33mEnter commit message (default: '$default_msg'):\033[0m" >&2
  read -e -i "$default_msg" commit_msg
  commit_msg=${commit_msg:-$default_msg}
  git commit -m "$commit_msg"
  PUSH_OUTPUT=$(git push --set-upstream origin "$BRANCH_NAME" 2>&1)
  # Look for PR link in push output and open if present
  PR_LINK=$(echo "$PUSH_OUTPUT" | grep -oE 'https://github.com/[^ ]+/pull/new/[^ ]+')
  if [ -n "$PR_LINK" ]; then
    if command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$PR_LINK" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then
      open "$PR_LINK" >/dev/null 2>&1 &
    elif command -v explorer.exe >/dev/null 2>&1; then
      explorer.exe "$PR_LINK" >/dev/null 2>&1 &
    else
      echo "Please open: $PR_LINK"
    fi
  fi
else
  echo "No changes to commit."
fi