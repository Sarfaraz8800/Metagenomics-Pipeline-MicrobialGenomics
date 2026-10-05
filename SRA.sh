#!/bin/bash

# Set the output directory
OUTPUT_DIR="$DATA_DIR"
set -x

# Define the SRA accession numbers you want to download
SRR_ACCESSION_NUMBERS=(xxxxxxxx xxxxxxx xxxxxxxx xxxxxxxx)

# Function to download SRA files using prefetch
prefetch_sra() {
    "$DATA_DIR"/prefetch -r yes "$1"
}

# Run prefetch in parallel for each SRA accession number
for i in "${SRR_ACCESSION_NUMBERS[@]}"; do
    prefetch_sra "SRR${i}" &
done

# Wait for all prefetch processes to finish
wait

# Loop through the SRA accession numbers
for i in "${SRR_ACCESSION_NUMBERS[@]}"; do
    #Run the fasterq-dump program with the SRA files
    "$DATA_DIR"/fasterq-dump "$DATA_DIR"/SRR${i}.sra --threads 70 -O ${OUTPUT_DIR}
  
    # Compress the FASTQ files using pigz with multiple threads
    pigz -p 70 ${OUTPUT_DIR}/SRR${i}_1.fastq
    pigz -p 70 ${OUTPUT_DIR}/SRR${i}_2.fastq
      
    # Delete the SRA files after they have been used to extract the FASTQ files
    rm "$DATA_DIR"/SRR${i}.sra
done
