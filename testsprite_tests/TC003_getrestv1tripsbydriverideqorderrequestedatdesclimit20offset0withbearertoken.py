import requests

BASE_ENDPOINT = "http://localhost:5173"
AUTH_ENDPOINT = "https://ygvbangmbiywbdakcsnk.supabase.co/auth/v1/token?grant_type=password"
TRIPS_ENDPOINT = "https://ygvbangmbiywbdakcsnk.supabase.co/rest/v1/trips"
DRIVERS_ENDPOINT = "https://ygvbangmbiywbdakcsnk.supabase.co/rest/v1/drivers"

# Use valid credentials of a test driver
TEST_EMAIL = "testdriver@example.com"
TEST_PASSWORD = "TestPassword123!"

# Add your Supabase anon/public API key here (replace with actual key)
API_KEY = "your_supabase_anon_key"

def test_get_trips_by_driverid_order_requested_at_desc_limit_20_offset_0_with_bearer_token():
    try:
        # Step 1: Authenticate to get bearer token
        auth_payload = {
            "email": TEST_EMAIL,
            "password": TEST_PASSWORD
        }
        auth_headers = {
            "apikey": API_KEY,
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        auth_response = requests.post(AUTH_ENDPOINT, json=auth_payload, headers=auth_headers, timeout=30)
        assert auth_response.status_code == 200, f"Authentication failed: {auth_response.text}"
        auth_data = auth_response.json()
        assert "access_token" in auth_data, "access_token missing in auth response"
        bearer_token = auth_data["access_token"]
        token_type = auth_data.get("token_type", "").lower()
        assert token_type == "bearer", f"Expected token_type bearer, got {token_type}"
        user = auth_data.get("user")
        assert user is not None and "id" in user, "User object with id missing in auth response"
        user_id = user["id"]

        # Step 2: Get driver profile to find driver id (assumed driver record linked by user_id)
        headers = {
            "Authorization": f"Bearer {bearer_token}",
            "Accept": "application/json",
            "apikey": API_KEY
        }
        driver_profile_response = requests.get(
            f"{DRIVERS_ENDPOINT}?user_id=eq.{user_id}&select=*",
            headers=headers,
            timeout=30
        )
        assert driver_profile_response.status_code == 200, f"Failed to fetch driver profile: {driver_profile_response.text}"
        drivers = driver_profile_response.json()
        assert isinstance(drivers, list) and len(drivers) > 0, "Driver profile list is empty"
        driver = drivers[0]
        driver_id = driver.get("id")
        assert driver_id is not None, "Driver id is missing"

        # Step 3: Get trips for this driver with required query parameters
        params = {
            "driver_id": f"eq.{driver_id}",
            "order": "requested_at.desc",
            "limit": "20",
            "offset": "0"
        }
        trips_response = requests.get(
            TRIPS_ENDPOINT,
            headers=headers,
            params=params,
            timeout=30
        )
        assert trips_response.status_code == 200, f"Failed to fetch trips: {trips_response.text}"

        trips = trips_response.json()
        # trips should be a list (possibly empty)
        assert isinstance(trips, list), "Response trips is not a list"

    except requests.RequestException as e:
        assert False, f"RequestException occurred: {e}"


test_get_trips_by_driverid_order_requested_at_desc_limit_20_offset_0_with_bearer_token()
