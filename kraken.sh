#!/bin/bash

# Path to Kraken 2 executable
kraken2_exec="$DATA_DIR"

# Path to Kraken 2 database
kraken2_db="$DATA_DIR"

# Number of threads
num_threads=xx

# Output directory
output_dir="$DATA_DIR"

# Input directory containing paired-end fastq files
input_dir="$DATA_DIR"

# Process all paired-end files in the input directory
for file1 in "${input_dir}"/*_1.fastq.gz; do
    # Extract the sample name from the filename
    sample_name=$(basename "${file1%_1.fastq.gz}")

    # Corresponding file2
    file2="${input_dir}/${sample_name}_2.fastq.gz"

    # Output report file
    output_report="${output_dir}/${sample_name}_k2_report.txt"
    
        # Output .kraken2 file
    #output_kraken2="${output_dir}/${sample_name}.kraken2"

    # Run Kraken 2
    "${kraken2_exec}" --db "${kraken2_db}" --threads ${num_threads} \
        --report "${output_report}" "${file1}" "${file2}" > /dev/null 2>&1

    echo "Processing completed for ${sample_name}"
done
