#!/bin/bash

# Set the number of threads to use
NUM_THREADS=xx  # Adjust the number of threads as needed

# Define the path to the MEGAHIT executable
MEGAHIT_PATH="$DATA_DIR/megahit"

# Define the input directory containing the paired-end FASTQ.gz files
INPUT_DIR="$DATA_DIR"

# Define the output directory to store the assembly results
OUTPUT_DIR="$DATA_DIR"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Iterate over each pair of FASTQ.gz files in the input directory
for FORWARD_FILE in "$INPUT_DIR"/*_1.fastq.gz; do
    # Extract the base filename (without extension) from the forward read file
    BASENAME=$(basename -- "$FORWARD_FILE")
    SAMPLE="${BASENAME%_1.fastq.gz}"
    
    # Define the forward and reverse read files
    FORWARD_READ="$FORWARD_FILE"
    REVERSE_READ="$INPUT_DIR/$SAMPLE"_2.fastq.gz
    
    # Define the output directory for this sample
    OUTPUT_SAMPLE_DIR="$OUTPUT_DIR/$SAMPLE"
    
    # Create a directory for the sample in the output directory
    #mkdir -p "$OUTPUT_SAMPLE_DIR"
    
    # Run MEGAHIT on the current pair of paired-end reads in parallel --num-cpu-threads $NUM_THREADS
    echo "Running MEGAHIT on sample $SAMPLE..."
    "$MEGAHIT_PATH" -1 "$FORWARD_READ" -2 "$REVERSE_READ" -t $NUM_THREADS -o "$OUTPUT_SAMPLE_DIR" --continue
    
    # Optional: You can add additional commands here to further process the output if needed
done

    
