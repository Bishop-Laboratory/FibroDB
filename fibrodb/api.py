from fibrodb.model import (
    Genes, GenesSchema,
    GeneAliases, GeneAliasesSchema,
    DEGs, DEGsSchema,
    Samples, SamplesSchema,
    GeneExp, GeneExpSchema
)
from flask import Blueprint, request, jsonify
from flask_cors import CORS, cross_origin
# Init blueprint and api (Need to ask Henry about this.)
bp = Blueprint('api', __name__)
# Init marshmallow schemas
genes_schema = GenesSchema(many=True)
gene_aliases_schema = GeneAliasesSchema(many=True)
degs_schema = DEGsSchema(many=True)
samples_schema = SamplesSchema(many=True)
geneexp_schema = GeneExpSchema(many=True)

global full_data_cache
full_data_cache = None

@bp.route('/api-v1/gene-info', methods=('GET',))
@cross_origin(origin='*')
def gene_info_api():
    """API resource - Query genes by any column"""
    genes = Genes.query.filter_by(**request.args.to_dict()).all()
    return genes_schema.dumps(genes)


@bp.route('/api-v1/gene-aliases', methods=('GET',))
@cross_origin(origin='*')
def gene_alias_api():
    """API resource - Query genes by any column"""
    gene_aliases = GeneAliases.query.filter_by(**request.args.to_dict()).all()
    return gene_aliases_schema.dumps(gene_aliases)


@bp.route('/api-v1/samples', methods=('GET',))
@cross_origin(origin='*')
def samples_api():
    """API resource - Query samples by any column"""
    samples = Samples.query.filter_by(**request.args.to_dict()).all()
    return jsonify(samples_schema.dump(samples))


@bp.route('/api-v1/deg', methods=('GET',))
@cross_origin(origin='*')
def degs_api():
    """API resource - Query DEGs by any column"""
    global full_data_cache
    if request.args.to_dict() == {}:
        if full_data_cache != None:
            return full_data_cache
    degs = DEGs.query.filter_by(**request.args.to_dict()).all()
    output = degs_schema.dump(degs)
    output = jsonify(output)
    if request.args.to_dict() == {}:
        full_data_cache = output
    return  output


@bp.route('/api-v1/expression', methods=('GET',))
@cross_origin(origin='*')
def gene_exp_api():
    """API resource - Query Gene Exp by any column"""
    gene_exp = GeneExp.query.filter_by(**request.args.to_dict()).all()
    return jsonify(geneexp_schema.dump(gene_exp))

