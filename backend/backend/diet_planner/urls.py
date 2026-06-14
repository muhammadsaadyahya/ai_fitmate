from django.urls import path
from .views import GenerateDietPlanView, DietPlanView, MealLogView

urlpatterns = [
    path('generate/', GenerateDietPlanView.as_view(), name='diet-generate'),
    path('plan/', DietPlanView.as_view(), name='diet-plan'),
    path('meals/', MealLogView.as_view(), name='meal-log'),
]
