# app.py
from flask import Flask
from flask import render_template
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = os.path.join(app.instance_path, 'fibrodb.sqlite')
print(app.config['SQLALCHEMY_DATABASE_URI'])

db = SQLAlchemy(app)

# print(db.Model.metadata.reflect(db.engine))

# print(dir(db))

class Samples(db.Model):
    __tablename__ = 'samples'
    sample_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    study = db.Column(db.Text)
    study_info = db.Column(db.Text)
    sample_name = db.Column(db.Text, unique=True, nullable=False)

    def __init__(self, sample_id, study, study_info, sample_name):
        self.sample_id = sample_id
        self.study = study
        self.study_info = study_info
        self.sample_name = sample_name


class Genes(db.Model):
    __tablename__ = 'genes'
    gene_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ensemble_id = db.Column(db.Text, unique=True, nullable=False)
    gene_symbol = db.Column(db.Text)
    gene_biotype = db.Column(db.Text)
    gene_location = db.Column(db.Text)

    def __init__(self, gene_id, ensemble_id, gene_symbol, gene_biotype, gene_location):
        self.gene_id = gene_id
        self. ensemble_id = ensemble_id
        self.gene_symbol = gene_symbol
        self.gene_biotype = gene_biotype
        self.gene_location = gene_location


class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    expression_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    sample = db.Column(db.Text, nullable=False)
    counts = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)
    rpkm = db.Column(db.Numeric)

    def __init__(self, expression_id, gene_id, sample, counts, cpm, rpkm):
        self.expression_id = expression_id
        self.gene_id = gene_id
        self.sample = sample
        self. counts = counts
        self.cpm = cpm
        self.rpkm = rpkm


class Degs(db.Model):
    __tablename__ = 'degs'
    degs_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.TInteger, db.ForeignKey('genes.gene_id'), nullable=False)
    sample_id = db.Column(db.Integer, db.ForeignKey('samples.sample_id'), nullable=False)
    log2fc = db.Column(db.Numeric)
    pval = db.Column(db.Numeric)
    padj = db.Column(db.Numeric)

    def __init__(self, degs_id, gene_id, sample_id, log2fc, pval, padj):
        self.degs_id = degs_id
        self.gene_id = gene_id
        self.sample_id = sample_id
        self.log2fc = log2fc
        self.pval = pval
        self.padj = padj

