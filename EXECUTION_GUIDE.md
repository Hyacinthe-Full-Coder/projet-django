# 🚀 Guide Complet d'Exécution

## Prérequis
- Python 3.11+ (Backend)
- Flutter 3.10.7+ (Frontend)
- PostgreSQL (ou SQLite développement)
- Node.js/npm (optionnel pour web)

---

## 🔧 Setup Backend

### 1. Configurer l'Environnement Python

```bash
cd /home/miles/Documents/Projet/gestion_reclamations

# Activer venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate     # Windows

# Vérifier Django
python manage.py --version
# Django version 6.0.3
```

### 2. Appliquer les Migrations

```bash
python manage.py migrate
# Operations to perform:
#   Apply all migrations: ...
# Running migrations:
#   [OK] 0001_initial
#   [OK] 0002_customuser_role...
```

### 3. Créer l'Admin Initial

```bash
python manage.py create_initial_admin
# Output: Initial admin user created: bigglazer@gmail.com

# Vérifier avec login
python manage.py shell
>>> from accounts.models import CustomUser
>>> u = CustomUser.objects.get(email='bigglazer@gmail.com')
>>> u.role
'ADMIN'
>>> exit()
```

### 4. Démarrer le Serveur

```bash
python manage.py runserver 0.0.0.0:8001
# Watching for file changes with StatReloader
# Quit the server with CONTROL-C.
# [timestamp] "GET /api/auth/login/ HTTP/1.1" 405 41
```

✅ **Backend ready on http://localhost:8001**

---

## 📱 Setup Frontend

### 1. Configurer l'Environnement Flutter

```bash
cd /home/miles/Documents/Projet/reclamation_app

# Vérifier Flutter
flutter --version
# Flutter 3.10.7

# Vérifier devices
flutter devices
# 3 connected device(s):
# linux (mobile) • Linux
# chrome (web)   • Chrome
```

### 2. Résoudre les Dépendances

```bash
flutter pub get
# Running "flutter pub get" in reclamation_app...
# Got dependencies! 10 packages have newer versions

flutter pub upgrade --dry-run
# [optionnel] voir les mises à jour disponibles
```

### 3. Validate Code

```bash
flutter analyze
# Analyzing reclamation_app...
# 13 issues found. (ran in X.Xs)
# ✅ 0 ERREURS CRITIQUES
# ⚠️ 13 warnings de style (acceptable)
```

### 4. Lancer l'Application

```bash
# Linux/Desktop
flutter run -d linux
# Building linux application...
# lib/main.dart

# Web (si vous voulez tester dans navigateur)
flutter run -d chrome

# Avertissement: Utiliser le device spécifique disponible
flutter devices  # voir options
```

---

## 🧪 Testing Scénarios

### Scénario 1: Login Admin

**Backend**: Assurez-vous que le serveur tourne sur 8001

```bash
# 1. Lancer Backend
cd gestion_reclamations
python manage.py runserver 0.0.0.0:8001

# 2. Lancer Frontend (dans terminal separate)
cd reclamation_app
flutter run -d linux

# 3. Test dans l'app
Login Screen:
  Email: bigglazer@gmail.com
  Password: pass1234
  ✅ Click "Connexion"
  
Expected: Routes vers AdminDashboardScreen avec statstics

AdminDashboardScreen:
  - Voir "Bienvenue Administrateur"
  - Voir Total Tickets count
  - Voir Tickets par Statut (grid)
  - Voir Utilisateurs par Role (grid)
  - Voir Actions (Créer Utilisateur, Statistiques)
```

### Scénario 2: Register Citoyen

```
Login Screen:
  - Click "Nouveau utilisateur? S'inscrire"
  
Register Screen:
  Email: citoyen.test@test.com
  Username: citoyentest
  First Name: Jean
  Last Name: Dupont
  Telephone: +212612345678
  Password: Test1234!
  Confirm: Test1234!
  ✅ Click "S'inscrire"
  
Expected: 
  - Success message
  - Auto-redirect to LoginScreen (2s)
  
LoginScreen:
  Email: citoyen.test@test.com
  Password: Test1234!
  ✅ Click "Connexion"
  
Expected: Routes vers TicketListScreen (rôle CITOYEN)
```

