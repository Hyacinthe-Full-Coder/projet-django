# Guide de déploiement Django sur Render

## 📋 Prérequis

1. Un compte Render (https://render.com)
2. Git installé et votre code committée
3. Un dépôt GitHub (gratuit et privé possible)

---

## 🚀 Étapes de déploiement

### 1️⃣ **Préparer le dépôt Git** 

```bash
cd /home/mm/Documents/projet-django
git init
git add .
git commit -m "Initial commit - Django backend for Render deployment"
```

### 2️⃣ **Pousser le code sur GitHub**

```bash
git remote add origin https://github.com/YOUR_USERNAME/votre-repo.git
git branch -M main
git push -u origin main
```

---

## 🔧 Configuration Render

### 3️⃣ **Créer un Web Service sur Render**

1. Allez sur https://dashboard.render.com
2. Cliquez sur **"New +"** → **"Web Service"**
3. Connectez votre repository GitHub
4. Sélectionnez votre dépôt contenant le code Django

### 4️⃣ **Configurer le Service**

**Build Command:**
```
cd gestion_reclamations && pip install -r requirements.txt
```

**Start Command:**
```
cd gestion_reclamations && gunicorn config.wsgi:application
```

**Environment Variables** (dans le dashboard Render):

```
DEBUG=False
SECRET_KEY=your-super-secret-key-generate-one-here
ALLOWED_HOSTS=your-service.onrender.com
DATABASE_URL=postgresql://your-db-user:your-db-password@your-db-host:5432/your-db-name
CORS_ALLOWED_ORIGINS=https://your-service.onrender.com
```

### 5️⃣ **Créer une base de données PostgreSQL sur Render**

1. Dans le dashboard Render, cliquez **"New +"** → **"Database"** → **"PostgreSQL"**
2. Configurez:
   - **Name**: reclamation_db
   - **Database**: reclamation_db
   - **User**: postgres
   - **Region**: (même région que votre service)
3. Copiez l'URL de connexion (elle apparaîtra après création)

### 6️⃣ **Mettre à jour DATABASE_URL**

La variable `DATABASE_URL` fournie par Render aura ce format:
```
postgresql://user:password@hostname:5432/dbname
```

---

## 🔐 Générer une nouvelle SECRET_KEY

Exécutez ceci dans le terminal Python:

```python
from django.core.management.utils import get_random_secret_key
print(get_random_secret_key())
```

Ou visitez: https://miniwebtool.com/django-secret-key-generator/

---

## 📝 Modifications à apporter à settings.py

Voici ce que vous devez modifier dans `gestion_reclamations/config/settings.py`:

```python
import os
from decouple import config
import dj_database_url

# ✅ MODE PRODUCTION
DEBUG = config('DEBUG', default=False, cast=bool)
SECRET_KEY = config('SECRET_KEY', default='change-me-in-production')

# ✅ HOSTS
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='*').split(',')

# ✅ BASE DE DONNÉES (Support DB URL)
DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL', default='postgresql://localhost/reclamation_db'),
        conn_max_age=600
    )
}

# ✅ STATIC FILES (pour WhiteNoise)
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATIC_URL = '/static/'

# ✅ MIDDLEWARE (ajouter WhiteNoise)
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # ← Ajouter ici
    'django.middleware.security.SecurityMiddleware',
    # ... reste du middleware ...
]

# ✅ CORS (Restreindre en production)
CORS_ALLOWED_ORIGINS = config(
    'CORS_ALLOWED_ORIGINS', 
    default='http://localhost:3000'
).split(',')

# ✅ SÉCURITÉ EN PRODUCTION
if not DEBUG:
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_SECURITY_POLICY = {
        'default-src': ("'self'",),
    }
```

---

## 🎯 Checklist de déploiement

- [ ] ✅ requirements.txt mis à jour (gunicorn, whitenoise, python-decouple, dj-database-url)
- [ ] ✅ Procfile créé
- [ ] ✅ runtime.txt créé
- [ ] ✅ settings.py configuré pour les variables d'environnement
- [ ] ✅ Code pushé sur GitHub
- [ ] ✅ Web Service créé sur Render
- [ ] ✅ Base de données PostgreSQL créée sur Render
- [ ] ✅ Variables d'environnement configurées
- [ ] ✅ DATABASE_URL défini correctement
- [ ] ✅ Migrations exécutées (`python manage.py migrate`)

---

## 🧪 Tester après déploiement

Après le déploiement, testez les endpoints:

```bash
curl https://your-service.onrender.com/api/tickets/
curl https://your-service.onrender.com/api/users/
```

Vous devriez obtenir une erreur 401 (Unauthorized) si l'authentification JWT fonctionne correctement.

---

## 📚 URLs utiles

- **Dashboard Render**: https://dashboard.render.com
- **Logs du Service**: https://dashboard.render.com → Service → Logs (onglet)
- **Admin Django**: https://your-service.onrender.com/admin/

---

## ⚠️ Points importants

1. **Ne jamais committer** `.env` ou des secrets dans Git
2. **Générez une nouvelle SECRET_KEY** pour la production
3. **Configurez CORS correctement** - ne pas utiliser `CORS_ALLOW_ALL_ORIGINS = True` en production
4. **DEBUG = False** en production
5. **ALLOWED_HOSTS** doit être précis (domaine Render)
6. **SSL automatique** - Render fournit des certificats HTTPS gratuits

---

## 🐛 Résolution de problèmes

### Les migrations ne s'exécutent pas
- Vérifiez que le `release` command dans Procfile est correct
- Checkez les logs Render pour les erreurs

### CORS errors
- Mettez à jour `CORS_ALLOWED_ORIGINS` avec votre domaine Render
- Assurez-vous que votre Flutter app utilise le bon URL

### Erreur de base de données
- Vérifiez la `DATABASE_URL`
- Confirmez que la base de données PostgreSQL est en course
- Check les logs pour les détails

---

## 📞 Support

Pour plus d'aide:
- Docs Render: https://render.com/docs
- Docs Django: https://docs.djangoproject.com
