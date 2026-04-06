from django.test import override_settings
from datetime import timedelta
from rest_framework import status
from rest_framework.test import APITestCase
from django.urls import reverse
from accounts.models import CustomUser
from tickets.models import Ticket, HistoriqueStatut


# TESTS DU WORKFLOW DES TICKETS
class TicketWorkflowTests(APITestCase):
    
    # CRÉATION DES UTILISATEURS DE TEST
    def setUp(self):
        self.citoyen = CustomUser.objects.create_user(
            username='citoyen', email='citoyen@example.com', password='Test1234', role=CustomUser.Roles.CITOYEN
        )
        self.technicien = CustomUser.objects.create_user(
            username='technicien', email='tech@example.com', password='Test1234', role=CustomUser.Roles.TECHNICIEN
        )
        self.admin = CustomUser.objects.create_superuser(
            username='admin', email='admin@example.com', password='Test1234', role=CustomUser.Roles.ADMIN
        )

    # AUTHENTIFICATION HELPER
    def authenticate(self, user):
        url = reverse('token_obtain')
        resp = self.client.post(url, {'email': user.email, 'password': 'Test1234'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        token = resp.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        return resp.data

    # TEST 1 : VÉRIFICATION DE L'AUTHENTIFICATION REQUISE
    def test_authentication_header_required(self):
        url = reverse('ticket-list')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_401_UNAUTHORIZED)

        self.authenticate(self.citoyen)
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

    # TEST 2 : CRÉATION DE TICKET PAR CITOYEN
    def test_citoyen_can_create_ticket_and_author_assigned(self):
        self.authenticate(self.citoyen)
        url = reverse('ticket-list')
        data = {
            'titre': 'Panne #1',
            'description': 'Le wifi tombe',
            'type_ticket': Ticket.TypeTicket.RECLAMATION,
            'priorite': Ticket.Priorite.NORMALE,
        }
        resp = self.client.post(url, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        ticket_id = resp.data['id']

        ticket = Ticket.objects.get(pk=ticket_id)
        self.assertEqual(ticket.auteur, self.citoyen)
        self.assertEqual(ticket.statut, Ticket.Statut.OUVERT)

    # TEST 3 : FILTRAGE DES TICKETS PAR STATUT
    def test_list_filter_by_statut(self):
        ticket1 = Ticket.objects.create(
            titre='Ticket ouvert', description='Ouvert', type_ticket=Ticket.TypeTicket.INCIDENT,
            priorite=Ticket.Priorite.BASSE, auteur=self.citoyen, assigne_a=self.technicien, statut=Ticket.Statut.OUVERT
        )
        ticket2 = Ticket.objects.create(
            titre='Ticket résolu', description='Résolu', type_ticket=Ticket.TypeTicket.INCIDENT,
            priorite=Ticket.Priorite.BASSE, auteur=self.citoyen, statut=Ticket.Statut.RESOLU
        )

        self.authenticate(self.technicien)
        url = reverse('ticket-list') + '?statut=OUVERT'
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        returned_ids = [t['id'] for t in resp.data['results']]
        self.assertIn(ticket1.id, returned_ids)
        self.assertNotIn(ticket2.id, returned_ids)

    # TEST 4 : CHANGEMENT DE STATUT PAR TECHNICIEN AVEC HISTORIQUE
    def test_technicien_change_status_and_history_created(self):
        ticket = Ticket.objects.create(
            titre='Ticket pour traitement', description='...', type_ticket=Ticket.TypeTicket.INCIDENT,
            priorite=Ticket.Priorite.HAUTE, auteur=self.citoyen, assigne_a=self.technicien, statut=Ticket.Statut.OUVERT
        )

        self.authenticate(self.technicien)
        url = f"/api/tickets/{ticket.id}/changer_statut/"
        resp = self.client.patch(url, {'statut': Ticket.Statut.EN_COURS}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)

        ticket.refresh_from_db()
        self.assertEqual(ticket.statut, Ticket.Statut.EN_COURS)

        historique = HistoriqueStatut.objects.filter(ticket=ticket).first()
        self.assertIsNotNone(historique)
        self.assertEqual(historique.ancien_statut, Ticket.Statut.OUVERT)
        self.assertEqual(historique.nouveau_statut, Ticket.Statut.EN_COURS)
        self.assertEqual(historique.modifie_par, self.technicien)

        self.authenticate(self.citoyen)
        detail_url = reverse('ticket-detail', kwargs={'pk': ticket.id})
        resp = self.client.get(detail_url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data['statut'], Ticket.Statut.EN_COURS)

    # TEST 5 : CITOYEN NE PEUT PAS CHANGER LE STATUT
    def test_citoyen_cannot_change_status(self):
        ticket = Ticket.objects.create(
            titre='Ticket non autorisé', description='...', type_ticket=Ticket.TypeTicket.INCIDENT,
            priorite=Ticket.Priorite.NORMALE, auteur=self.citoyen, statut=Ticket.Statut.OUVERT
        )

        self.authenticate(self.citoyen)
        url = f"/api/tickets/{ticket.id}/changer_statut/"
        resp = self.client.patch(url, {'statut': Ticket.Statut.EN_COURS}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)

    # TEST 6 : RAFRAÎCHISSEMENT DE TOKEN JWT
    @override_settings(SIMPLE_JWT={'ACCESS_TOKEN_LIFETIME': timedelta(seconds=1), 'REFRESH_TOKEN_LIFETIME': timedelta(minutes=5), 'AUTH_HEADER_TYPES': ('Bearer',)})
    def test_refresh_token_flow(self):
        url_auth = reverse('token_obtain')
        resp = self.client.post(url_auth, {'email': self.citoyen.email, 'password': 'Test1234'}, format='json')
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        refresh_token = resp.data['refresh']

        import time
        time.sleep(2)

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {resp.data['access']}")
        resp2 = self.client.get(reverse('ticket-list'))
        self.assertIn(resp2.status_code, (status.HTTP_200_OK, status.HTTP_401_UNAUTHORIZED))

        url_refresh = reverse('token_refresh')
        resp_refresh = self.client.post(url_refresh, {'refresh': refresh_token}, format='json')
        self.assertEqual(resp_refresh.status_code, status.HTTP_200_OK)
        self.assertIn('access', resp_refresh.data)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {resp_refresh.data['access']}")
        resp3 = self.client.get(reverse('ticket-list'))
        self.assertEqual(resp3.status_code, status.HTTP_200_OK)


# TESTS DU TABLEAU DE BORD
class DashboardTests(APITestCase):
    
    # CRÉATION DES DONNÉES DE TEST
    def setUp(self):
        self.citoyen = CustomUser.objects.create_user(
            username='citoyen', email='citoyen@example.com', password='Test1234', role=CustomUser.Roles.CITOYEN
        )
        self.technicien = CustomUser.objects.create_user(
            username='technicien', email='tech@example.com', password='Test1234', role=CustomUser.Roles.TECHNICIEN
        )
        self.admin = CustomUser.objects.create_superuser(
            username='admin', email='admin@example.com', password='Test1234', role=CustomUser.Roles.ADMIN
        )
        
        self.ticket1 = Ticket.objects.create(
            titre='Ticket 1', description='...',
            type_ticket=Ticket.TypeTicket.INCIDENT, priorite=Ticket.Priorite.BASSE,
            auteur=self.citoyen, assigne_a=self.technicien, statut=Ticket.Statut.EN_COURS
        )
        self.ticket2 = Ticket.objects.create(
            titre='Ticket 2', description='...',
            type_ticket=Ticket.TypeTicket.RECLAMATION, priorite=Ticket.Priorite.HAUTE,
            auteur=self.citoyen, statut=Ticket.Statut.OUVERT
        )

    def authenticate(self, user):
        url = reverse('token_obtain')
        resp = self.client.post(url, {'email': user.email, 'password': 'Test1234'}, format='json')
        token = resp.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    # TEST DASHBOARD ADMIN
    def test_admin_dashboard(self):
        self.authenticate(self.admin)
        url = reverse('ticket-dashboard')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        
        data = resp.data
        self.assertEqual(data['role'], 'ADMIN')
        self.assertIn('total_tickets', data)
        self.assertIn('tickets_by_status', data)
        self.assertIn('total_users', data)
        self.assertIn('users_by_role', data)
        self.assertIn('recent_tickets', data)
        self.assertEqual(data['total_tickets'], 2)

    # TEST DASHBOARD TECHNICIEN
    def test_technicien_dashboard(self):
        self.authenticate(self.technicien)
        url = reverse('ticket-dashboard')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        
        data = resp.data
        self.assertEqual(data['role'], 'TECHNICIEN')
        self.assertIn('total_tickets_assignes', data)
        self.assertIn('my_tickets', data)
        self.assertEqual(data['total_tickets_assignes'], 1)
        self.assertEqual(data['my_tickets']['EN_COURS'], 1)

    # TEST DASHBOARD CITOYEN
    def test_citoyen_dashboard(self):
        self.authenticate(self.citoyen)
        url = reverse('ticket-dashboard')
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        
        data = resp.data
        self.assertEqual(data['role'], 'CITOYEN')
        self.assertIn('total_tickets', data)
        self.assertEqual(data['total_tickets'], 2)


# TESTS DE CRÉATION D'UTILISATEURS PAR ADMIN
class CreateUserTests(APITestCase):
    
    # CRÉATION DES UTILISATEURS DE TEST
    def setUp(self):
        self.admin = CustomUser.objects.create_superuser(
            username='admin', email='admin@example.com', password='Test1234', role=CustomUser.Roles.ADMIN
        )
        self.citoyen = CustomUser.objects.create_user(
            username='citoyen', email='citoyen@example.com', password='Test1234', role=CustomUser.Roles.CITOYEN
        )

    def authenticate(self, user):
        url = reverse('token_obtain')
        resp = self.client.post(url, {'email': user.email, 'password': 'Test1234'}, format='json')
        token = resp.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    # TEST : ADMIN PEUT CRÉER UN TECHNICIEN
    def test_admin_can_create_technicien(self):
        self.authenticate(self.admin)
        url = reverse('create_user')
        data = {
            'email': 'newtech@example.com',
            'username': 'newtech',
            'password': 'TechPass123',
            'first_name': 'Tech',
            'last_name': 'User',
            'role': 'TECHNICIEN',
        }
        resp = self.client.post(url, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['role'], 'TECHNICIEN')
        self.assertTrue(CustomUser.objects.filter(email='newtech@example.com').exists())

    # TEST : ADMIN PEUT CRÉER UN ADMIN
    def test_admin_can_create_admin(self):
        self.authenticate(self.admin)
        url = reverse('create_user')
        data = {
            'email': 'newadmin@example.com',
            'username': 'newadmin',
            'password': 'AdminPass123',
            'first_name': 'New',
            'last_name': 'Admin',
            'role': 'ADMIN',
        }
        resp = self.client.post(url, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(resp.data['role'], 'ADMIN')

    # TEST : CITOYEN NE PEUT PAS CRÉER D'UTILISATEUR
    def test_citoyen_cannot_create_user(self):
        self.authenticate(self.citoyen)
        url = reverse('create_user')
        data = {
            'email': 'another@example.com',
            'username': 'another',
            'password': 'Pass123',
            'first_name': 'Another',
            'last_name': 'User',
            'role': 'TECHNICIEN',
        }
        resp = self.client.post(url, data, format='json')
        self.assertEqual(resp.status_code, status.HTTP_403_FORBIDDEN)