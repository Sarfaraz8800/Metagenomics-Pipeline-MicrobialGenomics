#!/bin/bash

# Set the number of threads to use
NUM_THREADS=xx  # Adjust the number of threads as needed

# Define the directory containing the assembly files
ASSEMBLY_DIR="$DATA_DIR"

# Define the output directory to store the CheckM results
OUTPUT_DIR="$DATA_DIR"

# Define the path to the CheckM executable
CHECKM_PATH="$DATA_DIR"

# Define the path to the CheckM database directory
CHECKM_DATABASE="$DATA_DIR"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Iterate over each assembly file in the input directory
for ASSEMBLY_FILE in "$ASSEMBLY_DIR"*.fa; do
    # Extract the base filename (without extension) from the assembly file
    BASENAME=$(basename -- "$ASSEMBLY_FILE")
    
    # Define the output directory for this sample
    OUTPUT_SAMPLE_DIR="$OUTPUT_DIR/${BASENAME%.*}_msnkk"
    
    # Run CheckM predict for completeness and contamination assessment
    echo "Running CheckM predict for sample $BASENAME..."
    "$CHECKM_PATH" predict --threads $NUM_THREADS --input "$ASSEMBLY_FILE" --output-directory "$OUTPUT_SAMPLE_DIR" --database "$CHECKM_DATABASE"
done
