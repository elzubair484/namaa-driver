import requests
import time

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# NOTE: You must replace these with valid test credentials and sample data
TEST_PHONE_NUMBER = "+12345678901"
TEST_OTP = "123456"  # This should be the OTP received or mocked for testing
TEST_FULL_NAME = "Test Driver"
TEST_EMAIL = "testdriver@example.com"
TEST_VEHICLE = {
    "make": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "color": "Blue",
    "plate_number": "ABC1234",
    "vehicle_type": "Sedan"
}
# For uploading avatar and documents, use small binary blobs to simulate files
TEST_AVATAR_BINARY = b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00"
TEST_DOCUMENT_BINARY = b"\x25PDF-1.4\n%..."


def test_driver_onboarding_process():
    session = requests.Session()

    try:
        # Step 1: Authenticate driver - send OTP
        otp_send_resp = session.post(
            f"{BASE_URL}/supabase.auth.signInWithOtp",
            json={"phone": TEST_PHONE_NUMBER},
            timeout=TIMEOUT
        )
        assert otp_send_resp.status_code == 200, f"Failed to send OTP: {otp_send_resp.text}"

        # Step 2: Verify OTP and get DriverModel + session info
        otp_verify_resp = session.post(
            f"{BASE_URL}/supabase.auth.verifyOTP",
            json={"phone": TEST_PHONE_NUMBER, "otp": TEST_OTP},
            timeout=TIMEOUT
        )
        assert otp_verify_resp.status_code == 200, f"OTP verification failed: {otp_verify_resp.text}"
        driver_model = otp_verify_resp.json()
        assert "id" in driver_model, "DriverModel missing 'id' after OTP verification"
        driver_id = driver_model["id"]

        # Save auth token or session cookie if provided for subsequent requests
        # Assuming the session cookie or header-based auth is managed automatically
        # If token returned, add header like: session.headers.update({"Authorization": f"Bearer {token}"})

        # Step 3: Upsert driver profile (full_name, phone, email)
        upsert_profile_resp = session.post(
            f"{BASE_URL}/supabase.from(drivers).upsert",
            json={
                "full_name": TEST_FULL_NAME,
                "phone": TEST_PHONE_NUMBER,
                "email": TEST_EMAIL,
            },
            timeout=TIMEOUT
        )
        assert upsert_profile_resp.status_code == 200, f"Failed to upsert driver profile: {upsert_profile_resp.text}"
        updated_driver = upsert_profile_resp.json()
        assert updated_driver.get("full_name") == TEST_FULL_NAME

        # Step 4: Upload avatar image (binary)
        avatar_upload_resp = session.post(
            f"{BASE_URL}/supabase.storage.avatars.uploadBinary",
            data=TEST_AVATAR_BINARY,
            headers={"Content-Type": "application/octet-stream"},
            timeout=TIMEOUT
        )
        assert avatar_upload_resp.status_code == 200, f"Avatar upload failed: {avatar_upload_resp.text}"
        avatar_url = avatar_upload_resp.text
        assert avatar_url.startswith("http"), "Invalid avatar URL received"

        # Step 5: Upsert vehicle info
        vehicle_upsert_resp = session.post(
            f"{BASE_URL}/supabase.from(vehicles).upsert",
            json=TEST_VEHICLE,
            timeout=TIMEOUT
        )
        assert vehicle_upsert_resp.status_code == 200, f"Vehicle upsert failed: {vehicle_upsert_resp.text}"
        vehicle_model = vehicle_upsert_resp.json()
        assert vehicle_model.get("make") == TEST_VEHICLE["make"]

        # Step 6: Upload document image (binary)
        document_upload_resp = session.post(
            f"{BASE_URL}/supabase.storage.documents.uploadBinary",
            data=TEST_DOCUMENT_BINARY,
            headers={"Content-Type": "application/octet-stream"},
            timeout=TIMEOUT
        )
        assert document_upload_resp.status_code == 200, f"Document upload failed: {document_upload_resp.text}"
        document_url = document_upload_resp.text
        assert document_url.startswith("http"), "Invalid document URL received"

        # Step 7: Save document metadata (type, URL, expiry)
        from datetime import datetime, timedelta
        expiry_date = (datetime.utcnow() + timedelta(days=365)).isoformat() + "Z"
        document_metadata = {
            "document_type": "driver_license",
            "url": document_url,
            "expiry": expiry_date
        }
        document_upsert_resp = session.post(
            f"{BASE_URL}/supabase.from(driver_documents).upsert",
            json=document_metadata,
            timeout=TIMEOUT
        )
        assert document_upsert_resp.status_code == 200, f"Document metadata upsert failed: {document_upsert_resp.text}"
        document_model = document_upsert_resp.json()
        assert document_model.get("document_type") == "driver_license"

        # Step 8: Submit driver profile for admin review (status=under_review)
        submit_review_resp = session.patch(
            f"{BASE_URL}/supabase.from(drivers).update(status=under_review)",
            timeout=TIMEOUT
        )
        assert submit_review_resp.status_code == 200, f"Failed to submit profile for review: {submit_review_resp.text}"
        submitted_driver = submit_review_resp.json()
        assert submitted_driver.get("status") == "under_review"

    finally:
        # Cleanup: delete the created driver profile to keep test isolated if API supports it
        # Since no delete endpoint described, this step is skipped unless provided explicitly
        pass


test_driver_onboarding_process()