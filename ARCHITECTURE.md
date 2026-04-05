# 📋 Flux Application - Vue d'Ensemble Visuelle

## 🔄 User Journey Par Rôle

### ADMIN Journey
```
┌─────────────┐
│  LoginPage  │  bigglazer@gmail.com / pass1234
└──────┬──────┘
       │ POST /api/auth/login/ → JWT Tokens
       ▼
┌─────────────────────────────┐
│  HomeScreen (Routing Logic) │  getUserProfile() → role = ADMIN
└──────┬──────────────────────┘
       │
       ▼
┌───────────────────────────────────┐
│   AdminDashboardScreen            │
│ ┌─────────────────────────────┐   │
│ │ Welcome Card               │   │
│ │ Total Tickets: 12          │   │
│ │ By Status: OUVERT(5), ...  │   │
│ │ Users by Role: ADMIN(1)... │   │
│ │                             │   │
│ │ [Créer Utilisateur] [Stats] │   │
│ └─────────────────────────────┘   │
│                                   │
│ Actions:                          │
│  1. Click "Créer Utilisateur"     │
│  2. Navigate to CreateUserScreen  │
│  3. Select Role (TECHNICIEN/ADMIN)│
│  4. Fill Form + Submit            │
│  5. POST /api/auth/create-user/   │
│                                   │
│  → RefreshIndicator (Pull-Up)     │
│  → Logout (AppBar Button)         │
└───────────────────────────────────┘
       │
       └─────→ Dashboard Updates │
              with new user counts
```

### CITOYEN Journey
```
┌──────────────────┐
│  LoginPage       │
└────┬──────┬──────┘
     │      │
     │      └──→ [S'inscrire Link]
     │           │
     │           ▼
     │      ┌───────────────────────┐
     │      │  RegisterScreen       │
     │      │  Fill Form:           │
     │      │  - email              │
     │      │  - username           │
     │      │  - password (confirm) │
     │      │  - firstName          │
     │      │  - lastName           │
     │      │  - telephone          │
     │      │  [S'inscrire]         │
     │      │  POST /api/register/  │
     │      │  → Auto-redirect (2s) │
     │      └─────────┬─────────────┘
     │                └──→ Back to LoginPage
     │
     │ POST /api/auth/login/
     ▼
┌────────────────────────┐
│  HomeScreen            │
│  role = CITOYEN        │
└────┬───────────────────┘
     │
     ▼
┌────────────────────────────────────┐
│  TicketListScreen (CITOYEN)        │
│                                    │
│  [+ Créer Ticket Button]           │
│                                    │
│  ┌──────────────────────┐          │
│  │ Ticket #1            │          │
│  │ Title: Panne Eau     │          │
│  │ Status: EN_COURS     │          │
│  │ Priority: Haut       │          │
│  │ Type: Service        │          │
│  └──────────────────────┘          │
│                                    │
│  [Logout]                          │
└────────────────────────────────────┘

Actions Disponibles:
- View own tickets only
- Create new ticket
- View ticket details & comments
- Cannot change status
```

### TECHNICIEN Journey
```
┌─────────────────┐
│  LoginPage      │
│ (Created by     │
│  Admin via      │
│  createUser)    │
└────┬────────────┘
     │ POST /api/auth/login/
     ▼
┌────────────────────────┐
│  HomeScreen            │
│  role = TECHNICIEN     │
└────┬───────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  TechnicienDashboardScreen              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Tab 1: Dashboard (Selected)     │   │
│  │ Total Assigned: 8               │   │
│  │ EN_COURS: 5 | RESOLU: 2 | CLOS:1 │   │
│  │                                 │   │
│  │ Recent Tickets:                 │   │
│  │ • Panne Électricité (EN_COURS)  │   │
│  │ • Problème Routier (EN_COURS)   │   │
│  │ • Route Cassée (RESOLU)         │   │
│  └─────────────────────────────────┘   │
│                                         │
│ ┌──────────────────────────────────┐   │
│ │ Tab 2: Mes Tickets (BottomNav)   │   │
│ │ → TicketListScreen (filtered)    │   │
│ │   Show ASSIGNED tickets only     │   │
│ │   Can change status              │   │
│ └──────────────────────────────────┘   │
│                                         │
│ Actions:                                │
│ 1. View dashboard stats                │
│ 2. Switch to "Mes Tickets" tab         │
│ 3. Select ticket → Detail Screen       │
│ 4. Change Status:                      │
│    EN_COURS → RESOLU → CLOS            │
│ 5. PATCH /api/tickets/{id}/changer...  │
│                                         │
│ [Logout]                                │
└─────────────────────────────────────────┘
```

