from fibrodb.model import Genes


def clean_init_db(db):
    """Clean and initialize the db"""
    db.drop_all()
    db.create_all()


def load_db(db):
    """Load all data into the db"""
    # TODO: Need loading functions here instead of test data...
    gene = Genes(
        gene_id=1, gene_biotype="Coding", gene_symbol="TP53",
        ensemble_id="ENSG0912039", seqnames="Chr1", start=1, end=10
    )
    db.session.add(gene)
    db.session.commit()
