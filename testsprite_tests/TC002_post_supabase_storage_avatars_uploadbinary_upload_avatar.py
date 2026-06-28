import requests
import base64

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Replace these with valid test driver credentials
TEST_DRIVER_PHONE = "+1234567890"
TEST_DRIVER_PASSWORD = "testpassword"

def test_post_supabase_storage_avatars_uploadbinary_upload_avatar():
    session = requests.Session()
    try:
        # Step 1: Authenticate driver (signInWithPassword)
        signin_url = f"{BASE_URL}/supabase.auth.signInWithPassword"
        signin_payload = {
            "phone": TEST_DRIVER_PHONE,
            "password": TEST_DRIVER_PASSWORD
        }
        signin_resp = session.post(signin_url, json=signin_payload, timeout=TIMEOUT)
        assert signin_resp.status_code == 200, f"Sign in failed with status {signin_resp.status_code}"

        # Step 2: Get OTP from signin response or simulate verification (assuming direct session token in response)
        # Since OTP flow might need a separate call, here we check if token/session is received
        # Note: If OTP verification is needed, this code would add that step; for now assuming direct auth
        # But from PRD: signInWithPassword returns 200 and OTP/session initiation. 
        # If OTP required, we need to verify with OTP; here we simulate verified session.

        # For this test, we mock the verify OTP step (assuming OTP "123456")
        verify_otp_url = f"{BASE_URL}/supabase.auth.verifyOTP"
        verify_otp_payload = {
            "phone": TEST_DRIVER_PHONE,
            "otp": "123456"
        }
        verify_otp_resp = session.post(verify_otp_url, json=verify_otp_payload, timeout=TIMEOUT)
        assert verify_otp_resp.status_code == 200, f"OTP verification failed with status {verify_otp_resp.status_code}"

        # Extract access token from the verified OTP response (assuming response contains a token or in headers)
        # For this example, assuming JSON response with a field 'access_token'
        verify_otp_json = verify_otp_resp.json()
        access_token = verify_otp_json.get("access_token")
        assert access_token, "No access token received on OTP verification"

        headers = {
            "Authorization": f"Bearer {access_token}"
        }

        # Step 3: Prepare a valid avatar image binary payload (a small PNG 1x1 transparent pixel)
        # base64 PNG data for a 1x1 transparent pixel
        png_base64 = (
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAoMBgQIlUJkAAAAASUVORK5CYII="
        )
        avatar_binary = base64.b64decode(png_base64)

        # Step 4: Upload avatar image
        upload_url = f"{BASE_URL}/supabase.storage.avatars.uploadBinary"
        upload_headers = headers.copy()
        upload_headers["Content-Type"] = "application/octet-stream"

        upload_resp = session.post(upload_url, headers=upload_headers, data=avatar_binary, timeout=TIMEOUT)
        assert upload_resp.status_code == 200, f"Avatar upload failed with status {upload_resp.status_code}"

        # Step 5: Validate response contains a public URL (a non-empty string)
        public_url = upload_resp.text.strip()
        assert public_url.startswith("http"), "Avatar upload did not return a valid public URL"
        assert len(public_url) > 10, "Returned public URL seems too short to be valid"

    finally:
        # No resource deletion endpoint given for avatar; this might be handled by cleanup in backend or not needed.
        session.close()

test_post_supabase_storage_avatars_uploadbinary_upload_avatar()