PAGE_PLOT_WIDTH = "96%"
PAGE_PLOT_HEIGHT = "650px"
ANNO_PLOT_HEIGHT = "1000px"
DEFAULT_STUDY = samples$study_id[1]

ExplorePageContents <- function() {
    fluidPage(
        title = "Explore",
        fluidRow(
            column(
                width = 5,
                GeneTable_panel()
            ),
            column(
                width = 7,
                OutputPanel_tabset()
            )
        )
    )
}


GeneTable_panel <- function() {
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
                    selected = DEFAULT_STUDY,
                    choices = unique(samples$study_id)
                ),
            )
        ),
        hr(),
        fluidRow(
            column(
                width = 12,
                makeHeaders(
                    title = "FibroDB Samples Table ",
                    message=paste0("Fibroblast RNA-Sequencing analysis results",
                                   " across several studies. Selecting a row",
                                   " in the table will update the outputs on",
                                   " the right-hand side of the screen.")
                ),
                DTOutput('fibrodbSamples')
            )
        )
    )
}


OutputPanel_tabset <- function() {
    column(
        width = 12,
        tabsetPanel(
            id = "rmapSampsTabset",
            tabPanel(
                title = "Summary",
                icon=icon('chart-pie'),
                Summary_panel()
            ),
            tabPanel(
                title = "Sample-sample comparison",
                icon = icon('check-double'),
                br(),
                Sample_Sample_panel()
            ),
            tabPanel(
                title = "Annotation",
                icon = icon("paint-brush"),
                Annotation_panel()
            ),
            tabPanel(
                title = "RLFS",
                icon = icon('wave-square'),
                RLFS_panel()
            ),
            tabPanel(
                title = "RL Regions",
                icon = icon('map'),
                br(),
                RLoops_Panel()
            ),
            tabPanel(
                title = "Downloads",
                icon = icon('download'),
                br(),
                fluidRow(
                    column(
                        width = 6, offset = 3,
                        hr(),
                        makeHeaders(
                            title = "Sample downloads ",
                            message = paste0("Sample downloads list. Hover over help icons for information about each.", 
                                             " See 'Download' for more detail.")
                        ),
                        hr(),
                        Downloads_panel()
                    )
                )
            )
        )
    )
}


RLFS_panel <- function() {
    tagList(
        fluidRow(
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "R-loop forming sequences (RLFS) analysis results ",
                    message = paste0("R-loop forming sequences (RLFS) analysis summary.",
                                     "'RLFS-PVAL': the pvalue from permutation testing.",
                                     "'Num. Peaks Available: the number of peaks in the selected sample.'",
                                     "'Labeled Condition': the labeled condition based on sample metadata in GEO/SRA.",
                                     "'Predicted Condition': the predicted condition based on the quality mode.",
                                     "See Documentation for more detail.")
                ),
                hr(),
                htmlOutput(outputId = "RLFSOutHTML")
            ),
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Z-score distribution plot ",
                    message = paste0("Plot showing the enrichment of sample peaks within RLFS. See Documentation for more detail.")
                ),
                hr(),
                plotOutput('zScorePlot')
            )
        ),
        fluidRow(
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Permutation test plot ",
                    message = paste0("Plot showing the results of permutation testing. ",
                                     "Green bar shows actual number of overlaps between",
                                     " sample peaks and RLFS in comparison with the random distribution.",
                                     " See Documentation for more detail.")
                ),
                hr(),
                plotOutput('pValPlot')
            ),
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Fourier transform plot ",
                    message = paste0("Plot of the Fourier transform of the Z-score distribution.",
                                     " See Documentation for more detail.")
                ),
                hr(),
                plotOutput('FFTPlot')
            )
        )
    )
}


Annotation_panel <- function() {
    tagList(
        fluidRow(
            column(
                width = 12,
                hr(),
                makeHeaders(
                    title = "Sample annotations ",
                    message = paste0("Sample annotation plots show the enrichment of genomic features within the RLBase samples. ",
                                     "The &#9670; shows the location of the select sample in 'RLBase Samples Table'. ",
                                     "See Documentation for more detail.")
                ),
                hr()
            )
        ),
        fluidRow(
            column(
                width = 6,
                selectInput(
                    inputId = "splitby",
                    label = "Split",
                    choices = c("prediction", "label", "none"),
                    selected = "prediction"
                )
            )
        ),
        fluidRow(
            column(
                width = 12,
                uiOutput(outputId = "annoPlots")
            )
        )
    )
}

