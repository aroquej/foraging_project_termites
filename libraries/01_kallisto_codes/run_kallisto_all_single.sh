#!/bin/bash

# Main paths
BASE_DIR="/../libraries/Selected_species/01_mapped"
INDEX="/../genomes/Selected_species/index_kallisto/reference_index.idx"
LENGTHS_FILE="/../libraries/Selected_species/read_lengths/read_length_summary.txt"
BOOTSTRAPS=100

# Loop over all *_mapped_1.fastq.gz files in subdirectories
find "$BASE_DIR" -type f -name "*_mapped.fastq.gz" | while read -r FASTQ; do
    # Nome da pasta da amostra
    SAMPLE_DIR=$(dirname "$FASTQ")
    sample=$(basename "$SAMPLE_DIR")
    OUTPUT_DIR="$SAMPLE_DIR/kallisto"
    LOG_FILE="$OUTPUT_DIR/${sample}.log"

    # Skip if quantification already done
    if [[ -f "$OUTPUT_DIR/abundance.tsv" ]]; then
        echo "Skipping $sample: quantification already exists." | tee -a "$BASE_DIR/skipped_samples.log"
        continue
    fi

    # Retrieve mean and standard deviation from summary file
    read mean std <<< $(awk -v s="$sample" '
        $0 == "Sample: " s {
            getline; gsub("Mean: ", "", $0); mean = $0;
            getline; gsub("Standard Deviation: ", "", $0); std = $0;
            print mean, std;
        }
    ' "$LENGTHS_FILE")

    if [[ -z "$mean" || -z "$std" ]]; then
        echo "Warning: Mean or standard deviation not found for $sample. Skipping." | tee -a "$BASE_DIR/skipped_samples.log"
        continue
    fi

    mkdir -p "$OUTPUT_DIR"

    echo "Running Kallisto for $sample (mean length=$mean, std=$std)..." | tee "$LOG_FILE"

    kallisto quant \
      --single \
      --single-overhang \
      -i "$INDEX" \
      -o "$OUTPUT_DIR" \
      -b "$BOOTSTRAPS" \
      -l "$mean" \
      -s "$std"\
      --rf-stranded \
      -t 10 \
      "$FASTQ" 2>&1 | tee -a "$LOG_FILE"

    echo "Finished $sample. Log saved to $LOG_FILE" | tee -a "$LOG_FILE"
done

