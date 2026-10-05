#!/bin/bash

# Path to the combine_bracken_outputs.py script
combine_script="$DATA_DIR"/combine_bracken_outputs.py

# Directory containing Bracken output files
bracken_files_dir="$DATA_DIR"

# Output file for the combined Bracken report
combined_output=/"$DATA_DIR"

# Check if the combine script exists
if [ ! -f "$combine_script" ]; then
    echo "Error: combine_bracken_outputs.py script not found at $combine_script"
    exit 1
fi

# Check if the Bracken files directory exists
if [ ! -d "$bracken_files_dir" ]; then
    echo "Error: Bracken files directory not found at $bracken_files_dir"
    exit 1
fi

# Collect all Bracken files in the directory
bracken_files=$(find "$bracken_files_dir" -type f -name "*.bracken")

# Check if any Bracken files were found
if [ -z "$bracken_files" ]; then
    echo "Error: No Bracken files found in $bracken_files_dir"
    exit 1
fi

# Run the combine_bracken_outputs.py script
python "$combine_script" --files $bracken_files -o "$combined_output"

# Check if the output file was created
if [ -f "$combined_output" ]; then
    echo "Combined Bracken report created at $combined_output"
else
    echo "Error: Failed to create combined Bracken report"
    exit 1
fi