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
