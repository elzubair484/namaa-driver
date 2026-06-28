import requests

def test_postauthv1tokengranttypepasswordwithvalidcredentials():
    base_url = "https://ygvbangmbiywbdakcsnk.supabase.co"
    url = f"{base_url}/auth/v1/token?grant_type=password"
    headers = {
        "Content-Type": "application/json"
    }
    # Use valid email and password for test; replace these with valid test credentials.
    payload = {
        "email": "valid_driver@example.com",
        "password": "ValidPassword123!"
    }
    timeout = 30

    try:
        response = requests.post(url, json=payload, headers=headers, timeout=timeout)
    except requests.RequestException as e:
        assert False, f"Request failed: {e}"

    assert response.status_code == 200, f"Expected status 200, got {response.status_code}"
    try:
        data = response.json()
    except ValueError:
        assert False, "Response is not valid JSON"

    assert "access_token" in data and isinstance(data["access_token"], str) and data["access_token"], "Missing or invalid access_token"
    assert "token_type" in data and data["token_type"] == "bearer", "Missing or invalid token_type"
    assert "user" in data and isinstance(data["user"], dict) and data["user"], "Missing or invalid user object"

test_postauthv1tokengranttypepasswordwithvalidcredentials()