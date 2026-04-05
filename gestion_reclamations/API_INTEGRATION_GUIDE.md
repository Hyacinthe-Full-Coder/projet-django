# 📱 Guide d'Intégration API Flutter - Gestion des Réclamations

## 🆔 Credentials de Test

Pour tester rapidement l'API, utilisez ces identifiants :

### **Admin (Système)**
```
Email: bigglazer@gmail.com
Password: pass1234
Role: ADMIN
```

### **Technicien (Exemple)**
```
Email: tech@example.com
Password: Test1234
Role: TECHNICIEN
```

### **Citoyen (Exemple)**
```
Email: citoyen@example.com
Password: Test1234
Role: CITOYEN
```

---

Cette API REST Django gère le cycle de vie complet des tickets/réclamations avec authentification JWT, rôles utilisateurs et historique de changements.

---

## 🔐 Authentification

### 1. **Connexion (Login)**

**Endpoint:**
```
POST /api/auth/login/
```

**Corps (JSON):**
```json
{
  "email": "citoyen@example.com",
  "password": "MonMotDePasse123"
}
```

**Réponse (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**⚠️ Stockage (Flutter SharedPreferences):**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', response.data['access']);
await prefs.setString('refresh_token', response.data['refresh']);
```

---

### 2. **Rafraîchir le Token (Refresh)**

**Endpoint:**
```
POST /api/auth/refresh/
```

**Corps (JSON):**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**Réponse (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

**⏱️ Durée de vie :**
- Access Token : **2 heures**
- Refresh Token : **7 jours**

---

### 3. **Profil Utilisateur**

**Endpoint:**
```
GET /api/auth/profile/
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Réponse (200 OK):**
```json
{
  "id": 1,
  "email": "citoyen@example.com",
  "first_name": "Jean",
  "last_name": "Dupont",
  "role": "CITOYEN",
  "telephone": "06XXXXXXXX"
}
```

---

### 4. **Inscription (Citoyens/Agents)**

**Endpoint:**
```
POST /api/auth/register/
```

**Corps (JSON):**
```json
{
  "email": "noveau@example.com",
  "username": "nouveau_user",
  "password": "SecurePass123",
  "first_name": "Albert",
  "last_name": "Dupont",
  "telephone": "06XXXXXXXX"
}
```

**Réponse (201 CREATED):**
```json
{
  "id": 15,
  "email": "noveau@example.com",
  "username": "nouveau_user",
  "first_name": "Albert",
  "last_name": "Dupont",
  "role": "CITOYEN",
  "telephone": "06XXXXXXXX"
}
```

**ℹ️ Note:** Les nouveaux utilisateurs sont automatiquement créés avec le rôle **CITOYEN**.

---

### 5. **Créer Utilisateur (Admin uniquement)** ⚠️

**Endpoint:**
```
POST /api/auth/create-user/
```

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Corps (JSON):**
```json
{
  "email": "newtech@example.com",
  "username": "newtech",
  "password": "TechPass123",
  "first_name": "Marie",
  "last_name": "Dupont",
  "role": "TECHNICIEN",
  "telephone": "06XXXXXXXX"
}
```

**Réponse (201 CREATED):**
```json
{
  "id": 20,
  "email": "newtech@example.com",
  "username": "newtech",
  "first_name": "Marie",
  "last_name": "Dupont",
  "role": "TECHNICIEN",
  "telephone": "06XXXXXXXX"
}
```

**✅ Rôles autorisés:** `TECHNICIEN`, `ADMIN`

**❌ Erreurs possibles:**
- **403** : Non-admin → `{"detail": "Seul un administrateur peut créer des utilisateurs."}`
- **400** : Rôle invalide → `{"role": ["Rôle doit être ADMIN ou TECHNICIEN"]}`

---

## 🎫 Gestion des Tickets

### 📋 **Énumérés**

#### **Statuts**
```
OUVERT           → État initial
EN_COURS         → En traitement par technicien
RESOLU           → Résolu
CLOS             → Archivé
```

#### **Types de Ticket**
```
INCIDENT         → Problème technique
RECLAMATION      → Plainte/réclamation
DEMANDE          → Demande de service
```

#### **Priorités**
```
BASSE
NORMALE
HAUTE
CRITIQUE
```

#### **Rôles Utilisateurs**
```
CITOYEN          → Crée/consulte ses tickets
TECHNICIEN       → Traite les tickets assignés
ADMIN            → Gère tout (utilisateurs, types, statuts)
```

---

### 1. **Créer un Ticket**

**Endpoint:**
```
POST /api/tickets/
```

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Corps (JSON):**
```json
{
  "titre": "Panne d'internet",
  "description": "Le wifi ne fonctionne plus depuis hier soir.",
  "type_ticket": "RECLAMATION",
  "priorite": "HAUTE",
  "assigne_a_id": null
}
```

**Réponse (201 CREATED):**
```json
{
  "id": 42,
  "titre": "Panne d'internet",
  "description": "Le wifi ne fonctionne plus depuis hier soir.",
  "type_ticket": "RECLAMATION",
  "statut": "OUVERT",
  "priorite": "HAUTE",
  "auteur": {
    "id": 1,
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "citoyen@example.com",
    "role": "CITOYEN"
  },
  "assigne_a": null,
  "date_creation": "2026-03-29T14:30:00Z",
  "date_modification": "2026-03-29T14:30:00Z",
  "date_resolution": null,
  "commentaires": [],
  "historique": []
}
```

---

### 2. **Lister les Tickets**

**Endpoint:**
```
GET /api/tickets/
```

**Avec filtres et pagination:**
```
GET /api/tickets/?statut=OUVERT&priorite=HAUTE&page=1
GET /api/tickets/?assigne_a__id=5
GET /api/tickets/?search=internet
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Réponse (200 OK):**
```json
{
  "count": 15,
  "next": "http://localhost:8000/api/tickets/?page=2",
  "previous": null,
  "results": [
    {
      "id": 42,
      "titre": "Panne d'internet",
      "type_ticket": "RECLAMATION",
      "statut": "OUVERT",
      "priorite": "HAUTE",
      "auteur": {
        "id": 1,
        "first_name": "Jean",
        "last_name": "Dupont",
        "email": "citoyen@example.com",
        "role": "CITOYEN"
      },
      "assigne_a": null,
      "date_creation": "2026-03-29T14:30:00Z"
    }
  ]
}
```

**📊 Paramètres de filtre:**
```
?statut=OUVERT,EN_COURS,RESOLU,CLOS
?priorite=BASSE,NORMALE,HAUTE,CRITIQUE
?type_ticket=INCIDENT,RECLAMATION,DEMANDE
?assigne_a__id={technicien_id}
?search={mots_clés}
?ordering=-date_creation,priorite,-statut
```

---

### 3. **Détail d'un Ticket**

**Endpoint:**
```
GET /api/tickets/{ticket_id}/
```

**Réponse (200 OK):**
```json
{
  "id": 42,
  "titre": "Panne d'internet",
  "description": "Le wifi ne fonctionne plus depuis hier soir.",
  "type_ticket": "RECLAMATION",
  "statut": "OUVERT",
  "priorite": "HAUTE",
  "auteur": {
    "id": 1,
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "citoyen@example.com",
    "role": "CITOYEN"
  },
  "assigne_a": null,
  "date_creation": "2026-03-29T14:30:00Z",
  "date_modification": "2026-03-29T14:30:00Z",
  "date_resolution": null,
  "commentaires": [
    {
      "id": 101,
      "auteur": {
        "id": 2,
        "first_name": "Marie",
        "last_name": "Dupont",
        "email": "tech@example.com",
        "role": "TECHNICIEN"
      },
      "contenu": "Ticket reçu, en investigation...",
      "date": "2026-03-29T15:00:00Z"
    }
  ],
  "historique": [
    {
      "id": 201,
      "ancien_statut": "OUVERT",
      "nouveau_statut": "EN_COURS",
      "date_changement": "2026-03-29T14:50:00Z",
      "modifie_par": {
        "id": 2,
        "first_name": "Marie",
        "last_name": "Dupont",
        "email": "tech@example.com",
        "role": "TECHNICIEN"
      }
    }
  ]
}
```

---

### 4. **Changer le Statut d'un Ticket** ⚠️

**Endpoint:**
```
PATCH /api/tickets/{ticket_id}/changer_statut/
```

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Corps (JSON):**
```json
{
  "statut": "EN_COURS"
}
```

**✅ Réponse (200 OK):**
```json
{
  "id": 42,
  "titre": "Panne d'internet",
  "description": "...",
  "statut": "EN_COURS",
  "historique": [
    {
      "id": 201,
      "ancien_statut": "OUVERT",
      "nouveau_statut": "EN_COURS",
      "date_changement": "2026-03-29T14:50:00Z",
      "modifie_par": {
        "id": 2,
        "first_name": "Marie",
        "last_name": "Dupont",
        "email": "tech@example.com",
        "role": "TECHNICIEN"
      }
    }
  ]
}
```

**❌ Erreurs possibles:**

| Code | Signification |
|------|---|
| **400** | Statut invalide → `{"error": "Statut invalide"}` |
| **403** | Droits insuffisants → `{"detail": "Vous n'avez pas les droits pour changer le statut."}` |
| **404** | Ticket introuvable |

**🔒 Permissions :**
- ✅ **ADMIN** : tout changement autorisé
- ✅ **TECHNICIEN** : uniquement sur tickets assignés
- ❌ **CITOYEN** : interdit (403 Forbidden)

---

### 5. **Ajouter un Commentaire**

**Endpoint:**
```
POST /api/tickets/{ticket_id}/commenter/
```

**Corps (JSON):**
```json
{
  "contenu": "Je viens de redémarrer le routeur, merci de tester !"
}
```

**Réponse (201 CREATED):**
```json
{
  "id": 102,
  "auteur": {
    "id": 1,
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "citoyen@example.com",
    "role": "CITOYEN"
  },
  "contenu": "Je viens de redémarrer le routeur, merci de tester !",
  "date": "2026-03-29T16:15:00Z"
}
```

---

## 👥 Gestion des Techniciens

### **Lister les Techniciens**

**Endpoint:**
```
GET /api/techniciens/
```

**Réponse (200 OK):**
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 2,
      "first_name": "Marie",
      "last_name": "Dupont",
      "email": "tech@example.com",
      "role": "TECHNICIEN"
    },
    {
      "id": 3,
      "first_name": "Pierre",
      "last_name": "Martin",
      "email": "tech2@example.com",
      "role": "TECHNICIEN"
    }
  ]
}
```

**Utile pour:** Afficher le dropdown d'assignation d'un ticket.

---

## 📋 Checklist d'Intégration Flutter

### **Phase 1 : Authentification**
- [ ] Implémenter écran de login (email + mot de passe) pour **Admin/Technicien**
- [ ] Implémenter écran d'inscription pour **Citoyen/Agent métier**
- [ ] Sauvegarder tokens dans `SharedPreferences`
- [ ] Ajouter interceptor pour inclure header `Authorization: Bearer {token}`
- [ ] Implémenter refresh automatique du token en cas d'expiration (401)

### **Phase 1b : Gestion des Utilisateurs (Admin)**
- [ ] Écran pour créer nouveaux Admin/Technicien
- [ ] Validation que seul Admin peut accéder

### **Phase 2 : Dashboard**
- [ ] Afficher dashboard personnalisé selon le rôle (Admin/Technicien/Citoyen)
- [ ] Admin : vue globale (total tickets, stats par rôle)
- [ ] Technicien : tickets assignés
- [ ] Citoyen : ses propres tickets

### **Phase 3 : Liste des Tickets**
- [ ] Récupérer et afficher liste des tickets via `GET /api/tickets/`
- [ ] Implémenter filtrage par statut, type, priorité
- [ ] Implémenter recherche par titre/description
- [ ] Ajouter pagination (20 tickets par page)

### **Phase 4 : Création de Ticket**
- [ ] Formulaire Flutter avec champs : titre, description, type, priorité
- [ ] Validation avant envoi
- [ ] Afficher confirmation après création
- [ ] Rafraîchir la liste

### **Phase 5 : Détail & Historique**
- [ ] Afficher ticket complet (statut, commentaires, historique)
- [ ] Afficher timeline des changements de statut
- [ ] Liste des commentaires avec auteur/date

### **Phase 6 : Actions (Technicien)**
- [ ] Assigner ticket à technicien
- [ ] Changer statut : OUVERT → EN_COURS → RESOLU → CLOS
- [ ] Ajouter commentaire lors changemet de statut

### **Phase 7 : Gestion des Erreurs**
- [ ] Gérer 401 (token expiré) → refresh + retry
- [ ] Gérer 403 (permissions insuffisantes)
- [ ] Gérer 404 (ticket supprimé)
- [ ] Gérer timeout réseau

---

## 🔄 Flux Complet : Citoyen → Technicien → Résolution

```
1️⃣  CITOYEN se connecte
    POST /api/auth/login/
    ↓
2️⃣  CITOYEN crée ticket
    POST /api/tickets/
    Statut: OUVERT
    ↓
3️⃣  CITOYEN consulte tickets
    GET /api/tickets/?statut=OUVERT
    ↓
4️⃣  ADMIN assigne ticket à TECHNICIEN
    PATCH /api/tickets/{id}/
    ↓
5️⃣  TECHNICIEN change statut EN_COURS
    PATCH /api/tickets/{id}/changer_statut/
    Statut: EN_COURS
    ↓ [Historique créé automatiquement]
    ↓
6️⃣  TECHNICIEN ajoute commentaires
    POST /api/tickets/{id}/commenter/
    ↓
7️⃣  TECHNICIEN change statut RESOLU
    PATCH /api/tickets/{id}/changer_statut/
    Statut: RESOLU
    date_resolution: auto-remplie
    ↓
8️⃣  CITOYEN voit notification & consulte ticket
    GET /api/tickets/{id}/
    Voir historique + commentaires
```

---

## 🛠️ Configuration HTTP Client (Dio/Http Package)

### **Exemple avec Dio (Flutter):**

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expiré, try refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString('refresh_token');
      final response = await _dio.post(
        '/auth/refresh/',
        data: {'refresh': refresh},
      );
      await prefs.setString('access_token', response.data['access']);
      return true;
    } catch (e) {
      // Re-login required
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Endpoints
  Future<Response> login(String email, String password) =>
      _dio.post('/auth/login/', data: {'email': email, 'password': password});

  Future<Response> getTickets({String? statut, int? page}) =>
      _dio.get('/tickets/', queryParameters: {'statut': statut, 'page': page});

  Future<Response> getTicketDetail(int id) => _dio.get('/tickets/$id/');

  Future<Response> createTicket(Map<String, dynamic> data) =>
      _dio.post('/tickets/', data: data);

  Future<Response> changeStatus(int id, String statut) =>
      _dio.patch('/tickets/$id/changer_statut/', data: {'statut': statut});

  Future<Response> addComment(int id, String contenu) =>
      _dio.post('/tickets/$id/commenter/', data: {'contenu': contenu});
}
```

---

## 📞 Support & Dépannage

| Problème | Solution |
|----------|----------|
| **401 Unauthorized** | Token manquant ou expiré → Refetch via `/auth/refresh/` |
| **403 Forbidden** | Rôle insuffisant → Vérifier rôle dans profil |
| **400 Bad Request** | Données invalides → Valider format JSON |
| **Timeout** | Réseau lent → Augmenter timeout du client |

---

## � Dashboard (Statistiques)

### **Endpoint Dashboard**

**Endpoint:**
```
GET /api/tickets/dashboard/
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Réponse - Admin (200 OK):**
```json
{
  "role": "ADMIN",
  "total_tickets": 42,
  "tickets_by_status": {
    "OUVERT": 15,
    "EN_COURS": 10,
    "RESOLU": 12,
    "CLOS": 5
  },
  "total_users": 28,
  "users_by_role": {
    "ADMIN": 1,
    "TECHNICIEN": 5,
    "CITOYEN": 22
  },
  "recent_tickets": [
    {
      "id": 42,
      "titre": "Panne d'internet",
      "type_ticket": "RECLAMATION",
      "statut": "OUVERT",
      "priorite": "HAUTE",
      "auteur": {...},
      "assigne_a": null,
      "date_creation": "2026-03-29T14:30:00Z"
    }
  ]
}
```

