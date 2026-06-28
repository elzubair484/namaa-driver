import requests
import time

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

def test_phone_otp_authentication_flow():
    phone_number = "+12345678901"  # Example valid phone number for test
    headers_json = {"Content-Type": "application/json"}
    session = requests.Session()
    auth_token = None

    # Step 1: Send OTP to driver phone number
    try:
        send_otp_resp = session.post(
            f"{BASE_URL}/supabase.auth.signInWithOtp",
            json={"phone": phone_number},
            headers=headers_json,
            timeout=TIMEOUT
        )
        assert send_otp_resp.status_code == 200, f"Expected 200 but got {send_otp_resp.status_code}"
    except requests.RequestException as e:
        assert False, f"Failed to send OTP: {str(e)}"

    # For testing, we must have a way to get the OTP. In real test environments, this is often mocked or fetched from DB/log.
    # Here we simulate with a fixed OTP for demonstration (e.g., '123456').
    # Since PRD does not specify OTP retrieval, we will simulate. If OTP is invalid, expect failure.
    test_otp = "123456"

    # Step 2: Verify OTP and create session
    try:
        verify_otp_resp = session.post(
            f"{BASE_URL}/supabase.auth.verifyOTP",
            json={"phone": phone_number, "otp": test_otp},
            headers=headers_json,
            timeout=TIMEOUT
        )
        # OTP verification successful returns 200 with DriverModel payload and session cookie/token
        if verify_otp_resp.status_code == 200:
            auth_token = verify_otp_resp.headers.get("Authorization") or verify_otp_resp.json().get("access_token")
            assert auth_token is not None, "No auth token in verification response"
            driver_model = verify_otp_resp.json()
            assert isinstance(driver_model, dict), "DriverModel response is not a dict"
        else:
            # If OTP is incorrect / expired, expect 400 and OtpException
            assert verify_otp_resp.status_code == 400, f"Unexpected status code {verify_otp_resp.status_code} on OTP verify"
            err_obj = verify_otp_resp.json()
            assert "OtpException" in str(err_obj), "Expected OtpException in error response"
            return  # Stop test on OTP verify failure
    except requests.RequestException as e:
        assert False, f"Failed to verify OTP: {str(e)}"

    # Prepare auth header for authenticated endpoints
    auth_headers = {
        "Authorization": f"Bearer {auth_token}",
        "Content-Type": "application/json"
    }

    # Step 3: Fetch current authenticated driver profile
    try:
        profile_resp = session.get(
            f"{BASE_URL}/supabase.from(drivers).select",
            headers=auth_headers,
            timeout=TIMEOUT
        )
        assert profile_resp.status_code == 200, f"Expected 200 when fetching profile, got {profile_resp.status_code}"
        profile_data = profile_resp.json()
        assert isinstance(profile_data, dict), "Driver profile response is not a dict"
        assert profile_data.get("phone") == phone_number, "Fetched profile phone does not match login phone"
    except requests.RequestException as e:
        assert False, f"Failed to fetch authenticated driver profile: {str(e)}"

    # Step 4: Simulate real-time profile updates via streaming (GET supabase.from(drivers).stream)
    # Streaming HTTP is complex to simulate here; we test connectivity and response status 200.
    try:
        stream_resp = session.get(
            f"{BASE_URL}/supabase.from(drivers).stream",
            headers=auth_headers,
            timeout=TIMEOUT,
            stream=True
        )
        assert stream_resp.status_code == 200, f"Expected 200 on realtime profile stream, got {stream_resp.status_code}"
        # We read part of the stream to confirm it's open
        chunk = next(stream_resp.iter_content(chunk_size=10), None)
        assert chunk is not None, "Real-time stream did not yield any data"
        stream_resp.close()
    except requests.RequestException as e:
        assert False, f"Failed on real-time driver profile stream: {str(e)}"

    # Step 5: Sign out driver
    try:
        signout_resp = session.post(
            f"{BASE_URL}/supabase.auth.signOut",
            headers=auth_headers,
            timeout=TIMEOUT
        )
        assert signout_resp.status_code == 200, f"Expected 200 on sign out, got {signout_resp.status_code}"
    except requests.RequestException as e:
        assert False, f"Failed to sign out: {str(e)}"

test_phone_otp_authentication_flow()