import requests
import uuid

BASE_ENDPOINT = "http://localhost:5173"
SUPABASE_AUTH_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/auth/v1/token?grant_type=password"
SUPABASE_REST_URL = "https://ygvbangmbiywbdakcsnk.supabase.co/rest/v1"

# Use valid credentials for authentication
VALID_EMAIL = "testdriver@example.com"
VALID_PASSWORD = "TestPassword123!"

def get_access_token(email, password):
    payload = {
        "email": email,
        "password": password
    }
    headers = {
        "Content-Type": "application/json"
    }
    response = requests.post(SUPABASE_AUTH_URL, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    data = response.json()
    assert "access_token" in data and "token_type" in data and data["token_type"] == "bearer"
    return data["access_token"], data["user"]["id"]

def test_post_rest_v1_support_tickets_with_valid_data():
    access_token, driver_user_id = get_access_token(VALID_EMAIL, VALID_PASSWORD)
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    # First, get driver profile to retrieve driver_id
    driver_profile_resp = requests.get(
        f"{SUPABASE_REST_URL}/drivers?user_id=eq.{driver_user_id}&select=*",
        headers=headers,
        timeout=30
    )
    driver_profile_resp.raise_for_status()
    drivers = driver_profile_resp.json()
    assert isinstance(drivers, list) and len(drivers) > 0
    driver_id = drivers[0]["id"]
    assert driver_id is not None

    # Prepare support ticket data
    category = "Technical Issue"
    subject = f"Test Support Ticket {uuid.uuid4()}"
    ticket_payload = {
        "driver_id": driver_id,
        "category": category,
        "subject": subject
    }

    created_ticket_id = None
    try:
        # Create a support ticket
        post_resp = requests.post(
            f"{SUPABASE_REST_URL}/support_tickets",
            headers=headers,
            json=ticket_payload,
            timeout=30
        )
        # Validate status code
        assert post_resp.status_code == 201
        ticket_data = post_resp.json()
        # Validate ticket response fields
        assert "id" in ticket_data
        assert ticket_data["category"] == category
        assert ticket_data["subject"] == subject
        assert "status" in ticket_data
        created_ticket_id = ticket_data["id"]
    finally:
        if created_ticket_id:
            # Cleanup - delete the created support ticket
            delete_resp = requests.delete(
                f"{SUPABASE_REST_URL}/support_tickets?id=eq.{created_ticket_id}",
                headers=headers,
                timeout=30
            )
            # Either 204 No Content or 200 OK expected on delete
            assert delete_resp.status_code in [200, 204]

test_post_rest_v1_support_tickets_with_valid_data()