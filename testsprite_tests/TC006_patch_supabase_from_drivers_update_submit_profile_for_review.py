import requests
import json

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Replace these with valid test credentials for authentication
TEST_PHONE = "+1234567890"
TEST_PASSWORD = "testpassword"

def test_patch_supabase_from_drivers_update_submit_profile_for_review():
    session = requests.Session()
    try:
        # Step 1: Authenticate driver via signInWithPassword to get session
        signin_url = f"{BASE_URL}/supabase.auth.signInWithPassword"
        signin_payload = {
            "phone": TEST_PHONE,
            "password": TEST_PASSWORD
        }
        signin_resp = session.post(signin_url, json=signin_payload, timeout=TIMEOUT)
        assert signin_resp.status_code == 200, f"SignIn failed: {signin_resp.text}"

        # Step 2: Verify OTP (simulate OTP verification with a valid OTP for this user)
        verify_otp_url = f"{BASE_URL}/supabase.auth.verifyOTP"
        # For the sake of this test, assume OTP = "123456"
        verify_otp_payload = {
            "phone": TEST_PHONE,
            "otp": "123456"
        }
        verify_otp_resp = session.post(verify_otp_url, json=verify_otp_payload, timeout=TIMEOUT)
        assert verify_otp_resp.status_code == 200, f"OTP verification failed: {verify_otp_resp.text}"
        driver_model = verify_otp_resp.json()
        assert isinstance(driver_model, dict), "DriverModel should be a dict"

        # Extract auth token/cookie from session or response for authorization
        # Assume token is in cookies or headers for subsequent requests in this test environment

        # Step 3: Upsert driver profile if needed to ensure driver exists before patch
        upsert_url = f"{BASE_URL}/supabase.from(drivers).upsert"
        # Minimal valid profile update (using name and phone)
        upsert_payload = {
            "full_name": driver_model.get("full_name", "Test Driver"),
            "phone": TEST_PHONE
        }
        upsert_resp = session.post(upsert_url, json=upsert_payload, timeout=TIMEOUT)
        assert upsert_resp.status_code == 200, f"Upsert driver failed: {upsert_resp.text}"
        driver_after_upsert = upsert_resp.json()
        assert "status" in driver_after_upsert, "DriverModel missing status field"

        # Step 4: PATCH supabase.from(drivers).update(status=under_review)
        patch_url = f"{BASE_URL}/supabase.from(drivers).update"
        patch_payload = {
            "status": "under_review"
        }
        patch_resp = session.patch(patch_url, json=patch_payload, timeout=TIMEOUT)
        assert patch_resp.status_code == 200, f"Patch update status failed: {patch_resp.text}"

        updated_driver_model = patch_resp.json()
        assert isinstance(updated_driver_model, dict), "Updated DriverModel should be a dict"
        assert updated_driver_model.get("status") == "under_review", "Driver status not updated to under_review"

    finally:
        # Cleanup: revert status back to original if possible (optional)
        try:
            revert_payload = {"status": driver_model.get("status", "pending")}
            session.patch(patch_url, json=revert_payload, timeout=TIMEOUT)
        except Exception:
            pass

test_patch_supabase_from_drivers_update_submit_profile_for_review()