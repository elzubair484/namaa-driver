import requests

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# For demonstration, placeholders for the driver auth token and a sample document image binary data.
# In real tests, replace with actual valid credentials, token retrieval, and proper image data.
AUTH_TOKEN = "Bearer your_valid_driver_auth_token_here"
DOCUMENT_IMAGE_PATH = "driver_document_sample.jpg"


def post_supabase_storage_documents_uploadbinary_upload_document_image():
    headers = {
        "Authorization": AUTH_TOKEN,
        "Content-Type": "application/octet-stream"
    }
    url = f"{BASE_URL}/supabase.storage.documents.uploadBinary"

    try:
        with open(DOCUMENT_IMAGE_PATH, "rb") as f:
            binary_data = f.read()

        response = requests.post(url, headers=headers, data=binary_data, timeout=TIMEOUT)

        # Assert HTTP status code 200 for success
        assert response.status_code == 200, f"Expected status 200, got {response.status_code}"

        # Response should be a signed URL string
        signed_url = response.text.strip()
        assert signed_url.startswith("http"), "Signed URL does not look valid"

    except requests.RequestException as e:
        assert False, f"Request failed: {e}"
    except FileNotFoundError:
        assert False, f"Document image file not found: {DOCUMENT_IMAGE_PATH}"


post_supabase_storage_documents_uploadbinary_upload_document_image()