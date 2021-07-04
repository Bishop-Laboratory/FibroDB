from fibrodb.model import (
    Genes, GenesSchema,
    DEGs, DEGsSchema,
    Samples, SamplesSchema,
    GeneExp, GeneExpSchema
)
from flask import Blueprint, request, jsonify

# Init blueprint and api
bp = Blueprint('api', __name__)

# Init marshmallow schemas
genes_schema = GenesSchema(many=True)
gene_schema = GenesSchema(many=True)
degs_schema = DEGsSchema(many=True)
samples_schema = SamplesSchema(many=True)
geneexp_schema = GeneExpSchema(many=True)


@bp.route('/api-v1/gene-info', methods=('GET',))
def gene_info():
    """API resource - Query genes by id"""
    geneids = request.args['geneid']
    print(geneids)
    genes = Genes.query.filter(Genes.gene_id.in_([geneids])).all()
    return jsonify(genes_schema.dump(genes))