Summary_panel <- function() {
    list(
        fluidRow(
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Sample summary ",
                    message=paste0("A high-level summary for the sample that is selected in the 'Sample Table'.",
                                   " Hover over the help icons for each row to learn more.")
                ),
                hr(),
                uiOutput("sampleSummary")
            ),
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "R-loop mapping modalities ",
                    message=paste0("Representation of R-loop mapping modalities in",
                                   " selected data. Use 'Table Controls' to adjust ",
                                   " this. See Documentation for more detail.")
                ),
                hr(),
                withSpinner(plotlyOutput("modeDonut"))
            )
        ),
        fluidRow(
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Sample labels ",
                    message=paste0("Representation of sample labels among the",
                                   " selected data. 'POS' indicates a sample which was ",
                                   " expected to map R-loops (e.g., 'S9.6 -RNH1' in DRIP-Seq) and ",
                                   " 'NEG' indicates a sample which was not expected to map",
                                   " R-loops (e.g., 'S9.6 +RNH1' or 'Genomic Input').",
                                   " See Documentation for more detail.")
                ),
                hr(),
                withSpinner(plotlyOutput("labelDonut"))
            ),
            column(
                width = 6,
                hr(),
                makeHeaders(
                    title = "Sample quality prediction ",
                    message=paste0("Representation of sample quality predictions among the",
                                   " selected data. 'POS' indicates a sample which was ",
                                   " predicted by the RLSeq quality model to map R-loops robustly and ",
                                   " 'NEG' indicates a sample which was predicted to map R-loops poorly.",
                                   " 'null' indicates samples for which no peaks were found by macs3.",
                                   " See Documentation for more detail.")
                ),
                hr(),
                withSpinner(plotlyOutput("predictionDonut"))
            )
        )
    )
}


Sample_Sample_panel <- function() {
    tabsetPanel(
        id = "RMapSamplesSummary",
        type = "pills",
        tabPanel(
            title = "Heatmap", icon = icon("fire-alt"),
            hr(),
            makeHeaders(
                title = "Sample Heatmap ",
                message=paste0("The sample heatmap displays the sample-sample pearson ",
                               "correlation around gold-standard R-loop sites.",
                               "The 'group' annotation on the heatmap shows the location of the sample selected in",
                               " the 'RLBase Samples Table'. See Documentation for more detail.")
            ),
            hr(),
            plotOutput('heatmap',  
                       height = PAGE_PLOT_HEIGHT, 
                       width = PAGE_PLOT_WIDTH)
        ),
        tabPanel(
            title = "PCA", icon = icon("ruler-combined"),
            fluidRow(
                column(
                    width = 12,
                    hr(),
                    makeHeaders(
                        title = "Sample PCA ",
                        message=paste0("The sample PCA plot displays the sample-sample variance ",
                                       "based on the correlation around gold-standard R-loop sites.",
                                       "The 'group' annotation displays the location of the sample selected in",
                                       " the 'RLBase Samples Table'. The 'Shape' control determines whether the",
                                       " point shape represents the 'Label' or the 'Prediction'. See Documentation for more detail.")
                    ),
                    hr()
                )
            ),
            fluidRow(
                column(
                    width = 6,
                    selectInput(
                        inputId = "PCA_shapeBy",
                        choices = c("label", "prediction"),
                        selected = "prediction",
                        label = "Shape"
                    )
                )
            ),
            column(
                width = 12, 
                plotOutput('rmapPCA', 
                           height = PAGE_PLOT_HEIGHT, 
                           width = PAGE_PLOT_WIDTH)
            )
        )
    )
}


