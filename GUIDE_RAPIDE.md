# 🚀 Guide Rapide - Système de Gestion des Tickets

## Pour le Citoyen 👤

### Comment créer un ticket?
1. Appuyez sur **\"Créer\"** dans la navigation inférieure
2. Complétez les informations:
   - 📝 Titre (Exemple: \"Internet ne marche pas\")
   - 📄 Description détaillée
   - 🏷️ Type (Incident, Réclamation, Demande)
   - ⚠️ Priorité (Basse, Normale, Haute, Critique)
3. Appuyez sur **\"Créer le ticket\"**
4. ✅ Attendez l'assignation à un technicien

### Comment suivre un ticket?
1. Allez dans **\"Mes Tickets\"**
2. Appuyez sur le ticket que vous voulez voir
3. Vous verrez:
   - 🟢 L'état actuel du ticket (OUVERT, EN COURS, RÉSOLU, CLOS)
   - 👤 Qui le traite (Technicien assigné)
   - 💬 Tous les commentaires échangés
   - 📅 Les dates importantes

### Comment ajouter un commentaire?
1. En bas de l'écran du ticket, vous verrez: **\"Ajouter un commentaire...\"**
2. Tapez votre message
3. Appuyez sur le bouton **➤** (flèche)
4. ✅ Votre commentaire apparaît immédiatement
5. 🔔 Le technicien reçoit une notification

### Comment recevoir les notifications?
1. Appuyez sur **\"Notifications\"** dans la navigation inférieure
2. Vous verrez un badge rouge avec le nombre (Exemple: 🔔 **5**)
3. Cliquez sur **\"Notifications\"** pour voir les détails
4. Vous recevrez une notification pour:
   - ✅ Quand on vous assigne un ticket
   - ✅ Quand un technicien ajoute un commentaire
   - ✅ Quand le statut change (OUVERT → EN COURS, etc.)
   - ✅ Quand le ticket est résolu ou clos

### Vous pouvez aussi:
- 🔍 Voir l'historique complet des changements
- ✓ Marquer les notifications comme lues
- 👁️ Voir qui a travaillé sur votre ticket

---

## Pour le Technicien 🔧

### Comment voir les tickets assignés?
1. Allez dans **\"Tickets\"** dans la navigation inférieure
2. Vous verrez la liste de vos tickets
3. Cliquez sur un ticket pour voir les détails

### ⚡ Ce qui se passe quand vous ouvrez un ticket:
- Le ticket est en statut **OUVERT** (bleu 🔵)
- Vous voyez toutes les informations du citoyen
- Vous voyez tous les commentaires précédents

### 🎯 Comment traiter un ticket:

**Étape 1: Ajouter un commentaire**
1. Allez en bas de l'écran
2. Tapez votre réponse
3. Appuyez sur le bouton **➤**
4. ✅ **Le statut change AUTOMATIQUEMENT à EN COURS** 🟠
5. ✅ **Le citoyen reçoit une notification immédiate**
6. Message du citoyen: *\"Le technicien a commencé à traiter votre ticket. Statut: OUVERT → EN COURS\"*

**Étape 2: Continuer à échanger**
1. Le citoyen peut répondre à votre commentaire
2. Vous recevez une notification 🔔
3. Vous répondez de nouveau
4. Répétition du processus...

**Étape 3: Résoudre le ticket**
1. Quand vous avez fini, vous avez 2 options:

   **Option A - Rapide:**
   - Appuyez sur le gros bouton vert: **\"Marquer comme RÉSOLU\"** 🟢
   - ✅ Statut change immédiatement
   - ✅ Citoyen reçoit notification

   **Option B - Choisir manuellement:**
   - Vous verrez 3 boutons: **OUVERT | EN_COURS | RÉSOLU**
   - Cliquez sur le statut que vous désirez
   - ✅ Le statut se met à jour
   - ✅ Citoyen reçoit notification

### 📊 Vous pouvez voir:
- 📅 La date de création du ticket
- 👤 Le citoyen qui a créé le ticket
- 🏷️ Le type (Incident, Réclamation, Demande)
- ⚠️ La priorité
- 💬 Tous les commentaires échangés
- 📜 L'historique des changements de statut

### 🔔 Les notifications que vous recevez:
- ✅ Quand un nouveau ticket vous est assigné
- ✅ Quand le citoyen ajoute un commentaire
- ✅ Quand un autre utilisateur change le statut
- ✅ Quand un citoyen commente après votre réponse

---

## Pour l'Admin 🛡️

### Vous pouvez faire TOUT ce que font les techniciens ET:

1. **Voir tous les tickets** (pas seulement les vôtres)
2. **Assigner les tickets** aux techniciens
3. **Gérer les utilisateurs**
4. **Voir les statistiques globales**
5. **Forcer les changements de statut** sur n'importe quel ticket
6. **Archiver les tickets** (statut CLOS)

### Dashboard Admin:
- 📊 Nombre total de tickets
- 📊 Tickets par statut
- 📊 Tickets par priorité
- 👥 Nombre de techniciens et citoyens
- 📈 Tickets récents

---

## 🎓 Exemple Complet - Flux Complet

### **14:30 - Un citoyen crée un ticket**
```
Citoyen: \"Internet ne marche pas depuis ce matin\"
  ↓ Statut: OUVERT 🔵
  ↓ Technicien assigné: Papin DELA BLAST
  ↓ Papin reçoit notification 🔔
```

### **14:35 - Papin ouvre le ticket**
```
Papin voit: 
  - Titre: \"Internet ne marche pas\"
  - Statut: OUVERT 🔵
  - Citoyen: Hyacinthe PAPIN
  - Date: 2026-04-16
```

### **14:40 - Papin ajoute un commentaire**
```
Papin tape: \"Je vais vérifier...\"
  ↓ Appuie sur ➤
  ↓ ✅ AUTOMATIQUE: Statut OUVERT 🔵 → EN COURS 🟠
  ↓ Commentaire enregistré
  ↓ Citoyen reçoit notification 🔔
  ↓ Message: \"Le statut de votre ticket est passé de OUVERT à EN COURS\"
```

### **14:50 - Citoyen reçoit la notification**
```
Citoyen voit:
  - Badge rouge \"1\" sur Notifications 🔔
  - Ouvre le ticket
  - Voit: Commentaire de Papin + Statut maintenant EN COURS 🟠
```

### **14:55 - Citoyen répond**
```
Citoyen tape: \"D'accord, merci de vérifier\"
  ↓ Appuie sur ➤
  ↓ Papin reçoit notification 🔔
  ↓ Message: \"Un nouveau commentaire sur votre ticket\"
```

### **15:00 - Papin répond**
```
Papin tape: \"Problème identifié! C'était le routeur. Redémarrage effectué.\"
  ↓ Appuie sur ➤
  ↓ Statut reste EN COURS 🟠 (déjà en cours)
  ↓ Citoyen reçoit notification 🔔
```

### **15:05 - Papin marque comme RÉSOLU**
```
Papin appuie sur \"Marquer comme RÉSOLU\" (bouton vert)
  ↓ ✅ Statut EN COURS 🟠 → RÉSOLU 🟢
  ↓ Citoyen reçoit notification 🔔
  ↓ Message: \"Votre ticket a été résolu!\"
```

### **15:10 - Le citoyen confirme**
```
Citoyen ouvre le ticket:
  - Statut: RÉSOLU 🟢
  - Voit tout l'échange
  - Problème résolu! ✅
```

---

## 🎨 Les 4 Statuts Expliqués

| Statut | Couleur | Signification | Qui Change? |
|--------|---------|---------------|------------|
| **OUVERT** 🔵 | Bleu | Ticket créé, attendant traitement | Système (création) |
| **EN COURS** 🟠 | Orange | Technicien travaille dessus | Système (auto) ou Technicien |
| **RÉSOLU** 🟢 | Vert | Problème résolu, attendant fermé | Technicien/Admin |
| **CLOS** ⚫ | Gris | Archivé, ticket fermi | Admin |

---

## 👀 Voir l'Historique

1. Ouvrez le ticket
2. En bas, vous verrez: **\"Historique des changements\"**
3. Exemple:
   ```
   ✓ 14:40 - Statut OUVERT → EN COURS (Papin DELA BLAST)
   ✓ 15:05 - Statut EN COURS → RÉSOLU (Papin DELA BLAST)
   ```

---

## 🚨 Dépannage

### Je ne vois pas les notifications
- ✅ Appuyez sur le bouton **Notifications** en bas
- ✅ Vérifiez que vous avez un badge rouge 🔴
- ✅ Essayez de rafraîchir (tire vers le bas)

### Le statut ne change pas
- ✅ Assurez-vous d'être un TECHNICIEN
- ✅ Assurez-vous que le ticket est en statut OUVERT
- ✅ Ajoutez un commentaire (ne changez pas manuellement)

### Je ne reçois pas les notifications du citoyen
- ✅ Vérifiez que vous êtes assigné au ticket
- ✅ Vérifiez que le citoyen a ajouté un commentaire
- ✅ Rafraîchissez l'écran (tire vers le bas)

### Un ticket disparu
- ✅ Les tickets CLOS sont archivés
- ✅ Contactez l'admin pour les voir

---

## 💡 Conseils Pratiques

### Pour les Techniciens:
1. 📍 Toujours ajouter un commentaire en PREMIER (le statut changera auto)
2. 🔔 Vérifiez souvent vos notifications
3. 💬 Soyez clair dans vos commentaires pour le citoyen
4. ✅ Marquez comme RÉSOLU rapidement après réparation

### Pour les Citoyens:
1. 🎯 Soyez détaillé dans la description initiale
2. 📞 Mettez votre numéro de téléphone si urgent
3. 💬 Répondez aux questions du technicien rapidement
4. 🔔 Vérifiez régulièrement vos notifications

---

## 📞 Besoin d'aide?

Si vous rencontrez un problème:
1. Rafraîchissez l'écran (tire vers le bas)
2. Déconnectez-vous et reconnectez-vous
3. Vérifiez votre connexion Internet
4. Contactez l'administrateur

---

**Version:** 1.0
**Dernière mise à jour:** 16 Avril 2026
**Statut:** ✅ En production

Bonne gestion des tickets! 🚀
