library(tidyverse)
library(EnsDb.Hsapiens.v86)

# Get ensembl data
ensGene <- AnnotationDbi::select(EnsDb.Hsapiens.v86, keys = keys(EnsDb.Hsapiens.v86, keytype = "GENEID"),
       columns = c("ENTREZID", "SYMBOL", "GENEBIOTYPE"))
colnames(ensGene) <- c("gene_id", "entrez_id", "gene_symbol", "gene_biotype")

# Get aliases and wrangle
## Build Queries
dbCon <- org.Hs.eg.db::org.Hs.eg_dbconn()
sqlQuery <- 'SELECT * FROM alias, genes WHERE alias._id == genes._id;'
sqlQuery2 <- 'SELECT * FROM alias, gene_info WHERE alias._id == gene_info._id;'
## Query
dat1 <- DBI::dbGetQuery(dbCon, sqlQuery)[,c(-1)] %>%
  rename(entrez_id=gene_id)
dat2 <- DBI::dbGetQuery(dbCon, sqlQuery2)[,c(-1)] %>%
  dplyr::select(`_id`, description=gene_name)
## Wrangle
aliasSymbol <- left_join(dat1, dat2,  by = "_id") %>%
  dplyr::select(-`_id`) %>%
  unique()


# Ensembl data with entrez data and finalize dataset
res <- full_join(x = mutate(ensGene, entrez_id = as.character(entrez_id)),
                 y = aliasSymbol, by = c("entrez_id")) %>%
  filter(! is.na(gene_id)) %>%
  select(-entrez_id) %>%
  unique()


# Write to gene csv and compress
dplyr::select(res, -alias_symbol) %>%
  unique() %>%
  write_csv(file = "genes.csv")
system("xz -f genes.csv")

# Write to gene_aliases.csv and compress
dplyr::select(res, alias_symbol, gene_id) %>%
  unique() %>%
  write_csv(file = "gene_aliases.csv")
system("xz -f gene_aliases.csv")
