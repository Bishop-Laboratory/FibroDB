from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow

db = SQLAlchemy()
ma = Marshmallow()


class Samples(db.Model):
    __tablename__ = 'samples'
    sample_id = db.Column(db.Text, primary_key=True)
    condition = db.Column(db.Text)
    study_id = db.Column(db.Text)
    # TODO: copy replicate information to fill following 3 rows using treatment info; or ask scientists to
    # TODO: provide this as additional information
    # tissue = db.Column(db.Text)
    # time = db.Column(db.Text)
    # treatment = db.Column(db.Text)


class SamplesSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Samples


class Genes(db.Model):
    __tablename__ = 'genes'
    gene_id = db.Column(db.Text, primary_key=True)
    gene_symbol = db.Column(db.Text)
    description = db.Column(db.Text)
    gene_biotype = db.Column(db.Text)


class GenesSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = Genes


class GeneAliases(db.Model):
    __tablename__ = 'gene_aliases'
    alias_id = db.Column(db.Integer, primary_key=True)
    alias_symbol = db.Column(db.Text)
    gene_id = db.Column(db.Text, db.ForeignKey('genes.gene_id'), nullable=False)


class GeneAliasesSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = GeneAliases
        include_fk = True


class GeneExp(db.Model):
    __tablename__ = 'gene_exp'
    gene_id = db.Column(db.Text, db.ForeignKey('genes.gene_id'), nullable=False, primary_key=True)
    sample_id = db.Column(db.Text, db.ForeignKey('samples.study_id'), nullable=False, primary_key=True)
    # db.DECIMAL(asdecimal=False) from here:
    # https://medium.com/@erdoganyesil/python-typeerror-object-of-type-decimal-is-not-json-serializable-2af216af0390
    cpm = db.Column(db.DECIMAL(asdecimal=False))
    rpkm = db.Column(db.DECIMAL(asdecimal=False))
    tpm = db.Column(db.DECIMAL(asdecimal=False))


class GeneExpSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = GeneExp
        include_fk = True


class DEGs(db.Model):
    __tablename__ = 'degs'
    gene_id = db.Column(db.Text, db.ForeignKey('genes.gene_id'), nullable=False, primary_key=True)
    study_id = db.Column(db.Text, db.ForeignKey('samples.study_id'), nullable=False, primary_key=True)
    # db.DECIMAL(asdecimal=False) from here:
    # https://medium.com/@erdoganyesil/python-typeerror-object-of-type-decimal-is-not-json-serializable-2af216af0390
    fc = db.Column(db.DECIMAL(asdecimal=False))
    pval = db.Column(db.DECIMAL(asdecimal=False))
    padj = db.Column(db.DECIMAL(asdecimal=False))
    sig = db.Column(db.Boolean)


class DEGsSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = DEGs
        include_fk = True
