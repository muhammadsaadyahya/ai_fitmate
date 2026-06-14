from django.urls import path
from .views import GenerateWorkoutPlanView, WorkoutPlanView, WorkoutSessionView

urlpatterns = [
    path('generate/', GenerateWorkoutPlanView.as_view(), name='workout-generate'),
    path('plan/', WorkoutPlanView.as_view(), name='workout-plan'),
    path('sessions/', WorkoutSessionView.as_view(), name='workout-sessions'),
]
