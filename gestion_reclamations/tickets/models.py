from django.db import models
from django.conf import settings

# MODÈLE PRINCIPAL DES TICKETS 
class Ticket(models.Model):
    
    # CHOIX ÉNUMÉRÉS (ENUMS) 
    # Définit les types de tickets disponibles
    class TypeTicket(models.TextChoices):
        INCIDENT = 'INCIDENT', 'Incident technique'
        RECLAMATION = 'RECLAMATION', 'Réclamation'
        DEMANDE = 'DEMANDE', 'Demande de service'

    # Définit les différents statuts d'avancement d'un ticket
    class Statut(models.TextChoices):
        OUVERT = 'OUVERT', 'Ouvert'
        EN_COURS = 'EN_COURS', 'En cours de traitement'
        RESOLU = 'RESOLU', 'Résolu'                       
        CLOS = 'CLOS', 'Clos / Archive'

    # Définit les niveaux de priorité pour la gestion des tickets
    class Priorite(models.TextChoices):
        BASSE = 'BASSE', 'Basse'                          
        NORMALE = 'NORMALE', 'Normale'                    
        HAUTE = 'HAUTE', 'Haute'                          
        CRITIQUE = 'CRITIQUE', 'Critique'                 

    # CHAMPS D'INFORMATIONS GÉNÉRALES
    titre = models.CharField(max_length=200)              
    description = models.TextField()                      
    
    # CHAMPS DE CATÉGORISATION 
    type_ticket = models.CharField(max_length=15, choices=TypeTicket.choices, default=TypeTicket.INCIDENT)
    statut = models.CharField(max_length=10, choices=Statut.choices, default=Statut.OUVERT)
    priorite = models.CharField(max_length=10, choices=Priorite.choices, default=Priorite.NORMALE)
    
    # CHAMPS DE RELATIONS (UTILISATEURS) 
    # Auteur : utilisateur qui a créé le ticket
    auteur = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='tickets_crees')
    # Assigné à : technicien responsable
    assigne_a = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='tickets_assignes')
    
    # CHAMPS TEMPORELS (AUTOMATIQUES) 
    date_creation = models.DateTimeField(auto_now_add=True)
    date_modification = models.DateTimeField(auto_now=True)
    date_resolution = models.DateTimeField(null=True, blank=True) 
    
    # CHAMPS DE GESTION 
    est_archive = models.BooleanField(default=False)              

    # CONFIGURATION MÉTA 
    class Meta:
        ordering = ['-date_creation']        
        verbose_name = 'Ticket'              
        verbose_name_plural = 'Tickets'      

    # MÉTHODES 
    def __str__(self):
        """Représentation textuelle du ticket"""
        return f"[{self.statut}] {self.titre}"


# MODÈLE DES COMMENTAIRES 
class Commentaire(models.Model):
    # RELATIONS 
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE, related_name='commentaires')  
    auteur = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    
    # CONTENU 
    contenu = models.TextField()
    
    # TEMPOREL 
    date = models.DateTimeField(auto_now_add=True)

    # CONFIGURATION MÉTA 
    class Meta:
        ordering = ['date']
        # verbose_name = 'Commentaire'  # 

    # MÉTHODES 
    def __str__(self):
        """Représentation textuelle du commentaire"""
        return f"Commentaire de {self.auteur} sur #{self.ticket.id}"


# MODÈLE D'HISTORIQUE DES STATUTS 
class HistoriqueStatut(models.Model):
    # RELATIONS 
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE, related_name='historique')   # Ticket concerné
    modifie_par = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)  # Utilisateur ayant modifié
    
    # CHAMPS DE SUIVI 
    ancien_statut = models.CharField(max_length=10)     # Statut avant modification
    nouveau_statut = models.CharField(max_length=10)    # Statut après modification
    date_changement = models.DateTimeField(auto_now_add=True)  # Date du changement

    # CONFIGURATION MÉTA
    class Meta:
        ordering = ['-date_changement']        # Tri par date décroissante (les plus récents d'abord)

    # MÉTHODES
    def __str__(self):
        """Représentation textuelle du changement de statut"""
        return f"Changement {self.ancien_statut} → {self.nouveau_statut}"