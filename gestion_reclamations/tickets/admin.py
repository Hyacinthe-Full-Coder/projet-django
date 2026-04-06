from django.contrib import admin

from .models import Commentaire, HistoriqueStatut, Ticket


# ADMINISTRATION DES TICKETS 
@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):
    """
    Configuration de l'affichage et des fonctionnalités des tickets
    dans l'interface d'administration Django.
    """
    
    # COLONNES AFFICHÉES DANS LA LISTE 
    list_display = (
        'titre',
        'auteur',
        'assigne_a',
        'statut',
        'priorite',
        'date_creation'
    )
    
    # FILTRES LATÉRAUX 
    list_filter = (
        'statut',
        'priorite',
        'type_ticket',     
        'date_creation'
    )
    
    # CHAMPS RECHERCHABLES 
    search_fields = (
        'titre',
        'description',
        'auteur__email',
        'auteur__first_name',
        'auteur__last_name'
    )
    
    # OPTIMISATION DES PERFORMANCES
    raw_id_fields = (
        'auteur',        # Champ auteur avec popup de recherche
        'assigne_a'      # Champ assigné à avec popup de recherche
    )


# ADMINISTRATION DES COMMENTAIRES 
@admin.register(Commentaire)
class CommentaireAdmin(admin.ModelAdmin):
    """
    Configuration de l'affichage des commentaires dans l'administration.
    Utile pour la modération et le suivi des discussions.
    """
    
    # COLONNES AFFICHÉES 
    list_display = (
        'ticket',
        'auteur',
        'date'
    )
    
    # CHAMPS RECHERCHABLES 
    search_fields = (
        'ticket__titre',        # Titre du ticket associé 
        'auteur__email',        # Email de l'auteur
        'contenu'               # Texte du commentaire 
    )


# ADMINISTRATION DE L'HISTORIQUE DES STATUTS 
@admin.register(HistoriqueStatut)
class HistoriqueStatutAdmin(admin.ModelAdmin):
    """
    Configuration de l'affichage de l'historique des changements de statut.
    Essentiel pour l'audit et l'analyse des performances du support.
    """
    
    # COLONNES AFFICHÉES 
    list_display = (
        'ticket',                     # Ticket concerné
        'ancien_statut',              # Statut avant modification
        'nouveau_statut',             # Statut après modification
        'date_changement',            # Date du changement
        'modifie_par'                 # Utilisateur ayant fait le changement
    )
    
    # FILTRES LATÉRAUX 
    list_filter = (
        'ancien_statut',      # Filtre par statut de départ
        'nouveau_statut'      # Filtre par statut d'arrivée
    )
