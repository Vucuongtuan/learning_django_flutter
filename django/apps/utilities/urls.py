from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UtilityPricingViewSet, UtilityReadingViewSet

router = DefaultRouter()
router.register(r'utility-pricing', UtilityPricingViewSet, basename='utility-pricing')
router.register(r'utility-readings', UtilityReadingViewSet, basename='utility-reading')

urlpatterns = [
    path('', include(router.urls)),
]
