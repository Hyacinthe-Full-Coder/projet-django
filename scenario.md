# 🧪 Guide Complet des Scénarios de Test d'Intégration
## De A à Z pour débutants

---

## 📋 Vue d'ensemble

Ce guide vous montre comment tester manuellement les 6 scénarios critiques qui valident que votre application **Flutter** (frontend) communique correctement avec votre **API Django** (backend).

### Prérequis avant de commencer:
1. ✅ Django server **en cours d'exécution** sur `http://localhost:8000`
2. ✅ Application Flutter **compilée et lancée**
3. ✅ Django Admin accessible sur `http://localhost:8000/admin/`

---

# 🔐 Test 1: Authentification

### Objectif
Vérifier qu'un citoyen peut:
1. Se connecter avec ses identifiants
2. Recevoir un token d'accès
3. Le token est stocké localement dans l'app Flutter
4. Les futures requêtes utilisent correctement ce token

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Préparer les données de test
```
- Email: citoyen1@test.com
- Mot de passe: Test123!
- Rôle: CITOYEN (créé dans Django Admin)
```

**Comment créer cet utilisateur dans Django:**
```
1. Ouvrir http://localhost:8000/admin/
2. Se connecter avec admin/admin
3. Aller dans "Accounts" → "Custom users"
4. Cliquer "Add Custom User"
5. Remplir:
   - Email: citoyen1@test.com
   - Username: citoyen1
   - Password: Test123!
   - First name: Jean
   - Last name: Dupont
   - Role: CITOYEN
   - Téléphone: +212612345678
6. Cliquer "Save"
```

#### Étape 2️⃣: Tester la connexion dans Flutter
```
1. Ouvrir l'application Flutter sur votre téléphone/émulateur
2. Aller à l'écran "Login"
3. Entrer email: citoyen1@test.com
4. Entrer password: Test123!
5. Cliquer "Se connecter"
```

**Résultats attendus:**
- ✅ L'écran demande une seconde (appel API en cours)
- ✅ Vous êtes redirigé vers le Dashboard/Accueil
- ✅ Le prénom/nom (Jean Dupont) s'affiche en haut

#### Étape 3️⃣: Vérifier que le token est stocké
```
Dans le code Flutter (fichier service d'authentification):
- Le token reçu de l'API est sauvegardé dans SharedPreferences
- Clé: "access_token"
- Valeur: "eyJhbGciOiJIUzI1NiIs..." (long string)
```

**Vérification technique:**
```bash
# Sur Android (via DevTools ou logs):
# SharedPreferences contient: access_token = [token jwt complet]

# Vérifier dans les logs:
- Rechercher: "Token saved:" ou "Authentification réussie"
```

#### Étape 4️⃣: Vérifier que le token est utilisé dans les requêtes
Chaque requête suivante doit inclure:
```
Header: Authorization: Bearer [votre_token_ici]
```

**Vérifier avec les DevTools du navigateur (si Flutter Web):**
```
1. F12 pour ouvrir DevTools
2. Aller à Network
3. Créer un ticket (étape suivante)
4. Cliquer sur la requête POST /api/tickets/
5. En haut, chercher l'onglet "Headers"
6. Vérifier qu'on voit: Authorization: Bearer eyJ...
```

---

# 🎫 Test 2: Création de Ticket

### Objectif
Vérifier qu'un citoyen connecté peut:
1. Remplir et soumettre un formulaire de ticket
2. L'API crée le ticket correctement
3. Le ticket apparaît dans l'interface d'administration Django

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Être connecté comme citoyen
```
(Reprendre depuis Test 1 - vous devez être connecté)
```

#### Étape 2️⃣: Naviguer vers "Créer un ticket" dans Flutter
```
1. Dans l'application Flutter, aller à l'onglet "Ticketing" ou "Créer"
2. Cliquer sur "Nouveau Ticket" ou "+"
3. L'écran de formulaire s'affiche
```

#### Étape 3️⃣: Remplir le formulaire
```
Titre: "Panne d'eau dans le quartier"
Description: "L'eau ne coule plus depuis ce matin"
Type: "Service" (ou "Plainte", dépend de votre config)
Priorité: "Élevée"
Localisation: "Rue Mohammed V, Marrakech"
Photo (optionnel): Sélectionner une image
```

