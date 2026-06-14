from django.urls import path
from .views import SignupView, LoginView, ProfileView,SetTargetView

urlpatterns = [
    path('signup/', SignupView.as_view(), name='user-signup'),
    path('login/', LoginView.as_view(), name='user-login'),
    path('profile/', ProfileView.as_view(), name='user-profile'),
    path('set-targets/', SetTargetView.as_view(),name='set-targets'),

]
