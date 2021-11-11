# UI function to make ? button
helpButton <- function(message) {
    return(
        add_prompt(
            ui_element = span(
                HTML('<i class="fa fa-question-circle"></i>')),
            message = message, position = "right"
        )
    )
    
}

#' Make headers
makeHeaders <- function(title, message, fs=1.3) {
    tagList(
        span(span(title, style=paste0("font-size: ", fs, "em;")), helpButton(message))
    )
}


#' #' Makes the global data for the app
#' makeGlobalData <- function(APP_DATA) {
#'     exp <- read_csv("https://fibrodb-data.s3.amazonaws.com/gene_exp.csv.gz")
#'     samples <- read_csv("https://fibrodb-data.s3.amazonaws.com/samples.csv")
#'     contrasts <- read_csv("https://fibrodb-data.s3.amazonaws.com/contrasts.csv")
#'     degs <- read_csv("https://fibrodb-data.s3.amazonaws.com/degs.csv.gz")
#'     app_data <- list(
#'         exp=exp, samples=samples, contrasts=contrasts, degs=degs
#'     )
#'     ens2sym <- EnsDb.Hsapiens.v86::EnsDb.Hsapiens.v86 %>%
#'         AnnotationDbi::select(
#'             ., AnnotationDbi::keys(.), columns = "SYMBOL"
#'         ) %>% rename(gene_id=GENEID, gene_name=SYMBOL)
#'     results <- full_join(
#'         exp, samples
#'     ) %>% 
#'         full_join(
#'             degs
#'         ) %>%
#'         full_join(
#'             contrasts
#'         ) %>%
#'         inner_join(
#'             ens2sym
#'         )
#'     results <- results %>%
#'         relocate(gene_name) %>% 
#'         arrange(padj) 
#'     saveRDS(results, file = "app_data.rds", compress = "xz")
#'     return(app_data)
#' }
