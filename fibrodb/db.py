from fibrodb.model import Genes


def clean_init_db(db):
    """Clean and initialize the db"""
    db.drop_all()
    db.create_all()


def load_db(db):
    """Load all data into the db"""
