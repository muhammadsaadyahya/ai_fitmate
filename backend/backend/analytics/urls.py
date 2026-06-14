from django.urls import path
from .views import WorkoutLogView, ProgressSummaryView, WeeklyProgressView, ExerciseProgressView

urlpatterns = [
    path('log/', WorkoutLogView.as_view(), name='workout-log'),
    path('summary/', ProgressSummaryView.as_view(), name='progress-summary'),
    path('weekly/', WeeklyProgressView.as_view(), name='weekly-progress'),
    path('exercise/<str:exercise_name>/', ExerciseProgressView.as_view(), name='exercise-progress'),
]
