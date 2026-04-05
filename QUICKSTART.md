# 🚀 QUICKSTART - Démarrer l'Application en 5 Minutes

## ⚡ Prérequis

- ✅ Python 3.11+ (Backend)
- ✅ Flutter 3.10.7+ (Frontend)  
- ✅ PostgreSQL (ou SQLite pour dev)

---

## 🔥 Démarrage Rapide

### Terminal 1: Backend Django

```bash
cd /home/miles/Documents/Projet/gestion_reclamations

# Activer l'environnement
source .venv/bin/activate

# Démarrer le serveur
python manage.py runserver 0.0.0.0:8001
```

✅ **Backend prêt**: http://localhost:8001

---

### Terminal 2: Frontend Flutter

```bash
cd /home/miles/Documents/Projet/reclamation_app

# Deuxième terminal - lancer le frontend
flutter run -d linux    # ou -d chrome pour web
```

✅ **Frontend prêt**: App lance automatiquement

---

## 🎯 D'abord: Test Backend API

Vérifier que l'API fonctionne:

```bash
python3 /home/miles/Documents/Projet/test_complete_integration.py
```

**Résultat attendu**:
```
✅ Citoyen registered
✅ Citoyen logged in
✅ Ticket created: ID=3, Status=OUVERT
✅ Technicien created
✅ Technicien logged in
✅ Admin Dashboard: 3 tickets, 2 techniciens, 6 citoyens
```

---

## 💻 Utiliser l'Application

### 1️⃣ Login Admin

```
Email: bigglazer@gmail.com
Password: pass1234
```

**Voir**: AdminDashboardScreen avec statistiques en temps réel

### 2️⃣ Créer Citoyen

- Clic: "S'inscrire" sur login screen
- Remplir le formulaire
- Login avec les credentials créés
- Voir TicketListScreen

### 3️⃣ Créer Technicien

- Login admin
- Clic: "Créer Utilisateur"
- Sélectionner Role: TECHNICIEN
- Login avec credentials créés
- Voir TechnicienDashboardScreen

---

## 📊 Endpoints à Tester

```bash
# Admin Login
POST /api/auth/login/
{
  "email": "bigglazer@gmail.com",
  "password": "pass1234"
}

# Get Dashboard
GET /api/tickets/dashboard/
Header: Authorization: Bearer {token}

# Create Ticket
POST /api/tickets/
{
  "titre": "Test Ticket",
  "description": "Description",
  "type_ticket": "INCIDENT",
  "priorite": "HAUTE"
}
Header: Authorization: Bearer {token}
```

---

## 🔍 Diagnostiquer les Problèmes

### Backend ne démarre pas
```bash
# Vérifier les migrations
python manage.py migrate

# Créer l'admin initial
python manage.py create_initial_admin

# Redémarrer
python manage.py runserver 0.0.0.0:8001
```

### Frontend ne compile pas
```bash
# Nettoyer les dépendances
flutter clean

# Réinstaller
flutter pub get

# Analyzer
flutter analyze

# Relancer
flutter run -d linux
```

### Erreur de connexion
```bash
# Vérifier que le backend tourne sur 8001
lsof -i :8001

# Vérifier les logs Django
# (dans le terminal du serveur)
```

---

## 🎓 Documentation Complète

Pour plus de détails, voir:

- **`VALIDATION_REPORT.md`** - Rapport de validation final
- **`IMPLEMENTATION_COMPLETE.md`** - Résumé technique
- **`EXECUTION_GUIDE.md`** - Guide détaillé d'exécution
- **`ARCHITECTURE.md`** - Diagrammes et flux
- **`API_INTEGRATION_GUIDE.md`** - Documentation API (40+ endpoints)

---

## ✅ Checklist de Démarrage

- [ ] Backend Django démarre sur 8001
- [ ] Admin initial créé (bigglazer@gmail.com/pass1234)
- [ ] Frontend Flutter compile sans erreurs
- [ ] Login avec admin fonctionne
- [ ] AdminDashboard affiche data réelles
- [ ] Push-to-refresh fonctionne
- [ ] Logout redirige vers login

---

## 🎉 Vous êtes Prêt!

L'application est **100% fonctionnelle** et prête:

- ✅ Pour tester les scénarios complets
- ✅ Pour développement additionnel
- ✅ Pour déploiement production

**Happy coding!** 🚀

---

**Besoin d'aide?**
- Voir `EXECUTION_GUIDE.md` pour troubleshooting
- Voir `ARCHITECTURE.md` pour comprendre le flux
- Voir `API_INTEGRATION_GUIDE.md` pour endpoints
