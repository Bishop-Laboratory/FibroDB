from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

db = SQLAlchemy()
ma = Marshmallow()


class Samples(db.Model):
    __tablename__ = 'samples'
    sample_id = db.Column(db.Text, primary_key=True)
    study_id = db.Column(db.Text)
    study_info = db.Column(db.Text)
    condition = db.Column(db.Text)
    replicate = db.Column(db.Integer)
    tissue = db.Column(db.Text)
    timepoint = db.Column(db.Text)
    treatment = db.Column(db.Text)


class SamplesSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Samples


class Genes(db.Model):
    __tablename__ = 'genes'
    gene_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ensemble_id = db.Column(db.Text, unique=True, nullable=False)
    gene_symbol = db.Column(db.Text)
    gene_biotype = db.Column(db.Text)
    seqnames = db.Column(db.Text)
    start = db.Column(db.Integer)
    end = db.Column(db.Integer)


class GenesSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Genes


class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    expression_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    sample_id = db.Column(db.Text, db.ForeignKey('samples.study_id'), nullable=False)
    raw_counts = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)
    rpkm = db.Column(db.Numeric)
    tpm = db.Column(db.Numeric)


class GeneExpSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = GeneExp


class DEGs(db.Model):
    __tablename__ = 'degs'
    degs_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    study_id = db.Column(db.Integer, db.ForeignKey('samples.study_id'), nullable=False)
    log2fc = db.Column(db.Numeric)
    pval = db.Column(db.Numeric)
    padj = db.Column(db.Numeric)


class DEGsSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = DEGs
