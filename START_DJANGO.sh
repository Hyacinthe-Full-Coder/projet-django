#!/bin/bash

# Script pour démarrer Django correctement

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🚀 Démarrage du serveur Django"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Aller au répertoire Django
cd /home/mmm/Documents/projet-django/gestion_reclamations

# Activer l'environnement virtuel
source venv/bin/activate

# Tuer tout processus Django existant
echo "🛑 Arrêt de tous les serveurs Django existants..."
pkill -f "manage.py runserver" 2>/dev/null
sleep 2

# Lancer Django
echo "✅ Lancement de Django sur 0.0.0.0:8000..."
echo ""

python manage.py runserver 0.0.0.0:8000

# Les logs doivent s'afficher ici
# Ctrl+C pour arrêter
