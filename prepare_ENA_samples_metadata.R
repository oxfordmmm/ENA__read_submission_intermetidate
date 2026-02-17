## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
## Script name: prepare_ENA_samples_metadata.R
## Purpose of script: Prepare metadata for ENA Samples Submission
## Author: Dorottya Nagy
## Date Created: 17-02-2026
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##

# set working directory 
setwd("~/DPhil_Clin_Medicine/DPhil/NEKSUS/main_pipeline_v2/")

# Load required packages
install.packages("dplyr")
install.packages("tidyr")
install.packages("readr")
#install.packages("readxl") # uncomment if loading in excel files
library(dplyr)
library(tidyr)
library(readr)

# load in a spreadsheet of your own samples and metadata 
samples_metadata <- read.csv("samples_metadata.csv") # insert path to your own metadata file

# uncomment and use below option of your metadata is in .tsv or .txt format
#samples_metadata <- read_delim("samples_metadata.txt", delim = "\t", escape_double = FALSE, trim_ws = TRUE)

# uncomment and use below option of your metadata is in another Excel format like .xlsx format
#library(readxl)
#samples_metadata <- read_excel("samples_metadata.xlsx", col_names = TRUE)

# Examine loaded metadata 
View(samples_metadata)
# check how many samples (assuming 1 row per sample)
nrow(samples_metadata)
# check no samples are duplicated (should be same length as data frame)
length(unique(samples_metadata$sample))
#check column names 
colnames(samples_metadata)

# Wrangle data frame to include mandatory column names ####
# Mandatory column names required: (see https://www.ebi.ac.uk/ena/submit/webin/app-checklist/sample/true for desciptions and permitted values of mandatory metadata fields)
#tax_id	 - taxonomic id of species looked up from NCBI Taxonomy database (https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi) 
#scientific_name	- also from NCBI Taxonomy database (https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi) 
#sample_alias	- unique name of sample
#sample_title	- title of sample 
#sample_description	- free text descrition of sample
#isolation_source	- describes the physical, environmental and/or local geographical source of the biological sample from which the sample was derived
#collection date	- The date the sample was collected with the intention of sequencing, either as an instance (single point in time) or interval. In case no exact time is available, the date/time can be right truncated i.e. all of these are valid ISO8601 compliant times: 2008-01-23T19:23:10+00:00; 2008-01-23T19:23:10; 2008-01-23; 2008-01; 2008.
#geographic location (country and/or sea)	- Country or sea names should be chosen from the INSDC country list (http://insdc.org/country.html). 'missing' 'not collected' 'not applicable' 'not provided' if missing (see Webin portal for other permitted missing options)
#host health state	- health status of host at time of sample collection
#host scientific name	- Scientific name of the natural (as opposed to laboratory) host to the organism from which sample was obtained.
#isolate - individual isolate from which the sample was obtained
ena_metadata <- samples_metadata |>
 mutate(`collection date` = case_when(!is.na(samplecollectiondate) ~ samplecollectiondate,
                                       is.na(samplecollectiondate) ~ "2024", # right truncate missing dates
                                       TRUE ~ "missing"),
         scientific_name =  case_when(is.na(kraken2_species) ~ species,          # fill in missing species with phenotypic 'guess' as cannot have NA for Scientific name
                                      kraken2_species == "Raoultella ornithinolytica" ~ "Klebsiella ornithinolytica", # Fix Raoultella to match NCBI taxonomy names
                                      kraken2_species == "Raoultella planticola" ~ "Klebsiella planticola",
                                      TRUE ~ kraken2_species),
        # see https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi for other tax IDs
         tax_id	= case_when(scientific_name == "Escherichia coli" ~ 562,
                            scientific_name == "Escherichia albertii" ~ 208962,
                            scientific_name == "Escherichia marmotae" ~ 1499973,
                            scientific_name == "Klebsiella pneumoniae" ~ 573,
                            scientific_name == "Klebsiella oxytoca" ~ 571,
                            scientific_name == "Klebsiella aerogenes" ~ 548,
                            scientific_name == "Klebsiella grimontii" ~ 2058152,
                            scientific_name == "Klebsiella michiganensis" ~ 1134687,
                            scientific_name == "Klebsiella pasteurii" ~ 2587529,
                            scientific_name == "Klebsiella quasipneumoniae" ~ 1463165,
                            scientific_name == "Klebsiella quasivariicola" ~ 2026240 ,
                            scientific_name == "Klebsiella variicola" ~ 244366,
                            scientific_name == "Serratia marcescens"  ~ 615,
                            scientific_name == "Enterobacter hormaechei"  ~ 158836,
                            scientific_name == "Enterobacter cloacae"  ~ 550,
                            scientific_name == "Enterobacter roggenkampii"  ~ 1812935,
                            scientific_name == "Acinetobacter radioresistens"  ~ 40216,
                            scientific_name == "Citrobacter portucalensis"  ~ 1639133,
                            scientific_name == "Citrobacter freundii"  ~ 546,
                            scientific_name == "Citrobacter cronae"  ~ 1748967,
                            scientific_name == "Citrobacter farmeri"  ~ 67824,
                            scientific_name == "Citrobacter koseri"  ~ 545,
                            scientific_name == "Citrobacter sp."  ~ 1896336,
                            scientific_name == "Enterococcus faecalis"  ~ 1351,
                            scientific_name == "Enterococcus faecium"  ~ 1352,
                            scientific_name == "Micrococcus luteus"  ~ 1270,
                            scientific_name == "Proteus mirabilis"  ~ 584,
                            scientific_name == "Klebsiella ornithinolytica"  ~ 54291,
                            scientific_name == "Klebsiella planticola"  ~ 575,
                            TRUE ~ NA),
        # make unique sample identifier (sample alias)
         sample_alias	= isolateid,
         isolation_source	 = case_when(sampletype == "screening" ~ "rectal screening swab" ,
                                       sampletype == "blood" ~ "blood culture",
                                       sampletype == "unknown" ~ "unknown source",
                                       isolateid %in% c("AB21", "AB22", "AB48") ~ "urine",
                                       TRUE ~ "unknown"),
         sample_title	= paste0(scientific_name, " isolate ", sample_alias , " from human ", isolation_source),
         sample_description	= case_when(sampletype == "screening" ~ paste0("Carbapenemase-producing ", scientific_name, " isolate from human rectal screening swab collected from English hospital under NEKSUS study."),
                                        sampletype == "urine" ~ paste0("Carbapenemase-producing ", scientific_name, " isolate from human urine sample collected from English hospital under NEKSUS study."),
                                        sampletype == "unknown" ~ paste0("Unknown source ", scientific_name, " isolate from human collected from English hospital under NEKSUS study."),
                                        sampletype == "blood" ~  paste0("Bloodstream infection-associated ", scientific_name, " isolate from human blood collected from English hospital under NEKSUS study."),
                                        TRUE ~ "unknown"),
        # country of isolate collection
         `geographic location (country and/or sea)` = "United Kingdom",
        # was host healthy/diseased at time of isolate collection
         `host health state`	= case_when(sampletype == "rectal" ~ "not provided",
                                         sampletype == "unknown" ~ "not provided",
                                         sampletype == "urine" ~ "not provided",
                                         sampletype == "blood" ~ "diseased",
                                         TRUE ~ "not provided"),
        # species from which sample was taken 
         `host scientific name`	= "Homo sapiens",
        # make isolate the same as sample alias, as this dataset is pure-culture isolates, so 1 sample = 1 isolate
         isolate = sample_alias) |>
  # keep only required fields
  select(c(tax_id, scientific_name, sample_alias, sample_title, 
           sample_description, isolation_source, `collection date`, 
           `geographic location (country and/or sea)`, `host health state`,
           `host scientific name`, isolate)) |>
  # remove duplicates, as sample_alias has to be unique. NOTE: check this does not remove any samples
  group_by(sample_alias) |>
  slice_head(n = 1) |>
  ungroup() |>
