# Tests loading home page
def test_home(client):
    response = client.get('/')
    assert b"Welcome to FibroDB!" in response.data


# Tests loading of DEG explorer page
def test_deg_explorer(client):
    response = client.get('/deg-explorer')
    assert b"Maybe the DEG explorer goes here?" in response.data


# Tests loading of Downloads page
def test_downloads(client):
    response = client.get('/downloads')
    assert b"Downloads go here" in response.data


# Tests loading of API reference page
def test_api_ref(client):
    response = client.get('/api-ref')
    assert b"Usage page for API goes here!" in response.data


# Tests loading of help page
def test_help(client):
    response = client.get('/help')
    assert b"Help page goes here" in response.data
