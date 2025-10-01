#!/bin/bash

# Path to the folder with length files
LENGTHS_DIR="/../libraries/Selected_species/read_lengths"
SUMMARY_FILE="$LENGTHS_DIR/read_length_summary.txt"
COMBINED_TMP="$LENGTHS_DIR/_all_lengths.tmp"

# Clear old files
> "$SUMMARY_FILE"
> "$COMBINED_TMP"

# Loop through all *_read_lengths.txt files
for file in "$LENGTHS_DIR"/*_read_lengths.txt; do
    sample=$(basename "$file" _read_lengths.txt)
    echo "Sample: $sample" >> "$SUMMARY_FILE"

    awk '{sum+=$1; sumsq+=$1*$1} END {
        mean = sum/NR;
        std = sqrt(sumsq/NR - mean^2);
        printf "Mean: %.2f\nStandard Deviation: %.2f\n\n", mean, std;
    }' "$file" >> "$SUMMARY_FILE"

    # Append to combined file
    cat "$file" >> "$COMBINED_TMP"
done

# Statistical analysis
echo "=== Combined Statistics ===" >> "$SUMMARY_FILE"
awk '{sum+=$1; sumsq+=$1*$1} END {
    mean = sum/NR;
    std = sqrt(sumsq/NR - mean^2);
    printf "Combined Mean: %.2f\nCombined Standard Deviation: %.2f\n", mean, std;
}' "$COMBINED_TMP" >> "$SUMMARY_FILE"

# Remove temporary file
rm "$COMBINED_TMP"

echo "Summary saved to: $SUMMARY_FILE"

