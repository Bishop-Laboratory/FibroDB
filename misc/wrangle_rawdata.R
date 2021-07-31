library(tidyverse)

# Wrangle in the files
raw_data <- list.files("fibrodb/misc/raw_data/", full.names = TRUE, recursive = TRUE)
files <- raw_data[! grepl(raw_data, pattern = "List-Steps")]
df_lst <- map(files, read_tsv) 
names(df_lst) <- gsub(files, pattern = ".+//(.+)/GSE.+\\-([CPMKRT]+)[\\.\\-]+.*txt",
                      replacement = "\\1__xXx__\\2")

# SRR to column mapping
# TODO: Not possible because the necessary data isn't provided.... Continue without for now.
# The code below will work once the appropriate List.Steps-*.txt files are provided.
steps <- raw_data[grepl(raw_data, pattern = "List-Steps")]
names(steps) <- gsub(steps, pattern = ".+//(GSE.+)/List.+txt", replacement = "\\1")
lapply(
  names(steps), function(study) {
    stepnow <- steps[[study]]
    lins <- read_lines(stepnow)
    srrline <- lins[grep(lins, pattern = "paste SRR.+")]
    srrs <- str_extract_all(srrline, pattern = "SRR[0-9]+", simplify = F) %>%
      unlist()
    
    colnameline <- lins[grep(lins, pattern = "colnames\\(x\\)<\\-c\\(.+")]
    colnms <- str_match_all(colnameline, pattern = "\\\"([a-zA-Z0-9_\\-]+)\\\"")[[1]][,2]
    
    return(tibble(
      "study" = study,
      "sample_id" = srrs,
      "sample_name" = colnms
    ))
  }
) %>%
  bind_rows() %>%
  read_csv("fibrodb/misc/clean_data/samples.csv")

read_csv("fibrodb/misc/clean_data/samples.csv") %>%
  left_join(
    tibble(
      "study_id" = c("GSE140523", "GSE149413", "GSE97829", "GSE123018"),
      "paired_end" = c(FALSE, FALSE, TRUE, TRUE)
    ), by = c("study_id")
  ) %>% write_csv("fibrodb/misc/snake_out/samples.csv")

 


# Data munging
res <- plyr::llply(names(df_lst), function(dat) {
  print(dat)
  df <- df_lst[[dat]]
  study <- gsub(dat, pattern = "(.+)__xXx__(.+)", replacement = "\\1")
  type <- gsub(dat, pattern = "(.+)__xXx__(.+)", replacement = "\\2")
  df %>%
    select(! contains(c("Ensembl_ID", "Gene Symbol", "Biotype")) &
           ! matches("^Abdomen$")) %>%
    mutate(study = !! study,
           type = !! type) %>%
    pivot_longer(cols = ! contains(c("Ensembl", "study", "type"))) %>%
    mutate(data_group = case_when(
      name %in% c("FDR", "logCPM", "logFC", "LR", "PValue") ~ "degs",
      TRUE ~ "counts"
    ))
}) %>%
  bind_rows() %>%
  group_by(data_group) %>%
  {setNames(group_split(.), group_keys(.)[[1]])} %>%
  lapply(function(df) {
    data_group <- df$data_group[1]
    if (data_group == "degs") {
      df %>%
        select(-data_group, - type) %>%
        distinct( `Ensembl Gene ID`, study, name, .keep_all = TRUE) %>%  # TODO: BAD HACK
        pivot_wider(id_cols = c("Ensembl Gene ID", "study"), names_from = name, values_from = value) %>%
        write_csv(paste0(data_group, ".csv"))
    } else {
      df %>%
        select(-data_group, -study) %>%
        pivot_wider(names_from = type) %>%
        write_csv(paste0(data_group, ".csv"))
    }
  })



