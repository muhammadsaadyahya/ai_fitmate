import requests as http_requests
from firebase_admin import auth, firestore
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.conf import settings

from fitmate.firebase import get_firebase_app
from .serializers import SignupSerializer, LoginSerializer, UserProfileSerializer


def _db():
    get_firebase_app()
    return firestore.client()


class SignupView(APIView):
    """
    POST /api/users/signup/
    Creates a new Firebase Auth user and saves their profile to Firestore.

    Request body:
        { "email": "...", "password": "...", "name": "..." }

    Response:
        201 { "uid": "...", "email": "...", "name": "..." }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        # Create user in Firebase Auth
        get_firebase_app()
        try:
            firebase_user = auth.create_user(
                email=data['email'],
                password=data['password'],
                display_name=data['name'],
            )
        except auth.EmailAlreadyExistsError:
            return Response(
                {'email': 'An account with this email already exists.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # Save profile to Firestore
        profile = {
            'uid': firebase_user.uid,
            'email': data['email'],
            'name': data['name'],

            # Dashboard stats
            'activeStreak': 0,
            'todayCalories': 0,
            'caloriesGoal': 2000,
            'weeklyMinutes': 0,
            'minutesTarget': 180,
            'overallProgress': 0,
            'profileImage': 'lib/images/profilepic.jpeg',


        }
        _db().collection('users').document(firebase_user.uid).set(profile)

        return Response(profile, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    """
    POST /api/users/login/
    Signs in with email & password via Firebase REST API and returns an idToken.
    The client must include this idToken as 'Bearer <idToken>' on all protected requests.

    Request body:
        { "email": "...", "password": "..." }

    Response:
        200 { "uid": "...", "email": "...", "idToken": "...", "refreshToken": "...", "expiresIn": "3600" }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        api_key = settings.FIREBASE_WEB_API_KEY
        if not api_key:
            return Response(
                {'detail': 'FIREBASE_WEB_API_KEY is not configured.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        url = f'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}'
        payload = {
            'email': data['email'],
            'password': data['password'],
            'returnSecureToken': True,
        }

        try:
            resp = http_requests.post(url, json=payload, timeout=10)
            resp_data = resp.json()
        except Exception as e:
            return Response({'detail': f'Firebase request failed: {e}'}, status=status.HTTP_502_BAD_GATEWAY)

        if resp.status_code != 200:
            error_message = resp_data.get('error', {}).get('message', 'Login failed.')
            # Make Firebase error messages user-friendly
            friendly = {
                'EMAIL_NOT_FOUND': 'No account found with this email.',
                'INVALID_PASSWORD': 'Incorrect password.',
                'USER_DISABLED': 'This account has been disabled.',
                'INVALID_LOGIN_CREDENTIALS': 'Invalid email or password.',
            }
            return Response(
                {'detail': friendly.get(error_message, error_message)},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        return Response({
            'uid': resp_data.get('localId'),
            'email': resp_data.get('email'),
            'idToken': resp_data.get('idToken'),
            'refreshToken': resp_data.get('refreshToken'),
            'expiresIn': resp_data.get('expiresIn'),
        })


class ProfileView(APIView):
    """
    GET  /api/users/profile/  — fetch the authenticated user's full profile from Firestore.
    PUT  /api/users/profile/  — update profile fields (partial update supported).

    All requests require: Authorization: Bearer <idToken>
    """

    def get(self, request):
        user = request.user
        doc = _db().collection('users').document(user.uid).get()
        data = doc.to_dict() if doc.exists else {}
        data.update({'uid': user.uid, 'email': user.email})
        return Response(data)

    def put(self, request):
        user = request.user
        serializer = UserProfileSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        _db().collection('users').document(user.uid).set(
            serializer.validated_data, merge=True
        )
        # Return the full updated profile
        doc = _db().collection('users').document(user.uid).get()
        data = doc.to_dict() if doc.exists else {}
        data.update({'uid': user.uid, 'email': user.email})
        return Response(data)


class SetTargetView(APIView):
    """
    PUT /api/users/set-targets/

    Updates user fitness targets.

    Request body:
    {
        "caloriesGoal": 2500,
        "minutesTarget": 200
    }
    """

    def put(self, request):
        user = request.user

        calories_goal = request.data.get("caloriesGoal")
        minutes_target = request.data.get("minutesTarget")

        update_data = {}

        # Validate calories goal
        if calories_goal is not None:
            try:
                calories_goal = int(calories_goal)

                if calories_goal <= 0:
                    return Response(
                        {"detail": "Calories goal must be greater than 0."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                update_data["caloriesGoal"] = calories_goal

            except ValueError:
                return Response(
                    {"detail": "Invalid caloriesGoal value."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        # Validate minutes target
        if minutes_target is not None:
            try:
                minutes_target = int(minutes_target)

                if minutes_target <= 0:
                    return Response(
                        {"detail": "Minutes target must be greater than 0."},
                        status=status.HTTP_400_BAD_REQUEST,
                    )

                update_data["minutesTarget"] = minutes_target

            except ValueError:
                return Response(
                    {"detail": "Invalid minutesTarget value."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        if not update_data:
            return Response(
                {"detail": "No valid target fields provided."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Update Firestore
        _db().collection('users').document(user.uid).set(
            update_data,
            merge=True
        )

        # Return updated profile
        doc = _db().collection('users').document(user.uid).get()
        data = doc.to_dict() if doc.exists else {}

        data.update({
            'uid': user.uid,
            'email': user.email,
        })

        return Response(data, status=status.HTTP_200_OK)