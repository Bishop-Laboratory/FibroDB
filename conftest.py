import pytest
from fibrodb import create_app
from fibrodb.model import db
from fibrodb.db import clean_init_db, load_db
import os


@pytest.fixture
def client():
    test_db = 'sqlite:///../tests/fibrodb.test.db'
    app = create_app(test_config={
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': test_db,
        "SQLALCHEMY_TRACK_MODIFICATIONS": True,
        "FORCE_DB": True
    })

    with app.test_client() as client:
        yield client
