from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('users.urls')),
    path('api/workout/', include('workout_planner.urls')),
    path('api/diet/', include('diet_planner.urls')),
    path('api/chatbot/', include('chatbot.urls')),
    path('api/analytics/', include('analytics.urls')),
]