---

## 🔐 Authentication Flow

```
┌──────────────────────────────────────────────────────────┐
│                   AUTHENTICATION FLOW                     │
└──────────────────────────────────────────────────────────┘

User Input (Email/Password)
         │
         ▼
POST /api/auth/login/
    ├─ email: string
    ├─ password: string
    └─ role: auto-detected from DB
         │
         ├─ ✅ Valid Credentials
         │      │
         │      ▼
         │  Generate JWT Tokens
         │  ├─ Access Token (2h expiry)
         │  └─ Refresh Token (7d expiry)
         │      │
         │      ▼
         │  Store in SharedPreferences
         │  ├─ storage.save('access_token', token)
         │  ├─ storage.save('refresh_token', token)
         │      │
         │      ▼
         │  Return {access, refresh}
         │      │
         │      ▼
         │  Frontend Navigation
         │  └─ getUserProfile() → determine role
         │      └─ route to correct screen
         │
         └─ ❌ Invalid Credentials
            │
            ▼
         Return 401 Error
         ├─ Show error message
         ├─ Clear form
         └─ Allow retry

Token Usage:
┌─────────────────────────────────┐
│ All API Requests:               │
│ GET /api/tickets/               │
│ Header: Authorization: Bearer   │
│         {access_token}          │
│                                 │
│ If Token Expired:               │
│ → Auto-refresh using refresh_token
│ → Retry original request        │
│                                 │
│ If Refresh Expired:             │
│ → Logout                        │
│ → Redirect to LoginScreen       │
└─────────────────────────────────┘

Logout:
┌───────────────────────────────────┐
│ 1. clearTokens()                  │
│    ├─ storage.remove('access')    │
│    ├─ storage.remove('refresh')   │
│    └─ storage.remove('user_role') │
│ 2. Navigate to LoginScreen        │
│ 3. user = null (state reset)      │
└───────────────────────────────────┘
```

---

## 🛣️ Navigation Map

```
                    ┌─────────────────┐
                    │    LoginScreen  │◄────────┐
                    └────┬────────────┘         │
                         │                      │
          ┌──[S'inscrire]─┼─[Connexion]──┐     │
          │               │               │     │
          ▼               ▼               │     │
    ┌──────────────┐     │        ┌──────┴─────┴────┐
    │Register      │     │        │ HomeScreen      │
    │Screen        │     │        │ (Routing Logic) │
    │              │     │        └──┬──────┬───┬──┘
    │[S'inscrire]  │     │           │      │   │
    │→ auto-login  │     │      ┌────┘      │   └─────┐
    │→ LoginScreen◄──────┘      │           │         │
    └──────────────┘            │      CITOYEN   TECHNICIEN
                                │           │         │
                    ADMIN       │           │         │
                      │         │           │         │
                      ▼         ▼           ▼         ▼
            ┌──────────────────┐  ┌─────────────┐  ┌─────────────┐
            │Admin Dashboard   │  │Ticket List  │  │Technicien   │
            │Screen            │  │Screen       │  │Dashboard    │
            │                  │  │(CITOYEN)    │  │Screen       │
            │┌─────────────────┐  │             │  │             │
            ││  Stats Grid     │  │┌──────────┐ │  │┌──────────┐ │
            ││ [Créer User] ┐  │  ││Tickets   │▲│  ││Dashboard▼│ │
            │└──┬────────────│──┘  ││List      ││  ││┌────────┐││ │
            │   │            │     │└──────┬─┬─┘  │││  Stats ││ │ │
            │   │            │     │       │ │    │││┌──────┐││ │ │
            │   ▼            │     │       ▼ ▼    ││││Recent││ │ │
            │┌──────────────┐ │     │   ┌─────────┐│││ by   ││ │ │
            ││CreateUser    │ │     │   │Ticket   ││││Status││ │ │
            ││Screen        │ │     │   │Detail   │││└──────┘││ │ │
            ││•Email Form   │ │     │   │Screen   │││┌──────┐││ │ │
            ││•Role Select  │ │     │   │(View)   │││  Tab 2││ │ │
            ││•Post         │ │     │   │•Status  ││────────┘│ │ │
            ││              │ │     │   │•Comments││         │ │ │
            │└──────────────┘ │     │   │•History │││  Mes   │ │ │
            │                 │     │   └─────────┘││ Tickets│ │ │
            └─────────────────┘     │               └────────┘ │ │
                                    │                          │ │
                                    │ [Logout (any screen)]    │ │
                                    │◄─────────────────────────┘ │
                                    │
                                    └─→ Back to LoginScreen

[Créer Ticket]
            │
            ▼
    ┌──────────────────┐
    │CreateTicket      │
    │Screen (CITOYEN)  │
    │•Type, Priority   │
    │•Title, Desc      │
    │•Location         │
    │•Photos (opt)     │
    └─────┬────────────┘
          │ POST /api/tickets/
          ▼
    Returns to TicketListScreen
```

