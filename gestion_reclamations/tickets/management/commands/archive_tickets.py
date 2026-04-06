from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from tickets.models import Ticket


# COMMANDE PERSONNALISÉE D'ARCHIVAGE DES TICKETS
class Command(BaseCommand):
    help = 'Archives les tickets clos depuis plus de 30 jours'  # Description de la commande

    # MÉTHODE PRINCIPALE DE LA COMMANDE
    def handle(self, *args, **options):
        
        # CALCUL DE LA DATE SEUIL
        seuil = timezone.now() - timedelta(days=30)  # Date : il y a 30 jours
        
        # FILTRAGE DES TICKETS À ARCHIVER
        tickets_a_archiver = Ticket.objects.filter(
            statut=Ticket.Statut.CLOS,           # Statut = Clos
            date_resolution__lt=seuil,           # Résolu il y a plus de 30 jours
            est_archive=False                    # Non encore archivé
        )
        
        # COMPTAGE DES TICKETS CONCERNÉS
        compte = tickets_a_archiver.count()
        
        # MISE À JOUR (ARCHIVAGE)
        tickets_a_archiver.update(est_archive=True)
        
        # AFFICHAGE DU RÉSULTAT DANS LA CONSOLE
        self.stdout.write(self.style.SUCCESS(f'{compte} tickets clos archivés.'))