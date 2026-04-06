from rest_framework import serializers
from .models import Ticket, Commentaire, HistoriqueStatut
from accounts.models import CustomUser

# SÉRIALISEUR UTILISATEUR LÉGER 
class UserLightSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'first_name', 'last_name', 'email', 'role']


# SÉRIALISEUR DES COMMENTAIRES 
class CommentaireSerializer(serializers.ModelSerializer):
    # Inclut les informations de l'auteur via le sérialiseur léger (lecture seule)
    auteur = UserLightSerializer(read_only=True)

    class Meta:
        model = Commentaire
        fields = ['id', 'auteur', 'contenu', 'date']
        read_only_fields = ['id', 'auteur', 'date']


# SÉRIALISEUR DE L'HISTORIQUE DES STATUTS 
class HistoriqueStatutSerializer(serializers.ModelSerializer):
    # L'utilisateur qui a modifié le statut (lecture seule)
    modifie_par = UserLightSerializer(read_only=True)

    class Meta:
        model = HistoriqueStatut
        fields = ['id', 'ancien_statut', 'nouveau_statut', 'date_changement', 'modifie_par']


# SÉRIALISEUR PRINCIPAL DES TICKETS 
# Gère toutes les opérations CRUD sur les tickets
class TicketSerializer(serializers.ModelSerializer):
    # --- Champs avec relations (lecture seule) ---
    auteur = UserLightSerializer(read_only=True)
    assigne_a = UserLightSerializer(read_only=True)
    
    # Relations imbriquées (lecture seule)
    commentaires = CommentaireSerializer(many=True, read_only=True)
    historique = HistoriqueStatutSerializer(many=True, read_only=True)
    
    # --- Champ d'écriture pour l'assignation ---
    assigne_a_id = serializers.PrimaryKeyRelatedField(
        queryset=CustomUser.objects.filter(role=CustomUser.Roles.TECHNICIEN),
        source='assigne_a',
        write_only=True,
        required=False,
        allow_null=True
    )

    class Meta:
        model = Ticket
        fields = [
            'id', 'titre', 'description', 'type_ticket', 'statut', 'priorite',
            'auteur', 'assigne_a', 'date_creation', 'date_modification',
            'date_resolution', 'commentaires', 'historique', 'assigne_a_id', 'est_archive'
        ]
        read_only_fields = ['auteur', 'date_creation', 'date_modification', 'est_archive']

    # --- Méthode de création personnalisée ---
    # Assigne automatiquement l'utilisateur connecté comme auteur du ticket
    def create(self, validated_data):
        validated_data['auteur'] = self.context['request'].user
        return super().create(validated_data)


# SÉRIALISEUR ALLÉGÉ POUR LES LISTES 
class TicketListSerializer(serializers.ModelSerializer):
    auteur = UserLightSerializer(read_only=True)
    assigne_a = UserLightSerializer(read_only=True)
    
    class Meta:
        model = Ticket
        fields = ['id', 'titre', 'type_ticket', 'statut', 'priorite', 'auteur', 'assigne_a', 'date_creation']
        read_only_fields = ['auteur', 'date_creation']