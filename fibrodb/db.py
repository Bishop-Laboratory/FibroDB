import numpy

from fibrodb.model import Genes, GeneAliases, GeneExp, DEGs, Samples
import pandas as pd
import os
import numpy as np


def clean_init_db(db):
    """Clean and initialize the db"""
    db.drop_all()
    db.create_all()


def load_db(db):
    """Load all data into the db"""
    load_test_data(db)  # TODO: Finish replacing with real data loading function

    # Load gene datasets
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


def load_test_data(db):
    # Test data add Samples
    sample = Samples(
        sample_id="SRX10300304",
        study_id='SRP120020193',
        sample_name='Lung Fibroblasts 4H Rep 1',
        condition='lung_fibroblast_4h',
        replicate=1,
        tissue='Lung',
        time='4H',
        treatment=None
    )
    db.session.add(sample)
    db.session.commit()
    sample = Samples(
        sample_id="SRX10300305",
        study_id='SRP120020193',
        sample_name='Lung Fibroblasts 4H Rep 2',
        condition='lung_fibroblast_4h',
        replicate=2,
        tissue='Lung',
        time='4H',
        treatment=None
    )
    db.session.add(sample)
    db.session.commit()
    sample = Samples(
        sample_id="SRX10300306",
        study_id='SRP120020193',
        sample_name='Lung Fibroblasts 4H Rep 3',
        condition='lung_fibroblast_4h',
        replicate=3,
        tissue='Lung',
        time='4H',
        treatment=None
    )
    db.session.add(sample)
    db.session.commit()

    # Test data add DEGs
    deg = DEGs(
        deg_id=1, study_id='SRP120020193',
        gene_id="ENSG00000141510", fc=-1.203,
        pval=.02, padj=.13, sig=False
    )
    db.session.add(deg)
    db.session.commit()
    deg = DEGs(
        deg_id=2, study_id='SRP120020193', gene_id="ENSG00000012048",
        fc=-2.34, pval=.0045, padj=.023, sig=True
    )
    db.session.add(deg)
    db.session.commit()
    deg = DEGs(
        deg_id=3, study_id='SRP120020193', gene_id="ENSG00000245532",
        fc=-4.85, pval=.00065, padj=.005, sig=True
    )
    db.session.add(deg)
    db.session.commit()

    # Test data add GeneExp
    gene_exp = GeneExp(
        expression_id=1,
        gene_id='ENSG00000141510',
        sample_id="SRX10300306",
        raw_counts=138,
        cpm=13.8,
        rpkm=23.1,
        tpm=3.48
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=2,
        gene_id='ENSG00000012048',
        sample_id="SRX10300306",
        raw_counts=25,
        cpm=6.47,
        rpkm=3.54,
        tpm=1.25
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=3,
        gene_id='ENSG00000245532',
        sample_id="SRX10300306",
        raw_counts=640,
        cpm=153.4,
        rpkm=56.4,
        tpm=46.5
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=4,
        gene_id='ENSG00000141510',
        sample_id="SRX10300305",
        raw_counts=165,
        cpm=14.8,
        rpkm=45.1,
        tpm=51.48
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=5,
        gene_id='ENSG00000012048',
        sample_id="SRX10300305",
        raw_counts=63,
        cpm=32.47,
        rpkm=15.54,
        tpm=2.25
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=6,
        gene_id='ENSG00000245532',
        sample_id="SRX10300305",
        raw_counts=231,
        cpm=132.4,
        rpkm=75.4,
        tpm=234.5
    )
    db.session.add(gene_exp)
    db.session.commit()
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=7,
        gene_id='ENSG00000141510',
        sample_id="SRX10300304",
        raw_counts=263,
        cpm=77.8,
        rpkm=33.1,
        tpm=52.48
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=8,
        gene_id='ENSG00000012048',
        sample_id="SRX10300304",
        raw_counts=224,
        cpm=43.47,
        rpkm=51.54,
        tpm=25.25
    )
    db.session.add(gene_exp)
    db.session.commit()
    gene_exp = GeneExp(
        expression_id=9,
        gene_id='ENSG00000245532',
        sample_id="SRX10300304",
        raw_counts=546,
        cpm=52.4,
        rpkm=234.4,
        tpm=161.5
    )
    db.session.add(gene_exp)
    db.session.commit()