### Scénario 3: Create Technicien (Admin)

```
AdminDashboardScreen:
  - Click "Créer Utilisateur" button
  
CreateUserScreen:
  Email: technicien.test@test.com
  Username: technicientest
  First Name: Sophie
  Last Name: Martin
  Telephone: +212612345000
  Role: TECHNICIEN (dropdown)
  Password: Tech1234!
  Confirm: Tech1234!
  ✅ Click "Créer Utilisateur"
  
Expected:
  - Success SnackBar
  - Form reset
  
Test Login:
  Email: technicien.test@test.com
  Password: Tech1234!
  
Expected: Routes vers TechnicienDashboardScreen
```

### Scénario 4: Technicien Workflow

```
TechnicienDashboardScreen (Tab 1):
  - Voir stats (Total Assigned, par statut)
  - Voir recent tickets list
  
Tab 2 (Mes Tickets):
  - Click BottomNav "Mes Tickets"
  - See TicketListScreen
  - Can change ticket status
```

### Scénario 5: Admin assigne les tickets aux techniciens

```
AdminDashboardScreen:
  - Click "Assigner Tickets" button
  
AssignTicketsScreen:
  - Voir liste des tickets (filtre: Non assignés / Tous)
  - Pour chaque ticket non assigné:
    - Click sur le ticket ou bouton "Assigner"
    - Choisir un technicien dans la liste
    - OU choisir "Assignation automatique" (moins de tickets)
  
Expected:
  - Ticket assigné au technicien sélectionné
  - Notification de succès
  - Liste mise à jour automatiquement
  
TechnicienDashboardScreen (pour le technicien assigné):
  - Voir le nouveau ticket dans "Mes Tickets"
  - Pouvoir changer le statut du ticket
```

### Scénario 6: Logout

```
Any Screen (AppBar):
  - Click logout button (icon)
  
Expected: Redirect to LoginScreen
```

---

## 🔍 API Testing avec Python

### Créer un fichier `test_integration.py`

```python
#!/usr/bin/env python3
import http.client
import json
import time

BASE_URL = "http://localhost:8001/api"

def test_login():
    """Test admin login"""
    conn = http.client.HTTPConnection("localhost", 8001, timeout=5)
    payload = json.dumps({
        "email": "bigglazer@gmail.com",
        "password": "pass1234"
    })
    conn.request("POST", "/api/auth/login/", payload, 
                 {"Content-Type": "application/json"})
    response = conn.getresponse()
    data = json.loads(response.read().decode())
    
    assert response.status == 200, f"Expected 200, got {response.status}"
    assert "access" in data, "No access token in response"
    
    print("✅ Login test passed")
    return data["access"]

def test_profile(token):
    """Test get profile"""
    conn = http.client.HTTPConnection("localhost", 8001, timeout=5)
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    conn.request("GET", "/api/auth/profile/", headers=headers)
    response = conn.getresponse()
    data = json.loads(response.read().decode())
    
    assert response.status == 200, f"Expected 200, got {response.status}"
    assert data.get("role") == "ADMIN", f"Expected ADMIN role, got {data.get('role')}"
    
    print("✅ Profile test passed")

def test_dashboard(token):
    """Test dashboard stats"""
    conn = http.client.HTTPConnection("localhost", 8001, timeout=5)
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    conn.request("GET", "/api/tickets/dashboard/", headers=headers)
    response = conn.getresponse()
    data = json.loads(response.read().decode())
    
    assert response.status == 200, f"Expected 200, got {response.status}"
    assert "total_tickets" in data, "Missing total_tickets"
    assert "tickets_by_status" in data, "Missing tickets_by_status"
    assert "users_by_role" in data, "Missing users_by_role"
    
    print("✅ Dashboard test passed")
    print(f"   Total tickets: {data['total_tickets']}")
    print(f"   Users: {data['users_by_role']}")

if __name__ == "__main__":
    print("🧪 Testing API endpoints...\n")
    
    try:
        token = test_login()
        test_profile(token)
        test_dashboard(token)
        print("\n✨ All tests passed!")
    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        exit(1)
```

