-- ============================================================================
-- SCRIPT SQL - CRÉATION DES TABLES POUR LE PROJET GESTION DES RECLAMATIONS
-- Base de données: PostgreSQL
-- ============================================================================

-- 1. TABLE AUTH_USER (ÉTENDUE PAR CUSTOMUSER)
-- ============================================================================
CREATE TABLE IF NOT EXISTS accounts_customuser (
    id SERIAL PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    is_superuser BOOLEAN DEFAULT FALSE,
    username VARCHAR(150) NOT NULL UNIQUE,
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    email VARCHAR(254) NOT NULL UNIQUE,
    is_staff BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    date_joined TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role VARCHAR(15) NOT NULL DEFAULT 'CITOYEN' CHECK (role IN ('CITOYEN', 'TECHNICIEN', 'ADMIN')),
    telephone VARCHAR(20)
);

-- 2. TABLE TICKETS (TICKETS PRINCIPAUX)
-- ============================================================================
CREATE TABLE IF NOT EXISTS tickets_ticket (
    id SERIAL PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    type_ticket VARCHAR(15) NOT NULL DEFAULT 'INCIDENT' CHECK (type_ticket IN ('INCIDENT', 'RECLAMATION', 'DEMANDE')),
    statut VARCHAR(10) NOT NULL DEFAULT 'OUVERT' CHECK (statut IN ('OUVERT', 'EN_COURS', 'RESOLU', 'CLOS')),
    priorite VARCHAR(10) NOT NULL DEFAULT 'NORMALE' CHECK (priorite IN ('BASSE', 'NORMALE', 'HAUTE', 'CRITIQUE')),
    auteur_id INTEGER NOT NULL,
    assigne_a_id INTEGER,
    date_creation TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_resolution TIMESTAMP WITH TIME ZONE,
    est_archive BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (auteur_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE,
    FOREIGN KEY (assigne_a_id) REFERENCES accounts_customuser(id) ON DELETE SET NULL
);

-- 3. TABLE COMMENTAIRES (COMMENTAIRES SUR LES TICKETS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS tickets_commentaire (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    auteur_id INTEGER NOT NULL,
    contenu TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets_ticket(id) ON DELETE CASCADE,
    FOREIGN KEY (auteur_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE
);

-- 4. TABLE HISTORIQUE STATUT (HISTORIQUE DES CHANGEMENTS DE STATUT)
-- ============================================================================
CREATE TABLE IF NOT EXISTS tickets_historiquestatut (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    modifie_par_id INTEGER,
    ancien_statut VARCHAR(10) NOT NULL,
    nouveau_statut VARCHAR(10) NOT NULL,
    date_changement TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets_ticket(id) ON DELETE CASCADE,
    FOREIGN KEY (modifie_par_id) REFERENCES accounts_customuser(id) ON DELETE SET NULL
);

-- 5. TABLE NOTIFICATIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS tickets_notification (
    id SERIAL PRIMARY KEY,
    destinataire_id INTEGER NOT NULL,
    createur_id INTEGER,
    ticket_id INTEGER NOT NULL,
    type_notification VARCHAR(20) NOT NULL CHECK (type_notification IN ('NOUVELLEMENT_ASSIGNE', 'STATUT_CHANGE', 'NOUVEAU_COMMENTAIRE', 'TICKET_RESOLU', 'TICKET_CLOS', 'SYSTEME')),
    titre VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    donnees_supplementaires JSONB,
    est_lue BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (destinataire_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE,
    FOREIGN KEY (createur_id) REFERENCES accounts_customuser(id) ON DELETE SET NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets_ticket(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLES DJANGO STANDARD (REQUISES)
-- ============================================================================

-- 6. TABLE DJANGO_CONTENT_TYPE (TYPES DE CONTENU)
-- ============================================================================
CREATE TABLE IF NOT EXISTS django_content_type (
    id SERIAL PRIMARY KEY,
    app_label VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    UNIQUE(app_label, model)
);

-- 7. TABLE AUTH_GROUP (GROUPES D'UTILISATEURS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS auth_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

-- 8. TABLE AUTH_PERMISSION (PERMISSIONS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS auth_permission (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    content_type_id INTEGER NOT NULL,
    codename VARCHAR(100) NOT NULL,
    UNIQUE(content_type_id, codename),
    FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) ON DELETE CASCADE
);

-- 9. TABLE AUTH_GROUP_PERMISSIONS (PERMISSIONS PAR GROUPE)
-- ============================================================================
CREATE TABLE IF NOT EXISTS auth_group_permissions (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    UNIQUE(group_id, permission_id),
    FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES auth_permission(id) ON DELETE CASCADE
);

-- 10. TABLE ACCOUNTS_CUSTOMUSER_GROUPS
-- ============================================================================
CREATE TABLE IF NOT EXISTS accounts_customuser_groups (
    id SERIAL PRIMARY KEY,
    customuser_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    UNIQUE(customuser_id, group_id),
    FOREIGN KEY (customuser_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE,
    FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE
);

-- 11. TABLE ACCOUNTS_CUSTOMUSER_USER_PERMISSIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS accounts_customuser_user_permissions (
    id SERIAL PRIMARY KEY,
    customuser_id INTEGER NOT NULL,
    permission_id INTEGER NOT NULL,
    UNIQUE(customuser_id, permission_id),
    FOREIGN KEY (customuser_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES auth_permission(id) ON DELETE CASCADE
);

-- 12. TABLE AUTHTOKEN_TOKEN (TOKENS D'AUTHENTIFICATION)
-- ============================================================================
CREATE TABLE IF NOT EXISTS authtoken_token (
    key VARCHAR(40) PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE
);

-- 13. TABLE DJANGO_ADMIN_LOG (LOG D'ADMINISTRATION)
-- ============================================================================
CREATE TABLE IF NOT EXISTS django_admin_log (
    id SERIAL PRIMARY KEY,
    action_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER NOT NULL,
    content_type_id INTEGER,
    object_id TEXT,
    object_repr VARCHAR(200),
    action_flag SMALLINT NOT NULL,
    change_message TEXT,
    FOREIGN KEY (user_id) REFERENCES accounts_customuser(id) ON DELETE CASCADE,
    FOREIGN KEY (content_type_id) REFERENCES django_content_type(id) ON DELETE SET NULL
);

-- 14. TABLE DJANGO_MIGRATIONS (SUIVI DES MIGRATIONS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS django_migrations (
    id SERIAL PRIMARY KEY,
    app VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    applied TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 15. TABLE DJANGO_SESSION (SESSIONS UTILISATEUR)
-- ============================================================================
CREATE TABLE IF NOT EXISTS django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date TIMESTAMP WITH TIME ZONE NOT NULL
);

-- ============================================================================
-- CRÉATION DES INDEX POUR OPTIMISER LES REQUÊTES
-- ============================================================================

-- Index sur les clés étrangères
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_auteur ON tickets_ticket(auteur_id);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_assigne ON tickets_ticket(assigne_a_id);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_statut ON tickets_ticket(statut);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_type ON tickets_ticket(type_ticket);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_priorite ON tickets_ticket(priorite);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_date_creation ON tickets_ticket(date_creation);
CREATE INDEX IF NOT EXISTS idx_tickets_ticket_est_archive ON tickets_ticket(est_archive);

CREATE INDEX IF NOT EXISTS idx_tickets_commentaire_ticket ON tickets_commentaire(ticket_id);
CREATE INDEX IF NOT EXISTS idx_tickets_commentaire_auteur ON tickets_commentaire(auteur_id);

CREATE INDEX IF NOT EXISTS idx_tickets_historiquestatut_ticket ON tickets_historiquestatut(ticket_id);
CREATE INDEX IF NOT EXISTS idx_tickets_historiquestatut_date ON tickets_historiquestatut(date_changement);

CREATE INDEX IF NOT EXISTS idx_tickets_notification_destinataire ON tickets_notification(destinataire_id);
CREATE INDEX IF NOT EXISTS idx_tickets_notification_ticket ON tickets_notification(ticket_id);
CREATE INDEX IF NOT EXISTS idx_tickets_notification_lue ON tickets_notification(est_lue);
CREATE INDEX IF NOT EXISTS idx_tickets_notification_date ON tickets_notification(date_creation);

CREATE INDEX IF NOT EXISTS idx_auth_permission_content_type ON auth_permission(content_type_id);
CREATE INDEX IF NOT EXISTS idx_django_admin_log_user ON django_admin_log(user_id);
CREATE INDEX IF NOT EXISTS idx_django_session_expire ON django_session(expire_date);

-- ============================================================================
-- INSERTION DES DONNÉES INITIALES (OPTIONNEL)
-- ============================================================================

-- Insertion du django_migrations (pour que Django reconnaisse la structure)
INSERT INTO django_migrations (app, name, applied) VALUES
    ('contenttypes', '0001_initial', CURRENT_TIMESTAMP),
    ('contenttypes', '0002_remove_content_type_name', CURRENT_TIMESTAMP),
    ('auth', '0001_initial', CURRENT_TIMESTAMP),
    ('auth', '0002_alter_permission_options', CURRENT_TIMESTAMP),
    ('auth', '0003_alter_user_email_max_length', CURRENT_TIMESTAMP),
    ('auth', '0004_alter_user_username_opts', CURRENT_TIMESTAMP),
    ('auth', '0005_alter_user_last_login_null', CURRENT_TIMESTAMP),
    ('auth', '0006_require_contenttypes_0002', CURRENT_TIMESTAMP),
    ('auth', '0007_alter_validators_add_error_messages', CURRENT_TIMESTAMP),
    ('auth', '0008_alter_user_username_max_length', CURRENT_TIMESTAMP),
    ('auth', '0009_alter_user_last_name_max_length', CURRENT_TIMESTAMP),
    ('auth', '0010_alter_group_name_max_length', CURRENT_TIMESTAMP),
    ('auth', '0011_update_proxy_permissions', CURRENT_TIMESTAMP),
    ('auth', '0012_alter_user_first_name_max_length', CURRENT_TIMESTAMP),
    ('default', '0001_initial', CURRENT_TIMESTAMP),
    ('authtoken', '0001_initial', CURRENT_TIMESTAMP),
    ('authtoken', '0002_auto_20160226_1747', CURRENT_TIMESTAMP),
    ('sessions', '0001_initial', CURRENT_TIMESTAMP),
    ('admin', '0001_initial', CURRENT_TIMESTAMP),
    ('admin', '0002_logentry_remove_auto_add', CURRENT_TIMESTAMP),
    ('admin', '0003_logentry_add_user_null_and_delete', CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================
