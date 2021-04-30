source("code/specify_paths.R", echo = TRUE)

# Load GWAS input
input <- data.table::fread("output/t2d_input.txt",
                           data.table = FALSE)

# Record case/control counts
ncase <- nrow(input[input$t2d==2,])
ncont <- nrow(input[input$t2d==1,])
mu <- ncase / (ncase + ncont)

# Load GWAS output
df <- data.table::fread(paste0(output_path, "t2d/65ac2851-b408-4f09-baf7-5baf310a3196/t2d_imputed.txt.gz"), 
                        data.table = FALSE, 
                        fill = TRUE,
                        stringsAsFactors = FALSE)

# Add logOR
df$logOR <- df$BETA / (mu * (1-mu))
df$se_logOR <- df$SE / (mu * (1-mu))

# Identify genome-wide significant hits
df_gws <- df[df$P_LINREG<5e-8 & !is.na(df$P_LINREG),]

# Clump genome-wide significant hits
df_gws$rsid <- df_gws$SNP
df_gws$pval <- df_gws$P_LINREG
df_clump <- ieugwasr::ld_clump(df_gws)
