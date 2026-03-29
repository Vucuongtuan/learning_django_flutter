from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AiSearchViewSet, AiChatViewSet

router = DefaultRouter()
router.register(r'search', AiSearchViewSet, basename='ai_search')
router.register(r'chat', AiChatViewSet, basename='ai_chat')

urlpatterns = [
    path('', include(router.urls)),
]
