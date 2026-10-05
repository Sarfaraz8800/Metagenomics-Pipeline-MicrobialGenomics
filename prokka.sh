#!/bin/bash

# Define input directory containing genome FASTA files
INPUT_DIR="$DATA_DIR"

# Define output directory for Prokka results
output_dir="$INPUT_DIR/prokka"

# Define name prefix for Prokka output files
output_prefix="prokka"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through each MEGAHIT output directory
for dir in "$INPUT_DIR"/*_trimmed_human_filtered; do
    # Extract sample name from directory name
    sample_name=$(basename "$dir")
    
    # Define path to the final contigs file (assuming it's named final.contigs.fa)
    CONTIGS_FILE="$dir"/final.contigs.fa

    # Run Prokka
    "$prokka_path/prokka" --outdir "$output_dir/$output_prefix_$sample_name" \
                          --prefix "$output_prefix_$sample_name" \
                          --metagenome \
                          --cpus 16 --quiet "$CONTIGS_FILE"
done
