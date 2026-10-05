#!/bin/bash

# Specify the path to your input files
input_path="$DATA_DIR"
# Specify the path where you want to store the trimmed output
output_path="$DATA_DIR"

# Path to BBMap/BBduk
bbduk_path="$DATA_DIR"  # Update with the correct path

# Number of threads
num_threads=xx


# Initial heap size for JVM
initial_heap_size="100g"  # You can adjust this value as needed

# Process paired-end files
for file1 in "$input_path"/SRR*_trimmed_1.fastq.gz; do
    # Extract the sample name from the filename
    sample_name=$(basename "${file1%_1.fastq.gz}")

    # Corresponding file2
    file2="$input_path/${sample_name}_2.fastq.gz"

    # Run BBduk on the paired-end files with multiple threads
    $bbduk_path in1="$file1" in2="$file2" \
        out1="${output_path}/${sample_name}_human_filtered_1.fastq.gz" \
        out2="${output_path}/${sample_name}_human_filtered_2.fastq.gz" \
        ref=""$DATA_DIR"/human_genome.fa" threads=$num_threads \
         -Xmx"${initial_heap_size}"
 
rm "$file1" "$file2"  # Remove original files
       
done

echo "Processing completed."
