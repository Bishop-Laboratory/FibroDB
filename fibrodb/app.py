# app.py
from flask import Flask
from flask import render_template
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI']  = 'sqlite:///fibrodb.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
# print('[+] DB PATH:\t',app.config['SQLALCHEMY_DATABASE_URI'])  ##uncomment for debugging

db = SQLAlchemy(app)

@app.route("/")
def landing_page():
    return "FIBRO DB UNDER CONSTRUCTION!"

# print(db.Model.metadata.reflect(db.engine))

# print(dir(db))

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

    def __init__(self, sample_id, study_id, study_info, condition, replicate, tissue, timepoint, treatment):
        self.sampleID = sample_id
        self.studyID = study_id
        self.condition = condition
        self.replicate = replicate
        self.tissue = tissue
        self.timepoint = timepoint
        self.treatment = treatment
        self.study_info = study_info



class Genes(db.Model):
    __tablename__ = 'genes'
    gene_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ensemble_id = db.Column(db.Text, unique=True, nullable=False)
    gene_symbol = db.Column(db.Text)
    gene_biotype = db.Column(db.Text)
    chromosome = db.Column(db.Text)
    chr_start = db.Column(db.Integer)
    chr_end = db.Column(db.Integer)

    def __init__(self, gene_id, ensemble_id, gene_symbol, gene_biotype, chromosome, chr_start, chr_end):
        self.gene_id = gene_id
        self. ensemble_id = ensemble_id
        self.gene_symbol = gene_symbol
        self.gene_biotype = gene_biotype
        self.chromosome = gene_chromosome
        self.chr_start = chr_start
        self.chr_end = chr_end


class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    expression_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    sample_id = db.Column(db.Text, db.ForeignKey('samples.study_id'), nullable=False)
    raw_counts = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)
    rpkm = db.Column(db.Numeric)

    def __init__(self, expression_id, gene_id, sample_id, raw_counts, cpm, rpkm):
        self.expression_id = expression_id
        self.gene_id = gene_id
        self.sample_id = sample_id
        self.raw_counts = raw_counts
        self.cpm = cpm
        self.rpkm = rpkm


class Degs(db.Model):
    __tablename__ = 'degs'
    degs_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    study_id = db.Column(db.Integer, db.ForeignKey('samples.study_id'), nullable=False)
    log2fc = db.Column(db.Numeric)
    pval = db.Column(db.Numeric)
    padj = db.Column(db.Numeric)

    def __init__(self, degs_id, gene_id, study_id, log2fc, pval, padj):
        self.degs_id = degs_id
        self.gene_id = gene_id
        self.sample_id = sample_id
        self.log2fc = log2fc
        self.pval = pval
        self.padj = padj

if __name__ == "__main__":
    # delete all tables in database to upload 'fresh' data
    db.drop_all()
    # create tables initiated above
    db.create_all()
    app.run(debug=True)