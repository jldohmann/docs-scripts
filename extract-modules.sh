#!/bin/bash

INPUT_FILE="$1"
OUTPUT_FILE="module-output.txt"

if [[ -z "$INPUT_FILE" || ! -f "$INPUT_FILE" ]]; then
  echo "❌Please provide a valid AsciiDoc file."
  echo "Usage: $0 <your-assembly>.adoc"
  exit 1
fi

grep '^include::modules/' "$INPUT_FILE" | \
  sed -E 's|include::modules/([^[]+)\[.*|\1|' > "$OUTPUT_FILE"

echo "✅Extracted module filenames to $OUTPUT_FILE"
