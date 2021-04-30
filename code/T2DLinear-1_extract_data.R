rm(list=ls())
graphics.off()

# Specify paths ---------------------------------------------------------------

source("code/specify_paths.R")

# Specify and extract variables from UKB --------------------------------------

vars <- c("eid","21022-0.0", # ID, Age at recruitment
          paste0("41270-0.",seq(0,212))) # ICD10 diagnoses

df <- data.table::fread(paste0(rdsf_path,"data.33352.csv"),
                        sep = ",", 
                        header = TRUE, 
                        select = vars,
                        data.table = FALSE)

# Save dataset ----------------------------------------------------------------

data.table::fwrite(df,"data/extract.csv")