---

## 📡 API Call Sequence Map

```
┌──────────────────────────────────────────────────────────────┐
│                   REQUEST/RESPONSE SEQUENCE                    │
└──────────────────────────────────────────────────────────────┘

LOGIN FLOW:
  Frontend                          Backend
    │                                 │
    ├─────POST /auth/login/──────────►│
    │  {email, password}              │ (authenticate)
    │                                 │ (generate JWT)
    │◄────200 {access, refresh}───────┤
    │                                 │
    └─ Store tokens in SharedPrefs

GET PROFILE FLOW:
    │                                 │
    ├──GET /auth/profile/────────────►│
    │  Header: Bearer {access}        │ (validate token)
    │                                 │ (return user data)
    │◄──200 {email, role, ...}────────┤
    │

GET DASHBOARD FLOW:
    │                                 │
    ├──GET /tickets/dashboard/───────►│
    │  Header: Bearer {access}        │ (validate token)
    │                                 │ (role-based stats)
    │◄──200 {total_tickets, ...}──────┤
    │  {tickets_by_status: {...}}     │
    │  {users_by_role: {...}}         │
    │  {recent_tickets: [...]}        │

CREATE USER FLOW (ADMIN):
    │                                 │
    ├┬─POST /auth/create-user/───────►│
    ││ {email, password, role}        │ (check: is_admin?)
    ││ Header: Bearer {access}        │ (validate role ∈ ADMIN/TECH)
    ││                                │ (create CustomUser)
    ││◄──201 {email, role, ...}───────┤
    ││
    ││ (Error cases:)
    ││ 403 = Not Admin
    ││ 400 = Invalid role
    │

CREATE TICKET FLOW (CITOYEN):
    │                                 │
    ├─POST /tickets/─────────────────►│
    │ {title, description, ...}       │ (create Ticket)
    │ Header: Bearer {access}         │ (auto assigned_to=null)
    │                                 │ (auto created_by={user})
    │◄─201 {id, status: OUVERT, ...}─┤
    │

CHANGE STATUS FLOW (TECHNICIEN):
    │                                 │
    ├─PATCH /tickets/{id}/────────────►│
    │ changer_statut/                 │ (check: is_assigned?)
    │ {new_status}                    │ (validate status transition)
    │ Header: Bearer {access}         │ (update status)
    │                                 │ (create history)
    │◄─200 {id, status: RESOLU, ...}──┤
    │

LOGOUT FLOW:
    │                                 │
    ├─ Clear tokens (local storage)   │ (frontend only)
    ├─ Navigate to LoginScreen        │
    │                                 │
    (No backend logout call needed)   │
    (JWT is stateless)                │

ERROR HANDLING:

    401 Unauthorized:
    ├─ Token expired/invalid
    └─ Retry with refresh token

    403 Forbidden:
    ├─ User lacks permissions
    └─ Show error message

    400 Bad Request:
    ├─ Invalid input data
    └─ Show validation errors

    500 Server Error:
    ├─ Backend error
    └─ Show error message + retry option
```

---

## 💾 Data Storage

