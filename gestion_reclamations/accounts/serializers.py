from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


# SÉRIALISEUR POUR LA CONNEXION PAR EMAIL
class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'email'  # Utilise l'email comme identifiant au lieu du username

    # VALIDATION DES IDENTIFIANTS
    def validate(self, attrs):
        # Permet la connexion via email et mot de passe
        return super().validate(attrs)


# SÉRIALISEUR POUR L'INSCRIPTION DES CITOYENS
class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)  # Mot de passe en écriture seule

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'first_name', 'last_name', 'telephone']

    # CRÉATION D'UN NOUVEL UTILISATEUR (RÔLE CITOYEN PAR DÉFAUT)
    def create(self, validated_data):
        password = validated_data.pop('password')  # Extrait le mot de passe
        user = User(role=User.Roles.CITOYEN, **validated_data)  # Crée avec rôle CITOYEN
        user.set_password(password)  # Hache le mot de passe
        user.save()
        return user


# SÉRIALISEUR POUR LE PROFIL UTILISATEUR (LECTURE SEULE)
class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'telephone']


# SÉRIALISEUR POUR LA CRÉATION D'UTILISATEURS PAR ADMIN
class CreateUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)  # Mot de passe en écriture seule

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'first_name', 'last_name', 'role', 'telephone']

    # VALIDATION DU RÔLE (ADMIN OU TECHNICIEN UNIQUEMENT)
    def validate_role(self, value):
        if value not in (User.Roles.ADMIN, User.Roles.TECHNICIEN):
            raise serializers.ValidationError("Rôle doit être ADMIN ou TECHNICIEN")
        return value

    # CRÉATION D'UN UTILISATEUR (ADMIN OU TECHNICIEN)
    def create(self, validated_data):
        password = validated_data.pop('password')  # Extrait le mot de passe
        user = User(**validated_data)  # Crée l'utilisateur
        user.set_password(password)  # Hache le mot de passe
        user.save()
        return user


# SÉRIALISEUR POUR LA GESTION COMPLÈTE DES UTILISATEURS PAR ADMIN
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False)  # Mot de passe optionnel en mise à jour

    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'telephone', 'password', 'is_active']
        read_only_fields = ['id']

    # VALIDATION DU RÔLE
    def validate_role(self, value):
        if value not in (User.Roles.CITOYEN, User.Roles.ADMIN, User.Roles.TECHNICIEN):
            raise serializers.ValidationError("Rôle invalide")
        return value

    # CRÉATION OU MISE À JOUR
    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = User(**validated_data)
        if password:
            user.set_password(password)
        user.save()
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        return instance