#### Étape 4️⃣: Soumettre le formulaire
```
1. Cliquer "Soumettre" ou "Envoyer"
2. Attendre 1-2 secondes (traitement du serveur)
3. Vous devrez voir un message "Ticket créé avec succès"
```

**Résultats attendus:**
- ✅ Message de confirmation dans Flutter
- ✅ Vous êtes redirigé vers la liste mes tickets
- ✅ Le nouveau ticket apparaît avec statut "OUVERT"

#### Étape 5️⃣: Vérifier dans Django Admin
```
1. Ouvrir http://localhost:8000/admin/
2. Aller dans "Tickets" → "Tickets"
3. Rechercher le ticket créé: "Panne d'eau..."
4. Cliquer dessus pour voir les détails:
   - Titre: ✅ "Panne d'eau dans le quartier"
   - Auteur: ✅ Jean Dupont (citoyen1)
   - Description: ✅ "L'eau ne coule plus..."
   - Statut: ✅ "OUVERT"
   - Créé le: ✅ Date/heure d'aujourd'hui
```

---

# 🔍 Test 3: Liste des Tickets avec Filtre

### Objectif
Vérifier que:
1. Les filtres dans Flutter envoient les bons paramètres à l'API
2. L'API retourne seulement les tickets filtrés
3. La liste s'actualise correctement

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Se mettre en position
```
✅ Être connecté comme citoyen (Test 1)
✅ Avoir créé plusieurs tickets (Test 2)
   - 1 ticket de type "Service", priorité "Élevée"
   - 1 ticket de type "Plainte", priorité "Basse"
```

#### Étape 2️⃣: Appliquer un filtre dans Flutter
**Scénario A: Filtrer par statut**
```
1. Aller au menu "Mes tickets" ou "List tickets"
2. Finder l'option "Filtre" ou "Filter"
3. Sélectionner "Statut: OUVERT"
4. Cliquer "Appliquer" ou l'écran se met à jour automatiquement
```

**Résultats attendus:**
- ✅ Seuls les tickets avec statut "OUVERT" s'affichent
- ✅ Les autres tickets (fermés, résolus) n'apparaissent pas

**Scénario B: Filtrer par priorité**
```
1. Ouvrir les filtres
2. Sélectionner "Priorité: Élevée"
3. Cliquer "Appliquer"
```

**Résultats attendus:**
- ✅ Seuls les tickets avec priorité "Élevée" s'affichent

#### Étape 3️⃣: Vérifier que les paramètres sont envoyés correctement
Ouvrir les DevTools (F12) et regarder la requête réseau:
```
URL correcte: GET /api/tickets/?status=OUVERT&priority=Élevée
ou GET /api/tickets/?status=OUVERT
(Les paramètres doivent être dans la query string)

Headers:
✅ Authorization: Bearer [token]
✅ Content-Type: application/json
```

#### Étape 4️⃣: Vérifier dans Django Shell (optionnel)
```bash
# Terminal, dans le dossier gestion_reclamations:
cd /home/lamar/Documents/Projet/gestion_reclamations
source .venv/bin/activate
python manage.py shell

# Dans le shell Python:
from tickets.models import Ticket
from django.contrib.auth import get_user_model

citoyen = get_user_model().objects.get(email='citoyen1@test.com')
tickets = Ticket.objects.filter(author=citoyen, status='OUVERT')
print(f"Tickets OUVERT du citoyen: {len(tickets)}")
# Devrait afficher le nombre correct
```

---

# ↩️ Test 4: Changement de Statut

### Objectif
Vérifier que:
1. Un technicien peut changer le statut d'un ticket
2. L'historique du changement est enregistré
3. Le citoyen voit le nouveau statut

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Créer un technicien et être connecté
**Dans Django Admin:**
```
1. http://localhost:8000/admin/
2. Accounts → Custom users → Add
3. Email: tech1@test.com
4. Username: technicien1
5. Password: Tech123!
6. First name: Sophie
7. Last name: Martin
8. Role: TECHNICIEN
9. Save
```

