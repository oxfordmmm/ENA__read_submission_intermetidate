# ENA__read_submission_intermetidate
Instructions and helper scripts for batch read submission to the European Nucleotide Archive (ENA) using interactive Study and Sample registration on the Webin submission portal, and webin-cli for read submission. The example provided is for prokaryotic pathogen submission with minimum metadata and ONT long reads, but is adaptable. 

## Options for ENA Read submission 
There are 3 ways to upload sequencing data to ENA:
1. Interactively - using the [Webin Submission Portal webiste](https://www.ebi.ac.uk/ena/submit/webin/login) - only for a small number of samples.
2. Using the [Webin-CLI tool](https://ena-docs.readthedocs.io/en/latest/submit/general-guide/webin-cli.html) - instrictions below, uses command-line, is approporiate for large batch submissions.
3. Programatically - using XML files for completely automated workflows. See this [Nextflow submission workflow](https://github.com/oxfordmmm/minimal_pathogen_fq_ENA_upload).
More about [ENA read submission options](https://ena-docs.readthedocs.io/en/latest/submit/reads.html).

## Overview of ENA Read submission procedure
**Reads** submitted to ENA have to be linked to a **Study** and a **Sample**. More about the [ENA metadata structure](https://ena-docs.readthedocs.io/en/latest/submit/general-guide/metadata.html).

The steps involved in uploading reads to the ENA are: 
1. Make a [Webin submission portal](https://www.ebi.ac.uk/ena/submit/webin/login) account and log in
2. Register a **Study** [Webin website](https://www.ebi.ac.uk/ena/submit/webin/study)
3. Register **Samples** [Webin website tsv file upload](https://www.ebi.ac.uk/ena/submit/webin/app-checklist/sample/true)
4. Submit **Raw Reads** [Webin-CLI command-line tool](https://github.com/enasequence/webin-cli)
(5. +/- Optional submission on assemblies/annotations)
These ateps are detailed below:

### 1. Make a Webin account and login

### 2. Register Study (interactively on website)

### 3. Register Samples (interactively on website)

### 4. Submit Reads (using webin-cli tool)
