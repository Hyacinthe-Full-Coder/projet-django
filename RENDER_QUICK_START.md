# 🚀 Déploiement sur Render - Résumé Rapide

## ✅ Ce qui a été fait automatiquement

1. ✅ **requirements.txt mise à jour** avec:
   - `gunicorn` (serveur WSGI)
   - `whitenoise` (fichiers statiques)
   - `python-decouple` (variables d'environnement)
   - `dj-database-url` (support DATABASE_URL)

2. ✅ **Fichiers de configuration créés**:
   - `Procfile` - Configuration Render
   - `runtime.txt` - Version Python 3.13.7
   - `.env.example` - Modèle variables d'environnement
   - `.gitignore` - Fichiers à ignorer

3. ✅ **settings.py configuré pour production**:
   - Support des variables d'environnement
   - WhiteNoise activé pour les fichiers statiques
   - CORS configurable
   - Sécurité SSL en production

---

## 🎯 Prochaines étapes (à faire manuellement)

### 1. **Versionner votre code sur GitHub**

```bash
cd /home/mm/Documents/projet-django

# Initialiser git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Committer
git commit -m "Prepare Django backend for Render deployment"

# Créer un dépôt sur GitHub et le relier
git remote add origin https://github.com/YOUR_USERNAME/votre-repo.git
git branch -M main
git push -u origin main
```

### 2. **Créer une base de données PostgreSQL sur Render**

1. Allez sur https://dashboard.render.com
2. **"New +"** → **"Database"** → **"PostgreSQL"**
3. Configurez avec:
   - **Name**: reclamation_db
   - **Database**: reclamation_db
   - **User**: postgres
   - **Region**: votre région
4. **Copier l'URL externe** (format: `postgresql://user:pass@host:5432/dbname`)

### 3. **Créer un Web Service sur Render**

1. **"New +"** → **"Web Service"**
2. Connectez votre repository GitHub
3. Configurez:

```
Nom: reclamation-api
Environment: Docker (Auto-detected as Python)
Build Command: cd gestion_reclamations && pip install -r requirements.txt
Start Command: cd gestion_reclamations && gunicorn config.wsgi:application
```

### 4. **Ajouter les Variables d'Environnement**

Dans le dashboard Render, onglet **"Environment Variables"**, ajouter:

```env
DEBUG=False
SECRET_KEY=<générer-une-clé-ici>
ALLOWED_HOSTS=<your-service>.onrender.com
DATABASE_URL=<copier-depuis-la-DB-PostreSQL>
CORS_ALLOWED_ORIGINS=https://<your-service>.onrender.com
```

**Générer une SECRET_KEY sécurisée:**
```python
# Dans Python console:
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```

Ou utiliser: https://miniwebtool.com/django-secret-key-generator/

### 5. **Lancer le déploiement**

Render détectera automatiquement les changements sur GitHub et déployera.

---

## 🔗 URLs qui seront disponibles après déploiement

- **API**: `https://<your-service>.onrender.com/api/`
- **Admin**: `https://<your-service>.onrender.com/admin/`
- **Token**: POST `https://<your-service>.onrender.com/api/token/` (JWT)

---

## 🧪 Tester après déploiement

```bash
# Test de connexion sans authentification (doit retourner 401)
curl https://<your-service>.onrender.com/api/tickets/

# Test authentification
curl -X POST https://<your-service>.onrender.com/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"user@email.com", "password":"password"}'
```

---

## 📝 Mettre à jour l'URL dans Flutter

Dans votre app Flutter, mettez à jour le `BaseURL`:

```dart
// auth_service.dart ou ticket_service.dart
final String baseUrl = 'https://<your-service>.onrender.com/api';
```

---

## 🔐 Considérations de sécurité

⚠️ **IMPORTANT:**
- ✅ Jamais committez `.env` avec vraies données
- ✅ Générez une nouvelle `SECRET_KEY` pour production
- ✅ `DEBUG=False` obligatoire en production
- ✅ Restreignez `ALLOWED_HOSTS` et `CORS_ALLOWED_ORIGINS`
- ✅ Utilisez HTTPS uniquement (`SECURE_SSL_REDIRECT=True`)

---

## 📚 Ressources utiles

- [Render Docs - Django](https://render.com/docs/deploy-django)
- [Render PostgreSQL](https://render.com/docs/databases)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/6.0/howto/deployment/checklist/)

---

## 💡 Tips

- Les migrations s'exécutent **automatiquement** via le `release` command dans Procfile
- Les logs sont visibles dans le dashboard Render → Service → Logs
- Les builds prennent ~2-5 minutes en général
- Render peut mettre en veille un service inactif (version free) - vous pouvez payer pour l'éviter

---

## ❓ Besoin d'aide?

Consultez:
- Les logs Render pour les erreurs
- La documentation officielle Render
- Les commentaires dans RENDER_DEPLOYMENT_GUIDE.md pour plus de détails
