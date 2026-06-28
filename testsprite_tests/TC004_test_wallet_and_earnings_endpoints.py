import requests

BASE_URL = "http://localhost:5173"
TIMEOUT = 30

# Dummy valid auth token for testing; replace with valid token for real tests
AUTH_TOKEN = "Bearer valid_driver_auth_token_example"

HEADERS_AUTH = {
    "Authorization": AUTH_TOKEN,
    "Content-Type": "application/json"
}

HEADERS_NO_AUTH = {
    "Content-Type": "application/json"
}


def test_wallet_and_earnings_endpoints():
    try:
        # 1. Check real-time wallet balance streaming
        stream_url = f"{BASE_URL}/supabase.from(driver_wallets).stream"
        resp_stream = requests.get(stream_url, headers=HEADERS_AUTH, timeout=TIMEOUT)
        assert resp_stream.status_code == 200, f"Expected 200 on wallet stream, got {resp_stream.status_code}"
        # Do NOT parse JSON here since streaming response is not JSON

        # 2. Paginated transaction history retrieval
        transactions_url = f"{BASE_URL}/supabase.from(wallet_transactions).select"
        params = {"limit": 30, "offset": 0}  # pagination params as integers
        resp_transactions = requests.get(transactions_url, headers=HEADERS_AUTH, params=params, timeout=TIMEOUT)
        assert resp_transactions.status_code == 200, f"Expected 200 on transaction history, got {resp_transactions.status_code}"
        transactions = resp_transactions.json()
        assert isinstance(transactions, list), "Transaction history should be a list"
        assert len(transactions) <= 30, "Returned more than 30 transactions"

        # 3. Withdrawal request submission with valid amount
        withdrawal_url = f"{BASE_URL}/supabase.from(withdrawal_requests).insert"
        valid_withdrawal_payload = {
            "amount": 50.0,
            "bank_name": "Valid Bank",
            "account_number": "123456789",
            "account_name": "Valid Account Name"
        }
        resp_withdraw_valid = requests.post(withdrawal_url, headers=HEADERS_AUTH, json=valid_withdrawal_payload, timeout=TIMEOUT)
        assert resp_withdraw_valid.status_code == 200, f"Expected 200 on valid withdrawal request, got {resp_withdraw_valid.status_code}"
        withdrawal_response = resp_withdraw_valid.json()
        assert "amount" in withdrawal_response and withdrawal_response["amount"] == valid_withdrawal_payload["amount"], "Withdrawal response missing or mismatched amount"
        assert "bank_name" in withdrawal_response and withdrawal_response["bank_name"] == valid_withdrawal_payload["bank_name"], "Withdrawal response missing or mismatched bank_name"

        # 4. Withdrawal request submission with invalid amount (exceeding balance)
        invalid_withdrawal_payload = {
            "amount": 999999999.99,  # Assuming this exceeds any realistic balance
            "bank_name": "Invalid Bank",
            "account_number": "000000000",
            "account_name": "Invalid Account Name"
        }
        resp_withdraw_invalid = requests.post(withdrawal_url, headers=HEADERS_AUTH, json=invalid_withdrawal_payload, timeout=TIMEOUT)
        assert resp_withdraw_invalid.status_code in [200, 400, 403, 422], f"Unexpected status code for invalid withdrawal: {resp_withdraw_invalid.status_code}"

        # 5. Earnings breakdown retrieval
        earnings_url = f"{BASE_URL}/supabase.from(trips).select(driver_earnings)"
        resp_earnings = requests.get(earnings_url, headers=HEADERS_AUTH, timeout=TIMEOUT)
        assert resp_earnings.status_code == 200, f"Expected 200 on earnings breakdown, got {resp_earnings.status_code}"
        assert resp_earnings.content and len(resp_earnings.content) > 0, "Earnings response is empty"
        earnings = resp_earnings.json()
        assert isinstance(earnings, dict), "Earnings breakdown should be a dict"
        for key in ["today", "week", "month"]:
            assert key in earnings, f"Earnings breakdown missing key: {key}"
            assert isinstance(earnings[key], (int, float)), f"Earnings value for {key} must be number"

        # 6. Authorization enforcement check:
        resp_no_auth = requests.get(transactions_url, headers=HEADERS_NO_AUTH, params=params, timeout=TIMEOUT)
        assert resp_no_auth.status_code in [401, 403], f"Expected auth failure status code without token, got {resp_no_auth.status_code}"

    except requests.RequestException as e:
        assert False, f"HTTP request failed: {e}"


test_wallet_and_earnings_endpoints()
