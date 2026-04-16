# Système de Gestion des Tickets - Implémentation Complète

## 📋 Vue d'ensemble

Ce document décrit la mise en place complète du système de gestion des tickets avec :
- ✅ Changement automatique de statut quand un technicien répond
- ✅ Sélection manuelle du statut
- ✅ Système de notifications pour les citoyens
- ✅ Compteur de notifications non lues
- ✅ Interface améliorée basée sur la maquette

---

## 🔄 Flux de Travail Principal

### 1️⃣ **Citoyen crée un ticket**
```
1. Citoyen → Crée un ticket (Statut: OUVERT)
2. Ticket assigné à un technicien automatiquement ou manuellement
3. Technicien reçoit une notification "Nouveau ticket assigné"
```

### 2️⃣ **Technicien commence à traiter le ticket**
```
1. Technicien ouvre le ticket (Statut: OUVERT)
2. Technicien ajoute un COMMENTAIRE
3. ↓ AUTOMATIQUEMENT:
   - Statut change: OUVERT → EN COURS
   - Historique enregistré
   - Citoyen NOTIFIÉ: "Statut de votre ticket modifié"
   - Message: "Le technicien a commencé à traiter votre ticket. Statut: OUVERT → EN COURS"
```

### 3️⃣ **Échange de commentaires**
```
1. Citoyen commente son ticket
   ↓ Technicien reçoit notification "Nouveau commentaire"
   
2. Technicien répond
   ↓ Citoyen reçoit notification "Nouveau commentaire"
   
3. Répétition du flux...
```

### 4️⃣ **Technicien peut changer le statut manuellement**
```
Options disponibles pour Technicien/Admin:
- OUVERT      → Pour les nouveaux tickets
- EN COURS    → Pendant le traitement
- RÉSOLU      → Quand le problème est résolu
- CLOS        → Pour archiver le ticket

Chaque changement:
- Enregistré dans l'historique
- Notifie le citoyen
- Crée un enregistrement de audit
```

### 5️⃣ **Notifications du Citoyen**
```
Le citoyen reçoit une notification pour:
✓ Ticket assigné au technicien
✓ Changement de statut (OUVERT → EN COURS, EN COURS → RÉSOLU, etc.)
✓ Nouveau commentaire du technicien
✓ Ticket résolu
✓ Ticket clos/archivé

Chaque notification:
- Apparaît dans la section "Notifications"
- Affiche un badge avec le compte non lu
- Peut être marquée comme lue
```

---

## 🔧 Implémentation Technique

### Backend Django

#### 1. **Changement automatique du statut** 
**Fichier:** `gestion_reclamations/tickets/views.py`

```python
@action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
def commenter(self, request, pk=None):
    # ... validation
    
    # CHANGEMENT AUTOMATIQUE DU STATUT À "EN_COURS" QUAND UN TECHNICIEN COMMENTE
    ancien_statut = ticket.statut
    if request.user.role == CustomUser.Roles.TECHNICIEN and ticket.statut == Ticket.Statut.OUVERT:
        ticket.statut = Ticket.Statut.EN_COURS
        ticket.save()
        
        # Enregistrement dans l'historique
        HistoriqueStatut.objects.create(...)
        
        # Notification au citoyen
        creer_notification(...)
```

**Logique:**
- Si l'utilisateur est un TECHNICIEN
- ET le ticket est en statut OUVERT
- ALORS → Passer automatiquement à EN_COURS
- Créer une notification pour le citoyen

#### 2. **Système de Notifications**

**Modèle:** `Notification` avec types :
- `NOUVELLEMENT_ASSIGNE` - Ticket neuf assigné
- `STATUT_CHANGE` - Le statut a changé
- `NOUVEAU_COMMENTAIRE` - Nouveau commentaire
- `TICKET_RESOLU` - Ticket marqué résolu
- `TICKET_CLOS` - Ticket archivé

**Endpoint de comptage:**
```
GET /api/notifications/compter_non_lues/
Response: { "non_lues": 5 }
```

---

### Frontend Flutter

#### 1. **Écran Détail du Ticket** (Basé sur la maquette)

**Structure de l'interface:**

