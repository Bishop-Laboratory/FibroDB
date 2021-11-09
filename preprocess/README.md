# Preprocess FibroDB data

This is the protocol used to re-build all the datasets used by FibroDB.

This protocol assumes that your working directory is `preprocess/`.

1. Install mamba and snakemake

```shell
conda install -c conda-forge mamba -y
mamba create -n snakemake -y -c conda-forge -c bioconda snakemake-minimal awscli pandas graphviz
conda activate snakemake
```

2. Snakemake dryrun and DAG (check for errors)

```shell
snakemake --cores 44 --snakefile process_data.smk --dryrun
snakemake --cores 44 --snakefile process_data.smk --dag | dot -Tpng > dag.png
```

3. Snakemake execute

```shell
snakemake --cores 44 --snakefile process_data.smk --use-conda
```

4. (Optional) upload data to AWS bucket

This was uploaded to a bucket called `fibrodb-data/` and made publicly accessible. 

```shell
aws s3 sync fibro_data/ s3://fibrodb-data/
```

