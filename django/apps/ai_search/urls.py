from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AiSearchViewSet

router = DefaultRouter()
router.register(r'', AiSearchViewSet, basename='ai_search')

urlpatterns = [
    path('', include(router.urls)),
]
