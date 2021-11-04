# UI function to make ? button
helpButton <- function(message) {
    return(
        with_tippy(
            element = span(
                HTML('<i class="fa fa-question-circle"></i>')), 
            tooltip = message, placement = "right"
        )
    )
    
}

#' Make headers
makeHeaders <- function(title, message, fs=1.3) {
    tagList(
        span(span(title, style=paste0("font-size: ", fs, "em;")), helpButton(message))
    )
}


#' Makes a gene cards link for an official gene symbol
makeGeneCards <- function(x) {
    GENECARDS_BASE <- "https://www.genecards.org/cgi-bin/carddisp.pl?gene="
    as.character(a(
        href=paste0(GENECARDS_BASE, x),
        target="_blank",
        x
    ))
}

#' Makes the global data for the app
makeGlobalData <- function(APP_DATA) {
    exp <- read_csv("../database/fibro_data/gene_exp.csv.xz")
    samples <- read_csv("../database/fibro_data/samples.csv")
    contrasts <- read_csv("../database/fibro_data/contrasts.csv")
    degs <- read_csv("../database/fibro_data/degs.csv")
    app_data <- list(
        exp=exp, samples=samples, contrasts=contrasts, degs=degs
    )
    saveRDS(app_data, file = "app_data.rds", compress = "xz")
    return(app_data)
}