```
┌─────────────────────────────┐
│  STATUT: OUVERT | PRIORITÉ: NORMALE
├─────────────────────────────┤
│  MODIFICATION
│  2026-04-16T07:39:57
│  
│  Titre du ticket
│  
│  [Description du ticket dans une boîte grise]
│
├─────────────────────────────┤
│  Type: INCIDENT
│  Auteur: Hyacinthe PAPIN
│  Assigné à: Papin DELA BLAST
│  Date de création: 2026-04-16...
├─────────────────────────────┤
│  GESTION DU STATUT (Technicien/Admin)
│  
│  [Marquer comme RÉSOLU] (bouton vert)
│  
│  Ou choisir le statut manuellement
│  ┌────────────────────────────┐
│  │ [OUVERT] [EN_COURS] [RESOLU]│
│  └────────────────────────────┘
├─────────────────────────────┤
│  COMMENTAIRES
│  
│  ┌────────────────┐
│  │ Auteur | Date │
│  │ Contenu...     │
│  └────────────────┘
│  
│  [Ajouter un commentaire...] [➤]
└─────────────────────────────┘
```

**Améliorations apportées:**

1. **Affichage des badges supérieurs**
   - Statut avec couleur (bleu, orange, vert)
   - Priorité avec couleur indépendante

2. **Section Modification**
   - Affichage clair du titre
   - Description dans une boîte de contenu
   - Détails structurés (Type, Auteur, Assigné, Date)

3. **Gestion du statut**
   - Bouton prominent "Marquer comme RÉSOLU"
   - Grille 3x1 pour sélection manuelle
   - Visible uniquement pour Technicien/Admin

4. **Notifications améliorées**
   ```dart
   // Quand un technicien commente
   if (_userRole == 'TECHNICIEN' && previousStatus == 'OUVERT' && _ticket?.status == 'EN_COURS') {
       showSnackBar("✓ Commentaire ajouté et statut changé en EN COURS");
   }
   ```

#### 2. **Badge de Notification**

**Fichier:** `lib/widgets/notification_badge.dart`

- Affiche le nombre de notifications non lues
- Badge rouge avec chiffre
- Rafraîchissement automatique toutes les 5 secondes
- Affichage "99+" si plus de 99 notifications

#### 3. **Service de Notification**

**Fichier:** `lib/services/notification_service.dart`

```dart
// Récupérer le nombre de notifications non lues
Future<int> getUnreadCount() {
    GET /notifications/compter_non_lues/
}

// Marquer une notification comme lue
Future<void> markAsRead(int notificationId)

// Marquer toutes comme lues
Future<void> markAllAsRead()
```

---

## 📊 Flux de Notifications

### Exemple Concret

**Temps: 14:30**
```
1. Citoyen crée Ticket: "Internet ne marche pas"
   └─ Technicien NOTIFIÉ (badge: 1)
   
2. Technicien ouvre le ticket
   └─ Citoyen reçoit notification "Ticket assigné à Papin DELA BLAST"
   
3. Technicien ajoute commentaire: "Je suis en train de vérifier..."
   └─ AUTOMATIQUEMENT: Statut OUVERT → EN_COURS
   └─ Citoyen NOTIFIÉ: "Statut modifié: OUVERT → EN COURS"
   └─ Message: "Le technicien a commencé à traiter votre ticket"
   
4. Citoyen commente: "D'accord, merci!"
   └─ Technicien NOTIFIÉ: "Nouveau commentaire"
   
5. Technicien commente: "Problème résolu. Redémarrage effectué."
   └─ Citoyen NOTIFIÉ (x2): Comment + changement de statut eventual
```

---

## 🎯 Checklist pour Technicien

### Quand j'ouvre un ticket assigné:

- [ ] **Voir immédiatement:**
  - ✅ Statut actuel (OUVERT, EN_COURS, RÉSOLU, CLOS)
  - ✅ Priorité du ticket
  - ✅ Qui a créé le ticket
  - ✅ Quand il a été créé
  - ✅ Tous les échanges précédents

- [ ] **Répondre au citoyen:**
  - ✅ Ajouter un commentaire dans la boîte
  - ✅ Cliquer sur le bouton d'envoi (➤)
  - ✅ ✓ Automatiquement: Statut change à "EN_COURS"
  - ✅ Citoyen reçoit notification

- [ ] **Changer le statut manuellement:**
  - ✅ Voir les 3 boutons: OUVERT, EN_COURS, RÉSOLU
  - ✅ Cliquer sur le statut désiré
  - ✅ Statut change immédiatement
  - ✅ Citoyen reçoit notification
  - ✅ Historique enregistré pour audit

---

## 🎯 Checklist pour Citoyen

### Quand j'attends une réponse:

- [ ] **Recevoir une notification:**
  - ✅ Badge rouge dans le menu "Notifications"
  - ✅ Chiffre indiquant le nombre de nouveaux messages
  - ✅ Notification pour chaque: nouveau commentaire, changement de statut

