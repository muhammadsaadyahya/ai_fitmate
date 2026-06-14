from pathlib import Path
import os
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parent.parent / '.env'
print("LOADING .env FROM:", env_path)

load_dotenv(Path(__file__).resolve().parent.parent / '.env')

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'changeme-in-production')

DEBUG = os.getenv('DEBUG', 'True') == 'True'

ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '192.168.1.5,localhost,127.0.0.1,').split(',')

print("ACTIVE SETTINGS FILE LOADED")
ALLOWED_HOSTS=['192.168.1.5']
print("ALLOWED_HOSTS =", ALLOWED_HOSTS)

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third-party
    'rest_framework',
    'corsheaders',
    # Local apps
    'users',
    'workout_planner',
    'diet_planner',
    'chatbot',
    'analytics',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'fitmate.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'fitmate.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True
STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ── Django REST Framework ──────────────────────────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'users.authentication.FirebaseAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# ── CORS ───────────────────────────────────────────────────────────────────────
# CORS_ALLOWED_ORIGINS = os.getenv(
#     'CORS_ALLOWED_ORIGINS',
#     'http://localhost:3000,http://localhost:8080'
# ).split(',')
# CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = True

# ── Firebase ───────────────────────────────────────────────────────────────────
_env_firebase_key = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY', '')
if _env_firebase_key and os.path.isabs(_env_firebase_key):
    FIREBASE_SERVICE_ACCOUNT_KEY = _env_firebase_key
elif _env_firebase_key:
    FIREBASE_SERVICE_ACCOUNT_KEY = str(BASE_DIR / _env_firebase_key)
else:
    FIREBASE_SERVICE_ACCOUNT_KEY = str(BASE_DIR / 'serviceAccountkey.json')

FIREBASE_WEB_API_KEY = os.getenv('FIREBASE_WEB_API_KEY', '')

# ── Groq (Chatbot) ─────────────────────────────────────────────────────────────
GROQ_API_KEY = os.getenv('GROQ_API_KEY', '')

# ── Gemini (Workout & Diet Planner) ───────────────────────────────────────────
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
