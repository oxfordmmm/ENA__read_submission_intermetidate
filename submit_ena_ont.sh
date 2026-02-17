#!/usr/bin/env bash

# submit_ena_pilot_ont.sh
# Usage: ./submit_ena_ont.sh -m MANIFEST_DIR -i INPUT_FASTQ_DIR -o OUTPUT_DIR -p PASSWORD_FILE

set -euo pipefail

# Parse arguments
while getopts "m:i:o:p:" opt; do
    case $opt in
        m) MANIFEST_DIR="$OPTARG" ;;
        i) INPUT_FASTQ_DIR="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        p) PASSWORD_FILE="$OPTARG" ;;
        *) echo "Usage: $0 -m MANIFEST_DIR -i INPUT_FASTQ_DIR -o OUTPUT_DIR -p PASSWORD_FILE" >&2; exit 1 ;;
    esac
done

# Check arguments
if [[ -z "${MANIFEST_DIR:-}" || -z "${INPUT_FASTQ_DIR:-}" || -z "${OUTPUT_DIR:-}" || -z "${PASSWORD_FILE:-}" ]]; then
    echo "Error: -m MANIFEST_DIR -i INPUT_FASTQ_DIR -o OUTPUT_DIR -p PASSWORD_FILE must all be specified."
    exit 1
fi

# Ensure directories/files exist
[[ -d "$MANIFEST_DIR" ]] || { echo "Manifest directory not found: $MANIFEST_DIR"; exit 1; }
[[ -d "$INPUT_FASTQ_DIR" ]] || { echo "Input FASTQ directory not found: $INPUT_FASTQ_DIR"; exit 1; }
[[ -f "$PASSWORD_FILE" ]] || { echo "Password file not found: $PASSWORD_FILE"; exit 1; }

# Create main output directory
mkdir -p "$OUTPUT_DIR"

# Loop through manifest files
shopt -s nullglob
manifests=("$MANIFEST_DIR"/*_manifest.txt)

if (( ${#manifests[@]} == 0 )); then
    echo "No manifest files found in $MANIFEST_DIR"
    exit 1
fi

for manifest in "${manifests[@]}"; do

    manifest_base=$(basename "$manifest" _manifest.txt)
    run_output_dir="$OUTPUT_DIR/$manifest_base"

    mkdir -p "$run_output_dir"

    echo "Submitting manifest: $manifest"
    echo "Output directory: $run_output_dir"

    # run java and capture exit code
    # replace ~/webin-cli-9.0.3.jar with the location and version of webin you have downloaded
    # replace -context reads to match the type of data you are uploading, eg 'genomes' for assembly data
    # replace -userName with your Webin username, 
    # replace -passwordFile with -password "PASSWORD" if desired, but caution that any speciel characters like (*) do not cause issues
    # replace -centerName with your center/ institution name
    # -manifest should be the path to your manifest file. If these were generated using the make_manifests_ont.sh script, the naming convention should be compatible with this script.
    # -outputDir is where the submission/ error reports go. This script generates a folder with the name of the sample within the specified output directory
    # -inputDir is the FOLDER where the .fastq.gz read files are stored. Note this MUST be a folder (not a single file), the file MUST be compressed to .fastq.gz, and the file name MUST match the file name specified in the manifest file in the FASTQ field 
    # -submit validates and submits files. replace with -validate to just validate, or -test to just test everything is working.
if java --enable-native-access=ALL-UNNAMED \
    -jar ~/webin-cli-9.0.3.jar \
    -context reads \
    -userName Webin-71008 \ 
    -passwordFile "$PASSWORD_FILE" \
    -centerName "University of Oxford" \
    -manifest "$manifest" \
    -outputDir "$run_output_dir" \
    -inputDir "$INPUT_FASTQ_DIR" \
    -submit \
    > "$run_output_dir/submission.log" 2>&1
then
    echo "Submission succeeded for $manifest_base"
else
    rc=$?
    echo "ERROR: Submission failed for $manifest_base (exit code $rc). See $run_output_dir/submission.log" >&2
    # record failure to a summary file (optional)
    printf "%s\t%s\n" "$manifest_base" "$rc" >> "$OUTPUT_DIR/failed_submissions.tsv"
    # continue to next manifest
    continue
fi

    echo "Finished submission for $manifest_base"
    echo "--------------------------------------------"
done

echo "All submissions completed."



