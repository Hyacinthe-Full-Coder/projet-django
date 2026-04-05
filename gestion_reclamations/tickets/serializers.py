from rest_framework import serializers
from .models import Ticket, Commentaire, HistoriqueStatut
from accounts.models import CustomUser

class UserLightSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'first_name','last_name', 'email', 'role']

class CommentaireSerializer(serializers.ModelSerializer):
    auteur = UserLightSerializer(read_only=True)

    class Meta:
        model = Commentaire
        fields = ['id', 'auteur', 'contenu', 'date']
        read_only_fields = ['id', 'auteur', 'date']

class HistoriqueStatutSerializer(serializers.ModelSerializer):
    modifie_par = UserLightSerializer(read_only=True)

    class Meta:
        model = HistoriqueStatut
        fields = ['id', 'ancien_statut', 'nouveau_statut', 'date_changement', 'modifie_par']

class TicketSerializer(serializers.ModelSerializer):
    auteur = UserLightSerializer(read_only=True)
    assigne_a = UserLightSerializer(read_only=True)
    commentaires = CommentaireSerializer(many=True, read_only=True)
    historique = HistoriqueStatutSerializer(many=True, read_only=True)
    assigne_a_id = serializers.PrimaryKeyRelatedField(queryset=CustomUser.objects.filter(role=CustomUser.Roles.TECHNICIEN), source='assigne_a', write_only=True, required=False, allow_null=True)

    class Meta:
        model = Ticket
        fields = ['id', 'titre', 'description', 'type_ticket', 'statut', 'priorite', 'auteur', 'assigne_a', 'date_creation', 'date_modification', 'date_resolution', 'commentaires', 'historique', 'assigne_a_id', 'est_archive']
        read_only_fields = ['auteur', 'date_creation', 'date_modification', 'est_archive']

    def create(self, validated_data):
        validated_data['auteur'] = self.context['request'].user
        return super().create(validated_data)


class TicketListSerializer(serializers.ModelSerializer):
    auteur = UserLightSerializer(read_only=True)
    assigne_a = UserLightSerializer(read_only=True)
    
    class Meta:
        model = Ticket
        fields = ['id', 'titre', 'type_ticket', 'statut', 'priorite', 'auteur', 'assigne_a', 'date_creation']
        read_only_fields = ['auteur', 'date_creation']