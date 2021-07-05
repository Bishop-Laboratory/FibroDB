from fibrodb.model import Genes, GeneExp, DEGs, Samples


def clean_init_db(db):
    """Clean and initialize the db"""
    db.drop_all()
    db.create_all()


def load_db(db):
    """Load all data into the db"""
    # TODO: Replace with real data loading function
    load_test_data(db)


def load_test_data(db):
    """Loads test data into db -- temporary usage while developing"""
    # Test data add Genes
    gene = Genes(
        gene_id="ENSG00000141510", gene_biotype="Protein coding",
        description="tumor protein 53",
        gene_symbol="TP53", seqnames="Chr17", start=7661779, end=7687538
    )
    db.session.add(gene)
    db.session.commit()
    gene = Genes(
        gene_id="ENSG00000012048", gene_biotype="Protein coding",
        description="BRCA1 DNA repair associated",
        gene_symbol="BRCA1", seqnames="Chr17", start=43044295, end=43170245
    )
    db.session.add(gene)
    db.session.commit()
    gene = Genes(
        gene_id="ENSG00000245532", gene_biotype="lncRNA",
        description="nuclear paraspeckle assembly transcript 1",
        gene_symbol="NEAT1", seqnames="Chr11", start=65422774, end=65445540
    )
    db.session.add(gene)
    db.session.commit()

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
