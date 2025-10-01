#!/bin/bash

# Base path where the subdirectories are located
BASE_DIR="/../libraries/Selected_species/01_mapped"

# Create folder to save the output files
OUTPUT_DIR="/../libraries/Selected_species/read_lengths"
mkdir -p "$OUTPUT_DIR"

# Loop through all *_mapped.fastq.gz files
find "$BASE_DIR" -type f -name "*_mapped.fastq.gz" | while read file; do
    echo "Processing: $file"

    # Extracting the base name of the file
    base_name=$(basename "$file" .fastq.gz)

    # Defining the output path for the length file
    output_file="$OUTPUT_DIR/${base_name}_read_lengths.txt"

    # Run seqtk + awk and save the result
    seqtk seq -A "$file" | awk '{if(NR%2==0) print length($0)}' > "$output_file"

    echo "Saved to: $output_file"
done

