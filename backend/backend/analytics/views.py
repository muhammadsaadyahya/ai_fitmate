from collections import defaultdict
from datetime import datetime, timezone, timedelta

from firebase_admin import firestore
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from fitmate.firebase import get_firebase_app
from .serializers import WorkoutLogSerializer


def _db():
    get_firebase_app()
    return firestore.client()


def _all_history(uid: str) -> list[dict]:
    """
    Fetch all workoutHistory docs for a user.
    Sorting is done in Python to avoid requiring a Firestore composite index.
    """
    docs = (
        _db()
        .collection('workoutHistory')
        .where('uid', '==', uid)
        .stream()
    )
    entries = [d.to_dict() | {'id': d.id} for d in docs]
    return sorted(entries, key=lambda x: x.get('date', ''))


class WorkoutLogView(APIView):
    """
    POST /api/analytics/log/                         — log a workout to workoutHistory.
    GET  /api/analytics/log/                         — list all entries (newest first).
    GET  /api/analytics/log/?exercise=Push-ups       — filter by exercise name.
    """

    def post(self, request):
        serializer = WorkoutLogSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        data['date'] = str(data['date'])
        data['uid'] = request.user.uid
        data['logged_at'] = datetime.now(timezone.utc).isoformat()

        ref = _db().collection('workoutHistory').add(data)
        return Response({'id': ref[1].id} | data, status=status.HTTP_201_CREATED)

    def get(self, request):
        uid = request.user.uid
        exercise = request.query_params.get('exercise')

        docs = (
            _db()
            .collection('workoutHistory')
            .where('uid', '==', uid)
            .stream()
        )
        entries = [d.to_dict() | {'id': d.id} for d in docs]

        if exercise:
            entries = [e for e in entries if e.get('exercise_name') == exercise]

        entries.sort(key=lambda x: x.get('date', ''), reverse=True)
        return Response(entries)


class ProgressSummaryView(APIView):
    """
    GET /api/analytics/summary/
    Returns aggregated stats shaped to match the frontend ProgressScreen expectations.

    Query params:
      ?period=week   (default) — last 7 days
      ?period=month            — last 30 days
      ?period=year             — last 365 days
    """

    def get(self, request):
        uid = request.user.uid
        period = request.query_params.get('period', 'week')

        period_days = {'week': 7, 'month': 30, 'year': 365}.get(period, 7)
        cutoff = (datetime.now(timezone.utc) - timedelta(days=period_days)).date().isoformat()

        all_history = _all_history(uid)
        history = [h for h in all_history if h.get('date', '') >= cutoff]

        if not history:
            return Response(self._empty_response(period_days))

        total_workouts = len(history)
        total_minutes = sum(h.get('duration_minutes', 0) for h in history)
        total_calories = sum(h.get('calories_burned', 0) for h in history)

        # Streak — count consecutive days with workouts ending today
        all_dates = sorted({h['date'] for h in all_history})
        date_set = {datetime.fromisoformat(d).date() for d in all_dates}
        current_streak, check = 0, datetime.now(timezone.utc).date()
        while check in date_set:
            current_streak += 1
            check -= timedelta(days=1)

        # Longest streak across all history
        longest_streak, streak = 0, 1
        for i in range(1, len(all_dates)):
            prev = datetime.fromisoformat(all_dates[i - 1]).date()
            curr = datetime.fromisoformat(all_dates[i]).date()
            streak = streak + 1 if (curr - prev).days == 1 else 1
            longest_streak = max(longest_streak, streak)
        longest_streak = max(longest_streak, streak if all_dates else 0)

        # Activity array — minutes per day for the period (for bar chart)
        activity_map: dict = defaultdict(int)
        for h in history:
            activity_map[h['date']] += h.get('duration_minutes', 0)

        today = datetime.now(timezone.utc).date()
        activity = []
        activity_labels = []
        for i in range(period_days - 1, -1, -1):
            day = today - timedelta(days=i)
            activity.append(activity_map.get(day.isoformat(), 0))
            activity_labels.append(day.strftime('%a') if period == 'week' else day.strftime('%d'))

        # Recent sessions (last 10)
        recent = sorted(history, key=lambda x: x.get('date', ''), reverse=True)[:10]
        sessions = [
            {
                'title': h.get('exercise_name', 'Workout'),
                'duration': f"{h.get('duration_minutes', 0)} min",
                'calories': f"{h.get('calories_burned', 0)} kcal",
                'date': h.get('date'),
                'sets': h.get('sets_completed', 0),
                'reps': h.get('reps_completed', 0),
                'weight_kg': h.get('weight_kg', 0),
                'notes': h.get('notes', ''),
            }
            for h in recent
        ]

        return Response({
            'period': period,
            'workouts': total_workouts,
            'minutes': total_minutes,
            'calories': total_calories,
            'current_streak': current_streak,
            'longest_streak': longest_streak,
            'avg_duration_per_session': round(total_minutes / total_workouts, 1),
            'avg_calories_per_session': round(total_calories / total_workouts, 1),
            'unique_exercises': len({h.get('exercise_name') for h in history}),
            'activity': activity,
            'activity_labels': activity_labels,
            'sessions': sessions,
        })

    @staticmethod
    def _empty_response(period_days):
        return {
            'period': 'week',
            'workouts': 0,
            'minutes': 0,
            'calories': 0,
            'current_streak': 0,
            'longest_streak': 0,
            'avg_duration_per_session': 0,
            'avg_calories_per_session': 0,
            'unique_exercises': 0,
            'activity': [0] * period_days,
            'activity_labels': [],
            'sessions': [],
        }


class WeeklyProgressView(APIView):
    """
    GET /api/analytics/weekly/
    Groups workoutHistory by ISO week — for week-over-week chart data.
    """

    def get(self, request):
        uid = request.user.uid
        history = _all_history(uid)

        weekly: dict = defaultdict(lambda: {
            'sessions': 0, 'calories_burned': 0,
            'duration_minutes': 0, 'exercises': [],
        })

        for entry in history:
            date = datetime.fromisoformat(entry['date']).date()
            iso_year, iso_week, _ = date.isocalendar()
            key = f'{iso_year}-W{iso_week:02d}'
            weekly[key]['sessions'] += 1
            weekly[key]['calories_burned'] += entry.get('calories_burned', 0)
            weekly[key]['duration_minutes'] += entry.get('duration_minutes', 0)
            ex = entry.get('exercise_name')
            if ex and ex not in weekly[key]['exercises']:
                weekly[key]['exercises'].append(ex)

        return Response([{'week': k} | v for k, v in sorted(weekly.items())])


class ExerciseProgressView(APIView):
    """
    GET /api/analytics/exercise/<exercise_name>/
    Tracks weight, reps, and volume over time for a specific exercise.
    """

    def get(self, request, exercise_name):
        uid = request.user.uid
        all_history = _all_history(uid)
        entries = [e for e in all_history if e.get('exercise_name') == exercise_name]

        if not entries:
            return Response(
                {'detail': f'No history found for exercise: {exercise_name}'},
                status=status.HTTP_404_NOT_FOUND,
            )

        progression = [
            {
                'date': e['date'],
                'weight_kg': e.get('weight_kg', 0),
                'reps_completed': e.get('reps_completed', 0),
                'sets_completed': e.get('sets_completed', 0),
                'volume': round(
                    e.get('weight_kg', 0) * e.get('sets_completed', 0) * e.get('reps_completed', 0), 1
                ),
            }
            for e in entries
        ]

        return Response({
            'exercise': exercise_name,
            'total_sessions': len(progression),
            'progression': progression,
        })
