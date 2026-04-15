from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db import models

from .models import Ticket, Commentaire, HistoriqueStatut, Notification
from .serializers import (TicketSerializer, CommentaireSerializer, TicketListSerializer, UserLightSerializer, NotificationSerializer)
from .permissions import IsAuteurOrReadOnly, IsTechnicienOrReadOnly, IsAdminOrReadOnly
from accounts.models import CustomUser


# VIEWSET PRINCIPAL DES TICKETS
class TicketViewSet(viewsets.ModelViewSet):
    
    # REQUÊTE OPTIMISÉE AVEC SELECT/PRETCH
    queryset = Ticket.objects.select_related('auteur', 'assigne_a').prefetch_related('commentaires', 'historique')
    
    # PERMISSIONS ET FILTRES
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['statut', 'priorite', 'type_ticket', 'assigne_a__id']
    search_fields = ['titre', 'description']
    ordering_fields = ['date_creation', 'priorite', 'statut']

    # SÉLECTION DU SÉRIALISEUR SELON L'ACTION
    def get_serializer_class(self):
        if self.action in ['list']:
            return TicketListSerializer  # Version légère pour la liste
        return TicketSerializer          # Version complète pour le détail

    # FILTRAGE DES TICKETS SELON LE RÔLE UTILISATEUR
    def get_queryset(self):
        user = self.request.user
        base_q = Ticket.objects.filter(est_archive=False)  # Exclut les archivés
        
        if user.role == 'CITOYEN':
            return base_q.filter(auteur=user)              # Citoyen : ses propres tickets
        elif user.role == 'TECHNICIEN':
            return base_q.filter(assigne_a=user)           # Technicien : tickets assignés
        return base_q                                       # Admin : tous les tickets

    # ACTION : CHANGER LE STATUT D'UN TICKET
    @action(detail=True, methods=['patch'], permission_classes=[IsAuthenticated])
    def changer_statut(self, request, pk=None):
        ticket = self.get_object()

        # VÉRIFICATION DES DROITS
        if request.user.role not in (CustomUser.Roles.TECHNICIEN, CustomUser.Roles.ADMIN):
            return Response({'detail': 'Vous n\'avez pas les droits pour changer le statut.'}, status=status.HTTP_403_FORBIDDEN)
        if request.user.role == CustomUser.Roles.TECHNICIEN and ticket.assigne_a != request.user:
            return Response({'detail': 'Technicien non assigné au ticket.'}, status=status.HTTP_403_FORBIDDEN)

        # VALIDATION DU NOUVEAU STATUT
        nouveau_statut = request.data.get('statut')
        if nouveau_statut not in dict(Ticket.Statut.choices):
            return Response({'error': 'Statut invalide'}, status=status.HTTP_400_BAD_REQUEST)

        # MISE À JOUR DU TICKET
        if nouveau_statut == Ticket.Statut.CLOS:
            ticket.est_archive = False
        
        ancien_statut = ticket.statut
        ticket.statut = nouveau_statut
        if nouveau_statut == Ticket.Statut.RESOLU:
            ticket.date_resolution = timezone.now()
        ticket.save()

        # ENREGISTREMENT DE L'HISTORIQUE
        HistoriqueStatut.objects.create(
            ticket=ticket,
            ancien_statut=ancien_statut,
            nouveau_statut=nouveau_statut,
            modifie_par=request.user
        )

        # CRÉATION DES NOTIFICATIONS
        # Notification pour l'auteur du ticket (si différent du modificateur)
        if ticket.auteur != request.user:
            creer_notification(
                destinataire=ticket.auteur,
                type_notification=Notification.TypeNotification.STATUT_CHANGE,
                titre=f"Statut de votre ticket modifié",
                message=f"Le statut de votre ticket '{ticket.titre}' est passé de '{ancien_statut}' à '{nouveau_statut}'.",
                createur=request.user,
                ticket=ticket,
                donnees_supplementaires={'ancien_statut': ancien_statut, 'nouveau_statut': nouveau_statut}
            )

        # Notification pour le technicien assigné (si différent du modificateur)
        if ticket.assigne_a and ticket.assigne_a != request.user:
            creer_notification(
                destinataire=ticket.assigne_a,
                type_notification=Notification.TypeNotification.STATUT_CHANGE,
                titre=f"Statut du ticket modifié",
                message=f"Le statut du ticket '{ticket.titre}' assigné à vous est passé de '{ancien_statut}' à '{nouveau_statut}'.",
                createur=request.user,
                ticket=ticket,
                donnees_supplementaires={'ancien_statut': ancien_statut, 'nouveau_statut': nouveau_statut}
            )

        # Notification spéciale pour résolution
        if nouveau_statut == Ticket.Statut.RESOLU:
            if ticket.auteur != request.user:
                creer_notification(
                    destinataire=ticket.auteur,
                    type_notification=Notification.TypeNotification.TICKET_RESOLU,
                    titre=f"Votre ticket a été résolu",
                    message=f"Le ticket '{ticket.titre}' a été marqué comme résolu.",
                    createur=request.user,
                    ticket=ticket
                )

        # Notification spéciale pour clôture
        if nouveau_statut == Ticket.Statut.CLOS:
            if ticket.auteur != request.user:
                creer_notification(
                    destinataire=ticket.auteur,
                    type_notification=Notification.TypeNotification.TICKET_CLOS,
                    titre=f"Votre ticket a été clos",
                    message=f"Le ticket '{ticket.titre}' a été clos et archivé.",
                    createur=request.user,
                    ticket=ticket
                )

        return Response(TicketSerializer(ticket, context={'request': request}).data)

    # ACTION : AJOUTER UN COMMENTAIRE
    @action(detail=True, methods=['post'])
    def commenter(self, request, pk=None):
        ticket = self.get_object()
        serializer = CommentaireSerializer(data=request.data)
        if serializer.is_valid():
            commentaire = serializer.save(auteur=request.user, ticket=ticket)

            # CRÉATION DE NOTIFICATIONS
            # Notification pour l'auteur du ticket (si différent du commentateur)
            if ticket.auteur != request.user:
                creer_notification(
                    destinataire=ticket.auteur,
                    type_notification=Notification.TypeNotification.NOUVEAU_COMMENTAIRE,
                    titre=f"Nouveau commentaire sur votre ticket",
                    message=f"Un nouveau commentaire a été ajouté à votre ticket '{ticket.titre}'.",
                    createur=request.user,
                    ticket=ticket
                )

            # Notification pour le technicien assigné (si différent du commentateur)
            if ticket.assigne_a and ticket.assigne_a != request.user:
                creer_notification(
                    destinataire=ticket.assigne_a,
                    type_notification=Notification.TypeNotification.NOUVEAU_COMMENTAIRE,
                    titre=f"Nouveau commentaire sur un ticket",
                    message=f"Un nouveau commentaire a été ajouté au ticket '{ticket.titre}' qui vous est assigné.",
                    createur=request.user,
                    ticket=ticket
                )

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # ACTION : ASSIGNER UN TECHNICIEN À UN TICKET
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def assigner(self, request, pk=None):
        ticket = self.get_object()
        
        # SEUL L'ADMIN PEUT ASSIGNER
        if request.user.role != CustomUser.Roles.ADMIN:
            return Response({'detail': 'Seul l\'admin peut assigner un ticket.'}, status=status.HTTP_403_FORBIDDEN)

        technicien_id = request.data.get('technicien_id')
        auto = request.data.get('auto', False)

        # ASSIGNATION AUTOMATIQUE (LOAD BALANCING)
        if auto:
            technicien = CustomUser.objects.filter(role=CustomUser.Roles.TECHNICIEN).annotate(
                nb_tickets=models.Count('tickets_assignes', filter=models.Q(tickets_assignes__statut__in=[Ticket.Statut.EN_COURS, Ticket.Statut.OUVERT]))
            ).order_by('nb_tickets').first()
            if not technicien:
                return Response({'detail': 'Aucun technicien disponible.'}, status=status.HTTP_400_BAD_REQUEST)
            ticket.assigne_a = technicien
        else:
            # ASSIGNATION MANUELLE
            if not technicien_id:
                return Response({'error': 'technicien_id requis'}, status=status.HTTP_400_BAD_REQUEST)
            try:
                technicien = CustomUser.objects.get(id=technicien_id, role=CustomUser.Roles.TECHNICIEN)
            except CustomUser.DoesNotExist:
                return Response({'detail': 'Technicien introuvable.'}, status=status.HTTP_404_NOT_FOUND)
            ticket.assigne_a = technicien

        ticket.save()

        # CRÉATION DE NOTIFICATION POUR LE TECHNICIEN
        creer_notification(
            destinataire=technicien,
            type_notification=Notification.TypeNotification.NOUVELLEMENT_ASSIGNE,
            titre=f"Nouveau ticket assigné",
            message=f"Le ticket '{ticket.titre}' vous a été assigné.",
            createur=request.user,
            ticket=ticket
        )

        return Response(TicketSerializer(ticket, context={'request': request}).data)

    # ACTION : TABLEAU DE BORD STATISTIQUE
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def dashboard(self, request):
        """
        Endpoint de dashboard retournant des statistiques.
        Admin : statistiques globales
        Technicien : ses propres statistiques
        Citoyen : ses tickets
        """
        user = request.user
        
        # DASHBOARD ADMIN
        if user.role == 'ADMIN':
            total_tickets = Ticket.objects.count()
            tickets_ouvert = Ticket.objects.filter(statut=Ticket.Statut.OUVERT).count()
            tickets_en_cours = Ticket.objects.filter(statut=Ticket.Statut.EN_COURS).count()
            tickets_resolu = Ticket.objects.filter(statut=Ticket.Statut.RESOLU).count()
            tickets_clos = Ticket.objects.filter(statut=Ticket.Statut.CLOS).count()
            total_users = CustomUser.objects.count()
            total_techniciens = CustomUser.objects.filter(role='TECHNICIEN').count()
            total_citoyens = CustomUser.objects.filter(role='CITOYEN').count()
            
            data = {
                'role': user.role,
                'total_tickets': total_tickets,
                'tickets_by_status': {
                    'OUVERT': tickets_ouvert,
                    'EN_COURS': tickets_en_cours,
                    'RESOLU': tickets_resolu,
                    'CLOS': tickets_clos,
                },
                'total_users': total_users,
                'users_by_role': {
                    'ADMIN': CustomUser.objects.filter(role='ADMIN').count(),
                    'TECHNICIEN': total_techniciens,
                    'CITOYEN': total_citoyens,
                },
                'recent_tickets': TicketListSerializer(
                    Ticket.objects.all().order_by('-date_creation')[:5],
                    many=True
                ).data,
            }
        
        # DASHBOARD TECHNICIEN
        elif user.role == 'TECHNICIEN':
            tickets_assignes = Ticket.objects.filter(assigne_a=user)
            total = tickets_assignes.count()
            en_cours = tickets_assignes.filter(statut=Ticket.Statut.EN_COURS).count()
            resolu = tickets_assignes.filter(statut=Ticket.Statut.RESOLU).count()
            clos = tickets_assignes.filter(statut=Ticket.Statut.CLOS).count()
            
            data = {
                'role': user.role,
                'name': f"{user.first_name} {user.last_name}",
                'total_tickets_assignes': total,
                'my_tickets': {
                    'EN_COURS': en_cours,
                    'RESOLU': resolu,
                    'CLOS': clos,
                },
                'recent_tickets': TicketListSerializer(
                    tickets_assignes.order_by('-date_creation')[:5],
                    many=True
                ).data,
            }
        
        # DASHBOARD CITOYEN
        else:
            my_tickets = Ticket.objects.filter(auteur=user)
            data = {
                'role': user.role,
                'name': f"{user.first_name} {user.last_name}",
                'total_tickets': my_tickets.count(),
                'my_tickets': {
                    'OUVERT': my_tickets.filter(statut=Ticket.Statut.OUVERT).count(),
                    'EN_COURS': my_tickets.filter(statut=Ticket.Statut.EN_COURS).count(),
                    'RESOLU': my_tickets.filter(statut=Ticket.Statut.RESOLU).count(),
                    'CLOS': my_tickets.filter(statut=Ticket.Statut.CLOS).count(),
                },
                'recent_tickets': TicketListSerializer(
                    my_tickets.order_by('-date_creation')[:5],
                    many=True
                ).data,
            }
        
        return Response(data)


