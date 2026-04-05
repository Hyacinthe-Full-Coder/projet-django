from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsAuteurOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux auteurs de modifier leurs propres tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    def has_object_permission(self, request, view, obj):
        # Les méthodes en lecture seule sont autorisées pour tous
        if request.method in SAFE_METHODS:
            return True
        
        # Seul l'auteur du ticket peut le modifier
        return obj.auteur == request.user
    
class IsTechnicienOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux techniciens de modifier certains tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        return request.user.role in ('TECHNICIEN', 'ADMIN')

    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        if request.user.role == 'ADMIN':
            return True
        # Technicien peut agir uniquement sur les tickets qui lui sont assignés
        return obj.assigne_a == request.user


class IsAdminOrReadOnly(BasePermission):
    """
    Permission personnalisée pour permettre aux administrateurs de modifier tous les tickets,
    tandis que les autres utilisateurs peuvent seulement lire les tickets.
    """

    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True
        return request.user.role == 'ADMIN'

    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True
        return request.user.role == 'ADMIN'
    