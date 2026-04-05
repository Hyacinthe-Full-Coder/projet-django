from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from tickets.models import Ticket

class Command(BaseCommand):
    help = 'Archives les tickets clos depuis plus de 30 jours'

    def handle(self, *args, **options):
        seuil = timezone.now() - timedelta(days=30)
        tickets_a_archiver = Ticket.objects.filter(statut=Ticket.Statut.CLOS, date_resolution__lt=seuil, est_archive=False)
        compte = tickets_a_archiver.count()
        tickets_a_archiver.update(est_archive=True)
        self.stdout.write(self.style.SUCCESS(f'{compte} tickets clos archivés.'))
