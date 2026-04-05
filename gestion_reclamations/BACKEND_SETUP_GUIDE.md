# 🚀 Backend Django - Guide Setup & Déploiement

## 📋 Prérequis

- Python 3.10+
- PostgreSQL 12+
- pip

## 🔧 Installation

### 1. Cloner le repo et entrer dans le dossier

```bash
cd gestion_reclamations
```

### 2. Créer un environnement virtuel

```bash
python -m venv .venv
source .venv/bin/activate  # Sur Windows: .venv\Scripts\activate
```

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Configurer la base de données PostgreSQL

Créer une base de données PostgreSQL:

```sql
CREATE DATABASE reclamation_db;
CREATE USER postgres WITH PASSWORD 'password';
ALTER ROLE postgres SET client_encoding TO 'utf8';
ALTER ROLE postgres SET default_transaction_isolation TO 'read committed';
ALTER ROLE postgres SET default_transaction_deferrable TO on;
ALTER ROLE postgres SET default_transaction_read_committed TO on;
GRANT ALL PRIVILEGES ON DATABASE reclamation_db TO postgres;
```

### 5. Appliquer les migrations

```bash
python manage.py migrate
```

### 6. Créer l'administrateur initial

```bash
python manage.py create_initial_admin
```

**Sortie attendue:**
```
✅ Admin créé avec succès!
   Email: bigglazer@gmail.com
   Password: pass1234
   Role: ADMIN
```

### 7. (Optionnel) Charger des données de test

```bash
python manage.py create_test_data
```

## 🚀 Lancer le serveur

```bash
python manage.py runserver
```

L'API sera disponible à `http://localhost:8000/api/`

## 🧪 Exécuter les tests

```bash
# Tous les tests
python manage.py test

# Tests spécifiques
python manage.py test tickets
python manage.py test accounts

# Tests verbose
python manage.py test tickets --verbosity=2
```

## 📊 Admin Django

Accéder à `http://localhost:8000/admin/` avec :
- Email: `bigglazer@gmail.com`
- Password: `pass1234`

## 📖 Documentation API

Consultez [API_INTEGRATION_GUIDE.md](./API_INTEGRATION_GUIDE.md) pour la documentation complète des endpoints.

## 🗂️ Structure du Projet

```
gestion_reclamations/
├── config/               # Configuration Django
│   ├── settings.py      # Settings (DB, INSTALLED_APPS, JWT)
│   ├── urls.py          # URL routing
│   └── wsgi.py
├── accounts/            # Authentification & Utilisateurs
│   ├── models.py        # CustomUser model
│   ├── views.py         # Login, Register, CreateUser, Profile
│   ├── serializers.py   # Custom serializers
│   └── management/      # Management commands
│       └── commands/
│           └── create_initial_admin.py
├── tickets/             # Gestion des Tickets
│   ├── models.py        # Ticket, Commentaire, HistoriqueStatut
│   ├── views.py         # TicketViewSet, Dashboard
│   ├── serializers.py   # Ticket serializers
│   ├── permissions.py   # Custom permissions
│   └── tests.py         # Tests unitaires
└── requirements.txt     # Dépendances Python
```

## 🔐 Sécurité

- ✅ JWT Authentication
- ✅ CORS configuré
- ✅ Password hashing (Django default)
- ✅ Role-based access control (RBAC)

**À faire en production :**
- [ ] Changer `SECRET_KEY` dans settings.py
- [ ] Metttre `DEBUG = False`
- [ ] Ajouter domaine à `ALLOWED_HOSTS`
- [ ] Utiliser HTTPS (nginx + Certbot)
- [ ] Configurer les variables d'environnement (.env)

## 📝 Endpoints Principaux

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/auth/login/` | POST | Connexion |
| `/api/auth/register/` | POST | Inscription (Citoyen) |
| `/api/auth/create-user/` | POST | Créer Admin/Technicien (Admin only) |
| `/api/tickets/` | GET, POST | Liste/Créer tickets |
| `/api/tickets/{id}/changer_statut/` | PATCH | Changer statut |
| `/api/tickets/dashboard/` | GET | Statistiques dashboard |
| `/api/techniciens/` | GET | Liste techniciens |

## 🐛 Troubleshooting

### Erreur: "No module named 'django_filters'"

```bash
pip install django-filter
```

### Erreur: "psycopg2" ImportError

```bash
pip install psycopg2-binary
```

### DB connection refused

Vérifier que PostgreSQL est lancé et les credentials dans `settings.py` sont corrects.

### Tests échouent

```bash
# Supprimer la DB de test et relancer
python manage.py test --keepdb
```

## 📚 Références Utiles

- [Django REST Framework Docs](https://www.django-rest-framework.org/)
- [DRF Simple JWT](https://github.com/jpadilla/django-rest-framework-simplejwt)
- [Django Filters](https://django-filter.readthedocs.io/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

✨ **Backend prêt pour l'intégration Flutter!**
