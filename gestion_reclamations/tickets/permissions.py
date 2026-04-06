from rest_framework.permissions import BasePermission, SAFE_METHODS

# PERMISSION AUTEUR (MODIFICATION PROPRE) 
class IsAuteurOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux auteurs de modifier leurs propres tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    def has_object_permission(self, request, view, obj):
        # --- Lecture seule pour tous ---
        # Les méthodes GET, HEAD, OPTIONS sont autorisées sans restriction
        if request.method in SAFE_METHODS:
            return True
        
        # --- Modification réservée à l'auteur ---
        # Seul l'utilisateur qui a créé le ticket peut le modifier (PUT, PATCH, DELETE)
        return obj.auteur == request.user


# PERMISSION TECHNICIEN (GESTION DES TICKETS ASSIGNÉS) 
class IsTechnicienOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux techniciens de modifier certains tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    # --- Permission au niveau de la collection (liste/création) ---
    def has_permission(self, request, view):
        # Lecture seule autorisée pour tous
        if request.method in SAFE_METHODS:
            return True
        # Pour les écritures, seuls les techniciens et admins sont autorisés
        return request.user.role in ('TECHNICIEN', 'ADMIN')

    # --- Permission au niveau de l'objet (modification d'un ticket spécifique) ---
    def has_object_permission(self, request, view, obj):
        # Lecture seule autorisée pour tous
        if request.method in SAFE_METHODS:
            return True
        
        # Les admins ont tous les droits
        if request.user.role == 'ADMIN':
            return True
        
        # Les techniciens ne peuvent modifier que les tickets qui leur sont assignés
        return obj.assigne_a == request.user


# PERMISSION ADMIN (POUVOIR TOTAL) 
class IsAdminOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux administrateurs de modifier tous les tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    # --- Permission au niveau de la collection ---
    def has_permission(self, request, view):
        # Lecture seule pour tous les utilisateurs
        if request.method in SAFE_METHODS:
            return True
        # Seuls les admins peuvent créer/modifier
        return request.user.role == 'ADMIN'
    
    # --- Permission au niveau de l'objet ---
    def has_object_permission(self, request, view, obj):
        # Lecture seule pour tous
        if request.method in SAFE_METHODS:
            return True
        # Seuls les admins peuvent modifier un ticket existant
        return request.user.role == 'ADMIN'