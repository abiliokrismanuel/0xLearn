import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
from app import app

# Setup Flask test client
@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

# Test route '/'
def test_index(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'goodbye world!' in response.data

# Test route '/second'
def test_second(client):
    response = client.get('/second')
    assert response.status_code == 200
    assert b'Ini halaman kedua' in response.data
