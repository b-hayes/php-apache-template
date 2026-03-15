#!/bin/bash
set -e

TEMPLATE_GIT_URL="https://github.com/b-hayes/php-apache-template.git"
TEMPLATE_DIRS=("$HOME/repo/php-apache-template" "$HOME/repo/b-hayes/php-apache-template" "../php-apache-template")
TEMPLATE_DIR=""

# Check for directory argument
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    TEMPLATE_DIR="$1"
    echo "Using specified directory: $TEMPLATE_DIR"
    # If the specified directory is a git repo, exclude git-ignored files
    if [ -d "$TEMPLATE_DIR/.git" ]; then
      echo "Files to be copied from $TEMPLATE_DIR (excluding .git, README.md, and git-ignored):" >&2
      git -C "$TEMPLATE_DIR" ls-files --others --ignored --exclude-standard --directory | sed "s|^|IGNORED: |" >&2
      files_to_copy=$(git -C "$TEMPLATE_DIR" ls-files --cached --others --exclude-standard | grep -vE '^README.md$')
      echo "$files_to_copy" >&2
      read -p "Are you sure you want to copy these files and overwrite existing ones? (y/N): " confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
      fi
      # Copy only tracked and untracked (not ignored) files, excluding .git and README.md
      (cd "$TEMPLATE_DIR" && tar --exclude=.git --exclude=README.md -cf - $files_to_copy) | tar -xf -
    else
      echo "Files to be copied from $TEMPLATE_DIR:" >&2
      find "$TEMPLATE_DIR" -type f ! -path "$TEMPLATE_DIR/.git/*" ! -name 'README.md' | sed "s|^$TEMPLATE_DIR/||" >&2
      read -p "Are you sure you want to copy these files and overwrite existing ones? (y/N): " confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
      fi
      # Copy files from specified directory
      rsync -av --exclude='.git' --exclude='README.md' "$TEMPLATE_DIR"/ ./
    fi
    if git diff --quiet; then
      echo "No changes detected."
    else
      git --no-pager diff
    fi
    exit 0
  fi
fi

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

# Pull latest changes from master
cd "$TEMPLATE_DIR"
git checkout master
git pull origin master
cd - > /dev/null

# Copy files from template to current project (excluding .git and README.md)
rsync -av --exclude='.git' --exclude='README.md' "$TEMPLATE_DIR"/ ./

# Show git diff
if git diff --quiet; then
  echo "No changes detected."
else
  git --no-pager diff
fi