```
┌──────────────────────────────────────────────┐
│         FRONTEND (Flutter)                   │
│         SharedPreferences                    │
├──────────────────────────────────────────────┤
│ access_token       │ JWT (2h expiry)         │
│ refresh_token      │ JWT (7d expiry)         │
│ user_id            │ int                     │
│ user_role          │ ADMIN/TECHNICIEN/...   │
│ user_email         │ string                 │
└──────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│              BACKEND (Django + PostgreSQL)             │
├────────────────────────────────────────────────────────┤
│ CustomUser                                             │
│ ├─ id (PK)                                             │
│ ├─ email (unique)                                      │
│ ├─ password (hashed)                                   │
│ ├─ role (ADMIN/TECHNICIEN/CITOYEN)                    │
│ ├─ first_name                                          │
│ ├─ last_name                                           │
│ └─ telephone                                           │
│                                                        │
│ Ticket                                                 │
│ ├─ id (PK)                                             │
│ ├─ title                                               │
│ ├─ description                                         │
│ ├─ status (OUVERT/EN_COURS/RESOLU/CLOS)              │
│ ├─ type (Service/Signalement/etc)                     │
│ ├─ priority (Bas/Moyen/Haut)                          │
│ ├─ created_by (FK CustomUser)                         │
│ ├─ assigned_to (FK CustomUser, nullable)              │
│ ├─ created_at (timestamp)                             │
│ └─ updated_at (timestamp)                             │
│                                                        │
│ Commentaire                                            │
│ ├─ id (PK)                                             │
│ ├─ ticket (FK Ticket)                                 │
│ ├─ author (FK CustomUser)                             │
│ ├─ content (text)                                      │
│ └─ created_at (timestamp)                             │
│                                                        │
│ HistoriqueStatut                                       │
│ ├─ id (PK)                                             │
│ ├─ ticket (FK Ticket)                                 │
│ ├─ old_status                                          │
│ ├─ new_status                                          │
│ ├─ changed_by (FK CustomUser)                         │
│ └─ changed_at (timestamp)                             │
└────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Component Hierarchy

```
MaterialApp
├── home: SplashScreen / LoginScreen (initial)
│
├── routes: MaterialPageRoute
│   ├── LoginScreen
│   │   └── TextField x2, Button, Link(RegisterScreen)
│   │
│   ├── RegisterScreen
│   │   └── Form > TextFormField x6, Button
│   │
│   ├── HomeScreen
│   │   └── FutureBuilder → route by role
│   │
│   ├── AdminDashboardScreen (role=ADMIN)
│   │   ├── AppBar(logout)
│   │   ├── RefreshIndicator
│   │   ├── SingleChildScrollView
│   │   │   ├── Container(welcome)
│   │   │   ├── _buildStatCard() x1
│   │   │   ├── _buildTicketStatsGrid()
│   │   │   ├── _buildUserStatsGrid()
│   │   │   └── GridView > _buildAdminCard() x2
│   │   │
│   │   ├── CreateUserScreen (nested)
│   │   │   └── Form > DropdownFormField(role) + TextFormField x6
│   │   │
│   │   └── StatisticsScreen (nested)
│   │       └── Chart widgets + tables
│   │
│   ├── TechnicienDashboardScreen (role=TECHNICIEN)
│   │   ├── AppBar(logout)
│   │   ├── RefreshIndicator
│   │   ├── TabBar (2 tabs)
│   │   │   ├── Tab 1: Dashboard
│   │   │   │   ├── _buildStatCard() x3
│   │   │   │   └── ListView > TicketTile
│   │   │   │
│   │   │   └── Tab 2: Mes Tickets
│   │   │       └── TicketListScreen
│   │   │
│   │   └── BottomNavigationBar
│   │
│   ├── TicketListScreen (role=CITOYEN, TECHNICIEN)
│   │   ├── FloatingActionButton (citoyen only)
│   │   ├── ListView > TicketCard
│   │   └── RefreshIndicator
│   │
│   ├── TicketDetailScreen
│   │   ├── Card(ticket info)
│   │   ├── ListView(comments)
│   │   ├── TextFormField(new comment)
│   │   └── Button(change status, tech only)
│   │
│   └── CreateTicketScreen
│       └── Form > Dropdown + TextFormField x4 + Image picker
│
└── Widgets
    ├── TicketCard (title, status, priority, type)
    │   └── Custom colors by status
    │
    └── Theme
        ├── primaryColor: #006743 (green)
        ├── Material3 Design
        └── Responsive layout
```

---

**Generated**: Implementation Summary  
**Status**: ✅ Complete & Ready for Testing
