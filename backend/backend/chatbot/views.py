import os
import sys
import requests
from firebase_admin import firestore
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, timezone
from django.conf import settings

from fitmate.firebase import get_firebase_app

# Make the existing chatbot module importable
_CHATBOT_DIR = os.path.join(
    os.path.dirname(__file__), '..', '..', 'Exercises', 'Moiz_Working', 'fitness_chatbot'
)
sys.path.insert(0, os.path.abspath(_CHATBOT_DIR))


def _db():
    get_firebase_app()
    return firestore.client()


class ChatView(APIView):
    """POST /api/chatbot/ask/ — answer a fitness question using the RAG pipeline."""

    _bot_ready = False

    def _ensure_bot(self):
        if not ChatView._bot_ready:
            import chatbot_backend  # noqa: F401 — triggers index load on first request
            ChatView._bot_ready = True

    def post(self, request):
        question = request.data.get('question', '').strip()
        if not question:
            return Response(
                {'detail': 'question is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        self._ensure_bot()
        import chatbot_backend as cb

        answer = cb.ask_bot(question)

        # Persist chat history in Firestore
        _db().collection('chat_history').add({
            'uid': request.user.uid,
            'question': question,
            'answer': answer,
            'timestamp': datetime.now(timezone.utc).isoformat(),
        })

        return Response({'question': question, 'answer': answer})


class ChatHistoryView(APIView):
    """GET /api/chatbot/history/ — return the user's past chat messages."""

    def get(self, request):
        uid = request.user.uid
        docs = (
            _db()
            .collection('chat_history')
            .where(filter=firestore.FieldFilter('uid', '==', uid))
            .order_by('timestamp', direction=firestore.Query.DESCENDING)
            .limit(50)
            .stream()
        )
        return Response([d.to_dict() | {'id': d.id} for d in docs])