#### Étape 2️⃣: Se déconnecter et reconnecter comme technicien
```
1. Dans Flutter, cliquer "Déconnectance"
2. Aller au Login
3. Entrer: email = tech1@test.com, password = Tech123!
4. Cliquer "Se connecter"
5. Attendre 1-2 secondes
```

**Résultats attendus:**
- ✅ Vous êtes connecté (Bienvenue Sophie)
- ✅ Vous voyez un Dashboard ou liste différente (pas vos propres tickets)

#### Étape 3️⃣: Chercher le ticket du citoyen
```
1. Aller au menu "Tickets" ou "Assignés"
2. Chercher: "Panne d'eau dans le quartier"
(Le ticket créé par Jean Dupont doit être visible)
```

#### Étape 4️⃣: Ouvrir le ticket et changer son statut
```
1. Cliquer sur le ticket "Panne d'eau..."
2. L'écran de détail s'ouvre
3. Finder le bouton "Changer statut" ou un dropdown de statut
4. Sélectionner: "EN_COURS"
5. Cliquer "Sauvegarder" ou "Confirmer"
```

**Résultats attendus:**
- ✅ Message "Statut mis à jour avec succès"
- ✅ Le statut passe de "OUVERT" à "EN_COURS"
- ✅ La date/heure de changement est enregistrée

#### Étape 5️⃣: Vérifier l'historique dans Django Admin
```
1. http://localhost:8000/admin/
2. Tickets → Cliquer sur "Panne d'eau..."
3. Scroller vers le bas
4. Vérifier qu'un nouvel enregistrement existe:
   - "Changement: EN_COURS par Sophie Martin"
   - Timestamp: date/heure actuelle
```

#### Étape 6️⃣: Vérifier que le citoyen voit le changement
```
1. Se déconnecter du compte technicien
2. Se reconnecter comme citoyen (citoyen1@test.com)
3. Aller à "Mes tickets"
4. Cliquer sur "Panne d'eau..."
5. Vérifier que le statut affiche "EN_COURS"
```

---

# 🚫 Test 5: Vérification des Privilèges

### Objectif
Vérifier que:
1. Un citoyen N'PEUT PAS changer le statut d'un ticket
2. L'API refuse la requête avec code 403 Forbidden
3. Seuls les techniciens/admins peuvent

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Préparation
```
✅ Vous êtes connecté comme citoyen (citoyen1@test.com)
✅ Vous avez au moins 1 ticket créé
```

#### Étape 2️⃣: Essayer de changer le statut du propre ticket
**Méthode A: Via l'interface Flutter (si elle permet)**
```
1. Aller à "Mes tickets"
2. Cliquer sur l'un de vos tickets
3. Essayer de trouver "Changer statut"
4. Si le bouton/option n'existe pas = ✅ Correct!
```

