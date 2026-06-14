from firebase_admin import firestore
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, timezone

from fitmate.firebase import get_firebase_app
from .serializers import WorkoutGenerateSerializer
from .utils import generate_workout_plan


def _db():
    get_firebase_app()
    return firestore.client()


class GenerateWorkoutPlanView(APIView):
    """
    POST /api/workout/generate/
    Generates an AI workout plan via Groq, stores it in Firestore, and returns it.

    Request body (all optional — missing fields are pulled from Firestore profile):
        {
            "fitness_goal": "weight_loss",
            "activity_level": "moderately_active",
            "weight_kg": 80,
            "height_cm": 175,
            "duration_weeks": 4
        }
    """

    def post(self, request):
        serializer = WorkoutGenerateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        overrides = serializer.validated_data

        uid = request.user.uid

        # Fetch saved profile from Firestore to fill any missing fields
        profile_doc = _db().collection('users').document(uid).get()
        profile = profile_doc.to_dict() if profile_doc.exists else {}

        fitness_goal = overrides.get('fitness_goal') or profile.get('fitness_goal')
        activity_level = overrides.get('activity_level') or profile.get('activity_level')
        weight_kg = overrides.get('weight_kg') or profile.get('weight_kg')
        height_cm = overrides.get('height_cm') or profile.get('height_cm')
        duration_weeks = overrides.get('duration_weeks', 4)

        missing = [
            field for field, val in [
                ('fitness_goal', fitness_goal),
                ('activity_level', activity_level),
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
            plan = generate_workout_plan(
                goal=fitness_goal,
                activity_level=activity_level,
                weight_kg=float(weight_kg),
                height_cm=float(height_cm),
                duration_weeks=duration_weeks,
            )
        except Exception as e:
            return Response(
                {'detail': f'Plan generation failed: {e}'},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        plan['uid'] = uid
        plan['created_at'] = datetime.now(timezone.utc).isoformat()

        ref = _db().collection('workout_plans').add(plan)
        plan['id'] = ref[1].id

        return Response(plan, status=status.HTTP_201_CREATED)


class WorkoutPlanView(APIView):
    """
    GET  /api/workout/plan/   — fetch the user's most recent plan.
    GET  /api/workout/plan/?all=true — fetch all plans.
    """

    def get(self, request):
        uid = request.user.uid
        query = (
            _db()
            .collection('workout_plans')
            .where('uid', '==', uid)
            .order_by('created_at', direction=firestore.Query.DESCENDING)
        )

        if request.query_params.get('all') == 'true':
            docs = query.stream()
            plans = [d.to_dict() | {'id': d.id} for d in docs]
            return Response(plans)

        doc = next(query.limit(1).stream(), None)
        if doc is None:
            return Response({'detail': 'No workout plan found.'}, status=status.HTTP_404_NOT_FOUND)
        return Response(doc.to_dict() | {'id': doc.id})


class WorkoutSessionView(APIView):
    """
    POST /api/workout/sessions/ — log a completed workout session.
    GET  /api/workout/sessions/ — list recent sessions.
    """

    def post(self, request):
        uid = request.user.uid
        data = dict(request.data)
        data['uid'] = uid
        data['logged_at'] = datetime.now(timezone.utc).isoformat()
        ref = _db().collection('workout_sessions').add(data)
        return Response({'id': ref[1].id}, status=status.HTTP_201_CREATED)

    def get(self, request):
        uid = request.user.uid
        docs = (
            _db()
            .collection('workout_sessions')
            .where('uid', '==', uid)
            .order_by('logged_at', direction=firestore.Query.DESCENDING)
            .limit(20)
            .stream()
        )
        return Response([d.to_dict() | {'id': d.id} for d in docs])
