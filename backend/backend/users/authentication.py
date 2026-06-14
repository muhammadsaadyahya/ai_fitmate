from firebase_admin import auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from fitmate.firebase import get_firebase_app


class FirebaseUser:
    """Minimal user object populated from a verified Firebase ID token."""

    def __init__(self, decoded_token):
        self.uid = decoded_token['uid']
        self.email = decoded_token.get('email', '')
        self.name = decoded_token.get('name', '')
        self.is_authenticated = True
        self.is_active = True

    def __str__(self):
        return self.email or self.uid


class FirebaseAuthentication(BaseAuthentication):
    """Authenticate requests using a Firebase ID token in the Authorization header."""

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return None

        id_token = auth_header.split('Bearer ')[1].strip()
        if not id_token:
            return None

        get_firebase_app()
        try:
            decoded_token = auth.verify_id_token(id_token)
        except auth.ExpiredIdTokenError:
            raise AuthenticationFailed('Firebase token has expired.')
        except auth.InvalidIdTokenError:
            raise AuthenticationFailed('Invalid Firebase token.')
        except Exception as e:
            raise AuthenticationFailed(f'Firebase authentication failed: {e}')

        return (FirebaseUser(decoded_token), id_token)

    def authenticate_header(self, request):
        return 'Bearer realm="Firebase"'
