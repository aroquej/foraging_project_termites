#!/bin/bash

# Main paths
BASE_DIR="/../libraries/Selected_species/01_mapped"
INDEX="/../genomes/Selected_species/index_kallisto/reference_index.idx"
BOOTSTRAPS=100

# Loop over all *_trimmed_paired_1.fastq.gz files
find "$BASE_DIR" -type f -name "*_mapped_1.fastq.gz" | while read -r FASTQ1; do
    # Defines FASTQ2 by replacing _1.fastq.gz by _2.fastq.gz
    FASTQ2="${FASTQ1/_mapped_1.fastq.gz/_mapped_2.fastq.gz}"

    # Verify the presence of the pair
    if [[ ! -f "$FASTQ2" ]]; then
        echo "Pair not found for $FASTQ1. Skipping." | tee -a "$BASE_DIR/skipped_samples.log"
        continue
    fi

    #Directory of the samples
    SAMPLE_DIR=$(dirname "$FASTQ1")
    sample=$(basename "$SAMPLE_DIR")
    OUTPUT_DIR="$SAMPLE_DIR/kallisto"
    LOG_FILE="$OUTPUT_DIR/${sample}.log"

    # Skip if quantification already done
    if [[ -f "$OUTPUT_DIR/abundance.tsv" ]]; then
        echo "Skipping $sample: quantification already exists." | tee -a "$BASE_DIR/skipped_samples.log"
        continue
    fi

    mkdir -p "$OUTPUT_DIR"

    echo "Running Kallisto for $sample (paired-end)..." | tee "$LOG_FILE"

    kallisto quant \
      -i "$INDEX" \
      -o "$OUTPUT_DIR" \
      -b "$BOOTSTRAPS" \
      -t 10 \
      "$FASTQ1" "$FASTQ2" 2>&1 | tee -a "$LOG_FILE"

    echo "Finished $sample. Log saved to $LOG_FILE" | tee -a "$LOG_FILE"
done

