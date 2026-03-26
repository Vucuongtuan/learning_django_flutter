from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DiscountViewSet, MonthlyInvoiceViewSet

router = DefaultRouter()
router.register(r'discounts', DiscountViewSet, basename='discount')
router.register(r'invoices', MonthlyInvoiceViewSet, basename='invoice')

urlpatterns = [
    path('', include(router.urls)),
]
