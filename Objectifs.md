# Perimetre du projet

## Utilisateurs cibles

- **Citoyen / Agent metier :** Soumet des reclamations, suit l'etat de ses tickets, recoit des notifications.

- **Technicien support :** Recoit les tickets assignes par l'admin, les traite, met a jour leur statut.

- **Administrateur :** Gere les utilisateurs, les roles, les types de tickets, les statistiques (Des diagrammes).

***

## Fonctionnalites principales attendues

###  Cote utilisateur (citoyens et agents)

- Creation de ticket ou soumission de reclamation (formulaire Flutter).
- Suivi de l'etat du ticket : Ouvert, En cours, Resolu, Clos.
- Consultation de l'historique des demandes.
- Notifications a chaque changement d'etat du ticket.

### Cote cellule informatique (support technique)

- Reception centralisee des tickets via tableau de bord Flutter.
- Attribution automatique ou manuelle des tickets aux techniciens.
- Interface de traitement des tickets avec suivi des actions.
- Systeme de classement, Filtrage et recherche des tickets.
- Generation de statistiques et tableaux de bord.

### Administration de la plateforme

- Gestion des utilisateurs et des roles (Django Admin + API).
- Parametrage des types de tickets : incident, reclamation, demande.
- Configuration des priorites et des delais de traitement.
- Archivage automatique des tickets clos apres un certain delai.
- **🆕 Interface d'assignation des tickets aux techniciens (manuel/auto).**

je veux que les menus soient latéral.
Et que le technocien ne puisse voir que des tickets assigné par l'admin

✅ Reduiser la taille des grilles des dashboard. 
✅ Fixer le menu. 
✅ Pour les statistique je veux des diagrammas circulaires.