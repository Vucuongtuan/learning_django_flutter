from rest_framework import viewsets, filters, permissions
from django_filters.rest_framework import DjangoFilterBackend
from .models import Lease
from .serializers import LeaseSerializer


class LeaseViewSet(viewsets.ModelViewSet):
    queryset = Lease.objects.all()
    serializer_class = LeaseSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'room', 'tenant']
    ordering = ['-created_at']

    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'tenant_profile'):
            return Lease.objects.filter(tenant=user.tenant_profile)
        return super().get_queryset()
