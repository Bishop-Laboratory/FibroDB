PAGE_PLOT_WIDTH = "96%"
PAGE_PLOT_HEIGHT = "650px"
ANNO_PLOT_HEIGHT = "1000px"

ExplorePageContents <- function(results) {
    fluidPage(
        title = "Explore",
        fluidRow(
            column(
                width = 6,
                GeneTable_panel(results)
            ),
            column(
                width = 6,
                OutputPanel_tabset()
            )
        )
    )
}


GeneTable_panel <- function(results) {
    tagList(
        fluidRow(
            column(width = 12,
                   h3("Explore results"),
                   hr())
        ),
        fluidRow(
            column(
                width = 6,
                selectInput(
                    inputId = "selectStudy", 
                    label = "Study",
                    selected = unique(results$study_id)[1],
                    choices = unique(results$study_id)
                ),
            )
        ),
        hr(),
        fluidRow(
            column(
                width = 12,
                makeHeaders(
                    title = "Results Table ",
                    message=paste0("Fibroblast RNA-Sequencing analysis results.")
                ),
                withSpinner(DT::DTOutput('results'))
            )
        )
    )
}


OutputPanel_tabset <- function() {
    column(
        width = 12,
        tabsetPanel(
            id = "expTabset",
            tabPanel(
                title = "Expression",
                icon=icon('chart-bar'),
                Expression_panel()
            ),
            tabPanel(
              title = "Volcano plot",
              icon=icon('mountain'),
              fluidRow(
                column(
                  width = 6,
                  hr(),
                  makeHeaders(
                    title = "Volcano plot ",
                    message=paste0("Volcano plot showing the differential gene expression results.")
                  ),
                  hr()
                )
              ),
              fluidRow(
                column(
                  width = 12,
                  plotOutput(
                    outputId = "volcanoPlot", height = "600px"
                  )
                )
              )
            ),
            tabPanel(
              title = "Heatmap",
              icon=icon("burn"),
              Heatmap_panel()
            ),
            tabPanel(
              title = "Pathway analysis",
              icon=icon("project-diagram"),
              Enrich_panel()
            ),
            tabPanel(
              title = "Comparison",
              icon=icon("adjust"),
              Venn_panel()
            )
        )
    )
}


Expression_panel <- function() {
    list(
        fluidRow(
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Gene counts ",
                    message=paste0("Gene count plots for samples in the selected study.")
                ),
                hr()
            )
        ),
        fluidRow(
          column(
            width = 12,
            selectInput(
              inputId = "selectCTS",
              choices = c("CPM", "TPM", "RPKM"),
              selected = "CPM", 
              label = "Normalization"
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            plotly::plotlyOutput(
              outputId = "countplot", height = "500px"
            )
          )
        )
    )
}


