#!/bin/sh

_SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$_SCRIPT_DIR/../output/output"

shldn_print_header "Commit All"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  shldn_log_warn_row "Current directory is not inside a Git repository. Nothing done."
  shldn_print_footer
  exit 1
fi

if [ "$#" -eq 0 ]; then
  shldn_log_error_row "Missing commit message."
  shldn_log_info_row "Usage: $(basename "$0") \"commit message\""
  shldn_print_footer
  exit 1
fi

_COMMIT_MESSAGE="$*"

shldn_log_info_row "Staging all changes..."
if ! git add --all; then
  shldn_log_error_row "Failed to stage changes."
  shldn_print_footer
  exit 1
fi

if git diff --cached --quiet; then
  shldn_log_warn_row "No changes to commit."
  shldn_print_footer
  exit 0
fi

shldn_log_info_row "Committing staged changes..."
if git commit -m "$_COMMIT_MESSAGE"; then
  shldn_log_success_row "Commit created successfully."
  shldn_print_footer
  exit 0
fi

shldn_log_error_row "Commit failed."
shldn_print_footer
exit 1