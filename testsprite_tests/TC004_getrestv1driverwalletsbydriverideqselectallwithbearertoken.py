import requests

BASE_ENDPOINT = "http://localhost:5173"
SUPABASE_AUTH_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/auth/v1/token?grant_type=password"
SUPABASE_API_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/rest/v1"
TIMEOUT = 30

# Replace these credentials with valid test driver credentials
TEST_EMAIL = "testdriver@example.com"
TEST_PASSWORD = "TestPassword123!"

def test_get_driver_wallets_by_driver_id_with_bearer_token():
    # Authenticate to get bearer token
    auth_payload = {"email": TEST_EMAIL, "password": TEST_PASSWORD}
    try:
        auth_resp = requests.post(SUPABASE_AUTH_URL, json=auth_payload, timeout=TIMEOUT)
        assert auth_resp.status_code == 200, f"Authentication failed with status {auth_resp.status_code}"
        auth_data = auth_resp.json()
        access_token = auth_data.get("access_token")
        assert access_token, "No access_token in auth response"
        user = auth_data.get("user")
        assert user and "id" in user, "No user id in auth response"
        driver_user_id = user["id"]

        # Get driver profile to obtain driver_id
        headers = {
            "Authorization": f"Bearer {access_token}",
            "apikey": access_token,
            "Accept": "application/json"
        }
        profile_url = f"{SUPABASE_API_URL}/drivers?user_id=eq.{driver_user_id}&select=*"
        profile_resp = requests.get(profile_url, headers=headers, timeout=TIMEOUT)
        assert profile_resp.status_code == 200, f"Failed to fetch driver profile with status {profile_resp.status_code}"
        profiles = profile_resp.json()
        assert isinstance(profiles, list) and len(profiles) > 0, "Driver profile not found"
        driver = profiles[0]
        driver_id = driver.get("id")
        assert driver_id, "Driver id missing in profile data"

        # Fetch driver_wallets with driver_id and select=*
        wallets_url = f"{SUPABASE_API_URL}/driver_wallets?driver_id=eq.{driver_id}&select=*"
        wallets_resp = requests.get(wallets_url, headers=headers, timeout=TIMEOUT)
        assert wallets_resp.status_code == 200, f"Failed to fetch driver wallets with status {wallets_resp.status_code}"
        wallets = wallets_resp.json()
        # Wallet response is expected as list of wallet objects
        assert isinstance(wallets, list), f"Expected list response, got {type(wallets)}"
        # Check contents if any wallet exists
        for wallet in wallets:
            assert "driver_id" in wallet and wallet["driver_id"] == driver_id, "Wallet driver_id mismatch"
            assert "balance" in wallet, "Wallet balance missing"
            assert "total_earned" in wallet, "Wallet total_earned missing"
            assert "total_withdrawn" in wallet, "Wallet total_withdrawn missing"

    except requests.RequestException as e:
        assert False, f"Request failed: {e}"

test_get_driver_wallets_by_driver_id_with_bearer_token()