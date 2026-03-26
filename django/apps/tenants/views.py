from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Tenant
from .serializers import TenantSerializer


class TenantViewSet(viewsets.ModelViewSet):
    queryset = Tenant.objects.all()
    serializer_class = TenantSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    search_fields = ['full_name', 'phone', 'identity_number']
