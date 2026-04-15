from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from tickets.views import TicketViewSet, TechnicienViewSet, NotificationViewSet
from accounts.views import EmailTokenObtainPairView, RegisterView, ProfileView, CreateUserView


# CONFIGURATION DU ROUTEUR API REST
Router = DefaultRouter()
Router.register(r'tickets', TicketViewSet, basename='ticket')      # Endpoints pour les tickets
Router.register(r'techniciens', TechnicienViewSet, basename='technicien')  # Endpoints pour les techniciens
Router.register(r'notifications', NotificationViewSet, basename='notification')  # Endpoints pour les notifications


# DÉFINITION DES ROUTES URL
urlpatterns = [
    # ADMINISTRATION
    path('admin/', admin.site.urls),
    
    # AUTHENTIFICATION ET COMPTES UTILISATEURS
    path('api/auth/login/', EmailTokenObtainPairView.as_view(), name='token_obtain'),      # Connexion (JWT)
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),           # Rafraîchir token
    path('api/auth/register/', RegisterView.as_view(), name='register'),                   # Inscription
    path('api/auth/profile/', ProfileView.as_view(), name='profile'),                      # Profil utilisateur
    path('api/auth/create-user/', CreateUserView.as_view(), name='create_user'),           # Création utilisateur (admin)
    
    # API TICKETS (routes générées automatiquement par le routeur)
    path('api/', include(Router.urls)),
]