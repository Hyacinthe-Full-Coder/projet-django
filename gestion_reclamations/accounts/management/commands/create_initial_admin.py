from django.core.management.base import BaseCommand
from accounts.models import CustomUser


class Command(BaseCommand):
    help = 'Crée l\'administrateur initial du système'

    def handle(self, *args, **options):
        email = 'bigglazer@gmail.com'
        username = 'admin'
        password = 'pass1234'
        first_name = 'Administrateur'
        last_name = 'Système'

        if CustomUser.objects.filter(email=email).exists():
            self.stdout.write(
                self.style.WARNING(f'Admin avec email {email} existe déjà.')
            )
            return

        admin_user = CustomUser.objects.create_superuser(
            username=username,
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name,
            role=CustomUser.Roles.ADMIN,
        )

        self.stdout.write(
            self.style.SUCCESS(
                f'✅ Admin créé avec succès!\n'
                f'   Email: {email}\n'
                f'   Password: {password}\n'
                f'   Role: ADMIN'
            )
        )
