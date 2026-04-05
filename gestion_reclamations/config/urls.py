from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from tickets.views import TicketViewSet, TechnicienViewSet
from accounts.views import EmailTokenObtainPairView, RegisterView, ProfileView, CreateUserView

Router = DefaultRouter()
Router.register(r'tickets', TicketViewSet, basename='ticket')
Router.register(r'techniciens', TechnicienViewSet, basename='technicien')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/login/', EmailTokenObtainPairView.as_view(), name='token_obtain'),
    path('api/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/profile/', ProfileView.as_view(), name='profile'),
    path('api/auth/create-user/', CreateUserView.as_view(), name='create_user'),
    path('api/', include(Router.urls)),
]
