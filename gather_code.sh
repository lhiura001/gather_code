#!/usr/bin/env bash
set -euo pipefail

#
# A script to gather relevant code files from the current directory (and subdirectories)
# and append them into a specified output text file.
#

EXTENSIONS=("js" "ts" "jsx" "tsx" "json" "tf" "tfvars" "sh" "bash" "py" "java")  # <-- add "java" etc. if needed
EXCLUDE_DIRS=("node_modules" ".git" ".terraform" "dist" "build" "coverage")

# -- Function to display usage --
usage() {
  echo "Usage: $0 [output_file]"
  exit 1
}

OUTPUT_FILE="${1:-all_code_output.txt}"

# Build the find expressions:
FIND_EXPR=""
for ext in "${EXTENSIONS[@]}"; do
  if [ -n "$FIND_EXPR" ]; then
    FIND_EXPR="${FIND_EXPR} -o "
  fi
  FIND_EXPR="${FIND_EXPR}-iname '*.${ext}'"
done

PRUNE_EXPR=""
for excl in "${EXCLUDE_DIRS[@]}"; do
  if [ -n "$PRUNE_EXPR" ]; then
    PRUNE_EXPR="${PRUNE_EXPR} -o "
  fi
  PRUNE_EXPR="${PRUNE_EXPR} -path './${excl}' -prune"
done

# DEBUG: print out what the find command will look like
echo "DEBUG: Searching for extensions: ${EXTENSIONS[@]}"
echo "DEBUG: Excluding directories: ${EXCLUDE_DIRS[@]}"
echo "DEBUG: Output file: $OUTPUT_FILE"

# Remove the 2>/dev/null so we can see any warnings or errors
FILES=$(find . \( $PRUNE_EXPR \) -o \( -type f \( $FIND_EXPR \) \) -print)

# DEBUG: print how many files we found
NUM_FILES=$(echo "$FILES" | wc -l | xargs)
echo "DEBUG: Found $NUM_FILES files matching our criteria."

> "$OUTPUT_FILE"

# If no files are found, we’ll just have an empty file unless you add a guard:
if [ "$NUM_FILES" -eq 0 ]; then
  echo "DEBUG: No matching files found. Exiting."
  exit 0
fi

for file in $FILES; do
  echo "============== START OF FILE: $file ==============" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "============== END OF FILE: $file ==============" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
done

echo "All relevant code files have been concatenated into '$OUTPUT_FILE'."
