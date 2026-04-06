from django.contrib.auth.models import AbstractUser
from django.db import models


# MODÈLE UTILISATEUR PERSONNALISÉ
class CustomUser(AbstractUser):
    
    # DÉFINITION DES RÔLES DISPONIBLES
    class Roles(models.TextChoices):
        CITOYEN = 'CITOYEN', 'Citoyen / Agent'        # Utilisateur standard
        TECHNICIEN = 'TECHNICIEN', 'Technicien Support'  # Technicien support
        ADMIN = 'ADMIN', 'Administrateur'             # Administrateur

    # CHAMPS ADDITIONNELS
    email = models.EmailField(unique=True)            # Email unique (utilisé pour connexion)
    role = models.CharField(max_length=15, choices=Roles.choices, default=Roles.CITOYEN)  # Rôle utilisateur
    telephone = models.CharField(max_length=20, blank=True)  # Téléphone (optionnel)

    # CONFIGURATION DE L'AUTHENTIFICATION
    USERNAME_FIELD = 'email'          # Utilise l'email comme identifiant principal
    REQUIRED_FIELDS = ['username']    # Username est requis mais n'est pas utilisé pour la connexion

    # REPRÉSENTATION TEXTUELLE
    def __str__(self):
        return f"{self.get_full_name()} ({self.email})"

    # PROPRIÉTÉS UTILES POUR LES PERMISSIONS
    @property
    def is_technicien(self):
        return self.role == self.Roles.TECHNICIEN  # Vérifie si l'utilisateur est technicien

    @property
    def is_admin_role(self):
        return self.role == self.Roles.ADMIN       # Vérifie si l'utilisateur est admin