RLoops_Panel <- function() {
    tagList(
        tabsetPanel(
            id = "rlsampleRLRegions",
            type = "pills",
            tabPanel(
                title = "Overlap",
                icon = icon("adjust"),
                fluidRow(
                    column(
                        width = 8, offset = 2,
                        hr(),
                        makeHeaders(
                            title = "Overlap of sample peaks and RL Regions ",
                            message = paste0("R-loop regions (RL Regions) were overlapped",
                                             " with peaks from the selected sample. The ",
                                             "plot shows the degree of overlap and significance (Fisher's exact test).",
                                             " See Documentation for more detail.")
                        ),
                        hr()
                    )
                ),
                fluidRow(
                    column(
                        width = 8, offset = 2,
                        plotOutput("rlVenn")
                    )
                )
            ),
            tabPanel(
                title = "Table",
                icon = icon("table"),
                fluidRow(
                    column(
                        width = 12,
                        hr(),
                        makeHeaders(
                            title = "R-loop regions in selected sample ",
                            message = paste0("The R-loop regions (RL Regions) overlapping with the selected sample.",
                                             " Clicking the links in the 'Location' column will open the RLBase genome",
                                             " browser session at the selected RL Region.",
                                             " Controls are provided for filtering this table: ",
                                             "'All genes' controls whether to show psuedogenes, RNA genes, etc.",
                                             "'Repetitive' controls whether to show RL Regions in repetitive elements.",
                                             "'Correlated with Expression' controls whether to only show RL Regions significantly",
                                             " correlated with gene expression.",
                                             " See Documentation for more detail.")
                        ),
                        hr()
                    )
                ),
                fluidRow(
                    column(
                        width = 2,
                        checkboxInput(inputId = "showAllGenesRLSamp",
                                      label = "All genes", 
                                      value = FALSE)  
                    ),
                    column(
                        width = 2,
                        checkboxInput(inputId = "showRepSamp",
                                      label = "Repetitive", 
                                      value = FALSE)  
                    ),
                    column(
                        width = 3,
                        checkboxInput(inputId = "showCorrSamp",
                                      label = "Correlated with expression", 
                                      value = FALSE)  
                    )
                ),
                fluidRow(
                    column(
                        12, 
                        DTOutput("RLoopsPerSample")
                    )
                )
            )
        )
    )
}


Downloads_panel <- function() {
    tableOutput("downloadsForSample")
}


RLoopsPageContents <- function() {
    fluidPage(
        title = "RL Regions",
        fluidRow(
            column(
                width = 7,
                fluidRow(
                    column(
                        width = 12,
                        h3("R-Loop Regions"),
                        hr()
                    )
                ),
                fluidRow(
                    column(
                        width = 8,
                        makeHeaders(
                            title = "Table Controls ",
                            message = paste0("Controls for filtering the 'RL Regions table': ",
                                             "'All genes' controls whether to show psuedogenes, RNA genes, etc.",
                                             "'Repetitive' controls whether to show RL Regions in repetitive elements.",
                                             "'Correlated with Expression' controls whether to only show RL Regions significantly",
                                             " correlated with gene expression.",
                                             " See Documentation for more detail.")
                        ),
                        fluidRow(
                            column(
                                width = 2,
                                checkboxInput(inputId = "showAllGenesRL",
                                              label = "All genes", 
                                              value = FALSE)  
                            ),
                            column(
                                width = 2,
                                checkboxInput(inputId = "showRep",
                                              label = "Repetitive", 
                                              value = FALSE)  
                            ),
                            column(
                                width = 4,
                                checkboxInput(inputId = "showCorr",
                                              label = "Correlated with expression", 
                                              value = FALSE)  
                            ),
                            hr()
                        )
                    ),
                    column(
                        width = 4,
                        span(span(a(img(src="https://ucscgenomics.soe.ucsc.edu/wp-content/uploads/genome-browse-logo.png", height="50"),
                                    href="https://genome.ucsc.edu/s/millerh1%40livemail.uthscsa.edu/RLBase", target="_blank"), 
                                  style=paste0("font-size: 1.3em;")), 
                             helpButton("Click the logo to visit the RLBase genome browser session. See Documentation for more detail."))
                    )
                ),
                fluidRow(
                    column(
                        width = 12,
                        makeHeaders(
                            title = "RL Regions Table ",
                            message = paste0("Interactive table of R-loop regions. Selecting rows in this table will change the output",
                                             " on the right side of the screen. Clicking the links in the 'Location'",
                                             " column will open the RLBase genome browser session at the indicated location See Documentation for more detail.")
                        ),
                        DTOutput('rloops')
                    )
                )
            ),
            
            column(
                width = 5,
                tabsetPanel(
                    id = "rloopStats",
                    tabPanel(
                        title = "Summary",
                        icon = icon("list"),
                        fluidRow(
                            column(
                                width = 12,
                                hr(),
                                makeHeaders(
                                    title = "RL Region Summary ",
                                    message = paste0("Summary information about the selected RL Region. ",
                                                     "Hover over the help icon on each row to see information about it.",
                                                     " See Documentation for more detail.")
                                ),
                                hr()
                            )
                        ),
                        fluidRow(
                            column(
                                width = 12,
                                uiOutput("RLoopsSummary")
                            )
                        )
                    ),
                    tabPanel(
                        title = "Expression",
                        icon = icon("dna"),
                        fluidRow(
                            column(
                                width = 12,
                                hr(),
                                makeHeaders(
                                    title = "RL Region expression correlation plot ",
                                    message = paste0("Plot showing the relationship between R-loop",
                                                     " abundance and expression with the selected RL-Region. ",
                                                     "See Documentation for more detail.")
                                ),
                                hr()
                            )
                        ),
                        fluidRow(
                            column(
                                width=12,
                                plotOutput(outputId = "RLvsExpbySample")
                            )
                        )
                    )
                )
            )
        )
    )
}


