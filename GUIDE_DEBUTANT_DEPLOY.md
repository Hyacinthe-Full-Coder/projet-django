# 🚀 Guide Déploiement pour Débutant - Expliqué Simple

Bienvenue! Je vais vous expliquer le déploiement comme si vous découvriez tout pour la première fois.

---

## 📚 Vocabulaire à connaître (simple)

### **Git** = Un carnet de versions
- C'est un outil qui enregistre chaque modification de votre code
- Comme l'historique "Annuler/Rétablir" de Word, mais pour tout votre projet
- **Avantage**: Vous pouvez revenir en arrière si vous cassez quelque chose

### **GitHub** = Un cloud pour votre code
- C'est un site (github.com) qui stocke votre code en ligne
- Gratuit, très populaire, utilisé par millions de développeurs
- **Avantage**: Votre code n'est pas perdu si votre ordinateur crash

### **Render** = Un hébergeur (gratuit!)
- C'est un serveur qui exécute votre code 24/7
- Votre app reste accessible même si vous fermez votre ordinateur
- Comme une petite maison louée dans le cloud ☁️

### **Déployer** = Mettre votre code "en live"
- C'est comme appuyer sur "Publier" d'un blog
- Votre code devient accessible par tout le monde sur Internet

---

## 🎯 Le flux simple en 3 étapes

```
Votre ordinateur (code)
         ↓
GitHub (sauvegarde)
         ↓
Render (serveur en ligne)
```

Chaque étape envoie vers la suivante automatiquement.

---

## 👣 ÉTAPE 1: Créer un compte GitHub

### C'est facile! Suivez ces étapes:

1. Allez sur **https://github.com**
2. Cliquez sur **"Sign up"** (en haut à droite)
3. Remplissez le formulaire:
   - Email
   - Password
   - Username (votre pseudo)
4. Vérifiez votre email (GitHub vous envoie un lien)
5. C'est fait! ✅

---

## 🔧 ÉTAPE 2: Installer Git sur votre ordinateur

Git est déjà probablement installé si vous utilisez Mac/Linux. Vérifiez:

```bash
# Ouvrez le Terminal (Windows: PowerShell) et tapez:
git --version
```

**Si vous voyez un numéro (ex: `git version 2.40.0`)** → Git est installé ✅

**Si erreur "command not found"** → Installez Git:
- **Mac**: Tapez `git --version`, macOS vous demandera l'installer
- **Windows**: Téléchargez https://git-scm.com/download/win
- **Linux**: `sudo apt install git`

---

## 📝 ÉTAPE 3: Configurer Git (une seule fois)

Dites à Git qui vous êtes:

```bash
# Remplacez par VOS infos (gardez les guillemets)
git config --global user.name "Votre Nom"
git config --global user.email "votre@email.com"
```

**Exemple:**
```bash
git config --global user.name "Jean Dupont"
git config --global user.email "jean@email.com"
```

---

## 🚀 ÉTAPE 4: Créer un dépôt sur GitHub

Un **dépôt** = un dossier de projet en ligne

### Allez sur GitHub:

1. Connectez-vous à **https://github.com**
2. Cliquez sur le **`+`** en haut à droite → **"New repository"**
3. Remplissez:
   - **Repository name**: `projet-django` (ou votre nom)
   - **Description**: "Gestion des Réclamations - Backend"
   - **Public** ou **Private** (privé = personne ne voit)
   - Cochez: "Initialize this repository with a README" (optionnel)
4. Cliquez **"Create repository"**

**Vous verrez une page avec un code en bleu en haut.**
Copiez l'URL (elle ressemble à): `https://github.com/VOTRE_USERNAME/projet-django`

---

## 💻 ÉTAPE 5: Envoyer votre code sur GitHub

Allez dans le Terminal et naviguez à votre projet:

```bash
# Accédez au dossier du projet
cd /home/mm/Documents/projet-django

# Vérifiez que vous y êtes
pwd
# Doit afficher: /home/mm/Documents/projet-django
```

### Maintenant exécutez ces commandes dans l'ordre:

#### **1) Initialiser Git** (dit à Git: "surveille ce dossier")
```bash
git init
```

#### **2) Dire à Git de surveiller tous les fichiers**
```bash
git add .
```
Le `.` signifie "tous les fichiers"

#### **3) Faire une "photo" (snapshot) de votre code**
```bash
git commit -m "Premier déploiement - backend Django"
```
Le `-m` c'est juste pour ajouter un message

#### **4) Connecter votre ordinateur à GitHub**
```bash
# Remplacez VOTRE_USERNAME et NOM_REPO par les vôtres!
git remote add origin https://github.com/VOTRE_USERNAME/projet-django.git
```

#### **5) Envoyer votre code sur GitHub**
```bash
git branch -M main
git push -u origin main
```

**Vous verrez un message du genre:**
```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
Writing objects: 100% (45/45)...
...
To https://github.com/VOTRE_USERNAME/projet-django.git
 * [new branch]      main -> main
```

✅ **Votre code est maintenant sur GitHub!**

---

## ☁️ ÉTAPE 6: Créer un compte Render

C'est gratuit et simple:

1. Allez sur **https://render.com**
2. Cliquez **"Sign Up"**
3. Choisissez **"Sign up with GitHub"** (plus facile)
4. Connectez-vous avec votre compte GitHub
5. Autorisez Render à accéder à GitHub

---

## 🗄️ ÉTAPE 7: Créer une base de données sur Render

