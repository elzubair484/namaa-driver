import requests

BASE_AUTH_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/auth/v1/token?grant_type=password"
BASE_API_URL = "https://ygvbangmbiywbdakcsnk.supabase.co"
AUTH_HEADERS = {"Content-Type": "application/json"}
TIMEOUT = 30

# Use valid test credentials for authentication (these should be replaced with valid testing credentials)
TEST_EMAIL = "test_driver_email@example.com"
TEST_PASSWORD = "test_driver_password"

def get_access_token(email: str, password: str) -> str:
    payload = {
        "email": email,
        "password": password
    }
    response = requests.post(BASE_AUTH_URL, json=payload, headers=AUTH_HEADERS, timeout=TIMEOUT)
    response.raise_for_status()
    data = response.json()
    assert "access_token" in data, "access_token missing in auth response"
    assert data.get("token_type") == "bearer", "Unexpected token_type"
    return data["access_token"], data["user"]["id"]

def test_get_notifications_by_recipient_with_bearer_token():
    access_token, user_id = get_access_token(TEST_EMAIL, TEST_PASSWORD)
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Accept": "application/json"
    }
    params = {
        "recipient_id": f"eq.{user_id}",
        "order": "created_at.desc",
        "limit": 50
    }
    url = f"{BASE_API_URL}/rest/v1/notifications"
    try:
        response = requests.get(url, headers=headers, params=params, timeout=TIMEOUT)
    except requests.exceptions.RequestException as e:
        assert False, f"Request to get notifications failed: {e}"

    assert response.status_code == 200, f"Expected status 200, got {response.status_code}"
    
    notifications = response.json()
    assert isinstance(notifications, list), "Response is not a list"
    
    # Optionally validate structure of at least one notification if present
    if notifications:
        notif = notifications[0]
        expected_keys = {"id", "type", "title_ar", "body_ar", "is_read", "created_at"}
        assert expected_keys.issubset(notif.keys()), f"Notification missing keys: {expected_keys - notif.keys()}"
    
    print("Test TC005 passed: GET notifications by recipient with bearer token")

test_get_notifications_by_recipient_with_bearer_token()