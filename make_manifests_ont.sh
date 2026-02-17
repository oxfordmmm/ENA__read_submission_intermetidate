#!/usr/bin/env bash

# make_manifest_files_ont.sh
# Usage: ./make_manifest_files_ont.sh -i INPUT_DIR -o OUTPUT_DIR

set -euo pipefail

# Parse arguments
while getopts "i:o:" opt; do
    case $opt in
        i) INPUT_DIR="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        *) echo "Usage: $0 -i INPUT_DIR -o OUTPUT_DIR" >&2; exit 1 ;;
    esac
done

# Check args
if [[ -z "${INPUT_DIR:-}" || -z "${OUTPUT_DIR:-}" ]]; then
    echo "Error: Both -i (input dir) and -o (output dir) must be specified."
    exit 1
fi

# Ensure input exists
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Create output dir if needed
mkdir -p "$OUTPUT_DIR"
EXPERIMENT_NAME=$(basename "$(dirname "$(dirname "$INPUT_DIR")")")

# Process each .fastq.gz
for file in "$INPUT_DIR"/*.fastq.gz; do
    [[ -e "$file" ]] || { echo "No .fastq.gz files found in $INPUT_DIR"; exit 1; }

    sample=$(basename "$file" .fastq.gz)

    # Simplify sample name to remove unnecessary prefixes, underscores, dashes, suffixes
    sample_simplified="$sample"
    sample_simplified="${sample_simplified#pilot_}"   # Remove 'pilot_' prefix
    sample_simplified="${sample_simplified//_/}"      # Remove underscores
    sample_simplified="${sample_simplified//-/}"      # Remove dashes
    # Remove single trailing letter if present (e.g. sample123A → sample123)
    sample_simplified="${sample_simplified%[A-Za-z]}"

    manifest_file="$OUTPUT_DIR/${sample}_manifest.txt"

    cat > "$manifest_file" <<EOF
    
STUDY   PRJEB108305
SAMPLE  ${sample_simplified}
NAME    ${sample_simplified}_ont
INSTRUMENT      PromethION
LIBRARY_SOURCE  GENOMIC
LIBRARY_SELECTION       RANDOM
LIBRARY_STRATEGY        WGS
FASTQ   ${sample}.fastq.gz
EOF

    echo "Created manifest: $manifest_file"
done
