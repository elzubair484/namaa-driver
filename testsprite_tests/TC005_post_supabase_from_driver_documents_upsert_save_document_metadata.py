import requests
import datetime

BASE_URL = "http://localhost:5173"

# Example credentials for authentication - to be replaced with valid test driver credentials
TEST_DRIVER_PHONE = "+15555550123"
TEST_OTP = "123456"

def sign_in(phone: str):
    url = f"{BASE_URL}/supabase.auth.signInWithPassword"
    payload = {
        "phone": phone
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    return response

def verify_otp(phone: str, otp: str):
    url = f"{BASE_URL}/supabase.auth.verifyOTP"
    payload = {
        "phone": phone,
        "otp": otp
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, json=payload, headers=headers, timeout=30)
    response.raise_for_status()
    json_resp = response.json()
    # Should contain DriverModel with session data and auth token
    return json_resp

def get_auth_token(driver_session: dict):
    # Extract token from session data
    return driver_session.get("access_token")

def upsert_driver_profile(auth_token: str, full_name: str, phone: str, email: str = None):
    url = f"{BASE_URL}/supabase.from(drivers).upsert"
    body = {"full_name": full_name, "phone": phone}
    if email:
        body["email"] = email
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {auth_token}"}
    response = requests.post(url, json=body, headers=headers, timeout=30)
    response.raise_for_status()
    return response.json()

def upload_document_image(auth_token: str):
    # Since we need a signed URL for the document, upload a test document image binary
    url = f"{BASE_URL}/supabase.storage.documents.uploadBinary"
    headers = {"Authorization": f"Bearer {auth_token}"}
    # Using a small dummy binary content for test document (e.g., a PNG magic number)
    dummy_file_content = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00'
    files = {'file': ('test_document.png', dummy_file_content, 'image/png')}
    response = requests.post(url, headers=headers, files=files, timeout=30)
    response.raise_for_status()
    # Response is a JSON string with the signed URL or just string?
    # According to PRD response is 200 with string (signed URL)
    signed_url = response.text.strip('"') if response.text else None
    if not signed_url:
        raise ValueError("No signed URL received from document upload")
    return signed_url

def upsert_driver_document(auth_token: str, doc_type: str, url_doc: str, expiry: str):
    url = f"{BASE_URL}/supabase.from(driver_documents).upsert"
    body = {
        "type": doc_type,
        "url": url_doc,
        "expiry": expiry
    }
    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {auth_token}"}
    response = requests.post(url, json=body, headers=headers, timeout=30)
    response.raise_for_status()
    return response.json()

def test_post_supabase_from_driver_documents_upsert_save_document_metadata():
    # Step 1: Authenticate driver - simulate signInWithPassword and verifyOTP
    try:
        sign_in_resp = sign_in(TEST_DRIVER_PHONE)
        # Normally OTP is sent via SMS or similar: here we simulate with a dummy OTP TEST_OTP
        driver_session = verify_otp(TEST_DRIVER_PHONE, TEST_OTP)
        assert "access_token" in driver_session, "No access_token in session"
        auth_token = get_auth_token(driver_session)
        assert auth_token, "Auth token extraction failed"

        # Step 2: Upload a document image to get a signed URL
        signed_url = upload_document_image(auth_token)
        assert signed_url.startswith("http"), "Invalid signed URL format"

        # Step 3: Prepare document metadata with type, url, and expiry
        doc_type = "license"
        expiry_date = (datetime.datetime.utcnow() + datetime.timedelta(days=365)).strftime("%Y-%m-%d")
        document_data = upsert_driver_document(auth_token, doc_type, signed_url, expiry_date)

        # Step 4: Validate response has expected document metadata fields (DocumentModel)
        # DocumentModel is not precisely defined, but should have at least type, url, and expiry in response
        assert isinstance(document_data, dict), "Response is not a dictionary"
        assert document_data.get("type") == doc_type, "Document type mismatch"
        assert document_data.get("url") == signed_url, "Document URL mismatch"
        assert document_data.get("expiry") == expiry_date, "Document expiry mismatch"

        # Also HTTP status 200 is implicit by raise_for_status above
        print("Test TC005 passed successfully.")

    except requests.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
        raise
    except AssertionError as assert_err:
        print(f"Assertion error: {assert_err}")
        raise
    except Exception as err:
        print(f"Unexpected error: {err}")
        raise

test_post_supabase_from_driver_documents_upsert_save_document_metadata()
