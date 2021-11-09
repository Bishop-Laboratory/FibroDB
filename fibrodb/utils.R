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


#' Makes the global data for the app
makeGlobalData <- function(APP_DATA) {
    exp <- read_csv("../fibrodb-data/gene_exp.csv.xz")
    samples <- read_csv("../fibrodb-data/samples.csv")
    contrasts <- read_csv("../fibrodb-data/contrasts.csv")
    degs <- read_csv("../fibrodb-data/degs.csv")
    app_data <- list(
        exp=exp, samples=samples, contrasts=contrasts, degs=degs
    )
    saveRDS(app_data, file = "app_data.rds", compress = "xz")
    return(app_data)
}
