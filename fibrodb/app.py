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

class Genes(db.Model):
    __tablename__ = 'genes'
    gene_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    ensemble_id = db.Column(db.Text, unique=True, nullable=False)
    gene_symbol = db.Column(db.Text)
    gene_biotype = db.Column(db.Text)
    gene_location = db.Column(db.Text)

class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    expression_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    sample = db.Column(db.Text, nullable=False)
    counts = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)
    rpkm = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)

class Degs(db.Model):
    __tablename__ = 'degs'
    degs_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.TInteger, db.ForeignKey('genes.gene_id'), nullable=False)
    sample_id = db.Column(db.Integer, db.ForeignKey('samples.sample_id'), nullable=False)
    log2fc = db.Column(db.Numeric)
    pval = db.Column(db.Numeric)
    padj = db.Column(db.Numeric)

