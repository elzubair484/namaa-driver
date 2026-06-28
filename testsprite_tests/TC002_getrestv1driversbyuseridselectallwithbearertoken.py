import requests
import uuid

BASE_ENDPOINT = "http://localhost:5173"
SUPABASE_AUTH_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/auth/v1/token?grant_type=password"
SUPABASE_DRIVERS_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/rest/v1/drivers"

# Use valid credentials known for testing - replace with actual valid test credentials
TEST_EMAIL = "testdriver@example.com"
TEST_PASSWORD = "testpassword123"

# Add Supabase API key for auth requests - replace with actual API key for testing
SUPABASE_API_KEY = "Your-Supabase-API-Key"

def test_getrestv1driversbyuseridselectallwithbearertoken():
    timeout = 30

    # Step 1: Authenticate to get bearer token
    auth_payload = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }
    headers_auth = {
        "Content-Type": "application/json",
        "apikey": SUPABASE_API_KEY
    }

    auth_resp = requests.post(SUPABASE_AUTH_URL, json=auth_payload, headers=headers_auth, timeout=timeout)
    assert auth_resp.status_code == 200, f"Auth failed with status {auth_resp.status_code} and body {auth_resp.text}"
    auth_data = auth_resp.json()
    access_token = auth_data.get("access_token")
    user = auth_data.get("user")
    assert access_token and user and "id" in user, "Missing access token or user id in auth response"

    user_id = user["id"]

    # Step 2: GET driver profile with bearer token
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    # Supabase uses query params in the URL encoded format for filtering
    # So the URL should be: /rest/v1/drivers?user_id=eq.{userId}&select=*
    url = f"{SUPABASE_DRIVERS_URL}?user_id=eq.{user_id}&select=*"
    
    resp = requests.get(url, headers=headers, timeout=timeout)
    assert resp.status_code == 200, f"Failed to fetch driver profile, status {resp.status_code}, body: {resp.text}"

    drivers_data = resp.json()
    assert isinstance(drivers_data, list), "Driver profile response is not a list"
    assert len(drivers_data) > 0, "No driver profile data returned"
    
    # Basic validation of the returned driver profile object keys
    driver_profile = drivers_data[0]
    expected_keys = {"id", "user_id", "full_name", "phone", "email", "status", "rating", "total_trips"}
    assert expected_keys.intersection(driver_profile.keys()), f"Driver profile missing expected keys: {driver_profile.keys()}"

test_getrestv1driversbyuseridselectallwithbearertoken()
