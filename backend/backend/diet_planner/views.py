from firebase_admin import firestore
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, timezone

from fitmate.firebase import get_firebase_app
from .serializers import DietGenerateSerializer
from .utils import generate_diet_plan


def _db():
    get_firebase_app()
    return firestore.client()


class GenerateDietPlanView(APIView):
    """
    POST /api/diet/generate/
    Calculates TDEE from user metrics, generates an AI meal plan via Groq,
    stores it in Firestore, and returns it.

    Request body (all optional — missing fields pulled from Firestore profile):
        {
            "fitness_goal": "weight_loss",
            "activity_level": "moderately_active",
            "gender": "male",
            "age": 25,
            "weight_kg": 80,
            "height_cm": 175
        }
    """

    def post(self, request):
        serializer = DietGenerateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        overrides = serializer.validated_data

        uid = request.user.uid

        # Merge overrides with saved Firestore profile
        profile_doc = _db().collection('users').document(uid).get()
        profile = profile_doc.to_dict() if profile_doc.exists else {}

        fitness_goal = overrides.get('fitness_goal') or profile.get('fitness_goal')
        activity_level = overrides.get('activity_level') or profile.get('activity_level')
        gender = overrides.get('gender') or profile.get('gender')
        age = overrides.get('age') or profile.get('age')
        weight_kg = overrides.get('weight_kg') or profile.get('weight_kg')
        height_cm = overrides.get('height_cm') or profile.get('height_cm')

        missing = [
            field for field, val in [
                ('fitness_goal', fitness_goal),
                ('activity_level', activity_level),
                ('gender', gender),
                ('age', age),
                ('weight_kg', weight_kg),
                ('height_cm', height_cm),
            ] if not val
        ]
        if missing:
            return Response(
                {'detail': f'Missing required fields: {", ".join(missing)}. '
                           'Provide them in the request body or save them to your profile first.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            plan = generate_diet_plan(
                goal=fitness_goal,
                activity_level=activity_level,
                gender=gender,
                age=int(age),
                weight_kg=float(weight_kg),
                height_cm=float(height_cm),
            )
        except Exception as e:
            return Response(
                {'detail': f'Diet plan generation failed: {e}'},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        plan['uid'] = uid
        plan['created_at'] = datetime.now(timezone.utc).isoformat()

        ref = _db().collection('diet_plans').add(plan)
        plan['id'] = ref[1].id

        return Response(plan, status=status.HTTP_201_CREATED)


class DietPlanView(APIView):
    """
    GET /api/diet/plan/            — fetch the most recent diet plan.
    GET /api/diet/plan/?all=true   — fetch all diet plans.
    """

    def get(self, request):
        uid = request.user.uid
        query = (
            _db()
            .collection('diet_plans')
            .where('uid', '==', uid)
            .order_by('created_at', direction=firestore.Query.DESCENDING)
        )

        if request.query_params.get('all') == 'true':
            docs = query.stream()
            return Response([d.to_dict() | {'id': d.id} for d in docs])

        doc = next(query.limit(1).stream(), None)
        if doc is None:
            return Response({'detail': 'No diet plan found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(doc.to_dict() | {'id': doc.id})


class MealLogView(APIView):
    """
    POST /api/diet/meals/ — log a meal entry.
    GET  /api/diet/meals/ — list recent meal logs.
    """

    def post(self, request):
        uid = request.user.uid
        data = dict(request.data)
        data['uid'] = uid
        data['logged_at'] = datetime.now(timezone.utc).isoformat()
        ref = _db().collection('meal_logs').add(data)
        return Response({'id': ref[1].id}, status=status.HTTP_201_CREATED)

    def get(self, request):
        uid = request.user.uid
        docs = (
            _db()
            .collection('meal_logs')
            .where('uid', '==', uid)
            .order_by('logged_at', direction=firestore.Query.DESCENDING)
            .limit(20)
            .stream()
        )
        return Response([d.to_dict() | {'id': d.id} for d in docs])
