from django.contrib import admin

from .models import Commentaire, HistoriqueStatut, Ticket


@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):
    list_display = ('titre', 'auteur', 'assigne_a', 'statut', 'priorite', 'date_creation')
    list_filter = ('statut', 'priorite', 'type_ticket', 'date_creation')
    search_fields = ('titre', 'description', 'auteur__email', 'auteur__first_name', 'auteur__last_name')
    raw_id_fields = ('auteur', 'assigne_a')


@admin.register(Commentaire)
class CommentaireAdmin(admin.ModelAdmin):
    list_display = ('ticket', 'auteur', 'date')
    search_fields = ('ticket__titre', 'auteur__email', 'contenu')


@admin.register(HistoriqueStatut)
class HistoriqueStatutAdmin(admin.ModelAdmin):
    list_display = ('ticket', 'ancien_statut', 'nouveau_statut', 'date_changement', 'modifie_par')
    list_filter = ('ancien_statut', 'nouveau_statut')
