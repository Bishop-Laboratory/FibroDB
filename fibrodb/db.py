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
    
    # Path MAGIC
    DATA_DIR = "database/gene_data/"
    
    # Find the gene datasets
    files = np.array([ind if ind[-3:] == ".xz" else np.NaN for ind in os.listdir(DATA_DIR)])
    datasets = files[np.where(files != str(np.NaN))]

    # Load the gene info data
    if 'genes.csv.xz' in datasets:
        genes = pd.read_csv(DATA_DIR + 'genes.csv.xz')
        genes.to_sql(name='genes', con=db.engine, if_exists="append", index=False)

    # Load the gene alias data
    if 'gene_aliases.csv.xz' in datasets:
        aliases = pd.read_csv(DATA_DIR + 'gene_aliases.csv.xz')
        aliases.to_sql(name='gene_aliases', con=db.engine, if_exists="append", index=False)


def load_data(db, path=f"database{os.sep}fibro_data"):
    """
    Iterates over csv files in directory and loads csv data to db tables.
    """
    print("[+] Loading data to database")

    for file in os.listdir(path):

        fl = file.split(".")
        name = fl[0]
        ext = fl[-1]
            
        if ext != "csv":
            print(f"\t[!] Compressed file detected. Decompressing! (file name: {file})")
            data = pd.read_csv(f'{path}{os.sep}{file}', compression=ext)
        else:
            print(f"\t[+] Loading data from file named: {file})")
            data = pd.read_csv(f'{path}{os.sep}{file}')

        data = data.fillna(-1)
        data.to_sql(name, con=db.engine, if_exists="replace")

    print("[+] All data successfully loaded to DB!")
