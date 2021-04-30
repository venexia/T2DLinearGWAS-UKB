rm(list=ls())
graphics.off()

# Specify paths ---------------------------------------------------------------

source("code/specify_paths.R")

# Load packages ---------------------------------------------------------------

library(magrittr)

# Specify GWAS info -----------------------------------------------------------

name <- "t2d"

pheno <- data.frame(var = "41270",
                    value3 = "E11",
                    stringsAsFactors = FALSE)

# Load data -------------------------------------------------------------------

df <- data.table::fread("data/extract.csv",
                        colClasses = c(rep("numeric",2),rep("character",260)),
                        header = TRUE, 
                        data.table = FALSE)

# Identify codes --------------------------------------------------------------

codes <- reshape2::melt(df, 
                        id.vars = c("eid","21022-0.0"),
                        variable.name = "var",
                        value.name = "value")

codes <- codes[codes$value!="",]

codes$var <- gsub("-.*","",as.character(codes$var))

codes <- unique(codes)

codes$value3 <- substr(x = codes$value, start = 1, stop = 3)

pheno_codes <- merge(pheno, codes, by = c("var","value3"))

# Mark codes in records -------------------------------------------------------

df <- df[,c("eid","21022-0.0")]
colnames(df) <- c("eid","age")
df$phenotype <- ifelse(df$eid %in% pheno_codes$eid,2,1)

# Add IEU IDs from linker data ------------------------------------------------

link <- data.table::fread("data/linker_app15825_withexcl.csv")
colnames(link) <- c("ieu","eid")
df <- merge(df,link,by = c("eid"))

# Format ----------------------------------------------------------------------

df <- df[,c("ieu","ieu","eid","phenotype","age")]
colnames(df) <- c("FID","IID","eid","phenotype","age")

# Add other covariates --------------------------------------------------------

std_covar <- data.table::fread(paste0(ukb_std_covar,"data.covariates.bolt.txt"),
                               data.table = FALSE,
                               stringsAsFactors = FALSE)

df <- merge(df,std_covar,by = c("FID","IID"))

# Format for GWAS pipeline ----------------------------------------------------

gwas_input <- df[,c("FID","IID","phenotype")]
colnames(gwas_input) <- c("FID","IID",name)

gwas_covar <- df[,c("FID","IID","age","sex","chip")]

# Save data --------------------------------------------------------------------

data.table::fwrite(gwas_input,paste0("output/",name,"_input.txt"),sep="\t",na = "")
data.table::fwrite(gwas_covar,paste0("output/",name,"_covar.txt"),sep="\t",na = "")
