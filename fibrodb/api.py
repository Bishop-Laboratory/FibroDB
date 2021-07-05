from fibrodb.model import (
    Genes, GenesSchema,
    GeneAliases, GeneAliasesSchema,
    DEGs, DEGsSchema,
    Samples, SamplesSchema,
    GeneExp, GeneExpSchema
)
from flask import Blueprint, request, jsonify

# Init blueprint and api
bp = Blueprint('api', __name__)

# Init marshmallow schemas
genes_schema = GenesSchema(many=True)
gene_aliases_schema = GeneAliasesSchema(many=True)
degs_schema = DEGsSchema(many=True)
samples_schema = SamplesSchema(many=True)
geneexp_schema = GeneExpSchema(many=True)


@bp.route('/api-v1/gene-info', methods=('GET',))
def gene_info_api():
    """API resource - Query genes by any column"""
    genes = Genes.query.filter_by(**request.args.to_dict()).all()
    return genes_schema.dumps(genes)


@bp.route('/api-v1/gene-aliases', methods=('GET',))
def gene_alias_api():
    """API resource - Query genes by any column"""
    gene_aliases = GeneAliases.query.filter_by(**request.args.to_dict()).all()
    return gene_aliases_schema.dumps(gene_aliases)


@bp.route('/api-v1/samples', methods=('GET',))
def samples_api():
    """API resource - Query samples by any column"""
    samples = Samples.query.filter_by(**request.args.to_dict()).all()
    return jsonify(samples_schema.dump(samples))


@bp.route('/api-v1/deg', methods=('GET',))
def degs_api():
    """API resource - Query DEGs by any column"""
    degs = DEGs.query.filter_by(**request.args.to_dict()).all()
    return jsonify(degs_schema.dump(degs))


@bp.route('/api-v1/expression', methods=('GET',))
def gene_exp_api():
    """API resource - Query Gene Exp by any column"""
    gene_exp = GeneExp.query.filter_by(**request.args.to_dict()).all()
    print(gene_exp)
    return jsonify(geneexp_schema.dump(gene_exp))
