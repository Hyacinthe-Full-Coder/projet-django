from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()

class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'email'

    def validate(self, attrs):
        # Allow login via email and password
        return super().validate(attrs)


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'first_name', 'last_name', 'telephone']

    def create(self, validated_data):
        password = validated_data.pop('password')
        # Les citoyens s'enregistrent toujours comme CITOYEN
        user = User(role=User.Roles.CITOYEN, **validated_data)
        user.set_password(password)
        user.save()
        return user


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'first_name', 'last_name', 'role', 'telephone']


class CreateUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'username', 'password', 'first_name', 'last_name', 'role', 'telephone']

    def validate_role(self, value):
        # Uniquement ADMIN ou TECHNICIEN peuvent être créés par cet endpoint
        if value not in (User.Roles.ADMIN, User.Roles.TECHNICIEN):
            raise serializers.ValidationError("Rôle doit être ADMIN ou TECHNICIEN")
        return value

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user
