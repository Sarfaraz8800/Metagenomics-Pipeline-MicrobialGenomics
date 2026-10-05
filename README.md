# Metagenomics-Pipeline-MicrobialGenomics
Bioinformatic pipelines, Bash scripts, and Python workflows for processing shotgun metagenomic sequencing datasets.

---

## Workflow Overview & Repository Contents

### 1. Data Acquisition & Preprocessing
* `SRA.sh`: Downloads raw sequencing data from the NCBI SRA database.
* `fastqc.sh`: Quality control assessment of raw reads.
* `trimmomatic.sh` & `bbduk.sh`: Quality trimming, adapter removal, and contaminant filtering.

### 2. Taxonomic Profiling & Abundance Estimation
* `kraken.sh`: Taxonomic classification of metagenomic reads using Kraken2.
* `braken.sh`: Species-level abundance estimation with Bracken.
* `combine_bracken.sh` & `merge-kreports.sh`: Aggregation and merging of taxonomic profiles across samples.

### 3. Assembly, Binning, and Quality Assessment
* `megahit.sh`: De novo metagenomic assembly.
* `maxbin.sh`: Metagenome-assembled genome (MAG) binning using MaxBin2.
* `checkm.sh`: Completeness and contamination evaluation of MAGs with CheckM.

### 4. Gene Prediction & Functional Annotation
* `prodigal.sh`: Protein-coding gene prediction from assembled contigs.
* `prokka.sh`: Genome annotation using Prokka.
* `eggnog.py`: Functional annotation of predicted proteins against the eggNOG database.

### 5. Downstream Statistical Analysis
* `MaAsLin2.R`: Differential abundance testing and multivariable association analysis using MaAsLin 2.
