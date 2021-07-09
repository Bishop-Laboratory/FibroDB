def test_hello(client):
    response = client.get('/hello')
    print(response)
    print(response.data)
    assert response.data == b'Hello world!'
