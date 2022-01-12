# Libraries
library(shiny)
library(shinycssloaders)
library(prompter)
library(dplyr)
library(tidyr)
library(ComplexHeatmap)
library(tibble)
library(futile.logger)
library(ggplot2)
# library(BiocManager)
# options(repos = BiocManager::repositories())

# Disable futile logger for venn
futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")

# Get constants
source("utils.R")
results <- readRDS("app_data.rds")  # from makeGlobalData()
eres <- readRDS("eres.rds")  # from makeGlobalData()

## Correct an error where GSE149414's labels are backwards ##
# TODO: Should probably fix this permanently when you get a chance
results <- results %>% 
    mutate(
        fc = case_when(
            study_id == "GSE149413" ~ -1 * fc, TRUE ~ fc
        ),
        numerator = case_when(
            study_id == "GSE149413" ~ "Thrombus", TRUE ~ numerator
        ),
        denominator = case_when(
            study_id == "GSE149413" ~ "Adventitia", TRUE ~ denominator
        )
    )
eres$GSE149413 <- eres$GSE149413 %>% 
    mutate(
        group = ifelse(group == "Under-expressed", "Over-expressed", "Under-expressed")
    )
#############################################################

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
        tags$head(
            tags$style(HTML(headerHTML())),
            tags$script(src="https://kit.fontawesome.com/5071e31d65.js", crossorigin="anonymous"),
            tags$link(rel="stylesheet", type="text/css", href="https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.1/cookieconsent.min.css")
        ),
        tags$body(
            tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.1/cookieconsent.min.js", `data-cfasync`="false"),
            # tags$script(src="cookie_consent.js")  # Uncomment for cookie consent form
        ),
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
    
    ## Heatmap
    output$heatmap <- renderPlot({
        study <- input$selectStudy
        toplt <- results_show %>%
            filter(
                study_id == {{ study }}
            )
        req(! is.na(toplt$padj[1]))
        ttl <- paste0(toplt$numerator[1], " vs. ", toplt$denominator[1])
        g2plt <- toplt %>%
            mutate(
                sigcond = case_when(
                    padj > 0.05 ~ "n.s.",
                    abs(fc) < 1 ~ "sig-only",
                    fc > 1 ~ "Over-expressed",
                    fc < -1 ~ "Under-expressed"
                )
            ) %>%
            filter(sigcond %in% c("Over-expressed", "Under-expressed")) %>% 
            group_by(sigcond) %>% 
            slice_min(
                order_by = padj, n = 12
            ) %>% pull(gene_name)
        
        cts_sel <- input$selectCTS2
        study <- input$selectStudy
        annot <- results
        topvt <- results %>%
            filter(
                study_id == {{ study }},
                gene_name %in% g2plt
            ) %>% 
            rename(
                counts = contains(cts_sel)
            ) 
        annot <- topvt %>% 
            select(sample_id, condition) %>% 
            unique() %>% 
            column_to_rownames("sample_id")
        plt <- pivot_wider(  
            data = topvt,
            id_cols = gene_name, names_from = sample_id, values_from = counts
        ) %>% 
            column_to_rownames("gene_name") %>% 
            as.matrix() %>% 
            pheatmap(
                scale = "row",
                angle_col = "45",
                annotation_col = annot,
                name = cts_sel,
                main = ttl
            )
        plt
    }) #%>% bindCache(input$selectStudy, current_gene())
    
    ## enrichment plot
    output$enrichPlot <- renderPlot({
        study <- input$selectStudy
        toplt <- results_show %>%
            filter(
                study_id == {{ study }}
            )
        req(! is.na(toplt$padj[1]))
        ttl <- paste0(toplt$numerator[1], " vs. ", toplt$denominator[1])
        
        pltdat <- eres[[study]]
        topick <- pltdat %>% 
            group_by(group) %>% 
            slice_max(Combined.Score, n = 8) %>% pull(Term)
        colby <- input$selectCB
        pltdat %>% 
            filter(pltdat$Term %in% topick) %>% 
            mutate(
                `Padj (-log10)`=-log10(Adjusted.P.value)
            ) %>% 
            rename(
                colby = contains(colby)
            ) %>% 
            pivot_wider(
                id_cols = Term, names_from = group, 
                values_from = colby,
                values_fill = 0
            ) %>% 
            column_to_rownames("Term") %>% 
            as.matrix() %>% 
            pheatmap(
                # scale = "col",
                angle_col = "45",
                name = colby,
                main = ttl
            )
    })
    
    
    ## Comparison
    output$vennDiagram <- renderPlot({
        upres <- results_show %>%
            filter(! is.na(padj) & padj < .05 & abs(fc) > 1) %>%
            mutate(
                group = case_when(
                    fc > 0 ~ "Over-expressed",
                    TRUE ~ "Under-expressed"
                ),
                study_id = paste0(study_id, " - ", numerator, " vs. ", denominator)
            ) %>% 
            group_by(group) %>%
            {setNames(group_split(.), group_keys(.)[[1]])} %>%
            lapply(
                function(x) {
                    dd <- x %>% 
                        group_by(study_id) %>% 
                        {setNames(group_split(.), group_keys(.)[[1]])} %>% 
                        lapply(pull, gene_name) %>% 
                        VennDiagram::venn.diagram(filename = NULL, col = c("firebrick", "goldenrod", "skyblue"), margin = .1)
                        # # UpSetR::fromList() %>% 
                        # # UpSetR::upset(text.scale = 1.5)
                        # make_comb_mat() %>% UpSet(column_title='asd')
                    
                }
            )    
        grid.draw(upres[[input$vennsel]])
    })
    
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
