from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()


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
    seqnames = db.Column(db.Text)
    start = db.Column(db.Integer)
    end = db.Column(db.Integer)

    def __init__(self, gene_id, ensemble_id, gene_symbol,
                 gene_biotype, seqnames, start, end):
        self.gene_id = gene_id
        self.ensemble_id = ensemble_id
        self.gene_symbol = gene_symbol
        self.gene_biotype = gene_biotype
        self.seqnames = seqnames
        self.start = start
        self.end = end


class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    expression_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    gene_id = db.Column(db.Integer, db.ForeignKey('genes.gene_id'), nullable=False)
    sample_id = db.Column(db.Text, db.ForeignKey('samples.study_id'), nullable=False)
    raw_counts = db.Column(db.Numeric)
    cpm = db.Column(db.Numeric)
    rpkm = db.Column(db.Numeric)
    tpm = db.Column(db.Numeric)

    def __init__(self, expression_id, gene_id, sample_id, raw_counts, cpm, rpkm, tpm):
        self.expression_id = expression_id
        self.gene_id = gene_id
        self.sample_id = sample_id
        self.raw_counts = raw_counts
        self.cpm = cpm
        self.rpkm = rpkm
        self.tpm = tpm


class DEGs(db.Model):
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
        self.study_id = study_id
        self.log2fc = log2fc
        self.pval = pval
        self.padj = padj
