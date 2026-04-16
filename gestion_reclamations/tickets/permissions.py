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


# PERMISSION UNIFIÉE POUR LES TICKETS
class IsTicketAccessAllowed(BasePermission):
    """
    Permission unifiée pour contrôler l'accès aux tickets selon le rôle utilisateur.
    - Citoyens: lisent leurs propres tickets, modifient les leurs
    - Techniciens: lisent les tickets assignés, modifient les leurs
    - Admins: accès complet à tous les tickets
    """
    
    def has_permission(self, request, view):
        # Tous les utilisateurs authentifiés peuvent lire les listes
        if request.method in SAFE_METHODS:
            return True
        
        # Pour les écritures, seuls les admins et techniciens sont autorisés
        return request.user.role in ('ADMIN', 'TECHNICIEN', 'CITOYEN')
    
    def has_object_permission(self, request, view, obj):
        # Lecture autorisée pour tous les utilisateurs authentifiés
        if request.method in SAFE_METHODS:
            return True
        
        user = request.user
        
        # Admins: tous les droits
        if user.role == 'ADMIN':
            return True
        
        # Citoyens: peuvent modifier leurs propres tickets
        if user.role == 'CITOYEN':
            return obj.auteur == user
        
        # Techniciens: peuvent modifier les tickets assignés et ajouter des commentaires
        if user.role == 'TECHNICIEN':
            return obj.assigne_a == user
        
        return False
        
        return False
