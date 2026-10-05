import os
import glob
import subprocess

# Set paths and variables
OUTPUT_DIR = "$DATA_DIR"  # Replace with your Prodigal output directory
EGGNOG_BIN = "$DATA_DIR"/emapper.py"  # Replace with the path to emapper.py script
EGGNOG_DB = "$DATA_DIR"  # Replace with the path to your eggNOG database directory
EGGNOG_OUTPUT_DIR = "$DATA_DIR"  # Replace with your desired output directory
NUM_THREADS = 16

# Create output directory if it doesn't exist
os.makedirs(EGGNOG_OUTPUT_DIR, exist_ok=True)

# Loop through each Prodigal output directory
for file in glob.glob(f"{OUTPUT_DIR}/*.faa"):
    # Extract sample name from file name
    sample_name = os.path.basename(file).replace(".faa", "")

    # Run eggNOG-mapper for functional profiling
    print(f"Running eggNOG-mapper for {sample_name}...")
    command = [EGGNOG_BIN, "-i", file, "-o", f"{EGGNOG_OUTPUT_DIR}/{sample_name}_eggnog", "--cpu", str(NUM_THREADS), "-d", EGGNOG_DB]
    subprocess.run(command)

print("eggNOG-mapper completed!")