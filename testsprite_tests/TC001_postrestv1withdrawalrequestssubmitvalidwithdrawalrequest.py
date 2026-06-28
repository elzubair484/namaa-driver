import requests

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

SUPABASE_URL = "https://ygvbangmbiywbdakcsnk.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlndmJhbmdtYml5d2JkYWtjc25rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0NzQ2MzgsImV4cCI6MjA5ODA1MDYzOH0.7LvUn_OO_RN-GtBs8s7SeT5Dq64jOHj-g_5zV8XMjyE"
TEST_EMAIL = "driver@test.com"
TEST_PASSWORD = "wweerr123"


def test_postrestv1withdrawalrequestssubmitvalidwithdrawalrequest():
    session = requests.Session()
    try:
        # Authenticate to get access_token
        auth_resp = session.post(
            f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
            json={"email": TEST_EMAIL, "password": TEST_PASSWORD},
            headers={"apikey": SUPABASE_ANON_KEY, "Content-Type": "application/json"},
            timeout=TIMEOUT,
        )
        assert auth_resp.status_code == 200, f"Authentication failed: {auth_resp.text}"
        auth_data = auth_resp.json()
        access_token = auth_data.get("access_token")
        assert access_token, "No access_token returned"

        headers = {
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        }

        # Get driver profile to retrieve driver_id
        user_id = auth_data.get("user", {}).get("id")
        assert user_id, "No user id in auth user data"

        drivers_resp = session.get(
            f"{SUPABASE_URL}/rest/v1/drivers?user_id=eq.{user_id}&select=*",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert drivers_resp.status_code == 200, f"Failed to fetch drivers: {drivers_resp.text}"
        drivers = drivers_resp.json()
        assert isinstance(drivers, list), "Drivers response is not a list"
        if len(drivers) > 0:
            driver = drivers[0]
            driver_id = driver.get("id")
            assert driver_id, "Driver missing id"
        else:
            # Create driver profile if not exists
            create_driver_resp = session.post(
                f"{SUPABASE_URL}/rest/v1/drivers",
                headers=headers,
                json={
                    "user_id": user_id,
                    "full_name": "Test Driver",
                    "phone": "0000000000",
                    "status": "pending",
                    "locale": "ar",
                },
                timeout=TIMEOUT,
            )
            assert create_driver_resp.status_code == 201, f"Failed to create driver: {create_driver_resp.text}"
            created_driver = create_driver_resp.json()
            assert isinstance(created_driver, list) and len(created_driver) == 1, "Unexpected create driver response"
            driver_id = created_driver[0].get("id")
            assert driver_id, "Created driver missing id"

        # Get driver wallet to retrieve wallet_id
        wallets_resp = session.get(
            f"{SUPABASE_URL}/rest/v1/driver_wallets?driver_id=eq.{driver_id}&select=*",
            headers=headers,
            timeout=TIMEOUT,
        )
        assert wallets_resp.status_code == 200, f"Failed to fetch driver wallets: {wallets_resp.text}"
        wallets = wallets_resp.json()
        assert isinstance(wallets, list), "Wallets response is not a list"
        assert len(wallets) > 0, "No wallet found for driver"
        wallet = wallets[0]
        wallet_id = wallet.get("id")
        assert wallet_id, "Wallet missing id"

        # Prepare withdrawal request data
        withdrawal_data = {
            "driver_id": driver_id,
            "wallet_id": wallet_id,
            "amount": 10.5,
            "bank_name": "Test Bank",
            "account_number": "1234567890",
            "account_name": "Test Account",
        }

        withdrawal_resp = session.post(
            f"{SUPABASE_URL}/rest/v1/withdrawal_requests",
            headers=headers,
            json=withdrawal_data,
            timeout=TIMEOUT,
        )
        assert withdrawal_resp.status_code == 201, f"Withdrawal request failed: {withdrawal_resp.text}"

        withdrawal_resp_json = withdrawal_resp.json()
        # According to Supabase, response will be a list with one object on creation
        assert isinstance(withdrawal_resp_json, list) and len(withdrawal_resp_json) == 1, "Invalid withdrawal response format"
        withdrawal = withdrawal_resp_json[0]

        # Validate response fields
        assert "id" in withdrawal, "Withdrawal response missing id"
        assert withdrawal.get("amount") == withdrawal_data["amount"], "Withdrawal amount mismatch"
        assert "status" in withdrawal, "Withdrawal response missing status"
        assert withdrawal.get("bank_name") == withdrawal_data["bank_name"], "Withdrawal bank_name mismatch"

    finally:
        # Cleanup: delete the created withdrawal request if it was created
        try:
            if 'withdrawal' in locals() and "id" in withdrawal:
                del_resp = session.delete(
                    f"{SUPABASE_URL}/rest/v1/withdrawal_requests?id=eq.{withdrawal['id']}",
                    headers=headers,
                    timeout=TIMEOUT,
                )
                # deletion may return 204 or 200
                assert del_resp.status_code in [200, 204], f"Failed to delete withdrawal request: {del_resp.text}"
        except Exception:
            pass

        # Optional: no driver or wallet cleanup as they might be shared resources


test_postrestv1withdrawalrequestssubmitvalidwithdrawalrequest()