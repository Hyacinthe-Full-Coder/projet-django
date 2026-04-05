from rest_framework import generics, permissions
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.response import Response
from rest_framework import status

from .serializers import EmailTokenObtainPairSerializer, RegisterSerializer, ProfileSerializer, CreateUserSerializer


class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer


class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer


class ProfileView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = ProfileSerializer

    def get_object(self):
        return self.request.user


class CreateUserView(generics.CreateAPIView):
    """
    Vue pour créer un nouvel utilisateur (admin ou technicien).
    Seul un ADMIN peut utiliser cet endpoint.
    """
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = CreateUserSerializer

    def check_permissions(self, request):
        super().check_permissions(request)
        if request.user.role != 'ADMIN':
            self.permission_denied(request, message='Seul un administrateur peut créer des utilisateurs.')
