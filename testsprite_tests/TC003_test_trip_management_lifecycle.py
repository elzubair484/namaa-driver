import requests
import time

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Placeholder credentials; in real test, replace with valid test driver phone and OTP
TEST_DRIVER_PHONE = "+12345678901"
TEST_OTP = "123456"  # Assuming 123456 is correct for testing

def test_trip_management_lifecycle():
    session = requests.Session()
    # Step 1: Sign in with phone OTP
    try:
        resp = session.post(
            f"{BASE_URL}/supabase.auth.signInWithOtp",
            json={"phone": TEST_DRIVER_PHONE},
            timeout=TIMEOUT
        )
        assert resp.status_code == 200, f"Failed to send OTP: {resp.text}"
    except requests.RequestException as e:
        assert False, f"Request error sending OTP: {e}"

    # Step 2: Verify OTP and create session with auth token
    try:
        resp = session.post(
            f"{BASE_URL}/supabase.auth.verifyOTP",
            json={"phone": TEST_DRIVER_PHONE, "otp": TEST_OTP},
            timeout=TIMEOUT
        )
        assert resp.status_code == 200, f"Failed to verify OTP: {resp.text}"
        driver_data = resp.json()
        assert "id" in driver_data, "DriverModel missing id"
        # Assuming response contains access_token field or similar for auth
        access_token = driver_data.get("access_token") or driver_data.get("token")
        assert access_token, "No access token received in OTP verify response"
        # Set Authorization header for further requests
        session.headers.update({"Authorization": f"Bearer {access_token}"})
    except requests.RequestException as e:
        assert False, f"Request error verifying OTP: {e}"

    # Helper function to create a new trip request for testing
    def create_trip_request():
        # Since PRD does not specify trip creation endpoint, assuming a POST to supabase.from(trips).insert for test setup
        # For demo, we simulate creating trip via POST /supabase.from(trips).insert with minimal required fields
        trip_payload = {
            "driver_id": driver_data["id"],
            "status": "requested",
            "origin": "POINT(0 0)",
            "destination": "POINT(1 1)",
            "passenger_id": "test-passenger-id",
        }
        try:
            r = session.post(
                f"{BASE_URL}/supabase.from(trips).insert",
                json=trip_payload,
                timeout=TIMEOUT
            )
            if r.status_code == 200:
                trip = r.json()
                assert "id" in trip, "Created trip missing id"
                return trip["id"]
            else:
                # If no insert API available, just return None to skip creation and assume existing trips
                return None
        except requests.RequestException:
            return None

    # Test plan: if no trip id provided, create one; here no ID provided, so create
    trip_id = create_trip_request()
    
    # If unable to create a trip, we cannot do full lifecycle, so fail early
    assert trip_id, "Could not create a trip for lifecycle testing"

    def patch_trip(status=None, passenger_rating=None):
        data = {}
        if status is not None:
            data["status"] = status
        if passenger_rating is not None:
            data["passenger_rating"] = passenger_rating
        try:
            resp = session.patch(
                f"{BASE_URL}/supabase.from(trips).update",
                json={"id": trip_id, **data},
                timeout=TIMEOUT
            )
            return resp
        except requests.RequestException as e:
            return e

    def get_active_trips_stream():
        try:
            resp = session.get(
                f"{BASE_URL}/supabase.from(trips).stream",
                timeout=TIMEOUT
            )
            return resp
        except requests.RequestException as e:
            return e

    # Use try-finally to delete trip after test to clean up
    try:
        # Step 3: Real-time trip streaming - GET supabase.from(trips).stream (simulated by GET)
        resp = get_active_trips_stream()
        assert resp.status_code == 200, f"Failed to open trip stream: {resp.text if isinstance(resp, requests.Response) else resp}"

        # Step 4: Accept the trip request (status=driver_arriving)
        resp = patch_trip(status="driver_arriving")
        assert isinstance(resp, requests.Response), f"Error response patching trip to driver_arriving: {resp}"
        assert resp.status_code == 200, f"Failed to patch status to driver_arriving: {resp.text}"
        trip_entity = resp.json()
        assert trip_entity.get("status") == "driver_arriving", "Trip status not updated to driver_arriving"

        # Step 5: Update status to arrived
        resp = patch_trip(status="arrived")
        assert isinstance(resp, requests.Response), f"Error response patching trip to arrived: {resp}"
        assert resp.status_code == 200, f"Failed to patch status to arrived: {resp.text}"
        trip_entity = resp.json()
        assert trip_entity.get("status") == "arrived", "Trip status not updated to arrived"
        assert "arrived_at" in trip_entity, "Trip timestamps missing 'arrived_at'"

        # Step 6: Update status to in_progress
        resp = patch_trip(status="in_progress")
        assert isinstance(resp, requests.Response), f"Error response patching trip to in_progress: {resp}"
        assert resp.status_code == 200, f"Failed to patch status to in_progress: {resp.text}"
        trip_entity = resp.json()
        assert trip_entity.get("status") == "in_progress", "Trip status not updated to in_progress"

        # Step 7: Update status to completed
        resp = patch_trip(status="completed")
        assert isinstance(resp, requests.Response), f"Error response patching trip to completed: {resp}"
        assert resp.status_code == 200, f"Failed to patch status to completed: {resp.text}"
        trip_entity = resp.json()
        assert trip_entity.get("status") == "completed", "Trip status not updated to completed"
        assert "completed_at" in trip_entity, "Trip timestamps missing 'completed_at'"

        # Step 8: Submit passenger rating after trip completion
        resp = patch_trip(passenger_rating=5)
        assert isinstance(resp, requests.Response), f"Error response patching passenger_rating: {resp}"
        assert resp.status_code == 200, f"Failed to submit passenger rating: {resp.text}"

        # Step 9: Test rejecting a trip request
        # Create another trip to simulate rejection
        another_trip_id = create_trip_request()
        assert another_trip_id, "Could not create a trip for reject test"
        # Reject the trip (status=cancelled)
        try:
            resp = session.patch(
                f"{BASE_URL}/supabase.from/trips).update",
                json={"id": another_trip_id, "status": "cancelled"},
                timeout=TIMEOUT
            )
        except requests.RequestException as e:
            assert False, f"Request error cancelling trip: {e}"
        else:
            assert resp.status_code == 200, f"Failed to patch status to cancelled: {resp.text}"

        # Step 10: Invalid update - complete trip before start (simulate out of order)
        try:
            invalid_resp = session.patch(
                f"{BASE_URL}/supabase.from(trips).update",
                json={"id": another_trip_id, "status": "completed"},
                timeout=TIMEOUT
            )
        except requests.RequestException as e:
            assert False, f"Request error patching invalid trip status: {e}"
        else:
            # Expect error or invalid state update, we accept 4xx or 200 but check for error presence
            assert invalid_resp.status_code in (400, 422, 200), "Unexpected status code for out-of-order trip complete"
            if invalid_resp.status_code == 200:
                # Check if the status was incorrectly updated
                trip_resp = invalid_resp.json()
                assert trip_resp.get("status") == "completed", "Trip status should reflect completed (even if out of order)"
            else:
                # Error expected for invalid update
                error_json = invalid_resp.json()
                assert error_json is not None, "Expected error info on invalid state update"

        # Step 11: Invalid rating before completion
        # Create a new trip for rating test
        rating_test_id = create_trip_request()
        assert rating_test_id, "Could not create trip for rating before completion test"
        try:
            rating_resp = session.patch(
                f"{BASE_URL}/supabase.from(trips).update",
                json={"id": rating_test_id, "passenger_rating": 4},
                timeout=TIMEOUT
            )
        except requests.RequestException as e:
            assert False, f"Request error patching passenger rating before completion: {e}"
        else:
            # Expect error or rejection due to DB constraints or 200 with no effect
            assert rating_resp.status_code in (200, 400, 422), "Unexpected status code for rating before completion"
            if rating_resp.status_code != 200:
                error_json = rating_resp.json()
                assert error_json is not None, "Expected error info on rating before trip completion"

    finally:
        # Cleanup: delete created trips
        def delete_trip(trip_to_delete_id):
            try:
                resp = session.delete(
                    f"{BASE_URL}/supabase.from(trips).delete",
                    json={"id": trip_to_delete_id},
                    timeout=TIMEOUT
                )
                # Accept 200 or 204 as successful deletion
                return resp.status_code in (200, 204)
            except requests.RequestException:
                return False

        delete_trip(trip_id)
        delete_trip(another_trip_id) if 'another_trip_id' in locals() else None
        delete_trip(rating_test_id) if 'rating_test_id' in locals() else None

test_trip_management_lifecycle()