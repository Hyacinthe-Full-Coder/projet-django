#!/bin/bash
# Script de test des endpoints Django
# Usage: bash test_api.sh

BASE_URL="http://localhost:8001/api"

echo "=== 🧪 Testing Gestion Réclamations API ==="
echo ""

# 1. Login Admin
echo "1️⃣  Testing Admin Login..."
LOGIN_RESPONSE=$(python3 -c "
import http.client
import json

conn = http.client.HTTPConnection('localhost', 8001, timeout=5)
login_data = json.dumps({
    'email': 'bigglazer@gmail.com',
    'password': 'pass1234'
})
conn.request('POST', '/api/auth/login/', login_data, {'Content-Type': 'application/json'})
response = conn.getresponse()
print(response.read().decode())
")

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access', ''))" 2>/dev/null)
REFRESH_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('refresh', ''))" 2>/dev/null)

if [ ! -z "$ACCESS_TOKEN" ]; then
    echo "✅ Login Successful"
    echo "   Access Token: ${ACCESS_TOKEN:0:50}..."
else
    echo "❌ Login Failed"
    echo "$LOGIN_RESPONSE"
    exit 1
fi

echo ""

# 2. Get Profile
echo "2️⃣  Testing Get Profile..."
PROFILE=$(python3 -c "
import http.client
import json

conn = http.client.HTTPConnection('localhost', 8001, timeout=5)
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $ACCESS_TOKEN'
}
conn.request('GET', '/api/auth/profile/', headers=headers)
response = conn.getresponse()
data = response.read().decode()
print(data)
")

if echo "$PROFILE" | grep -q "bigglazer"; then
    echo "✅ Profile Retrieved"
    echo "   $PROFILE" | python3 -m json.tool | head -10
else
    echo "❌ Profile Retrieval Failed"
    echo "$PROFILE"
fi

echo ""

# 3. Get Dashboard Stats
echo "3️⃣  Testing Dashboard Stats..."
DASHBOARD=$(python3 -c "
import http.client
import json

conn = http.client.HTTPConnection('localhost', 8001, timeout=5)
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $ACCESS_TOKEN'
}
conn.request('GET', '/api/tickets/dashboard/', headers=headers)
response = conn.getresponse()
data = response.read().decode()
print(data)
")

if echo "$DASHBOARD" | grep -q "total_tickets"; then
    echo "✅ Dashboard Stats Retrieved"
    echo "$DASHBOARD" | python3 -m json.tool | head -15
else
    echo "❌ Dashboard Stats Failed"
    echo "$DASHBOARD"
fi

echo ""

# 4. Register New Citoyen  
echo "4️⃣  Testing Citoyen Registration..."
REGISTER_RESPONSE=$(python3 -c "
import http.client
import json
import time

conn = http.client.HTTPConnection('localhost', 8001, timeout=5)
register_data = json.dumps({
    'email': f'test.citoyen@test.com',
    'username': f'testcitoyen',
    'password': 'TestPassword123!',
    'first_name': 'Test',
    'last_name': 'Citoyen',
    'telephone': '+212612345678'
})
conn.request('POST', '/api/auth/register/', register_data, {'Content-Type': 'application/json'})
response = conn.getresponse()
print(response.read().decode())
")

if echo "$REGISTER_RESPONSE" | grep -q "test.citoyen"; then
    echo "✅ Citoyen Registration Successful"
    echo "$REGISTER_RESPONSE" | python3 -m json.tool
else
    echo "⚠️  Registration Status"
    echo "$REGISTER_RESPONSE" | python3 -m json.tool | head -10
fi

echo ""

# 5. Create Technicien (Admin Only)
echo "5️⃣  Testing Create Technicien (Admin)..."
CREATE_USER=$(python3 -c "
import http.client
import json

conn = http.client.HTTPConnection('localhost', 8001, timeout=5)
user_data = json.dumps({
    'email': f'test.technicien@test.com',
    'username': f'testtechnicien',
    'password': 'TestPassword123!',
    'first_name': 'Test',
    'last_name': 'Technicien',
    'role': 'TECHNICIEN',
    'telephone': '+212612345678'
})
headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $ACCESS_TOKEN'
}
conn.request('POST', '/api/auth/create-user/', user_data, headers)
response = conn.getresponse()
print(response.read().decode())
")

if echo "$CREATE_USER" | grep -q "TECHNICIEN"; then
    echo "✅ Technicien Creation Successful"
    echo "$CREATE_USER" | python3 -m json.tool
else
    echo "⚠️  Create User Status"
    echo "$CREATE_USER" | python3 -m json.tool | head -10
fi

echo ""
echo "=== 🎉 API Testing Complete ==="
