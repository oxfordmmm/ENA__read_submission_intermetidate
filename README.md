# ENA__read_submission_intermetidate
Instructions and helper scripts for batch read submission to the European Nucleotide Archive (ENA) using interactive Study and Sample registration on the Webin submission portal, and webin-cli for read submission. The example provided is for prokaryotic pathogen submission with minimum metadata and ONT long reads, but is adaptable. 

## Options for ENA Read submission 
There are 3 ways to upload sequencing data to ENA:
1. Interactively - using the [Webin Submission Portal webiste](https://www.ebi.ac.uk/ena/submit/webin/login) - only for a small number of samples.
2. Using the [Webin-CLI tool](https://ena-docs.readthedocs.io/en/latest/submit/general-guide/webin-cli.html) - instrictions below, uses command-line, is approporiate for large batch submissions.
3. Programatically - using XML files for completely automated workflows. See this [Nextflow submission workflow](https://github.com/oxfordmmm/minimal_pathogen_fq_ENA_upload).
More about [ENA read submission options](https://ena-docs.readthedocs.io/en/latest/submit/reads.html).

## Overview of ENA Read submission procedure
**Reads** submitted to ENA have to be linked to a **Study** and a **Sample**. More about the [ENA metadata structure](https://ena-docs.readthedocs.io/en/latest/submit/general-guide/metadata.html). The steps involved in uploading reads to the ENA are: 
1. Make a [Webin submission portal](https://www.ebi.ac.uk/ena/submit/webin/login) account and log in
2. Register a **Study** [Webin website](https://www.ebi.ac.uk/ena/submit/webin/study)
3. Register **Samples** [Webin website tsv file upload](https://www.ebi.ac.uk/ena/submit/webin/app-checklist/sample/true)
4. Submit **Raw Reads** [Webin-CLI command-line tool](https://github.com/enasequence/webin-cli)
(5. +/- Optional submission on assemblies/annotations)
These ateps are detailed below:

### 1. Make a Webin account and login
- Go to the [Webin Submission Portal](https://www.ebi.ac.uk/ena/submit/webin/login) login page and click 'Register' for an account.
- Save your password in a text file called `ena.txt`, and save this on the same platform as your reads (e.g. on your laptop, BMRC, or a VM). It does not have to be in the same folder as your reads, just on a known path.

### 2. Register Study (interactively on website)
- Once logged-in to the Webin Submission portal webiste, click on the yellow ['Register Study' option](https://www.ebi.ac.uk/ena/submit/webin/study).
- Fill in your **Study** details.
- **NOTE:**Set a 'Release date' in the future if you want to embargo your reads. You HAVE to do this at the Study level, and cannot re-embargo part of your Study once it is public. 

### 3. Register Samples (interactively on website)
- Return to the Webin Submission Portal home page, and click on the green ['Register Samples' option](https://www.ebi.ac.uk/ena/submit/webin/app-checklist/sample/true).
- You need to upload a `.tsv` or `.tab` spreadsheet using the 'Upload filled spreadsheet with to register samples' option. The spreadsheet needs to be in the correct format with specific metadata fields and values. To make this spreadsheet you can either:
  1. Click through the 'Download spreadsheet to register samples' tab options to select the correct spreadsheet template, download the template, fill in with your samples in Excel, save as .tsv or .tab and upload.
   - e.g. 'Pathogens checklists' >
   - 'ENA prokaryotic pathogen minimal sample checklist' >
   - unselect 'Recommended Fields' unless you want to include these, and check the descriptions of the 'Mandatory Fields' >
   - 'Download TSV Template'
  2. Alternatively, use the `prepare_ENA_samples_metadata.R` R helper script in this repo (download file and open in R studio or text editor of your choice) to load in your own data and convert to the correct format for submission. The helper script makes a metadata file appropriate for the 'ENA prokaryotic pathogen minimal sample checklist' upload, and you will have to modify column names, species names, taxonomic IDs, etc to fit your own data.
- Upload your metadata file using the 'Upload filled spreadsheet with to register samples' option.


### 4. Submit Reads (using webin-cli tool)
- The rest of the submission process is done using command line with the [Webin-CLI submission tool](https://github.com/enasequence/webin-cli). This is a java application, and full installation instructions can be found [here](https://github.com/enasequence/webin-cli). Below is a minimal example for installation using bash in a Linux system. Adapted to macOS/Windows as needed:
1. Navigate to the same platform your reads are on (e.g.: your laptop, a HPC cluster, a VM) and create a conda environment with the latest version of Java installed
   ```
      conda create -n webin_cli_env -c conda-forge openjdk=21 -y
   ```
2. Activate the conda environment, and check java installation (should be version 17 or later)
   ```
   conda activate webin_cli_env
   java -version
   ```
3. Download the latest version of webin-cli by checking the [latest release](https://github.com/enasequence/webin-cli/releases). Right click on the latest release > 'Copy link address' and paste this into the place of the link below. Launch this `wget` command after navigating to the directory to which you want to download the webin application.
   ```
   wget https://github.com/enasequence/webin-cli/releases/download/9.0.3/webin-cli-9.0.3.jar
   ```
4. Test the Webin-cli tool with `-help` to see the options available. Replace the `~/webin-cli-9.0.3.jar` with the file path and version of webin-cli you have downloaded.
   ```
   java -jar ~/webin-cli-9.0.3.jar -help
   ```

Now that the Webin-cli tool is working, prepare the 2 essential inputs:

5. **Reads folder** - where the compressed fastq reads are.
      - NOTE: reads MUST be compressed with a .fastq.gz extension (or [other permitted file type](https://ena-docs.readthedocs.io/en/latest/submit/fileprep/reads.html)).
      - you can compress all files in a directory with this command:
      ```
      for f in *.fastq; do pigz -c "$f" > "$f.gz"; done
      ```
      NOTE: `pigz` is just a faster version of `gzip`, so you can replace this with `gzip` if you can't get `pigz` to work.

6. **Manifest file** - which declares essential metadata for the read submission, including the filename, and links it to the **Study** and **Sample** already registered
  - Make manifest files for each read using the `make_manifests_ont.sh` helper script. More info on [manifest files here](https://ena-docs.readthedocs.io/en/latest/submit/reads/webin-cli.html). Download the `make_manifests_ont.sh` script, or copy its contents into a text editor. You will need to edit the script: as a minimum, you need to change your Study accession to the one you registered in step 2, and may need to change other metadata fields at the bottom. Navigate to the directory where you  saved the script, ensure the script is executable then execute the script. Replace `INPUT_DIR` with the path to your `.fastq.gz` files, and replace `OUTPUT_DIR` with the path you want to write the output manifest files to.
   ```
   nano make_manifests_ont.sh # open script in text editor to modify Study accession and other metadata fields.
   chmod +x make_manifests_ont.sh # ensure script executable
   bash make_manifest_files_ont.sh -i INPUT_DIR -o OUTPUT_DIR
   ```
- - NOTE: the SAMPLE field must match either a sample_alias or sample accession uploaded in step 3, NAME (sequencing experiment name) must be unique to each uploaded file (or file pair if paired illumina), and FASTQ must match the file name of the .fastq.gz file being uploaded.

7. Once manifest files are prepared, read fastqs compressed, and webin-cli is installed, you should be ready to launch the upload

- Launch the Webin read upload as a single command for a single read (/read pair for paired Illumina):
  ```
  java --enable-native-access=ALL-UNNAMED \ # just a java option to supress warnings
    -jar ~/webin-cli-9.0.3.jar \ # replace with path to your webin-cli download
    -context reads \ # change to genome/transcriptome/sequences as needed
    -userName Webin-XXXXX \ # replace with your own Webin login
    -passwordFile ena.txt \ # replace with password file name
    -centerName "University of Oxford" \ # replace with centre name
    -manifest "$manifest" \ # path to single manifest file declaring metadata 
    -outputDir "$run_output_dir" \ # path to output directory for submission report
    -inputDir "$INPUT_FASTQ_DIR" \ # directory (NOT individual file) where reads to upload are. This directory MUST contain an exact match to the filename decalred in the FASTQ field in the supplied mnaifest file.
    -submit  # or -validate or -test flag
  ```
  - Or use the `submit_ena_ont.sh` helper script to submit reads declared in all of the manifest files in a specified `MANIFEST_DIR` (this should be the same as the `OUTPUT_DIR` for the previous `make_manifest_ont.sh`script). `INPUT_FASTQ_DIR` is the directory name of where your compressed `fastq.gz` files for upload are, `OUTPUT_DIR` is where the submission report will be written, and `PASSWORD_FILE` contains your Webin account password without quotes. It should be `ena.txt` if you saved it as in step 1. Get the helper script by downloading the file from this repo, or copy-pasting its contents into a text editor of your choice. 
  ```
  chmod +x submit_ena_ont.sh # ensure executable
  bash ./submit_ena_ont.sh -m MANIFEST_DIR -i INPUT_FASTQ_DIR -o OUTPUT_DIR -p PASSWORD_FILE
  ```
