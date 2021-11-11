# Libraries
library(shiny)
library(shinycssloaders)
library(prompter)
library(dplyr)
library(ggplot2)

# Get constants
source("utils.R")
results <- readRDS("app_data.rds")  # from makeGlobalData()
results_show <- results %>%
    select(gene_name, study_id, numerator, 
           denominator, fc, padj) %>%
    distinct(gene_name, study_id, .keep_all = TRUE) 

source("ui_globals.R")
GENECARDS_BASE <- "https://www.genecards.org/cgi-bin/carddisp.pl?gene="
GEO_BASE <- "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc="
S3_HTTPS <- "https://fibrodb-data.s3.amazonaws.com/"

# Define UI for application that draws a histogram
ui <- function(request) {
    tagList(
        tags$head(tags$style(HTML(headerHTML())),
                  tags$script(src="https://kit.fontawesome.com/5071e31d65.js", crossorigin="anonymous")),
        use_prompt(),
        navbarPage(
            title = "FibroDB",
            id = "fibrodb",
            theme = bslib::bs_theme(bootswatch = "cosmo"),
            tabPanel(title = "Home", id = "home-tab", value = "aboutTab", icon = icon("home"),
                     fluidPage(
                         br(), 
                         includeHTML("www/home.html"),
                     )),
            tabPanel(title = "Explore", id = "explore-tab", icon = icon('table'),
                     ExplorePageContents(results)),
            tabPanel(title = "Download", id = "download-tab", icon = icon('download'),
                     DownloadPageContents()),
            tabPanel(title = "Documentation", id = "docs-tab", icon = icon('file-alt'),
                     tags$iframe(src = './documentation.html', width = '100%', height = '800px',
                                 frameborder = 0, scrolling = 'auto'))
        ), 
        tags$footer(HTML(footerHTML()))
    )
}


# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    ## Results table
    output$results <- DT::renderDT(server = TRUE, {
        req(input$selectStudy)
        results_show %>%
            filter(study_id == input$selectStudy) %>%
            mutate(
                gene_name = paste0("<a href='", paste0(GENECARDS_BASE, gene_name),
                                   "' target='_blank'>", gene_name, "</a>"),
                study_id = paste0("<a href='", paste0(GEO_BASE, study_id), 
                                  "' target='_blank'>", study_id, "</a>")
            ) %>%
            DT::datatable(
                selection = list(mode = "single", selected = 1),
                rownames = FALSE, escape = FALSE,
                colnames = c("Gene", "Study", "Numerator", "Denominator", "Fold Change (log2)", "FDR"),
                options = list(pageLength = 6, scrollX = TRUE)
            )
    })
    
    ## Get currently-selected gene
    current_gene <- reactive({
        # Get selected row from datatable
        selectedRow <- ifelse(is.null(input$results_rows_selected),
                              1,
                              input$results_rows_selected)
        results_show %>%
            filter(study_id == input$selectStudy) %>%
            dplyr::filter(row_number() == selectedRow) %>%
            pull(gene_name)
    })
    
    ## Count plot
    output$countplot <- plotly::renderPlotly({
        cts_sel <- input$selectCTS
        gene <- current_gene()
        study <- input$selectStudy
        plt <- results %>%
            filter(
                study_id == {{ study }},
                gene_name == {{ gene }}
            ) %>%
            rename(
                counts = contains(cts_sel)
            ) %>%
            ggplot(
                aes(x = condition, y = counts, fill = condition)
            ) +
            geom_boxplot(width = .65, alpha = .6, outlier.shape = NA) +
            geom_jitter(width = .15) +
            xlab("Sample condition") +
            ylab(paste0("Expression (", cts_sel, ")")) +
            theme_gray(base_size = 13) + 
            ggtitle(gene) +
            theme(legend.position = "none")
        plotly::ggplotly(plt)
    }) #%>% bindCache(input$selectCTS, input$selectStudy, current_gene())
    
    ## Volcano plot
    output$volcanoPlot <- renderPlot({
        gene <- current_gene()
        study <- input$selectStudy
        toplt <- results_show %>%
            filter(
                study_id == {{ study }}
            )
        req(! is.na(toplt$padj[1]))
        ttl <- paste0(toplt$numerator[1], " vs. ", toplt$denominator[1])
        pltdata <- toplt %>%
            mutate(
                hlight = gene_name == {{ gene }},
                padj = case_when(
                    padj == 0 ~ .Machine$double.xmin, TRUE ~ padj
                ),
                padj = -log10(padj),
                sigcond = case_when(
                    padj < 3 ~ "n.s.",
                    abs(fc) < 1 ~ "sig-only",
                    fc > 1 ~ "Over-expressed",
                    fc < -1 ~ "Under-expressed"
                )
            ) %>%
            arrange(hlight, desc(padj)) 
        maxval <- max(pltdata$padj)
        pltdata %>%
            ggplot(
                aes(x = fc, y = padj, color = sigcond, size = hlight)
            ) +
            geom_vline(xintercept = 1, linetype = "dashed", alpha = .25) +
            geom_vline(xintercept = -1, linetype = "dashed", alpha = .25) +
            geom_hline(yintercept = 3, linetype = "dashed", alpha = .25) +
            geom_point() +
            xlab("Log2 Fold Change") +
            ylab("P adjusted value (-log10)") +
            guides(size = guide_none(),
                   color = guide_legend(title = NULL)) +
            theme_bw(base_size = 18) + 
            scale_y_continuous(expand = c(0,0), limits = c(0, 1.05*maxval)) +
            ggtitle(ttl, subtitle = gene) +
            scale_color_manual(
                values = c(
                    "n.s." = "#d6d6d6",
                    "sig-only" = "#91bac4",
                    "Over-expressed" = "#2fa4c2",
                    "Under-expressed" = "#c24e2f"
                )
            ) + 
            theme(legend.position = "bottom", legend.text=element_text(size=16)) 
    }) #%>% bindCache(input$selectStudy, current_gene())
    
    
    ## Downloads
    output$downloadLinks <- DT::renderDT({
        tibble(
            File = c("contrasts.csv", "degs.csv.gz", "gene_exp.csv.gz", "samples.csv")
        ) %>% 
            mutate(
                Download = paste0(
                    "<a href='",
                    paste0(S3_HTTPS, File), 
                    "' target='_blank'>link</a>"
                ) 
            ) %>%
            DT::datatable(
                selection = list(mode = "none"),
                rownames = FALSE, escape = FALSE, options = list(dom = 't')
            )
    })
    
}

# Run the application 
graphics.off()
shinyApp(ui, server)
