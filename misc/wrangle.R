library(tidyverse)

files <- list.files("misc", recursive = T, full.names = T, pattern = ".*CPM-Ratio.txt")
studies <- gsub(files, pattern = ".+/(GSE[0-9]+)\\-.+", replacement = "\\1")
names(files) <- studies

resList <- lapply(names(files), function(sample) {
  read_tsv(files[sample]) %>%
    select(`Ensembl Gene ID`, `Gene Symbol`, Biotype, Ensembl_ID, logFC, FDR) %>%
    mutate(sig = case_when(FDR < .05 ~ TRUE,
                           TRUE ~ FALSE)) %>%
    mutate(group = sample)
})
bind_rows(resList) %>% write_tsv(file = "misc/data_for_volcano.tsv")

