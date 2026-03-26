from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import UtilityPricing, UtilityReading
from .serializers import UtilityPricingSerializer, UtilityReadingSerializer


class UtilityPricingViewSet(viewsets.ModelViewSet):
    queryset = UtilityPricing.objects.all()
    serializer_class = UtilityPricingSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['utility_type']


class UtilityReadingViewSet(viewsets.ModelViewSet):
    queryset = UtilityReading.objects.all()
    serializer_class = UtilityReadingSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['room', 'utility_type', 'billing_month']
    ordering = ['-billing_month']
