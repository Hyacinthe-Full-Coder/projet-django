from rest_framework import generics, permissions
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.response import Response
from rest_framework import status

from .serializers import EmailTokenObtainPairSerializer, RegisterSerializer, ProfileSerializer, CreateUserSerializer

# Views pour l'authentification, l'enregistrement et la gestion des profils utilisateur
class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer

# Vue pour l'enregistrement des utilisateurs (citoyens)
class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

# Vue pour afficher et mettre à jour le profil de l'utilisateur connecté
class ProfileView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = ProfileSerializer

    # Le profil affiché est celui de l'utilisateur connecté
    def get_object(self):
        return self.request.user


# Vue pour la création d'utilisateurs par l'admin (ADMIN et TECHNICIEN)
class CreateUserView(generics.CreateAPIView):
    """
    Vue pour créer un nouvel utilisateur (admin ou technicien).
    Seul un ADMIN peut utiliser cet endpoint.
    """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CreateUserSerializer

# Vérification des permissions pour s'assurer que seul un ADMIN peut créer des utilisateurs
    def check_permissions(self, request):
        super().check_permissions(request)
        if request.user.role != 'ADMIN':
            self.permission_denied(request, message='Seul un administrateur peut créer des utilisateurs.')
