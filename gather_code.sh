#!/usr/bin/env bash
set -euo pipefail  # Good practice: fail on errors, unset vars, and pipeline errors

#
# A script to gather relevant code files from the current directory (and subdirectories)
# and append them into a specified output text file.
#
# Usage:
#   ./gather_code.sh [output_file]
#
# Example:
#   ./gather_code.sh my_code.txt
#
# Then "my_code.txt" will contain all your relevant code.
#
# By default, if no output file is specified, it writes to "all_code_output.txt".

# -- Settings / Customization --
# You can add or remove file extensions from the EXTENSIONS array as needed.
# The script also prunes directories that are almost always irrelevant (e.g., node_modules, .terraform, .git, etc.).

EXTENSIONS=("js" "ts" "jsx" "tsx" "json" "tf" "tfvars" "sh" "bash" "py")  # Add or remove any as needed

# Common directories to exclude (will prune these from the search).
EXCLUDE_DIRS=("node_modules" ".git" ".terraform" "dist" "build" "coverage")

# -- Function to display usage --
usage() {
  echo "Usage: $0 [output_file]"
  echo "Description: Gathers relevant code files from the current directory into a single text file."
  echo "If no output file is given, defaults to 'all_code_output.txt'."
  exit 1
}

# -- Parse arguments --
OUTPUT_FILE="${1:-}"
if [ -z "$OUTPUT_FILE" ]; then
  OUTPUT_FILE="all_code_output.txt"
fi

# 1. Build the 'find' command with all the desired file extensions
FIND_EXPR=""
for ext in "${EXTENSIONS[@]}"; do
  if [ -n "$FIND_EXPR" ]; then
    FIND_EXPR="${FIND_EXPR} -o "
  fi
  FIND_EXPR="${FIND_EXPR}-iname '*.${ext}'"
done

# 2. Build the exclude logic for directories
PRUNE_EXPR=""
for excl in "${EXCLUDE_DIRS[@]}"; do
  if [ -n "$PRUNE_EXPR" ]; then
    PRUNE_EXPR="${PRUNE_EXPR} -o "
  fi
  PRUNE_EXPR="${PRUNE_EXPR} -path './${excl}' -prune"
done

# 3. Run the 'find' command (ignore errors with 2>/dev/null).
FILES=$(find . \( $PRUNE_EXPR \) -o \( -type f \( $FIND_EXPR \) \) -print 2>/dev/null)

# 4. Overwrite/create the output file (this can throw an error if the shell is not truly bash or if CRLF issues exist).
> "$OUTPUT_FILE"

# 5. Loop over the found files and concatenate contents
for file in $FILES; do
  echo "============== START OF FILE: $file ==============" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "============== END OF FILE: $file ==============" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

# 6. Notify the user
echo "All relevant code files have been concatenated into '$OUTPUT_FILE'."
