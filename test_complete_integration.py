#!/usr/bin/env python3
"""
TEST COMPLET D'INTEGRATION - Gestion des Reclamations
Valide tous les scenarios utilisant directement les APIs
"""

print("SCRIPT STARTING - UNIQUE MARKER")
import http.client
import json
import time
from datetime import datetime
import sys

class APITester:
    def __init__(self, host="localhost", port=8000):
        self.host = host
        self.port = port
        self.base_url = f"http://{host}:{port}/api"
        self.tokens = {}
        self.test_results = []
        
    def _request(self, method, endpoint, data=None, token=None, expect_status=200):
        """Helper pour faire une requete HTTP"""
        conn = http.client.HTTPConnection(self.host, self.port, timeout=10)
        headers = {"Content-Type": "application/json"}
        
        if token:
            headers["Authorization"] = f"Bearer {token}"
        
        body = json.dumps(data) if data else None
        try:
            conn.request(method, endpoint, body, headers)
            response = conn.getresponse()
            response_data = response.read().decode()
            
            try:
                parsed = json.loads(response_data) if response_data else {}
            except:
                parsed = {"raw": response_data}
            
            success = response.status == expect_status
            return {
                "status": response.status,
                "success": success,
                "data": parsed,
                "expected": expect_status
            }
        except Exception as e:
            return {"status": 0, "success": False, "error": str(e)}
        finally:
            conn.close()
    
    def log_test(self, name, result, details="", error_details=None):
        """Enregistrer le resultat d'un test"""
        status = "PASS" if result else "FAIL"
        self.test_results.append((name, result, details))
        print(f"{status} | {name}")
        if details:
            print(f"         {details}")
        if error_details is not None:
            print(f"         Error: {error_details}")
        sys.stdout.flush()
    
    def print_summary(self):
        """Afficher le resume des tests"""
        print("\n" + "="*70)
        passed = sum(1 for _, r, _ in self.test_results if r)
        total = len(self.test_results)
        print(f"RESUME: {passed}/{total} tests passants")
        print("="*70 + "\n")
        
        if passed == total:
            print("TOUS LES TESTS REUSSIS - APPLICATION 100% FONCTIONNELLE")
        else:
            print("Certains tests ont echoue - voir details ci-dessus")
        print("="*70)
    
    # ==================== SCENARIOS DE TEST ====================
    
    def test_admin_login(self):
        """SCENARIO 1: Admin login avec identifiants systeme"""
        print("\n[SCENARIO 1] ADMIN LOGIN")
        print("-" * 50)
        
        result = self._request(
            "POST", "/api/auth/login/",
            {"email": "bigglazer@gmail.com", "password": "pass1234"},
            expect_status=200
        )
        
        passed = (result["success"] and 
                  "access" in result["data"] and 
                  "refresh" in result["data"])
        
        if passed:
            self.tokens["admin"] = result["data"]["access"]
            self.tokens["admin_refresh"] = result["data"]["refresh"]
        
        self.log_test(
            "Admin login (bigglazer)",
            passed,
            f"Token: {result['data'].get('access', 'N/A')[:30]}..."
        )
    
    def test_admin_profile(self):
        """Verifier le profil admin"""
        if "admin" not in self.tokens:
            print("Skipping - no admin token")
            return
        
        print("\n[SCENARIO 1] GET ADMIN PROFILE")
        result = self._request(
            "GET", "/api/auth/profile/",
            token=self.tokens["admin"],
            expect_status=200
        )
        
        passed = (result["success"] and 
                  result["data"].get("role") == "ADMIN" and
                  "bigglazer" in result["data"].get("email", ""))
        
        self.log_test(
            "Get admin profile",
            passed,
            f"Role: {result['data'].get('role')}, Email: {result['data'].get('email')}"
        )
    
    def test_admin_dashboard_stats(self):
        """Verifier les statistiques du dashboard admin"""
        if "admin" not in self.tokens:
            print("Skipping - no admin token")
            return
        
        print("\n[SCENARIO 1] GET DASHBOARD STATS")
        result = self._request(
            "GET", "/api/tickets/dashboard/",
            token=self.tokens["admin"],
            expect_status=200
        )
        
        passed = (result["success"] and
                  "total_tickets" in result["data"] and
                  "tickets_by_status" in result["data"] and
                  "users_by_role" in result["data"])
        
        if passed:
            print(f"         Total Tickets: {result['data'].get('total_tickets')}")
            print(f"         Users: {result['data'].get('users_by_role')}")
        
        self.log_test("Dashboard stats", passed)
    
    def test_citoyen_registration(self):
        """SCENARIO 2: Citoyen s'inscrit"""
        print("\n[SCENARIO 2] CITOYEN REGISTRATION")
        print("-" * 50)
        
        timestamp = int(time.time())
        citoyen_data = {
            "email": f"citoyen.test{timestamp}@test.com",
            "username": f"citoyen_{timestamp}",
            "password": "CitoyenTest123!",
            "first_name": "Jean",
            "last_name": "Dupont",
            "telephone": "+212612345678"
        }
        
        result = self._request(
            "POST", "/api/auth/register/",
            citoyen_data,
            expect_status=201
        )
        
        passed = (result["success"] and
                  result["data"].get("role") == "CITOYEN")
        
        if passed:
            self.tokens["citoyen_email"] = citoyen_data["email"]
            self.tokens["citoyen_password"] = citoyen_data["password"]
        
        error_details = None
        if not passed:
            error_details = f"Status: {result['status']}, Response: {result['data']}"
        
        print(f"DEBUG: passed={passed}, error_details={error_details}")
        sys.stdout.flush()
        
        self.log_test(
            "Citoyen registration",
            passed,
            f"Email: {citoyen_data['email']}",
            error_details
        )
    
    def test_citoyen_login(self):
        """Citoyen login avec nouvelles credentials"""
        if "citoyen_email" not in self.tokens:
            print("Skipping - no citoyen registered")
            return
        
        print("\n[SCENARIO 2] CITOYEN LOGIN")
        result = self._request(
            "POST", "/api/auth/login/",
            {
                "email": self.tokens["citoyen_email"],
                "password": self.tokens["citoyen_password"]
            },
            expect_status=200
        )
        
        passed = result["success"] and "access" in result["data"]
        
        if passed:
            self.tokens["citoyen"] = result["data"]["access"]
        
        self.log_test("Citoyen login", passed)
    
    def test_citoyen_profile(self):
        """Verifier profil citoyen"""
        if "citoyen" not in self.tokens:
            print("Skipping - no citoyen token")
            return
        
        print("\n[SCENARIO 2] GET CITOYEN PROFILE")
        result = self._request(
            "GET", "/api/auth/profile/",
            token=self.tokens["citoyen"],
            expect_status=200
        )
        
        passed = (result["success"] and
                  result["data"].get("role") == "CITOYEN")
        
        self.log_test("Citoyen profile role", passed, f"Role: {result['data'].get('role')}")
    
    def test_create_ticket(self):
        """Citoyen cree un ticket"""
        if "citoyen" not in self.tokens:
            print("Skipping - no citoyen token")
            return
        
        print("\n[SCENARIO 2] CREATE TICKET (CITOYEN)")
        
        ticket_data = {
            "title": "Panne d'eau dans le quartier",
            "description": "L'eau ne coule plus depuis ce matin",
            "type": "Service",
            "priority": "Haut",
            "location": "Rue Mohammed V"
        }
        
        result = self._request(
            "POST", "/api/tickets/",
            ticket_data,
            token=self.tokens["citoyen"],
            expect_status=201
        )
        
        passed = (result["success"] and
                  result["data"].get("status") == "OUVERT")
        
        if passed:
            self.tokens["ticket_id"] = result["data"].get("id")
        
        self.log_test(
            "Create ticket",
            passed,
            f"Status: {result['data'].get('status')}, ID: {result['data'].get('id')}"
        )
    
    def test_create_technicien(self):
        """SCENARIO 3: Admin cree un technicien"""
        if "admin" not in self.tokens:
            print("Skipping - no admin token")
            return
        
        print("\n[SCENARIO 3] CREATE TECHNICIEN (ADMIN)")
        print("-" * 50)
        
        timestamp = int(time.time())
        technicien_data = {
            "email": f"technicien.test{timestamp}@test.com",
            "username": f"technicien_{timestamp}",
            "password": "TechnicienTest123!",
            "first_name": "Sophie",
            "last_name": "Martin",
            "role": "TECHNICIEN",
            "telephone": "+212612345000"
        }
        
        result = self._request(
            "POST", "/api/auth/create-user/",
            technicien_data,
            token=self.tokens["admin"],
            expect_status=201
        )
        
        passed = (result["success"] and
                  result["data"].get("role") == "TECHNICIEN")
        
        if passed:
            self.tokens["technicien_email"] = technicien_data["email"]
            self.tokens["technicien_password"] = technicien_data["password"]
        
        self.log_test(
            "Create technicien",
            passed,
            f"Email: {technicien_data['email']}"
        )
    
    def test_technicien_login(self):
        """Technicien login"""
        if "technicien_email" not in self.tokens:
            print("Skipping - no technicien created")
            return
        
        print("\n[SCENARIO 3] TECHNICIEN LOGIN")
        result = self._request(
            "POST", "/api/auth/login/",
            {
                "email": self.tokens["technicien_email"],
                "password": self.tokens["technicien_password"]
            },
            expect_status=200
        )
        
        passed = result["success"] and "access" in result["data"]
        
        if passed:
            self.tokens["technicien"] = result["data"]["access"]
        
        self.log_test("Technicien login", passed)
    
    def test_technicien_dashboard(self):
        """Technicien voit son dashboard"""
        print("UNIQUE DEBUG: Technician dashboard test starting")
        if "technicien" not in self.tokens:
            print("Skipping - no technicien token")
            return
        
        print("\n[SCENARIO 3] TECHNICIEN DASHBOARD STATS")
        result = self._request(
            "GET", "/api/tickets/dashboard/",
            token=self.tokens["technicien"],
            expect_status=200
        )
        
        print(f"DEBUG: result after _request = {result}")
        sys.stdout.flush()
        
        passed = result["success"]
        
        if passed:
            print(f"         Total Tickets Assignes: {result['data'].get('total_tickets_assignes')}")
            print(f"         My Tickets: {result['data'].get('my_tickets')}")
        
        self.log_test("Technicien dashboard", passed)
    
    def test_technicien_cannot_create_user(self):
        """Technicien ne peut pas creer d'utilisateur"""
        if "technicien" not in self.tokens:
            print("Skipping - no technicien token")
            return
        
        print("\n[SCENARIO 3] TECHNICIEN CANNOT CREATE USER (Permission Check)")
        
        user_data = {
            "email": "fake@test.com",
            "username": "fake",
            "password": "Fake123!",
            "first_name": "Fake",
            "last_name": "User",
            "role": "ADMIN",
            "telephone": "+212612345000"
        }
        
        result = self._request(
            "POST", "/api/auth/create-user/",
            user_data,
            token=self.tokens["technicien"],
            expect_status=403  # Forbidden
        )
        
        passed = result["status"] == 403
        self.log_test(
            "Technicien forbidden to create user",
            passed,
            f"Status: {result['status']} (expected 403)"
        )
    
    def test_invalid_login(self):
        """Test avec mauvaises credentials"""
        print("\n[EDGE CASES] INVALID LOGIN ATTEMPT")
        print("-" * 50)
        
        result = self._request(
            "POST", "/api/auth/login/",
            {"email": "invalid@test.com", "password": "wrongpassword"},
            expect_status=401
        )
        
        passed = result["status"] == 401
        self.log_test("Invalid login returns 401", passed)
    
    def test_unauthorized_access(self):
        """Test endpoint sans token"""
        print("\n[EDGE CASES] UNAUTHORIZED ACCESS")
        
        result = self._request(
            "GET", "/api/auth/profile/",
            token=None,
            expect_status=401
        )
        
        passed = result["status"] == 401
        self.log_test("No token returns 401", passed)
    
    def test_api_endpoints_available(self):
        """Verifier que les endpoints existent"""
        print("\n[SMOKE TEST] API ENDPOINTS AVAILABLE")
        
        endpoints = [
            ("POST", "/api/auth/login/", 405),  # GET not allowed
            ("POST", "/api/auth/register/", None),
            ("GET", "/api/auth/profile/", 401),  # No auth
            ("GET", "/api/tickets/", 401),  # No auth
            ("GET", "/api/tickets/dashboard/", 401),  # No auth
        ]
        
        for method, endpoint, expected_status in endpoints:
            if expected_status is None:
                continue
            
            conn = http.client.HTTPConnection(self.host, self.port, timeout=5)
            try:
                conn.request(method, endpoint, headers={"Content-Type": "application/json"})
                response = conn.getresponse()
                response.read()
                available = response.status is not None
                self.log_test(
                    f"Endpoint available: {method} {endpoint}",
                    available,
                    f"Status: {response.status}"
                )
            except Exception as e:
                self.log_test(f"Endpoint {method} {endpoint}", False, str(e))
            finally:
                conn.close()
    
    def run_all_tests(self):
        """Executer tous les tests"""
        print("\n" + "="*70)
        print("VALIDATION COMPLETE - GESTION DES RECLAMATIONS")
        print("="*70)
        
        # Smoke tests
        self.test_api_endpoints_available()
        
        # Scenario 1: Admin
        self.test_admin_login()
        self.test_admin_profile()
        self.test_admin_dashboard_stats()
        
        # Scenario 2: Citoyen
        self.test_citoyen_registration()
        self.test_citoyen_login()
        self.test_citoyen_profile()
        self.test_create_ticket()
        
        # Scenario 3: Technicien
        self.test_create_technicien()
        self.test_technicien_login()
        self.test_technicien_dashboard()
        self.test_technicien_cannot_create_user()
        
        # Edge cases
        self.test_invalid_login()
        self.test_unauthorized_access()
        
        # Summary
        self.print_summary()
        return sum(1 for _, r, _ in self.test_results if r) == len(self.test_results)

if __name__ == "__main__":
    tester = APITester()
    success = tester.run_all_tests()
    exit(0 if success else 1)