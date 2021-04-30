rm(list=ls())
graphics.off()

# Specify paths ---------------------------------------------------------------

source("code/specify_paths.R")

# Load data -------------------------------------------------------------------

df <- data.table::fread(paste0(rdsf_path,"linker_app15825.csv"),
                        header = TRUE, 
                        data.table = FALSE)

# Restrict to europeans ------------------------------------------------------

eur <- data.table::fread(paste0(ukb_qc_path,"ancestry/data.europeans.qctools.txt"),
                         header = FALSE, 
                         data.table = FALSE)

df <- df[(df$ieu %in% eur$V1),]

# Recommended exclusions ------------------------------------------------------
# for sex_mismatch, putative_sex_chromosome_aneuploidy and het_missing_outliers

excl <- data.table::fread(paste0(ukb_qc_path,"standard_exclusions/data.combined_recommended.qctools.txt"),
                                 header = FALSE, 
                                 data.table = FALSE)

df <- df[!(df$ieu %in% excl$V1),]
                          
# Remove relateds -------------------------------------------------------------

rel_high <- data.table::fread(paste0(ukb_qc_path,"related/relateds_exclusions/data.highly_relateds.qctools.txt"),
                          header = FALSE, 
                          data.table = FALSE)

df <- df[!(df$ieu %in% rel_high$V1),]

# Remove those who have withdrawn consent

withdraw <- data.table::fread("raw/w15825_20210201.csv",
                              header = FALSE,
                              data.table = FALSE)


df <- df[!(df$app %in% withdraw$V1),]

# Save ------------------------------------------------------------------------

data.table::fwrite(df,"data/linker_app15825_withexcl.csv")
