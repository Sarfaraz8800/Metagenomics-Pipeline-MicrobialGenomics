#!/bin/bash

# Specify the path to your input files
input_path="$DATA_DIR"
# Specify the path where you want to store the trimmed output
output_path="$DATA_DIR"
# The second output for unpaired files
output_path1="$DATA_DIR"

# Path to Trimmomatic JAR file
trimmomatic_jar="$DATA_DIR"/Trimmomatic-0.39/trimmomatic-0.39.jar"  # Update with the correct path

# Iterate over paired-end files using zip
for file1 in "$DATA_DIR"/SRR*_1.fastq.gz;
do
    # Extract the sample name from the filename
    sample_name=$(basename "${file1%_1.fastq.gz}")

    # Corresponding file2
    file2="$DATA_DIR"/${sample_name}_2.fastq.gz"

    # Run Trimmomatic on the paired-end files
    java -jar "$trimmomatic_jar" PE -phred33 \
        "$file1" "$file2" \
        "${output_path}/${sample_name}_trimmed_1.fastq.gz" "${output_path1}/${sample_name}_unpaired_1.fastq.gz" \
        "${output_path}/${sample_name}_trimmed_2.fastq.gz" "${output_path1}/${sample_name}_unpaired_2.fastq.gz" \
       ILLUMINACLIP:"/home/data1/biotools/Trimmomatic-0.39/adapters/NexteraPE-PE.fa":2:30:10 LEADING:30 TRAILING:30 HEADCROP:15 SLIDINGWINDOW:4:30 MINLEN:75 -threads 70

    rm "$file1" "$file2"  # Remove original files
done