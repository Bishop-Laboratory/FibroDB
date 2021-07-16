import pandas as pd
import os
import numpy as np


def clean_init_db(db):
    """Clean and initialize the db"""
    db.drop_all()
    db.create_all()


def load_db(db):
    """
    Load all data into the db

    Params:
        db: database
    """

    load_data(db)
    load_gene_data(db)


def load_gene_data(db):
    """Load the gene info tables into the database"""
    # Find the gene datasets
    files = np.array([ind if ind[-3:] == ".xz" else np.NaN for ind in os.listdir("fibrodb/misc/gene_data")])
    datasets = files[np.where(files != str(np.NaN))]

    # Load the gene info data
    if 'genes.csv.xz' in datasets:
        genes = pd.read_csv('fibrodb/misc/gene_data/genes.csv.xz')
        genes.to_sql(name='genes', con=db.engine, if_exists="append", index=False)

    # Load the gene alias data
    if 'gene_aliases.csv.xz' in datasets:
        genes = pd.read_csv('fibrodb/misc/gene_data/gene_aliases.csv.xz')
        genes.to_sql(name='gene_aliases', con=db.engine, if_exists="append", index=False)


def load_data(db, path=f"fibrodb{os.sep}misc{os.sep}clean_data"):
    """
    Iterates over csv files in directory and loads csv data to db tables.
    """

    for file in os.listdir(path):

        name, ext = file.split(".")

        # TODO: Non-hardcode this
        if "samples" in file.lower():
            col_dict = {'Unnamed: 0': 'sample_id'}
        elif "gene_exp" in file.lower():
            col_dict = {'Unnamed: 0': 'sample_id', 'Unnamed: 1': 'gene_id'}
        else:
            col_dict = {'Unnamed: 0': 'study_id', 'Unnamed: 1': 'gene_id'}

        if ext != "csv":
            print(f"[!] Compressed file detected. Decompressing! (file name: {file})\n")
            data = pd.read_csv(f'{path}{os.sep}{file}', compression=ext)
        else:
            data = pd.read_csv(f'{path}{os.sep}{file}')

        data = data.dropna()
        data.rename(columns=col_dict, inplace=True)
        data.to_sql(name, con=db.engine, if_exists="replace")
