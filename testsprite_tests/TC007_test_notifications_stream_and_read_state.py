import requests
import time

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

PHONE_NUMBER = "+12345678901"
CORRECT_OTP = "123456"

def test_notifications_stream_and_read_state():
    session = requests.Session()
    try:
        resp = session.post(
            f"{BASE_URL}/supabase.auth.signInWithOtp",
            json={"phone": PHONE_NUMBER},
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200
        
        resp = session.post(
            f"{BASE_URL}/supabase.auth.verifyOTP",
            json={"phone": PHONE_NUMBER, "otp": CORRECT_OTP},
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200
        driver_data = resp.json()
        assert "id" in driver_data
        auth_token = None
        for key in resp.headers:
            if key.lower() == 'authorization':
                auth_token = resp.headers[key]
                break
        assert auth_token is not None, "Authorization token missing after OTP verify"
        
        headers = {"Authorization": f"Bearer {auth_token}"}
        
        resp = session.get(
            f"{BASE_URL}/supabase.from(notifications).stream",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200
        notifications = resp.json()
        assert isinstance(notifications, list)
        
        resp = session.get(
            f"{BASE_URL}/supabase.from(notifications).select(id).eq(is_read,false)",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert resp.status_code == 200
        unread_count = resp.json()
        assert isinstance(unread_count, int)
        
        if unread_count > 0:
            unread_notifications = [n for n in notifications if (not n.get("is_read", False))]
            if unread_notifications:
                notif_id = unread_notifications[0].get("id")
                assert notif_id is not None
                
                patch_resp = session.patch(
                    f"{BASE_URL}/supabase.from(notifications).update(is_read=true).eq(id,{notif_id})",
                    headers=headers,
                    timeout=TIMEOUT,
                )
                assert patch_resp.status_code == 200
                
                resp2 = session.get(
                    f"{BASE_URL}/supabase.from(notifications).select(id).eq(is_read,false)",
                    headers=headers,
                    timeout=TIMEOUT,
                )
                assert resp2.status_code == 200
                new_unread_count = resp2.json()
                assert new_unread_count == unread_count - 1
        
        recipient_id = driver_data.get("id")
        assert recipient_id is not None
        
        patch_all_resp = session.patch(
            f"{BASE_URL}/supabase.from(notifications).update(is_read=true).eq(recipient_id,{recipient_id})",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert patch_all_resp.status_code == 200
        
        resp3 = session.get(
            f"{BASE_URL}/supabase.from(notifications).select(id).eq(is_read,false)",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert resp3.status_code == 200
        final_unread_count = resp3.json()
        assert final_unread_count == 0
        
        resp_no_auth = session.get(
            f"{BASE_URL}/supabase.from(notifications).select(id).eq(is_read,false)",
            timeout=TIMEOUT,
        )
        assert resp_no_auth.status_code in (401, 403)
        
        invalid_notif_id = "00000000-0000-0000-0000-000000000000"
        patch_invalid_resp = session.patch(
            f"{BASE_URL}/supabase.from(notifications).update(is_read=true).eq(id,{invalid_notif_id})",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert patch_invalid_resp.status_code in (200, 400, 403, 404)
        
        resp_stream_no_auth = session.get(
            f"{BASE_URL}/supabase.from(notifications).stream",
            timeout=TIMEOUT,
        )
        assert resp_stream_no_auth.status_code in (401, 403)
        
    finally:
        if 'auth_token' in locals() and auth_token is not None:
            session.post(
                f"{BASE_URL}/supabase.auth.signOut",
                headers={"Authorization": f"Bearer {auth_token}"},
                timeout=TIMEOUT,
            )
        session.close()

test_notifications_stream_and_read_state()
