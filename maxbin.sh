#!/bin/bash

# Set paths and variables
INPUT_DIR="$DATA_DIR"
MAXBIN_OUTPUT_DIR="$DATA_DIR"
MAXBIN_BIN="$DATA_DIR"  # Assuming your MaxBin version is 2.2.7
NUM_THREADS=xx
FASTQ_DIR="$DATA_DIR"  # Path to the directory containing FASTQ files

# Create output directory if it doesn't exist
mkdir -p "$MAXBIN_OUTPUT_DIR"

# Loop through each MEGAHIT output directory
for dir in "$INPUT_DIR"/*_trimmed_human_filtered; do
    # Extract sample name from directory name
    sample_name=$(basename "$dir")
    
    # Define path to the final contigs file (assuming it's named final.contigs.fa)
    CONTIGS_FILE="$dir"/final.contigs.fa

    # Run MaxBin with specified parameters
    echo "Running MaxBin for $sample_name..."
    "$MAXBIN_BIN"/run_MaxBin.pl -thread "$NUM_THREADS" -contig "$CONTIGS_FILE" -reads "$FASTQ_DIR"/"$sample_name"_1.fastq.gz -reads2 "$FASTQ_DIR"/"$sample_name"_2.fastq.gz -out "$MAXBIN_OUTPUT_DIR"/"$sample_name" 
done
