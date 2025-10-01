#!/bin/bash

# Path to the input files
INPUT_DIR="/../libraries/Selected_species"

# Path to the reference FASTA file
REF_FASTA="/../genomes/Selected_species/index_bbmap/genome.fasta"

# Base output path
OUTPUT_BASE="$INPUT_DIR/01_mapped"

# Path to the log file
LOG_FILE="$OUTPUT_BASE/stats_bbmap_cds.txt"

# Create/clear the log file
mkdir -p "$OUTPUT_BASE"
: > "$LOG_FILE"

# Loop through all "_trimmed_paired_1.fastq.gz" files
find "$INPUT_DIR" -type f -name "*_trimmed_paired_1.fastq.gz" | while read FILE1; do

  FILE2="${FILE1/_trimmed_paired_1.fastq.gz/_trimmed_paired_2.fastq.gz}"
  
  #Sample name
  sample_name=$(basename "$FILE1" | cut -d'_' -f1)
  
  # Creating output directory
  sample_outdir="$OUTPUT_BASE/$sample_name"
  mkdir -p "$sample_outdir"
  
  #Output files
  mapped1="$sample_outdir/${sample_name}_mapped_1.fastq.gz"
  mapped2="$sample_outdir/${sample_name}_mapped_2.fastq.gz"
  unmapped1="$sample_outdir/${sample_name}_unmapped_1.fastq.gz"
  unmapped2="$sample_outdir/${sample_name}_unmapped_2.fastq.gz"

  #Checking if the file was already processed
  if [[ -d "$sample_outdir" && -s "$mapped1" && -s "$mapped2" && -s "$unmapped1" && -s "$unmapped2" ]]; then
    echo "Sample already processed, skipping: $sample_name" | tee -a "$LOG_FILE"
    continue
  fi

  echo "Running bbmap for BBMap para: $sample_name" | tee -a "$LOG_FILE"

bbmap.sh \
  "ref=$REF_FASTA" \
  "in1=$FILE1" \
  "in2=$FILE2" \
  "outm1=$mapped1" \
  "outm2=$mapped2" \
  "outu1=$unmapped1" \
  "outu2=$unmapped2" \
  "tossbrokenreads=t" \
  "threads=10" \
   -Xmx32g \
  -Xms32g \
  2>&1 | tee -a "$LOG_FILE"


done

