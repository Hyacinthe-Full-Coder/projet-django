from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    class Roles(models.TextChoices):
        CITOYEN = 'CITOYEN', 'Citoyen / Agent'
        TECHNICIEN = 'TECHNICIEN', 'Technicien Support'
        ADMIN = 'ADMIN', 'Administrateur'

    email = models.EmailField(unique=True)
    role = models.CharField(max_length=15, choices=Roles.choices, default=Roles.CITOYEN)
    telephone = models.CharField(max_length=20, blank=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return f"{self.get_full_name()} ({self.email})"

    @property
    def is_technicien(self):
        return self.role == self.Roles.TECHNICIEN

    @property
    def is_admin_role(self):
        return self.role == self.Roles.ADMIN