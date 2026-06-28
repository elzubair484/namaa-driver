import requests
import uuid

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

def authenticate_driver(phone: str, password: str):
    """Authenticate driver to get access token and driver info."""
    sign_in_url = f"{BASE_URL}/supabase/auth/signInWithPassword"
    verify_otp_url = f"{BASE_URL}/supabase/auth/verifyOTP"
    
    # Step 1: Request OTP (simulate by signInWithPassword)
    signin_payload = {
        "phone": phone,
        "password": password
    }
    resp = requests.post(sign_in_url, json=signin_payload, timeout=TIMEOUT)
    resp.raise_for_status()
    
    # For the test, assume OTP is delivered out-of-band, here we simulate OTP as '123456'
    otp_payload = {
        "phone": phone,
        "otp": "123456"
    }
    resp = requests.post(verify_otp_url, json=otp_payload, timeout=TIMEOUT)
    resp.raise_for_status()
    driver_model = resp.json()
    
    # We expect a DriverModel and a session token (e.g. access_token)
    # Assuming driver_model contains 'access_token' for auth header
    access_token = driver_model.get("access_token")
    assert access_token, "Authentication failed, no access_token received"
    
    return access_token, driver_model


def test_post_supabase_from_drivers_upsert_create_update_profile():
    phone = "+12345678901"
    password = "testpassword"
    
    access_token, driver_before = authenticate_driver(phone, password)
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    url = f"{BASE_URL}/supabase.from/drivers/upsert"
    
    # Create unique full name and optional email for update
    unique_id = str(uuid.uuid4())[:8]
    full_name = f"Test Driver {unique_id}"
    email = f"testdriver{unique_id}@example.com"
    
    payload = {
        "full_name": full_name,
        "phone": phone,
        "email": email
    }
    
    # Send upsert request
    response = requests.post(url, headers=headers, json=payload, timeout=TIMEOUT)
    
    try:
        response.raise_for_status()
    except requests.HTTPError as e:
        assert False, f"Expected 200 OK but got {response.status_code} with {response.text}"
    
    data = response.json()
    
    # Validate response contains keys consistent with DriverModel (at minimum full_name, phone, email)
    assert isinstance(data, dict), "Response is not a JSON object"
    assert data.get("full_name") == full_name, "Full name in response does not match"
    assert data.get("phone") == phone, "Phone in response does not match"
    # Email is optional but we sent it, so must match
    assert data.get("email") == email, "Email in response does not match"
    # Optionally check for an 'id' or similar
    assert "id" in data, "DriverModel response missing 'id' field"


test_post_supabase_from_drivers_upsert_create_update_profile()
