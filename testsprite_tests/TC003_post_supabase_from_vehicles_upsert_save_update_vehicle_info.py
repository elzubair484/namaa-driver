import requests
import uuid

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Placeholder for auth token for an authenticated driver; replace with valid token
AUTH_TOKEN = "your_valid_auth_token_here"

def test_post_supabase_from_vehicles_upsert_save_update_vehicle_info():
    url = f"{BASE_URL}/supabase.from(vehicles).upsert"
    headers = {
        "Authorization": f"Bearer {AUTH_TOKEN}",
        "Content-Type": "application/json"
    }

    # Vehicle data - creating a new unique plate_number to avoid conflicts
    vehicle_data = {
        "make": "Toyota",
        "model": "Corolla",
        "year": 2020,
        "color": "Blue",
        "plate_number": f"TEST-{uuid.uuid4().hex[:8].upper()}",
        "vehicle_type": "sedan"
    }

    # Use try-finally to delete the created vehicle after test as per instructions
    # But deletion endpoint is not defined in PRD; assuming it exists as DELETE supabase.from(vehicles).delete
    # Since not provided, skipping deletion but it's recommended to clean test data if possible
    
    try:
        response = requests.post(url, json=vehicle_data, headers=headers, timeout=TIMEOUT)
        response.raise_for_status()

        # Validate response status code
        assert response.status_code == 200, f"Expected status code 200 but got {response.status_code}"

        vehicle = response.json()
        # Validate VehicleModel content
        # Required fields as per request plus possibly id or others returned; check keys
        expected_keys = {"make", "model", "year", "color", "plate_number", "vehicle_type"}
        response_keys = set(vehicle.keys())
        missing_keys = expected_keys - response_keys
        assert not missing_keys, f"Response JSON missing keys: {missing_keys}"

        # Validate returned fields match sent data
        for key in expected_keys:
            assert vehicle[key] == vehicle_data[key], f"Mismatch in field '{key}': expected '{vehicle_data[key]}', got '{vehicle[key]}'"

    except requests.exceptions.RequestException as e:
        assert False, f"Request failed: {e}"

test_post_supabase_from_vehicles_upsert_save_update_vehicle_info()