HelpPageContents <- function() {
    list(
        h1("Help page")
    )
}

AnalyzePageContents <- function(rlsamples) {
    list(
        fluidRow(
            column(
                width = 12,
                h3("Analyze R-loop data"),
                hr()
            )
        ),
        fluidRow(
            column(
                width = 6,
                br(),
                makeHeaders(
                    title = "Enter sample info ", fs = 1.4,
                    message = paste0("Enter the information describing your sample and upload your peaks. ",
                                     "See Documentation for more detail.")
                ),
                fluidRow(
                    column(
                        width = 6,
                        textInput(inputId = "userSample", label = "Sample name"),
                        selectInput(inputId = "userGenome", label = "Genome", selected = "hg38",
                                    choices = RLSeq:::available_genomes$UCSC_orgID),
                        selectInput(inputId = "userMode", label = "Mode", selected = "DRIP",
                                    choices = unique(rlsamples$mode)),
                        selectInput(inputId = "userLabel", label = "Label", 
                                    choices = c("POS", "NEG"))
                    ),
                    column(
                        width = 6,
                        fileInput("userPeaks", label = tags$span(
                            tags$strong("Peaks"), " (broadPeak format)", tags$br(),
                            tags$span(
                                "Example: ", tags$a(
                                    "SRX1070676",
                                    href="https://rlbase-data.s3.amazonaws.com/peaks/SRX1070676_hg38.broadPeak"
                                )
                            )
                        ),
                        accept = c(".broadPeak", ".narrowPeak", ".bed")),
                        span(strong("Privacy statement"),": Uploaded data and analysis",
                             " will be posted on a publicly-accessible AWS S3 bucket and will NOT be kept private."),
                        br(),
                        br(),
                        checkboxInput(inputId = "privacyStatement", 
                                      label = "I have read and understood the privacy statement.", 
                                      value = FALSE),
                        actionButton(inputId = "userUpload", label = "Start", icon = icon("rocket")),
                    )
                ),
                hr(),
                br(),
                uiOutput("analysisResults")
            ),
            column(
                width = 4, offset = 1,
                h4("Running RLSeq"),
                hr(),
                div(
                    HTML('
      <img style="max-width: 100%; height: auto; " src="https://rlbase-data.s3.amazonaws.com/misc/assets/rlseq_workflow_analyze.png">
      <p>
      <a href=\"https://bishop-laboratory.github.io/RLSeq/\" target=\"_blank\"><em>RLSeq</em></a>
      is an R package for the downstream analysis of R-loop data sets. <em>RLBase</em> offers 
      in-browser access to the <em>RLSeq</em> analysis workflow. The workflow is described below:
      <br>
      <br>
      Peaks (<a href="https://genome.ucsc.edu/FAQ/FAQformat.html#format13" target="_blank">broadPeak format</a>; preferrably called with 
      <a href="https://github.com/macs3-project/MACS" target="_blank">MACS2/3</a>) are uploaded to <em>RLBase</em> (see the example data).
      To generate peaks that conform to these standards, please see the <a href="https://github.com/Bishop-Laboratory/RLPipes" target="_blank">RLPipes CLI tool</a>.
      RLSeq ingests the peaks and converts them to an <code>RLRanges</code> object with 
      <a href="https://bishop-laboratory.github.io/RLSeq/reference/RLRanges.html" target="_blank><code>RLSeq::RLRanges()</code></a>.
      Then, the core <em>RLSeq</em> pipeline is executed with 
      <a href="https://bishop-laboratory.github.io/RLSeq/reference/RLSeq.html" target="_blank><code>RLSeq::RLSeq()</code></a>. 
      The steps of this pipeline include (1) R-loop forming sequences analysis, (2) sample quality prediction, (3) feature 
      enrichment testing, (4) correlation analysis (<strong>only available in the R package version currently</strong>),
      (5) gene annotation, (6) RL Region overlap testing. For a full description of these analysis steps, 
      please refer to the <a href="https://bishop-laboratory.github.io/RLSeq/" target="_blank">RLSeq documentation</a>.
      The resulting <code>RLRanges</code> object, now containing all available results, 
      is then saved and uploaded to a <strong>public</strong> AWS S3 bucket. 
      Finally, the <code>RLRanges</code> object
      is then passed to the <code>RLSeq::report()</code> function to generate an HTML report. The 
      report is also uploaded to an AWS S3 bucket along with all log files. 
      <br>
      <br>
      <strong>Example results</strong>: 
      <a href="https://rlbase-userdata.s3.amazonaws.com/efe676b1-2a6f-4535-826f-acf2c1f4a210/res_index.html" target="_blank">SRX1070676</a>
      <br>
      <strong>Sharing</strong>: To share results, copy and send the results URL.
      </p>')
                )
            )
        )
    )
}

DownloadPageContents <- function(bucket_sizes, rlsamples) {
    md <- "
  ## RLBase Downloads
  <hr>
  
  *RLBase* provides access to the raw and processed data sets which were generated
  as part of the *RLSuite* project. With the exception of raw `.bam` files, these
  data are stored on the publicly-avialable *RLBase-data* AWS bucket (`s3://rlbase-data/`).
  
  For **bulk access** to *RLBase-data* (**67.8 GB**), please use <a href='https://anaconda.org/conda-forge/awscli' target='_blank'>*AWS CLI*</a>:
  
  ```shell
  # conda install -c conda-forge awscli
  aws s3 sync --no-sign-request s3://rlbase-data/ rlbase_data/  # Downloads all RLBase-data
  ```
  For **fine-grained access** to specific resources, please see the following guides:
  <br>
  "
    list(
        shiny::markdown(md),
        tabsetPanel(
            id = "downloads",
            tabPanel(
                title = "Processed data files",
                icon = icon("table"),
                processedDataDownloads(bucket_sizes, rlsamples)
            ),
            tabPanel(
                title = "RLHub downloads",
                icon = icon("database"),
                br(),
                rlhubDownloads(bucket_sizes)
            ),
            tabPanel(
                title = "Raw and misc data",
                icon = icon("dna"),
                br(),
                rawDataDownloads()
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
             background-color: #2C3E50;
           }
                "
}


footerHTML <- function() {
    "
    <footer class='footer'>
      <div class='footer-copyright text-center py-3'><span style='color:white'>FibroDB © 2021 Copyright:</span>
        <a href='https://gccri.uthscsa.edu/lab/bishop/' target='_blank'>FibroDB Team</a> 
        <span>&nbsp</span>
        <a href='https://github.com/Bishop-Laboratory/' target='_blank'> 
          <img src='GitHub-Mark-Light-64px.png' height='20'>
        </a>
      </div>
    </footer>"
}

processedDataDownloads <- function(bucket_sizes, rlsamples) {
    
    md <- paste0("
  ### Processed data files
  
  All data in *RLBase* were processed using the
  <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>
  program (part of *RLSuite*). Peaks and coverage files were generated from genomic alignments, 
  and the <a href='https://bishop-laboratory.github.io/RLSeq/' target='_blank'>*RLSeq*</a>
  analysis package (also part of *RLSuite*) was used to analyze the data and generate 
  an HTML report. *RLBase* provides both bulk and fine-grained access to these data.
  
  <details>
  <summary><strong>Data details</strong> (and bulk download instructions)</summary>
  
  <br>
  
  Data sets (below) can be downloaded in bulk using the AWS CLI.
  
  * **Peaks** (", bucket_sizes$peaks,")
    - Peaks were called from genomic alignments (`*.bam`) using <a href='https://github.com/macs3-project/MACS' target='_blank'>`macs3`</a>.
      When available, an input control was used. 
      See <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>.
    - Files are uncompressed, in `.broadPeak` (<a href='https://genome.ucsc.edu/FAQ/FAQformat.html#format13' target='_blank'>broadPeak</a>) format.
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/peaks/ peaks/`
  * **Coverage** (", bucket_sizes$coverage,")
    - Coverage tracks were generated from genomic alignments (`*.bam`) with 
      <a href='https://deeptools.readthedocs.io/en/develop/' target='_blank'>`deepTools`</a>. 
      See <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>.
    - Files are in `.bw` (<a href='https://genome.ucsc.edu/FAQ/FAQformat.html#format6.1' target='_blank'>bigWig</a>) format.
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/coverage/ coverage/`
  * **RLRanges** (from *RLSeq*) (", bucket_sizes$rlranges, ")
    - The *RLSeq* analysis package was used to analyze the peak and coverage tracks to assess quality, genomic annotation enrichment, 
      and other features of interest. The usage of *RLSeq* is found in the vignette 
      <a href='https://rlbase-data.s3.amazonaws.com/misc/analyzing-rloop-data-with-rlseq.html' target='_blank'>here</a>.
      See <a href='https://bishop-laboratory.github.io/RLSeq/' target='_blank'>*RLSeq*</a>.
    - The files are compressed `.rds` files. They can be loaded with the `readRDS()` function in R. 
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/rlranges/ rlranges/`
  * ***RLSeq* Reports** (", bucket_sizes$reports,")
    - The *RLSeq* analysis package also generates quality and analysis reports of samples analyzed with it. 
      For each sample in *RLBase*, a report was generated (via the `RLSeq::report()` command).
      See <a href='https://bishop-laboratory.github.io/RLSeq/' target='_blank'>*RLSeq*</a>.
    - The files are in uncompressed `*.html` format.
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/reports/ reports/`
  * **FASTQ Stats** (", bucket_sizes$fastq_stats, ")
    - Quality statistics for the raw reads were generated via the `fastp` program
      (<a href='https://github.com/OpenGene/fastp' target='_blank'>link</a>).
      See <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>.
    - The files are in uncompressed `*.json` format.
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/fastq_stats/ fastq_stats/`
  * **BAM Stats** (", bucket_sizes$bam_stats, ")
    - Quality statistics for the genomic alignments (`*.bam` files) were generated via the
      `samtools` program (<a href='http://www.htslib.org/' target='_blank'>link</a>).
      See <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>.
    - The files are in uncompressed `*.txt` format.
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/bam_stats/ bam_stats/`
  * **Quantified expression** (", bucket_sizes$quant, ")
    - Expression samples were quantified via *Salmon* `v1.5.2` (<a href='https://github.com/COMBINE-lab/salmon'>link</a>). 
      See <a href='https://github.com/Bishop-Laboratory/RLPipes' target='_blank'>*RLPipes*</a>.
    - The files are in compressed archive (`*.tar.xz`) format. The archive contains the output of salmon as described 
      in the *Salmon* documentation (<a href='https://salmon.readthedocs.io/en/latest/file_formats.html'>link</a>)
    - AWS CLI: `aws s3 sync --no-sign-request s3://rlbase-data/quant/ quant/`
      
  </details>
  <br>
  
  The **full list** of samples in *RLBase* and their corresponding download links are listed below:
    
  ")
    
    tagList(
        fluidRow(
            column(
                width = 12,
                shiny::markdown(md),
                dataTableOutput('rlsamplesDownloadFiles')
            )
        )
    )
}
