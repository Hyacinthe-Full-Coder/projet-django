# ⚡ Commandes à Copier-Coller - Déploiement Facile

## AVANT DE COMMENCER

Assurez-vous d'avoir créé:
- ✅ Compte GitHub (gratuit sur github.com)
- ✅ Créé un dépôt appelé `projet-django`
- ✅ Compte Render (gratuit sur render.com)
- ✅ Base de données PostgreSQL sur Render (voir étape 7 du guide)

---

## 🔄 ÉTAPE 1: Configuration Git (une seule fois)

```bash
# Ouvrez Terminal/PowerShell et tapez:

git config --global user.name "Votre Nom"
git config --global user.email "votre.email@exemple.com"

# Vérifiez:
git config --global user.name
git config --global user.email
```

✅ Validez que le nom et email s'affichent correctement

---

## 📤 ÉTAPE 2: Envoyer votre code sur GitHub

**REMPLACEZ ces trois éléments:**
- `VOTRE_USERNAME` → votre username GitHub
- `VOTRE_EMAIL` → l'email que vous avez utilisé pour GitHub
- `VOTRE_NOM` → votre nom réel ou pseudo

```bash
# Allez dans votre dossier projet
cd /home/mm/Documents/projet-django

# Initialisez Git
git init

# Configurez vos infos Git (si pas déjà fait)
git config user.name "VOTRE_NOM"
git config user.email "VOTRE_EMAIL"

# Ajoutez tous les fichiers
git add .

# Créez un "snapshot" (commit)
git commit -m "Déploiement initial - Backend Django avec WebSocket"

# Connectez à GitHub (changez VOTRE_USERNAME)
git remote add origin https://github.com/VOTRE_USERNAME/projet-django.git

# Changez le branch en "main"
git branch -M main

# Envoyez vers GitHub
git push -u origin main

# GitHub vous demandera peut-être un mot de passe
# Donnez votre mot de passe GitHub (ou jeton d'accès)
```

**Vous verrez:**
```
Enumerating objects: 45, done.
...
To https://github.com/VOTRE_USERNAME/projet-django.git
 * [new branch]      main -> main
```

✅ Votre code est maintenant sur GitHub!

Vérifiez: Allez sur `https://github.com/VOTRE_USERNAME/projet-django`
Vous devez voir votre code en ligne.

---

## ☁️ ÉTAPE 3: Déployer sur Render

### Partie A: Créer la base de données (une seule fois)

1. Allez sur: https://dashboard.render.com
2. Cliquez **"New +"** → **"PostgreSQL"**
3. **Name**: `reclamation-db`
4. **Database**: `reclamation_db`
5. **User**: `postgres`
6. Cliquez **"Create Database"**

⏳ Attendez 5-10 minutes...

Quand c'est prêt, vous verrez une URL:
```
postgresql://xxxxx:xxxxx@xxxxxx:5432/reclamation_db
```

**Copie-la!** 📌 Vous en aurez besoin dans 2 secondes.

### Partie B: Déployer le backend

1. Restez sur https://dashboard.render.com
2. Cliquez **"New +"** → **"Web Service"**
3. Choisissez **"GitHub"** 
4. Cherchez et sélectionnez `projet-django`
5. Remplissez:

```
Name: reclamation-api
Region: Ohio (ou votre région)
Branch: main
Runtime: Python 3
Build Command: cd gestion_reclamations && pip install -r requirements.txt
Start Command: cd gestion_reclamations && gunicorn config.wsgi:application
```

6. Scroller vers le bas, clicker **"Advanced"**
7. Dans **"Environment Variables"**, ajouter ces 5 lignes:

```
DEBUG
False

SECRET_KEY
(Allez sur https://miniwebtool.com/django-secret-key-generator/ et copiez une clé)

ALLOWED_HOSTS
reclamation-api.onrender.com

DATABASE_URL
(Collez l'URL de la DB PostgreSQL que vous avez copiée)

CORS_ALLOWED_ORIGINS
https://reclamation-api.onrender.com
```

8. Cliquez **"Create Web Service"**

⏳ Attendez 2-5 minutes (Render construit votre app)

Quand vous voyez **"Live"** en vert → C'est déployé! 🎉

---

## 🧪 TESTER que c'est vraiment déployé

Dans un navigateur, allez à:
```
https://reclamation-api.onrender.com/api/tickets/
```

Vous devriez voir:
```json
{
  "detail": "Authentication credentials were not provided."
}
```

C'est NORMAL! C'est une erreur 401 = "Authentifiez-vous d'abord"

Si vous voyez ça → Votre backend marche! ✅

---

## 📱 ÉTAPE 4: Mettre à jour Flutter

Dans votre code Flutter, trouvez tous les `localhost`:

**auth_service.dart:**
```dart
// AVANT:
final String baseUrl = 'http://localhost:8000/api';

// APRÈS:
final String baseUrl = 'https://reclamation-api.onrender.com/api';
```

**Pareil dans les autres fichiers service si nécessaire.**

```bash
# Reconstruisez l'APK
cd /home/mm/Documents/projet-django/reclamation_app
flutter clean
flutter build apk --release
```

Le nouvel APK utilisera votre backend en ligne! 📤

---

## 🔄 À chaque fois que vous modifiez votre code

C'est ultra-simple maintenant:

```bash
cd /home/mm/Documents/projet-django

git add .
git commit -m "Votre message ici"
git push
```

**5 secondes après, Render redéploie tout automatiquement!** ✨

---

## 🆘 SI ÇA NE MARCHE PAS

### "Authentication failed"
```bash
# GitHub a besoin d'authentification
# Utilisez un Personal Access Token:
# https://github.com/settings/tokens
```

### "Build failed" sur Render
Cliquez sur votre service → onglet "Logs"
Cherchez l'erreur et lisez-la

Erreurs courant:
- ❌ Variable d'environnement mal orthographiée
- ❌ DATABASE_URL incorrect
- ❌ requirements.txt manquant

### "Cannot connect to API"
- Vérifiez l'URL (https, pas http!)
- Vérifiez que CORS_ALLOWED_ORIGINS est correct
- Attendez 2 min que Render finisse le déploiement

---

## 📋 CHECKLIST FINALE

- [ ] Compte GitHub créé
- [ ] Compte Render créé
- [ ] Dépôt GitHub créé `projet-django`
- [ ] Code pusher vers GitHub (étape 2)
- [ ] Base de données créée sur Render
- [ ] Web Service créé et déployé
- [ ] Variables d'environnement configurées
- [ ] Lien `https://reclamation-api.onrender.com/api/tickets/` accessible
- [ ] Flutter app mise à jour avec bonne URL
- [ ] APK regénérée

---

## 🎉 Tada! Vous avez réussi!

Votre appli est maintenant **en ligne et accessible à tout le monde!** 🌍

Partagez l'APK et les gens peuvent l'utiliser sans avoir besoin de votre ordinateur. 📱

---

**Besoin d'aide? Consultez le guide complet: `GUIDE_DEBUTANT_DEPLOY.md`**
