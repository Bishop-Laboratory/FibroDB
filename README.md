# Fibroblast-lncRNASeq-explorer
![Build Status](https://github.com/Bishop-Laboratory/FibroDB/workflows/tests/badge.svg)

Shiny app for exploring the fibroblast lncRNA-Seq dataset from Therkelsen et al. 2021.

**Note**: To generate the data for this app, please see the instructions in `preprocess/`.

# Getting started

To run the app locally, please perform the following steps:

1. Clone the repo (+ pull LFS files)

```shell
git clone https://github.com/Bishop-Laboratory/FibroDB.git
cd FibroDB/
```

2. Set up the app environment (requires conda installed)

```shell
conda install -c conda-forge mamba -y
mamba env create -f fibrodb.yml --force
conda activate fibrodb
R -e "install.packages('prompter')"
```

3. Download the database

```shell
aws s3 sync --no-sign-request s3://fibrodb-data/ fibrodb-data/
```

4. Run the app

```shell
Rscript runApp.R 5566  # Port number
```
