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
find "$INPUT_DIR" -type f -name "*_trimmed_paired_1.fastq.gz" | while read input_file; do

  #Sample name
  sample_name=$(basename "$input_file" | cut -d'_' -f1)

  # Creating output folder
  sample_outdir="$OUTPUT_BASE/$sample_name"
  mkdir -p "$sample_outdir"

  #Output files
  mapped_out="$sample_outdir/${sample_name}_mapped.fastq.gz"
  unmapped_out="$sample_outdir/${sample_name}_unmapped.fastq.gz"

  #Checking if the file was already processed
  if [[ -f "$mapped_out" && -f "$unmapped_out" && -s "$mapped_out" && -s "$unmapped_out" ]]; then
    echo "Amostra já processada, pulando: $sample_name" | tee -a "$LOG_FILE"
    continue
  fi

  echo "Rodando BBMap para: $sample_name" | tee -a "$LOG_FILE"


 bbmap.sh \
  in="$input_file" \
  outm="$mapped_out" \
  outu="$unmapped_out" \
  ref="$REF_FASTA" \
  tossbrokenreads=t \
  threads=10 \
  -Xmx32g \
  -Xms32g \
  2>&1 | tee -a "$LOG_FILE"

done
