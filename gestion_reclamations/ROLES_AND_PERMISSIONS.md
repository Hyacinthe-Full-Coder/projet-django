# 🔐 Système de Rôles et Permissions

## 👥 Rôles Disponibles

### 1. **ADMIN (Administrateur)**

**Permissions:**
- ✅ Voir tous les tickets (global)
- ✅ Créer d'autres ADMIN et TECHNICIEN
- ✅ Changer statut de tous les tickets
- ✅ Accès au dashboard de statistiques globales
- ✅ Gestion complète via Admin Django

**Endpoints autorisés:**
```
POST   /api/auth/login/                           (login)
GET    /api/auth/profile/                         (see profile)
POST   /api/auth/create-user/                     (create admin/tech)
GET    /api/tickets/                              (all tickets)
GET    /api/tickets/{id}/                         (all ticket details)
PATCH  /api/tickets/{id}/changer_statut/          (change any status)
POST   /api/tickets/{id}/commenter/               (comment)
GET    /api/tickets/dashboard/                    (global stats)
GET    /api/techniciens/                          (list techs)
```

---

### 2. **TECHNICIEN (Technicien Support)**

**Permissions:**
- ✅ Voir tickets assignés à lui
- ✅ Voir tous les tickets OUVERT (non encore assignés)
- ✅ Changer statut des tickets assignés
- ✅ Ajouter des commentaires
- ✅ Accès au dashboard personnel

**Restrictions:**
- ❌ Changer statut d'un ticket non assigné → 403 Forbidden
- ❌ Créer utilisateurs → 403 Forbidden
- ❌ Voir tickets d'autres techniciens

**Endpoints autorisés:**
```
POST   /api/auth/login/                           (login)
GET    /api/auth/profile/                         (see profile)
GET    /api/tickets/                              (assigned or open tickets only)
GET    /api/tickets/{id}/                         (if assigned or open)
PATCH  /api/tickets/{id}/changer_statut/          (only if assigned)
POST   /api/tickets/{id}/commenter/               (add comment)
GET    /api/tickets/dashboard/                    (personal stats)
GET    /api/techniciens/                          (list techs)
```

---

### 3. **CITOYEN (Citoyen / Agent Métier)**

**Permissions:**
- ✅ Créer des tickets
- ✅ Voir ses propres tickets
- ✅ Ajouter des commentaires
- ✅ Consulter historique des changements
- ✅ Accès au dashboard personnel

**Restrictions:**
- ❌ Changer le statut → 403 Forbidden
- ❌ Voir tickets d'autres citoyens
- ❌ Créer utilisateurs ou ticket d'autres
- ❌ Supprimer tickets

**Endpoints autorisés:**
```
POST   /api/auth/login/                           (login)
POST   /api/auth/register/                        (sign up as CITOYEN)
POST   /api/auth/refresh/                         (refresh token)
GET    /api/auth/profile/                         (see profile)
POST   /api/tickets/                              (create ticket)
GET    /api/tickets/                              (own tickets only)
GET    /api/tickets/{id}/                         (if owner)
POST   /api/tickets/{id}/commenter/               (add comment)
GET    /api/tickets/dashboard/                    (personal stats)
GET    /api/techniciens/                          (list techs for assignment)
```

---

## 🔄 Flux de Statuts Ticket

```
┌─────────┐
│ OUVERT  │  État initial (créé par citoyen)
└────┬────┘
     │ [Technicien assigne le ticket]
     ↓
┌─────────────┐
│ EN_COURS    │  Technicien traite le ticket
└────┬────────┘
     │ [Ticket est résolu]
     ↓
┌──────────┐
│ RESOLU   │  Problème résolu (date_resolution auto-remplie)
└────┬─────┘
     │ [Admin/Technicien archive]
     ↓
┌──────┐
│ CLOS │  Archivé/Fermé
└──────┘
```

**Transitions autorisées :**
- OUVERT → EN_COURS (Technicien assigné ou Admin)
- EN_COURS → RESOLU (Technicien assigné ou Admin)
- RESOLU → CLOS (Any Technicien/Admin)
- Tous → Tous (Admin peut forcer n'importe quelle transition)

---

## 📊 Accès au Dashboard

Chaque rôle voit des statistiques différentes via `GET /api/tickets/dashboard/`:

### Admin voit :
- Nombre total de tickets par statut
- Nombre total d'utilisateurs par rôle
- 5 tickets les plus récents

### Technicien voit :
- Ses tickets assignés par statut
- Total de tickets assignés
- Ses 5 derniers tickets

### Citoyen voit :
- Ses tickets par statut
- Total de ses tickets
- Ses 5 derniers tickets

---

## 🛡️ Contrôle d'Accès - Exemples

### ✅ Cas autorisé

```
User: technicien@example.com (TECHNICIEN)
Action: Changer statut du ticket #42 assigné à lui
PATCH /api/tickets/42/changer_statut/
Body: {"statut": "RESOLU"}
Result: 200 OK - Statut changé, historique créé
```

### ❌ Cas interdits

```
User: citoyen@example.com (CITOYEN)
Action: Essayer de changer statut
PATCH /api/tickets/42/changer_statut/
Result: 403 Forbidden - "Vous n'avez pas les droits..."
```

```
User: technicien1@example.com (TECHNICIEN)
Action: Changer statut d'un ticket assigné à un autre technicien
PATCH /api/tickets/99/changer_statut/
Result: 403 Forbidden - "Technicien non assigné au ticket"
```

```
User: citoyen@example.com (CITOYEN)
Action: Créer un utilisateur
POST /api/auth/create-user/
Result: 403 Forbidden - "Seul un administrateur..."
```

---

## 🔑 Créer des Utilisateurs

### Par Admin via API

```bash
curl -X POST http://localhost:8000/api/auth/create-user/ \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newtech@example.com",
    "username": "newtech",
    "password": "SecurePass123",
    "first_name": "Marie",
    "last_name": "Martin",
    "role": "TECHNICIEN"
  }'
```

### Par Citoyen via API (Self-Registration)

```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newcitoyen@example.com",
    "username": "newcitoyen",
    "password": "SecurePass123",
    "first_name": "Jean",
    "last_name": "Dupont"
  }'
```

**Note:** Nouveau citoyen est automatiquement créé avec `role=CITOYEN`

---

## 🚨 Règles de Sécurité Importantes

1. **Mot de passe** : Jamais stocké en clair, hashé avec Django's `make_password()`
2. **Token JWT** : Expirent après 2 heures (access) ou 7 jours (refresh)
3. **CORS** : Configuré pour localhost - à adapter en production
4. **Roles** : Vérifiés côté serveur, pas côté client
5. **Permissions** : Appliquées sur chaque action, pas juste au niveau des routes

---

✅ **Modèle de sécurité complet et conforme aux bonnes pratiques!**
