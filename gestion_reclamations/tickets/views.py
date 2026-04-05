from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from django.utils import timezone
from django.db import models

from .models import Ticket, Commentaire, HistoriqueStatut
from .serializers import (TicketSerializer, CommentaireSerializer, TicketListSerializer, UserLightSerializer)
from .permissions import IsAuteurOrReadOnly, IsTechnicienOrReadOnly, IsAdminOrReadOnly
from accounts.models import CustomUser


class TicketViewSet(viewsets.ModelViewSet):
    queryset = Ticket.objects.select_related('auteur', 'assigne_a').prefetch_related('commentaires', 'historique')
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['statut', 'priorite', 'type_ticket', 'assigne_a__id']
    search_fields = ['titre', 'description']
    ordering_fields = ['date_creation', 'priorite', 'statut']

    def get_serializer_class(self):
        if self.action in ['list']:
            return TicketListSerializer
        return TicketSerializer
    
    def get_queryset(self):
        user = self.request.user
        base_q = Ticket.objects.filter(est_archive=False)
        if user.role == 'CITOYEN':
            return base_q.filter(auteur=user)
        elif user.role == 'TECHNICIEN':
            # Technicien ne voit que les tickets qui lui sont assignés
            return base_q.filter(assigne_a=user)
        
        # admin voit tous les tickets non archivés
        return base_q
    
    @action(detail=True, methods=['patch'], permission_classes=[IsAuthenticated])
    def changer_statut(self, request, pk=None):
        ticket = self.get_object()

        # Seuls les techniciens assignés au ticket et les admins peuvent changer le statut
        if request.user.role not in (CustomUser.Roles.TECHNICIEN, CustomUser.Roles.ADMIN):
            return Response({'detail': 'Vous n\'avez pas les droits pour changer le statut.'}, status=status.HTTP_403_FORBIDDEN)
        if request.user.role == CustomUser.Roles.TECHNICIEN and ticket.assigne_a != request.user:
            return Response({'detail': 'Technicien non assigné au ticket.'}, status=status.HTTP_403_FORBIDDEN)

        nouveau_statut = request.data.get('statut')
        if nouveau_statut not in dict(Ticket.Statut.choices):
            return Response({'error': 'Statut invalide'}, status=status.HTTP_400_BAD_REQUEST)

        # Optionnel : archive automatique si close
        if nouveau_statut == Ticket.Statut.CLOS:
            ticket.est_archive = False  # close visible, archive pur plus tard (cron)
        
        ancien_statut = ticket.statut
        ticket.statut = nouveau_statut
        if nouveau_statut == Ticket.Statut.RESOLU:
            ticket.date_resolution = timezone.now()
        ticket.save()

        # Enregistrer l'historique du changement de statut
        HistoriqueStatut.objects.create(
            ticket=ticket,
            ancien_statut=ancien_statut,
            nouveau_statut=nouveau_statut,
            modifie_par=request.user
        )
        return Response(TicketSerializer(ticket, context={'request': request}).data)
    
    @action(detail=True, methods=['post'])
    def commenter(self, request, pk=None):
        ticket = self.get_object()
        serializer = CommentaireSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(auteur=request.user, ticket=ticket)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
    def assigner(self, request, pk=None):
        ticket = self.get_object()
        if request.user.role != CustomUser.Roles.ADMIN:
            return Response({'detail': 'Seul l\'admin peut assigner un ticket.'}, status=status.HTTP_403_FORBIDDEN)

        technicien_id = request.data.get('technicien_id')
        auto = request.data.get('auto', False)

        if auto:
            technicien = CustomUser.objects.filter(role=CustomUser.Roles.TECHNICIEN).annotate(
                nb_tickets=models.Count('tickets_assignes', filter=models.Q(tickets_assignes__statut__in=[Ticket.Statut.EN_COURS, Ticket.Statut.OUVERT]))
            ).order_by('nb_tickets').first()
            if not technicien:
                return Response({'detail': 'Aucun technicien disponible.'}, status=status.HTTP_400_BAD_REQUEST)
            ticket.assigne_a = technicien
        else:
            if not technicien_id:
                return Response({'error': 'technicien_id requis'}, status=status.HTTP_400_BAD_REQUEST)
            try:
                technicien = CustomUser.objects.get(id=technicien_id, role=CustomUser.Roles.TECHNICIEN)
            except CustomUser.DoesNotExist:
                return Response({'detail': 'Technicien introuvable.'}, status=status.HTTP_404_NOT_FOUND)
            ticket.assigne_a = technicien

        ticket.save()
        return Response(TicketSerializer(ticket, context={'request': request}).data)

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def dashboard(self, request):
        """
        Endpoint de dashboard retournant des statistiques.
        Admin : statistiques globales
        Technicien : ses propres statistiques
        Citoyen : ses tickets
        """
        user = request.user
        
        if user.role == 'ADMIN':
            # Admin stats
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
        elif user.role == 'TECHNICIEN':
            # Technicien stats
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
        else:
            # Citoyen
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


class TechnicienViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet pour lister les techniciens (utilisé par Flutter)"""
    queryset = CustomUser.objects.filter(role='TECHNICIEN')
    serializer_class = UserLightSerializer
    permission_classes = [IsAuthenticated]
