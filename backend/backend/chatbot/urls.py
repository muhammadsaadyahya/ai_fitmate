from django.urls import path
from .views import ChatView, ChatHistoryView

urlpatterns = [
    path('ask/', ChatView.as_view(), name='chatbot-ask'),
    path('history/', ChatHistoryView.as_view(), name='chatbot-history'),
]
