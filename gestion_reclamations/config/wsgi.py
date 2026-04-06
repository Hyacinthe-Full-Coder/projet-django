"""
WSGI config for config project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/6.0/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application


# CONFIGURATION DES VARIABLES D'ENVIRONNEMENT
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

# POINT D'ENTRÉE WSGI POUR LE SERVEUR DE PRODUCTION
application = get_wsgi_application()