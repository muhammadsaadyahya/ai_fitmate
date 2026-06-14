import firebase_admin
from firebase_admin import credentials
from django.conf import settings

_app = None


def get_firebase_app():
    global _app
    if _app is None:
        cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_KEY)
        _app = firebase_admin.initialize_app(cred)
    return _app
