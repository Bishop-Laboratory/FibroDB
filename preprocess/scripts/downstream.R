library(edgeR)
library(tidyverse)

if (interactive()) {
  ## For development only - requires R Project File ##
  setwd(paste0(rprojroot::find_rstudio_root_file(), "/misc/snake_out/"))
  counts <- list.files("counts", full.names = TRUE)
  samples <- read_csv("samples.csv")
  contrasts <- read_csv("contrasts.csv")
  txdb <- GenomicFeatures::makeTxDbFromGFF(file = "~/genomes/Homo_sapiens.GRCh38.103.gtf")
  out_counts <- "fibro_data/gene_exp.csv"
  out_degs <- "fibro_data/degs.csv"
} else {
  counts <- snakemake@input$counts
  samples <- read_csv(snakemake@input$samples)
  contrasts <- read_csv(snakemake@input$contrasts)
  txdb <- GenomicFeatures::makeTxDbFromGFF(file = snakemake@input$gtf)
  out_counts <- snakemake@output$counts
  out_degs <- snakemake@output$degs
}

# Helper functions
mat_longify <- function(x) {
  as.data.frame(x) %>%
    rownames_to_column(var = "gene_id") %>%
    pivot_longer(cols = contains("SRR"))
}
tpm_from_rpkm <- function(x){
  # http://luisvalesilva.com/datasimple/rna-seq_units.html
  rpkm.sum <-colSums(x)
  return(t(t(x) / (1e-06 * rpkm.sum)))
}

# Get gene lengths
geneLengths <- GenomicFeatures::transcriptsBy(txdb, 'gene') %>%
  GenomicRanges::reduce() %>%
  GenomicRanges::width() %>%
  sum()

# Compile count matrix
mat <- lapply(counts, function(x) {
  sample_id <- gsub(x, pattern = "counts/(.+)\\.counts\\.tsv", replacement = "\\1")
  strand <- samples$stranded[samples$sample_id == sample_id]
  read_tsv(x, skip=4, 
           col_names = c("gene_id", "unstranded",
                         "forward", "reverse")) %>%
    select(gene_id, contains(!! strand)) %>%
    rename(counts = contains(!! strand)) %>%
    mutate(sample_id = !! sample_id)
}) %>%
  bind_rows() %>%
  pivot_wider(names_from = sample_id, values_from = counts) %>%
  column_to_rownames(var="gene_id") %>%
  as.matrix()

# Get normalized CPM within study
cpms <- lapply(unique(samples$study_id), function(study) {
  samps <- samples$sample_id[samples$study_id == study]
  mat[,samps] %>%
    DGEList() %>%
    calcNormFactors() %>%
    cpm() %>%
    mat_longify() %>%
    rename(sample_id=name, cpm=value)
}) %>%
  bind_rows()

# Get RPKM
rpkm_mat <- rpkm(mat, geneLengths[rownames(mat)])
rpkms <- rpkm_mat %>%
  mat_longify() %>%
  rename(sample_id=name, rpkm=value)

# Get TPM
tpms <- tpm_from_rpkm(rpkm_mat) %>%
  mat_longify() %>%
  rename(sample_id=name, tpm=value)

# Combine mats and output counts
purrr::reduce(list(cpms, rpkms, tpms), inner_join, by = c("gene_id", "sample_id")) %>%
  write_csv(out_counts)

# Analyze DEGs within study
lapply(unique(contrasts$study_id), function(study) {
  # Get samples and factor levels
  numerator <- contrasts$numerator[contrasts$study_id == study]
  denominator <- contrasts$denominator[contrasts$study_id == study]
  deg_samps <- samples %>%
    filter(study_id == !! study) %>%
    mutate(group = case_when(
      condition == !! numerator ~ 2,
      condition == !! denominator ~ 1,
      TRUE ~ 0
    )) %>%
    filter(group != 0)
  
  # DGE analysis
  groups <- factor(deg_samps$group)
  design <- model.matrix(~0+groups)
  mat[,deg_samps$sample_id] %>%
    DGEList(group = groups) %>%  
    calcNormFactors() %>% # TODO: Fix repetition with above CPM code
    estimateGLMCommonDisp(design) %>%
    estimateGLMTrendedDisp(design) %>%
    estimateGLMTagwiseDisp(design) %>%
    glmFit(design) %>%
    glmLRT(contrast = c(-1, 1)) %>%
    topTags(n="Inf") %>%
    pluck("table") %>%
    rownames_to_column(var = "gene_id") %>%
    mutate(study_id = !!study,
           sig = ifelse(FDR < .05 & ! is.na(FDR), TRUE, FALSE)) %>%
    select(study_id, gene_id, fc=logFC, pval=PValue, padj=FDR, sig)
}) %>%
  bind_rows() %>%
  write_csv(out_degs)


