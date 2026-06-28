import requests
import time

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Dummy credentials and initial data for test
TEST_PHONE = "+1234567890"
TEST_OTP = "123456"  # In real case would be received or mocked

def authenticate_driver():
    """
    Helper function to authenticate a driver to get auth headers with session token.
    Since PRD states verifyOTP returns DriverModel without session token,
    this function validates OTP flow but returns empty headers.
    """
    try:
        # Send OTP
        resp = requests.post(
            f"{BASE_URL}/supabase.auth.signInWithOtp",
            json={"phone": TEST_PHONE},
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200

        # Verify OTP
        resp = requests.post(
            f"{BASE_URL}/supabase.auth.verifyOTP",
            json={"phone": TEST_PHONE, "otp": TEST_OTP},
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200

        # No session token provided; return empty headers
        return {}

    except (requests.RequestException, AssertionError) as e:
        raise RuntimeError(f"Authentication failed: {e}")


def test_support_ticket_management():
    headers = authenticate_driver()
    # Common headers for JSON content
    headers = {"Content-Type": "application/json"}

    ticket_id = None

    try:
        # 1. List existing support tickets (GET supabase.from(support_tickets).select with auth)
        list_resp = requests.get(
            f"{BASE_URL}/supabase.from(support_tickets).select",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert list_resp.status_code == 200
        tickets = list_resp.json()
        assert isinstance(tickets, list)

        # 2. Create new ticket with initial message (POST supabase.from(support_tickets).insert + supabase.from(support_messages).insert)
        new_ticket_payload = {
            "category": "App Issue",
            "subject": "Test Ticket Subject",
            "firstMessage": "This is the initial message of the support ticket.",
            # "tripId" is optional and omitted here
        }
        create_resp = requests.post(
            f"{BASE_URL}/supabase.from(support_tickets).insert + supabase.from(support_messages).insert",
            headers=headers,
            json=new_ticket_payload,
            timeout=TIMEOUT,
        )
        assert create_resp.status_code == 200
        ticket_data = create_resp.json()
        # We expect a created TicketEntity with some id
        assert isinstance(ticket_data, dict)
        assert "id" in ticket_data and ticket_data["id"]
        ticket_id = ticket_data["id"]

        # 3. Stream real-time messages for that ticket (GET supabase.from(support_messages).stream)
        # This is a demo test, so simulate getting messages once as actual streaming not feasible here
        stream_resp = requests.get(
            f"{BASE_URL}/supabase.from(support_messages).stream",
            headers={**headers, "X-Ticket-Id": str(ticket_id)},
            timeout=TIMEOUT,
        )
        assert stream_resp.status_code == 200
        messages = stream_resp.json()
        assert isinstance(messages, list)
        # There should be at least the first message
        assert any(
            msg.get("content") == new_ticket_payload["firstMessage"] for msg in messages
        )

        # 4. Send a follow-up message (POST supabase.from(support_messages).insert)
        follow_up_payload = {
            "ticketId": ticket_id,
            "content": "This is a follow-up message to the support ticket.",
        }
        follow_up_resp = requests.post(
            f"{BASE_URL}/supabase.from(support_messages).insert",
            headers=headers,
            json=follow_up_payload,
            timeout=TIMEOUT,
        )
        assert follow_up_resp.status_code in (200, 204)

        # 5. Validate error responses for missing required fields on ticket creation
        invalid_payloads = [
            {"subject": "No category", "firstMessage": "Missing category"},
            {"category": "No subject", "firstMessage": "Missing subject"},
            {"category": "Category only"},
        ]
        for invalid_payload in invalid_payloads:
            err_resp = requests.post(
                f"{BASE_URL}/supabase.from(support_tickets).insert + supabase.from(support_messages).insert",
                headers=headers,
                json=invalid_payload,
                timeout=TIMEOUT,
            )
            # Expect error status code: 400 or 422 (validation error)
            assert err_resp.status_code >= 400

        # 6. Validate authentication enforcement

        # Attempt to list tickets without auth header
        unauth_resp = requests.get(
            f"{BASE_URL}/supabase.from(support_tickets).select", timeout=TIMEOUT
        )
        assert unauth_resp.status_code in (401, 403)

        # Attempt to create a ticket without auth header
        unauth_create_resp = requests.post(
            f"{BASE_URL}/supabase.from(support_tickets).insert + supabase.from(support_messages).insert",
            json=new_ticket_payload,
            timeout=TIMEOUT,
        )
        assert unauth_create_resp.status_code in (401, 403)

        # Attempt to send follow-up message without auth header
        unauth_msg_resp = requests.post(
            f"{BASE_URL}/supabase.from(support_messages).insert",
            json=follow_up_payload,
            timeout=TIMEOUT,
        )
        assert unauth_msg_resp.status_code in (401, 403)

    finally:
        # Cleanup: delete created support ticket if exists
        if ticket_id:
            try:
                del_resp = requests.delete(
                    f"{BASE_URL}/supabase.from(support_tickets).delete",
                    headers=headers,
                    json={"id": ticket_id},
                    timeout=TIMEOUT,
                )
                # Deletion may or may not return content; Accept 200 or 204
                assert del_resp.status_code in (200, 204, 404)
            except Exception:
                # Ignore cleanup errors
                pass


test_support_ticket_management()
