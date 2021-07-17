import json


def test_gene_info_1(client):
    """Test gene info endpoint. Query by gene ID"""
    response = client.get('/api-v1/gene-info?gene_id=ENSG00000141510')
    resdict = json.loads(response.data)[0]
    assert resdict['gene_symbol'] == "TP53"


def test_gene_info_2(client):
    """Test gene info endpoint. Query by gene symbol"""
    response = client.get('/api-v1/gene-info?gene_symbol=NEAT1')
    resdict = json.loads(response.data)[0]
    assert resdict['gene_id'] == "ENSG00000245532"


def test_gene_alias(client):
    """Test gene alias endpoint. Query by alias"""
    response = client.get('/api-v1/gene-aliases?alias_symbol=P16')
    resdict = json.loads(response.data)
    genes = [entry['gene_id'] for entry in resdict]
    assert "ENSG00000147889" in genes


def test_gene_expression_1(client):
    """Test gene expression endpoint. Query by gene ID"""
    response = client.get('/api-v1/expression?gene_id=ENSG00000141510')
    resdict = json.loads(response.data)
    samps = [entry['sample_id'] for entry in resdict]
    assert {'SRR8249114', 'SRR8249115', 'SRR8249116'}.issubset(samps)


def test_gene_expression_2(client):
    """Test gene expression endpoint. Query by Sample ID"""
    response = client.get('/api-v1/expression?sample_id=SRR8249114')
    resdict = json.loads(response.data)
    genes = [entry['gene_id'] for entry in resdict]
    assert {'ENSG00000227232', 'ENSG00000284733', 'ENSG00000225972'}.issubset(genes)


def test_gene_expression_3(client):
    """Test gene expression endpoint. Query by Sample ID and Gene ID"""
    response = client.get('/api-v1/expression?sample_id=SRR8249114&gene_id=ENSG00000141510')
    resdict = json.loads(response.data)[0]
    assert resdict['gene_id'] == "ENSG00000141510"


def test_deg_1(client):
    """Test DEG endpoint. Query by gene ID"""
    response = client.get('/api-v1/deg?gene_id=ENSG00000012048')
    resdict = json.loads(response.data)[0]
    assert resdict['gene_id'] == "ENSG00000012048"


def test_deg_2(client):
    """Test DEG endpoint. Query by Sample ID"""
    response = client.get('/api-v1/deg?study_id=GSE149413')
    resdict = json.loads(response.data)
    genes = [entry['gene_id'] for entry in resdict]
    assert {'ENSG00000223972', 'ENSG00000243485', 'ENSG00000186092'}.issubset(genes)


def test_deg_3(client):
    """Test DEG endpoint. Query by Sample ID and Gene ID"""
    response = client.get('/api-v1/deg?gene_id=ENSG00000012048&study_id=GSE149413')
    resdict = json.loads(response.data)[0]
    assert resdict['gene_id'] == "ENSG00000012048"


def test_samples_1(client):
    """Test samples endpoint. Query by gene ID"""
    response = client.get('/api-v1/samples?study_id=GSE149413')
    resdict = json.loads(response.data)
    samps = [entry['sample_id'] for entry in resdict]
    assert {'SRR11614730', 'SRR11614731', 'SRR11614733'}.issubset(samps)


def test_samples_2(client):
    """Test samples endpoint. Query by Sample ID and Gene ID"""
    response = client.get('/api-v1/samples?study_id=GSE149413&replicate=1')
    resdict = json.loads(response.data)[0]
    assert resdict['sample_id'] == "SRR11614730"
