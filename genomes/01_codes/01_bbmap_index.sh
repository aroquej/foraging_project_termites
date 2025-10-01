#!/bin/bash

# Path to the genome .fasta file
GENOME_PATH="../genomes/Selected_species/reference_genome.fa"

# Directory where the index will be created
REF_DIR="../genomes/Selected_species/index_bbmap"

# Create the reference directory if it doesn't exist
mkdir -p "$REF_DIR"

# Copy the genome to the directory and enter it
cp "$GENOME_PATH" "$REF_DIR/genome.fasta"
cd "$REF_DIR"

# Index the genome with BBMap
bbmap.sh ref=genome.fasta

