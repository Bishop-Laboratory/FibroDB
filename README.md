# Fibroblast-lncRNASeq-explorer
![Build Status](https://github.com/Bishop-Laboratory/Fibroblast-lncRNASeq-explorer/workflows/tests/badge.svg)

Shiny app for exploring the fibroblast lncRNA-Seq dataset from Therkelsen et al. 2021

# Getting started

To run the app locally, please perform the following steps:

1. Clone the repo (+ pull LFS files)

```shell
git clone https://github.com/Bishop-Laboratory/Fibroblast-lncRNASeq-explorer.git
cd Fibroblast-lncRNASeq-explorer/
git lfs pull
```

2. Set up the app environment (requires conda installed)

```shell
conda install -c conda-forge mamba -y
mamba env create -f fibrodb.yml --force
conda activate fibrodb
```

3. Run the app

```shell
Rscript runApp.R 8484  # Port number
```