# VIEWSET POUR LISTER LES TECHNICIENS
class TechnicienViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet pour lister les techniciens (utilisé par Flutter)"""
    queryset = CustomUser.objects.filter(role='TECHNICIEN')
    serializer_class = UserLightSerializer
    permission_classes = [IsAuthenticated]


# FONCTIONS UTILITAIRES POUR LES NOTIFICATIONS
def creer_notification(destinataire, type_notification, titre, message, createur=None, ticket=None, donnees_supplementaires=None):
    """
    Fonction utilitaire pour créer une notification
    """
    return Notification.objects.create(
        destinataire=destinataire,
        type_notification=type_notification,
        titre=titre,
        message=message,
        createur=createur,
        ticket=ticket,
        donnees_supplementaires=donnees_supplementaires
    )


# VIEWSET DES NOTIFICATIONS
class NotificationViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les notifications des utilisateurs
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['est_lue', 'type_notification']
    ordering_fields = ['date_creation', 'est_lue']

    def get_queryset(self):
        """Retourne uniquement les notifications de l'utilisateur connecté"""
        return Notification.objects.filter(destinataire=self.request.user)

    # ACTION : MARQUER UNE NOTIFICATION COMME LUE
    @action(detail=True, methods=['patch'])
    def marquer_lue(self, request, pk=None):
        notification = self.get_object()
        notification.est_lue = True
        notification.save()
        return Response(NotificationSerializer(notification).data)

    # ACTION : MARQUER TOUTES LES NOTIFICATIONS COMME LUES
    @action(detail=False, methods=['patch'])
    def marquer_toutes_lues(self, request):
        notifications = self.get_queryset().filter(est_lue=False)
        notifications.update(est_lue=True)
        return Response({'detail': f'{notifications.count()} notifications marquées comme lues'})

    # ACTION : COMPTER LES NOTIFICATIONS NON LUES
    @action(detail=False, methods=['get'])
    def compter_non_lues(self, request):
        count = self.get_queryset().filter(est_lue=False).count()
        return Response({'non_lues': count})