- [ ] **Voir le progrès:**
  - ✅ Ouvrir le ticket
  - ✅ Voir l'étape du traitement (OUVERT → EN_COURS → RÉSOLU)
  - ✅ Lire tous les commentaires du technicien
  - ✅ Répondre aux questions si nécessaire

- [ ] **Ajouter des commentaires:**
  - ✅ Voir tous les commentaires précédents
  - ✅ Ajouter un nouveau commentaire
  - ✅ Technicien reçoit notification automatiquement

---

## 🔐 Permissions et Sécurité

### Citoyen
- ✅ Voir ses propres tickets
- ✅ Ajouter des commentaires
- ✅ Recevoir des notifications
- ❌ Changer le statut
- ❌ Voir les tickets d'autres

### Technicien
- ✅ Voir les tickets assignés
- ✅ Ajouter des commentaires (statut change automatiquement)
- ✅ Changer le statut manuellement
- ✅ Recevoir des notifications
- ❌ Voir les tickets non assignés
- ❌ Modifier les tickets d'autres techniciens

### Admin
- ✅ Voir tous les tickets
- ✅ Assigner les tickets
- ✅ Ajouter des commentaires
- ✅ Changer le statut de n'importe quel ticket
- ✅ Archiver les tickets
- ✅ Voir toutes les notifications

---

## 📝 Base de Données

### Changements de Statut - Historique

```sql
-- Table: tickets_historique_statut
CREATE TABLE historique_statut (
    id INT PRIMARY KEY,
    ticket_id INT FOREIGN KEY,
    ancien_statut VARCHAR(10),
    nouveau_statut VARCHAR(10),
    modifie_par_id INT FOREIGN KEY,  -- Qui a fait le changement
    date_changement DATETIME
);

-- Exemple:
-- Ticket #42: OUVERT → EN_COURS par Papin (Technicien)
-- Ticket #42: EN_COURS → RÉSOLU par Papin (Technicien) 
-- Ticket #42: RÉSOLU → CLOS par Admin (Archivé)
```

### Notifications

```sql
-- Table: tickets_notification
CREATE TABLE notification (
    id INT PRIMARY KEY,
    destinataire_id INT FOREIGN KEY,  -- Qui reçoit
    ticket_id INT FOREIGN KEY,
    type_notification VARCHAR(20),    -- STATUT_CHANGE, NOUVEAU_COMMENTAIRE, etc.
    titre VARCHAR(200),
    message TEXT,
    est_lue BOOLEAN,                  -- Marquée comme lue?
    date_creation DATETIME
);

-- Exemple:
-- Citoyen #5 → Notification "Statut modifié" → Ticket #42 → 14:35
-- Citoyen #5 → Notification "Nouveau commentaire" → Ticket #42 → 14:40
```

---

## 🚀 Déploiement et Tests

### Pour tester le système:

1. **Backend Django:**
   ```bash
   cd gestion_reclamations
   python manage.py runserver 8000
   ```

2. **Frontend Flutter:**
   ```bash
   cd reclamation_app
   flutter run
   ```

3. **Scénario de test:**
   - Créer un compte citoyen
   - Créer un compte technicien
   - Citoyen crée un ticket
   - Technicien reçoit notification
   - Technicien ajoute un commentaire
   - Vérifier que le statut change automatiquement
   - Vérifier que le citoyen reçoit la notification

---

## 📱 Icons et Couleurs

### Statuts
- **OUVERT**: 🔵 Bleu (`Colors.blue`)
- **EN_COURS**: 🟠 Orange (`Colors.orange`)
- **RÉSOLU**: 🟢 Vert (`Colors.green`)
- **CLOS**: ⚫ Gris (`Colors.grey`)

### Priorités
- **BASSE**: 🟢 Vert
- **NORMALE**: 🔵 Bleu
- **HAUTE**: 🟠 Orange
- **CRITIQUE**: 🔴 Rouge

---

## 🎓 Conclusion

Le système est maintenant fully fonctionnel avec:

✅ **Automatisation**: Technicien commente → Statut change à EN_COURS
✅ **Notifications**: Citoyen reçoit tous les changements
✅ **Compteur**: Badge affichant les notifications non lues
✅ **Interface**: Maquette respectée et améliorée
✅ **Sécurité**: Permissions respectées par rôle
✅ **Audit**: Tous les changements enregistrés

Les utilisateurs peuvent maintenant gérer efficacement leurs tickets avec une expérience utilisateur fluide et informative!