### Exécuter le test

```bash
cd /home/miles/Documents/Projet
python3 test_integration.py

# Output:
# 🧪 Testing API endpoints...
# ✅ Login test passed
# ✅ Profile test passed
# ✅ Dashboard test passed
#    Total tickets: 0
#    Users: {'ADMIN': 1, 'TECHNICIEN': 0, 'CITOYEN': 0}
# ✨ All tests passed!
```

---

## 📊 Monitoring & Debugging

### Backend Debugging

```bash
# Vérifier migrations appliquées
python manage.py showmigrations

# Voir logs de la dernière requête
python manage.py shell
>>> from django.db import connection
>>> print(connection.queries[-1])

# Vérifier utilisateurs créés
python manage.py shell
>>> from accounts.models import CustomUser
>>> CustomUser.objects.all().values('email', 'role')
<QuerySet [{'email': 'bigglazer@gmail.com', 'role': 'ADMIN'}, ...]>
```

### Frontend Debugging

```bash
# Afficher logs détaillés
flutter run -v

# Vérifier device connectivity
flutter devices -v

# Vérifier les tokens stockés

---

## 🏁 Démarrage rapide (script simultané)

Le fichier `run_servers.sh` est ajouté à la racine du projet (`/home/miles/Documents/Projet/run_servers.sh`).

```bash
cd /home/miles/Documents/Projet
chmod +x run_servers.sh
./run_servers.sh
```

- Backend Django : http://127.0.0.1:8000
- Frontend Flutter : http://127.0.0.1:8100

Le script redirige les logs vers :
- `django.log`
- `flutter.log`

CTRL+C arrête proprement les deux serveurs.

# Dans le code: print(await authService.getAccessToken());
```

### Erreurs Communes

**1. Port déjà utilisé (8001)**
```bash
lsof -i :8001  # Voir quel processus utilise le port
kill -9 <PID>  # Terminer le processus
python manage.py runserver 0.0.0.0:8002  # Utiliser port différent
```

**2. "Method not allowed" (405)**
```
Cause: Utiliser GET sur endpoint POST
Solution: Vérifier méthode HTTP (POST /api/auth/login/, pas GET)
```

**3. "Invalid token" (401)**
```
Cause: Token expiré ou malformé
Solution: Récréer token via login, ou utiliser refresh token
```

**4. "CORS error"**
```
Cause: Frontend sur domaine différent que backend
Solution: Vérifier CORS_ALLOWED_ORIGINS dans settings.py
```

---

## 🎯 Checklist Final

- [ ] Backend Django démarré sur 8001
- [ ] Admin créé: `bigglazer@gmail.com / pass1234`
- [ ] Migrations appliquées
- [ ] Frontend Flutter compilé sans erreurs
- [ ] Login avec entités admin fonctionne
- [ ] AdminDashboard affiche données réelles
- [ ] RegisterScreen crée nouveau citoyen
- [ ] CreateUserScreen crée nouveau technicien
- [ ] TechnicienDashboard accessible par technicien
- [ ] Logout redirige vers login
- [ ] API tokens refresh automatique
- [ ] Permissions enforced (403 sur actions non autorisées)

---

## 📞 Support

Pour déboguer:
1. Vérifier les logs backend: `tail -f server.log`
2. Vérifier les logs frontend: `flutter run -v`
3. Tester endpoints avec script `test_integration.py`
4. Vérifier base de données: `python manage.py dbshell`

---

**Status**: ✅ Ready for Integration Testing