Votre backend a besoin d'une base de données PostgreSQL:

1. Allez sur https://dashboard.render.com
2. Cliquez **"New +"** (en haut à gauche)
3. Choisissez **"PostgreSQL"**
4. Remplissez:
   - **Name**: `reclamation-db`
   - **Database**: `reclamation_db`
   - **User**: `postgres`
   - Region: La plus proche de vous
5. Cliquez **"Create Database"**

⏳ **Ça prend 5-10 minutes à créer...**

Quand c'est prêt, vous verrez une URL qui ressemble à:
```
postgresql://username:password@hostname:5432/reclamation_db
```

**Gardez-la précieusement!** 📌 Vous en aurez besoin.

---

## 🚀 ÉTAPE 8: Déployer votre Backend sur Render

Maintenant le moment clé!

### Sur le dashboard Render:

1. Cliquez **"New +"** → **"Web Service"**
2. Choisissez **"GitHub"** (pour connecter votre repo)
3. Cherchez `projet-django` et cliquez dessus
4. Render fait automatiquement:
   ```
   Build Command: cd gestion_reclamations && pip install -r requirements.txt
   Start Command: cd gestion_reclamations && gunicorn config.wsgi:application
   ```
   (Ces commandes sont déjà configurées dans le Procfile! ✅)

5. Scroller vers le bas et clicker **"Advanced"**
6. Ajouter les variables d'environnement:

```
DEBUG: False
SECRET_KEY: (générez une clé ici)
ALLOWED_HOSTS: votre-service.onrender.com
DATABASE_URL: (collez l'URL de la DB)
CORS_ALLOWED_ORIGINS: https://votre-service.onrender.com
```

### Comment obtenir une SECRET_KEY sécurisée?

Allez sur: **https://miniwebtool.com/django-secret-key-generator/**
Copiez-collez la "clé" générée

7. Cliquez **"Create Web Service"**

⏳ **Render construit et déploie votre backend... (2-5 min)**

---

## ✅ C'est déployé!

Quand vous voyez **"Live"** en vert, c'est bon!

Vous aurez une URL du style:
```
https://votre-service.onrender.com
```

**Testez votre API:**
```
https://votre-service.onrender.com/api/tickets/
```

(Vous aurez une erreur 401, c'est normal - c'est parce qu'il faut s'authentifier)

---

## 📱 ÉTAPE 9: Mettre à jour votre Flutter app

Dans votre code Flutter, changez l'URL:

**Avant:**
```dart
final String baseUrl = 'http://localhost:8000/api';
```

**Après:**
```dart
final String baseUrl = 'https://votre-service.onrender.com/api';
```

Cherchez tous les fichiers qui utilisent `localhost:8000` et remplacez par votre URL Render.

---

## 🔄 À chaque fois que vous modifiez votre code

C'est simple! Juste 3 commandes:

```bash
# 1. Va dans le dossier
cd /home/mm/Documents/projet-django

# 2. Ajoute les modifications
git add .

# 3. Envoie à GitHub (Render fera la mise à jour automatique!)
git commit -m "Décrire ce que vous avez changé"
git push
```

Render détecte automatiquement la modification et redéploie! 🚀

---

## 📊 Résumé Visual

```
💻 Votre ordinateur
  └─ git add .
  └─ git commit -m "message"
  └─ git push
        ↓
🐙 GitHub
  └─ Render détecte les changements
        ↓
☁️ Render
  └─ Redéploie automatiquement
  └─ API accessible à tout le monde!
```

---

## 🆘 Problèmes courants

### **"Permission denied" quand je fais `git push`**
- Vous devez créer une clé SSH (authentification GitHub)
- Ou utiliser un "Personal Access Token"
- Consultez: https://docs.github.com/en/authentication

### **Render dit "Build failed"**
- Vérifiez les logs (onglet "Logs" dans le dashboard)
- Généralement c'est une variable d'environnement mal configurée
- Ou une dépendance manquante dans requirements.txt

### **Mon app Flutter ne peut pas atteindre l'API**
- Vérifiez que l'URL est correcte (https, pas http)
- Vérifiez que CORS_ALLOWED_ORIGINS inclut votre domaine
- Testez avec `curl` dans le terminal

---

## 🎉 Bravo!

Vous venez de:
- ✅ Apprendre Git
- ✅ Créer un compte GitHub
- ✅ Envoyer votre code en ligne
- ✅ Créer une base de données
- ✅ Déployer votre backend
- ✅ Rendre votre app accessible à tout le monde!

C'est tout ce qu'il faut savoir pour devenir un "deployer" ! 🚀

---

## 📚 Liens utiles

- **GitHub Docs (français)**: https://docs.github.com/fr
- **Commandes Git expliquées**: https://git-scm.com/book/fr
- **Render Docs**: https://render.com/docs
- **Django Deployment**: https://docs.djangoproject.com/en/6.0/howto/deployment/

---

## 💡 Pro Tips

1. **Commitez souvent** - Ne faites pas 100 changements avant de committer
2. **Messages clairs** - `git commit -m "Ajout login"` meilleur que `git commit -m "changes"`
3. **Testez localement d'abord** - Avant de pousher
4. **Gardez .env sécurisé** - Ne commitez JAMAIS `.env` avec vrai secrets
5. **Regardez les logs** - En cas de problème, les logs sont votre ami

---

**Des questions? N'hésitez pas à demander!** 👋
