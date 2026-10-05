#!/bin/bash

# Set paths and variables
MEGAHIT_OUTPUT_DIR="$DATA_DIR"
PRODIGAL_OUTPUT_DIR="$DATA_DIR"
PRODIGAL_BIN="$DATA_DIR"  # Replace "/path/to/prodigal" with the actual path to Prodigal executable
NUM_THREADS=xx

# Create output directory if it doesn't exist
mkdir -p "$PRODIGAL_OUTPUT_DIR"

# Loop through each MEGAHIT output directory
for dir in "$MEGAHIT_OUTPUT_DIR"/*_trimmed_human_filtered; do
    # Extract sample name from directory name
    sample_name=$(basename "$dir")
    
    # Define path to the final contigs file (assuming it's named final.contigs.fa)
    CONTIGS_FILE="$dir"/final.contigs.fa

    # Run Prodigal with specified parameters
    echo "Running Prodigal for $sample_name..."
    "$PRODIGAL_BIN" -i "$CONTIGS_FILE" -o "$PRODIGAL_OUTPUT_DIR"/"$sample_name".faa -f gff -t "$PRODIGAL_OUTPUT_DIR"/"$sample_name"_temp.gff -a "$PRODIGAL_OUTPUT_DIR"/"$sample_name".fna -d "$PRODIGAL_OUTPUT_DIR"/"$sample_name"_proteins.fna -s "$PRODIGAL_OUTPUT_DIR"/"$sample_name"_summary.txt -f gff -c -q -T "$NUM_THREADS"
done
