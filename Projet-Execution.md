# Guide Complet d'Exécution

## Prérequis
- Python 3.11+ (Backend)
- Flutter 3.10.7+ (Frontend)
- PostgreSQL

---

## Setup Backend

### 1. Configurer l'Environnement Python

```bash
cd /home/miles/Documents/Projet/gestion_reclamations

# Activer venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate     # Windows, moi j'suis sur Ubuntu/Linux

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
python manage.py runserver 0.0.0.0:8000
# Watching for file changes with StatReloader
# Quit the server with CONTROL-C.
# [timestamp] "GET /api/auth/login/ HTTP/1.1" 405 41
```

**Backend ready on http://localhost:8000**

---

## Setup Frontend

### 1. Configurer l'Environnement Flutter

```bash
cd /home/miles/Documents/Projet/reclamation_app

# Vérifier Flutter
flutter --version

# Vérifier devices
flutter devices
# 3 connected device(s):
# linux (mobile) • Linux
# chrome (web)   • Chrome
# Tecno K17 (mon téléphone)
```

### 2. Résoudre les Dépendances

```bash
flutter pub get

flutter pub upgrade --dry-run
# [optionnel] voir les mises à jour disponibles
```

### 3. Validate Code

```bash
flutter analyze
# Analyzing reclamation_app...
# 13 issues found. (ran in X.Xs)
# 0 ERREURS CRITIQUES
# 13 warnings de style (acceptable)
```

### 4. Lancer l'Application

```bash
# Linux/Desktop
flutter run -d linux

# Web (si vous voulez tester dans navigateur, mais parcontre chrome a fait Ramé ma machine)
flutter run -d chrome

# Avertissement: Utiliser le device spécifique disponible
flutter devices  # 
```

---


## API Testing avec Python

### Créer un fichier `test_integration.py`
Confer ***test_complete_intefration.py***

### Exécuter le test

```bash
cd /home/miles/Documents/Projet
python3 test_complete_integration.py

# Output:
# Testing API endpoints...
# Login test passed
# Profile test passed
# Dashboard test passed
#    Total tickets: 0
#    Users: {'ADMIN': 1, 'TECHNICIEN': 0, 'CITOYEN': 0}
# All tests passed!
```

---

## Monitoring & Debugging

### Backend Debugging

```bash
# Vérifier migrations appliquées
python manage.py showmigrations
```

### Frontend Debugging

```bash
# Afficher logs détaillés
flutter run -v

# Vérifier device connectivity
flutter devices -v
```

### Erreurs Communes

**1. Port déjà utilisé (8000)**
```bash
lsof -i :8000  # Voir quel processus utilise le port
kill -9 <PID>  # Terminer le processus
python manage.py runserver 0.0.0.0:8001  # Utiliser port différent
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

---
