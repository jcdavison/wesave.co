PLAID_CLIENT_ID = ENV['PLAID_SANDBOX'] == 'true' ? 'test_id' : ENV['PLAID_CLIENT_ID']
PLAID_SECRET = ENV['PLAID_SANDBOX'] == 'true' ? 'test_secret' : ENV['PLAID_SECRET']