**Méthode B: Via la console (accès direct à l'API)**
```
Ouvrir DevTools (F12) → Console (onglet)

Copier et coller:
fetch('http://localhost:8000/api/tickets/1/change-status/', {
  method: 'PATCH',
  headers: {
    'Authorization': 'Bearer [votre_token_citoyen]',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ status: 'EN_COURS' })
})
.then(r => r.json())
.then(d => console.log('Status:', d))
```

#### Étape 3️⃣: Vérifier la réponse
**Résultats attendus:**
```
✅ La réponse HTTP doit être 403 (Forbidden)
✅ Message d'erreur: "You do not have permission..." 
  ou "Seuls les techniciens peuvent..."
```

Dans la console, vous verre rez:
```json
{
  "detail": "You do not have permission to perform this action.",
  "status_code": 403
}
```

#### Étape 4️⃣: Confirmer qu'un technicien PEUT
```
1. Se connecter comme technicien (tech1@test.com)
2. Essayer la même opération (ou via le bouton dans l'UI)
3. Cette fois, ce devrait marcher ✅
```

---

# ⏰ Test 6: Expiration du Token

### Objectif
Vérifier que:
1. Un token expiré ne peut plus faire de requêtes
2. L'application gère l'expiration gracieusement
3. L'utilisateur peut se reconnecter automatiquement

### Étapes détaillées (Débutant)

#### Étape 1️⃣: Configurer l'expiration courte pour le test
**Modifier Django settings.py:**
```python
# Fichier: /home/lamar/Documents/Projet/gestion_reclamations/config/settings.py

# Chercher la section JWT ou SIMPLE_JWT
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=1),  # ⬅️ C'était peut-être 60 minutes
    ...
}
```

**Redémarrer Django:**
```bash
# Terminal:
cd /home/lamar/Documents/Projet/gestion_reclamations
source .venv/bin/activate
python manage.py runserver 8000
# (Laisser tourner)
```

#### Étape 2️⃣: Se connecter dans Flutter
```
1. Ouvrir l'app Flutter
2. Se connecter: citoyen1@test.com / Test123!
3. Vous recevez un token JWT valide 1 minute
```

#### Étape 3️⃣: Attendre l'expiration
```
⏳ Attendre 1 minute 30 secondes
(Vous pouvez laisser l'app ouverte)
```

#### Étape 4️⃣: Essayer une requête après expiration
```
Dans Flutter:
1. Cliquer un bouton qui fait une requête API
   (par exemple: "Actualiser les tickets")
2. Regarder ce qui se passe:

Option A: L'app renouvelle automatiquement le token
✅ Correct! C'est géré automatiquement

Option B: L'étudiant est redirigé vers Login
✅ Aussi correct, l'app détecte l'expiration

Option C: Erreur 401 Unauthorized
❌ À corriger dans le code de l'app
```

#### Étape 5️⃣: Vérifier via code (optionnel)
Dans les DevTools (F12) → Network:
```
Après attente:
- Requête retour 401 (Unauthorized)
  OU
- L'app envoie refresh_token pour obtenir un nouveau token
- Une 2ème requête avec le nouveau token réussit (200)
```

---

# 📊 Résumé des Vérifications

Voici un **checklist** pour vérifier que tous les tests réussissent:

| Test | ✅ À vérifier |
|------|:---|
| **1-Auth** | Connexion réussie, token reçu et stocké |
| **2-Ticket** | Ticket créé visible en admin django |
| **3-Filtre** | Les paramètres GET sont envoyés correctement |
| **4-Status** | Changement visible côté citoyen, historique en admin |
| **5-Priv** | Citoyen reçoit 403, technicien peut changer |
| **6-Token** | App gère l'expiration (rechargement ou login) |

---

# 🛠️ Outils Utiles

### Voir les requêtes API (Chrome/Firefox)
```
1. F12 (DevTools)
2. Onglet "Network"
3. Refaire une action (connexion, créer ticket, etc.)
4. Cliquer sur la requête POSTée
5. Voir les headers et réponse
```

### Tester l'API directement (sans app Flutter)
```bash
# Exemple: tester la création de ticket
curl -X POST http://localhost:8000/api/tickets/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test API",
    "description": "Ticket de test",
    "type": "Service",
    "priority": "Basse"
  }'
```

### Voir les logs Django
```bash
# Dans le terminal où Flask tourne:
# Les logs s'affichent en direct
# Chercher "POST /api/tickets/" ou autres requêtes
```

---

# ❓ Questions Fréquentes (FAQ)

### Q: "J'obtiens 400 Bad Request au lieu de créer le ticket"
**R:** Vérifiez que tous les champs requis sont envoyés:
- titre, description, type, priorité obligatoires
- Vérifier le format JSON dans la requête

### Q: "L'API retourne 401 au lieu de 403 pour le test des privilèges"
**R:** Cela signifie que le token n'est pas envoyé. Vérifiez:
- `Authorization: Bearer [token]` en majuscules
- Pas d'espace supplémentaire

### Q: "Je ne vois pas les changements immédiatement"
**R:** L'app Flutter peut mettre 1-2 secondes. Essayez:
- Actualiser l'écran (pull-to-refresh ou bouton refresh)
- Revenir à l'écran précédent et réouvrir

### Q: "Comment réinitialiser la base de données pour recommencer?"
**R:**
```bash
cd /home/lamar/Documents/Projet/gestion_reclamations
source .venv/bin/activate
python manage.py flush --no-input  # ⚠️ Supprime TOUT
python manage.py migrate
```

---

**Bravo! 🎉 Vous avez terminé tous les tests d'intégration!**

Retournez au code pour corriger les problèmes trouvés et réexécutez cette checklist.