**Réponse - Technicien (200 OK):**
```json
{
  "role": "TECHNICIEN",
  "name": "Marie Dupont",
  "total_tickets_assignes": 8,
  "my_tickets": {
    "EN_COURS": 5,
    "RESOLU": 2,
    "CLOS": 1
  },
  "recent_tickets": [...]
}
```

**Réponse - Citoyen (200 OK):**
```json
{
  "role": "CITOYEN",
  "name": "Jean Dupont",
  "total_tickets": 5,
  "my_tickets": {
    "OUVERT": 2,
    "EN_COURS": 1,
    "RESOLU": 1,
    "CLOS": 1
  },
  "recent_tickets": [...]
}
```

---

| Méthode | Endpoint | Rôles | Description |
|---------|----------|-------|-------------|
| POST | `/api/auth/login/` | — | Connexion |
| POST | `/api/auth/refresh/` | — | Rafraîchir token |
| POST | `/api/auth/register/` | — | Inscription citoyen |
| POST | `/api/auth/create-user/` | Admin | Créer admin/technicien |
| GET | `/api/auth/profile/` | Authentifié | Profil utilisateur |
| POST | `/api/tickets/` | Tous | Créer ticket |
| GET | `/api/tickets/` | Tous | Lister tickets |
| GET | `/api/tickets/{id}/` | Tous | Détail ticket |
| PATCH | `/api/tickets/{id}/changer_statut/` | Technicien/Admin | Changer statut |
| POST | `/api/tickets/{id}/commenter/` | Tous | Ajouter commentaire |
| GET | `/api/tickets/dashboard/` | Tous | Dashboard statistiques |
| GET | `/api/techniciens/` | Tous | Lister techniciens |

---

✅ **Documentation complète pour intégration Flutter !**