Heatmap_panel <- function() {
  list(
    fluidRow(
      column(
        width = 6,
        hr(),
        makeHeaders(
          title = "Heatmap ",
          message=paste0("Heatmap of top DEG count plots for samples in the selected study.")
        ),
        hr()
      )
    ),
    fluidRow(
      column(
        width = 12,
        selectInput(
          inputId = "selectCTS2",
          choices = c("CPM", "TPM", "RPKM"),
          selected = "CPM", 
          label = "Normalization"
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        plotOutput(
          outputId = "heatmap", height = "500px"
        )
      )
    ),
    br()
  )
}


Enrich_panel <- function() {
  list(
    fluidRow(
      column(
        width = 6,
        hr(),
        makeHeaders(
          title = "KEGG enrichment ",
          message=paste0("Heatmap of top hits from KEGG pathway enrichment in over- and under-expressed genes.")
        ),
        hr()
      )
    ),
    fluidRow(
      column(
        width = 12,
        selectInput(
          inputId = "selectCB",
          choices = c("Combined.Score", "Odds.Ratio", "Padj (-log10)"),
          selected = "Combined.Score", 
          label = "Enrichment metric"
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        plotOutput(
          outputId = "enrichPlot", height = "500px"
        )
      )
    ),
    br()
  )
}


Venn_panel <- function() {
  list(
    fluidRow(
      column(
        width = 6,
        hr(),
        makeHeaders(
          title = "DEG comparison ",
          message=paste0("Venn diagram comparing over- and under-expressed genes between studies.")
        ),
        hr()
      )
    ),
    fluidRow(
      column(
        width = 12,
        selectInput(
          inputId = "vennsel",
          choices = c("Over-expressed", "Under-expressed"),
          selected = "Over-expressed", 
          label = "DEG type"
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        plotOutput(
          outputId = "vennDiagram", height = "500px"
        )
      )
    ),
    br()
  )
}


DownloadPageContents <- function() {
  md <- paste0("
  ## FibroDB data
  
  All data in *FibroDB* were processed from a snakemake pipeline available in
  the FibroDB [GitHub repository](https://github.com/Bishop-Laboratory/FibroDB).
  
  Data are stored on a publicly-accessible AWS bucket and can be downloaded in bulk
  via the following command (assumes you have AWS CLI installed):
  
  ```shell
  aws s3 sync --no-sign-request s3://fibrodb-data/ fibrodb-data/
  ```
  
  <details>
  <summary><strong>Data details</strong></summary>
  
  <br>
  
  Data sets (below) can be downloaded here.
  * **samples.csv**
    - A CSV file detailing the samples in the dataset
    - Structure:
      * *sample_id*
        - The ID of the sample, in SRA run accession format
      * *condition*
        - The biological condition of the sample
      * *study_id*
        - The GEO ID for the study from which data were derived.
      * *paired_end*
        - A logical indicating whether the data are paired-end
      * *stranded*
        - A string indicating the strandedness of each sample.
  * **contrasts.csv**
    - A CSV file detailing the contrasts used in calculating DEGs.
    - Structure:
      * *study_id*
        - The GEO ID for the study from which data were derived.
      * *numerator*
        - In DGE analysis, the numerator 
      * *denominator*
        - In DGE analysis, the denominator
  * **degs.csv.xz**
    - An XZ-compressed CSV file containing the DEG results for comparison from *contrasts.csv*
    - Structure:
      * *study_id*
        - The GEO ID for the study from which data were derived.
      * *gene_id*
        - Ensembl gene ID
      * *fc*
        - The fold change of gene expression between the numerator and denominator (see *contrasts.csv*)
      * *pval*
        - The significance of the differential gene expression 
      * *padj*
        - The significance of the differential gene expression, with multiple testing correction
      * *sig*
        - A logical indicating whether the DGE result is significant.
  * **gene_exp.csv.xz**
    - An XZ-compressed CSV file containing the expression levels for each gene within each sample. 
    - Structure
      * *gene_id*
        - Ensembl gene ID
      * *sample_id*
        - The ID of the sample, in SRA run accession format
      * *cpm*
        - The normalized 'Counts Per Million' as derived from edgeR.
      * *rpkm*
        - The 'Reads per Kilobase of transcript, per Million mapped reads'.
      * *tpm*
        - The 'Transcripts Per Million'
  </details>
  <br>
  
  The direct download links are listed below:
    
  ")
  
  tagList(
    fluidRow(
      column(
        width = 12,
        shiny::markdown(md),
        DT::dataTableOutput('downloadLinks')
      )
    ),
    br()
  )
}

headerHTML <- function() {
    "
            html {
             position: relative;
             min-height: 100%;
           }
           body {
             margin-bottom: 60px; /* Margin bottom by footer height */
           }
           .footer {
             position: absolute;
             bottom: 0;
             width: 100%;
             height: 60px; /* Set the fixed height of the footer here */
             background-color: #373A3C;
           }
                "
}

footerHTML <- function() {
    "
    <footer class='footer'>
      <div class='footer-copyright text-center py-3'><span style='color:white'>FibroDB © 2021 Copyright:</span>
        <a href='http://heartlncrna.github.io/' target='_blank'>heartlncrna</a> 
        <span>&nbsp</span>
        <a href='https://github.com/Bishop-Laboratory/FibroDB/' target='_blank'> 
          <img src='GitHub-Mark-Light-64px.png' height='20'>
        </a>
      </div>
    </footer>
  "
}

