import pytest
from app import app as flask_app


# --- Setup ---

@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


# --- Tests ---

def test_home_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200

def test_home_returns_json(client):
    response = client.get("/")
    data = response.get_json()
    assert "message" in data
    assert data["message"] == "DevOps Lab API is running!"

def test_health_returns_healthy(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"

def test_info_returns_app_name(client):
    response = client.get("/info")
    assert response.status_code == 200
    data = response.get_json()
    assert data["app"] == "devops-lab"