# remove NA values for tax_id, which are not permitted and will throw an error during upload
  filter(!is.na(tax_id))
  
# check metadata file
View(ena_metadata)
nrow(ena_metadata) 
length(unique(ena_metadata$sample_alias)) # check no dupllicated sample_aliases, as these have to be unique (should have been removed above).
# check any dates which are not in the correct format, if needed
str(ena_metadata$`collection date`) # currently character format
ena_metadata$`collection date` <- format(ena_metadata$`collection date`, "%Y-%m-%d") # not working :/

#Combine with 2 header rows, as appears in the template spreadsheet:
ena_header1 <- data.frame(t(c("Checklist", "ERC000028", "ENA prokaryotic pathogen minimal sample checklist", rep("", ncol(ena_metadata) - 3))), stringsAsFactors = FALSE)
ena_header2 <- data.frame(t(colnames(ena_metadata)), stringsAsFactors = FALSE)
ena_header3 <- data.frame(t(c("#units", rep("", ncol(ena_metadata) - 1))), stringsAsFactors = FALSE)

# ensure all have same column names for binding rows
colnames(ena_header1) <- colnames(ena_metadata)
colnames(ena_header2) <- colnames(ena_metadata)
colnames(ena_header3) <- colnames(ena_metadata)

# Combine all rows (headers + data)
ena_combined <- rbind(ena_header1, ena_header2, ena_header3, ena_metadata)
View(ena_combined)

# Write to TSV without quotes or row names (ensure saved as .tsv or .txt or .tab))
write.table(ena_combined, file = "ena_submission_metadata.tsv", sep = "\t", row.names = FALSE, col.names = FALSE, quote = FALSE)
# upload "ena_submission_metadata.tsv" to https://www.ebi.ac.uk/ena/submit/webin/app-checklist/sample/true
