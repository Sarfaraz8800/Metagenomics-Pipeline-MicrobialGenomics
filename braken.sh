#!/bin/bash

# Path to Bracken executable
bracken_exec="$DATA_DIR"

# Kraken database and Kraken report files (modify as needed)
kraken_db="$DATA_DIR"

# Read length
read_length=100

# Taxonomic level for abundance estimation
taxonomic_level="G"

# Read threshold for abundance estimation
read_threshold=10

# Output directories
bracken_output_dir="$DATA_DIR"
bracken_report_dir="$DATA_DIR"
# Input directory containing Kraken output reports
kraken_output_dir="$DATA_DIR"

# Process all Kraken reports in the input directory
for kraken_report_file in "${kraken_output_dir}"/*.txt; do
    # Extract the sample name from the Kraken report filename
    sample_name=$(basename "${kraken_report_file%.txt}")

    # Output Bracken files
    bracken_output="${bracken_output_dir}/${sample_name}.bracken"
    bracken_report="${bracken_report_dir}/${sample_name}.breport"

    # Run Bracken for abundance estimation
    ${bracken_exec} -d ${kraken_db} -i ${kraken_report_file} -l ${taxonomic_level} -r ${read_length} -t ${read_threshold} -o ${bracken_output} -w ${bracken_report}

    echo "Abundance estimation completed for ${sample_name}"
done
