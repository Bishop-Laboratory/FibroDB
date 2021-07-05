library(EnsDb.Hsapiens.v86)

# Get dataset
genes <- select(EnsDb.Hsapiens.v86, keys = keys(EnsDb.Hsapiens.v86, keytype = "GENEID"),
       columns = c("SYMBOL", "GENEBIOTYPE"))
colnames(genes) <- c("gene_id", "gene_symbol", "gene_biotype")

# Write to csv and compress
write.csv(genes, file = "genes.csv", row.names = FALSE)
system("xz -f genes.csv")
