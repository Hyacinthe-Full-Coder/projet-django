#!/usr/bin/env bash
# Script de démarrage simultané pour le backend Django et le frontend Flutter.
# Usage : ./run_servers.sh
# Ensuite, ouvrir :
# - Backend : http://127.0.0.1:8000
# - Frontend : http://127.0.0.1:8100

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DJANGO_ROOT="$PROJECT_ROOT/gestion_reclamations"
FLUTTER_ROOT="$PROJECT_ROOT/reclamation_app"

# 1) Backend Django
echo "[run_servers] Démarrage backend Django..."
# Use absolute python binary from venv
DJANGO_PYTHON="$DJANGO_ROOT/venv/bin/python"
if [[ ! -x "$DJANGO_PYTHON" ]]; then
  echo "Erreur : python introuvable dans $DJANGO_ROOT/venv/bin/python"
  exit 1
fi

# 2) Flutter web
echo "[run_servers] Démarrage frontend Flutter..."

# Lance les deux serveurs en arrière-plan et garde le PID pour la fermeture propre.
"$DJANGO_PYTHON" "$DJANGO_ROOT/manage.py" runserver 0.0.0.0:8000 > "$PROJECT_ROOT/django.log" 2>&1 &
DJANGO_PID=$!

pushd "$FLUTTER_ROOT" >/dev/null
flutter run -d web-server --web-port=8100 --web-hostname=0.0.0.0 > "$PROJECT_ROOT/flutter.log" 2>&1 &
FLUTTER_PID=$!
popd >/dev/null

echo "[run_servers] Backend Django PID=$DJANGO_PID, frontend Flutter PID=$FLUTTER_PID"
echo "[run_servers] Logs: $PROJECT_ROOT/django.log, $PROJECT_ROOT/flutter.log"

echo "[run_servers] CTRL+C pour stopper."

trap 'echo "[run_servers] Arrêt..."; kill $DJANGO_PID $FLUTTER_PID; exit 0' INT TERM

# Attendre indéfiniment (la commande est interactive pour Flutter) pour process management.
while true; do sleep 1; done
