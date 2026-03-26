from django.db import models
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Discount, MonthlyInvoice
from .serializers import DiscountSerializer, MonthlyInvoiceSerializer
from apps.leases.models import Lease
from apps.utilities.models import UtilityReading


class DiscountViewSet(viewsets.ModelViewSet):
    queryset = Discount.objects.all()
    serializer_class = DiscountSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['lease', 'is_active', 'discount_type']


class MonthlyInvoiceViewSet(viewsets.ModelViewSet):
    queryset = MonthlyInvoice.objects.all()
    serializer_class = MonthlyInvoiceSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['lease', 'is_paid', 'billing_month']
    ordering = ['-billing_month']

    @action(detail=False, methods=['post'])
    def generate(self, request):
        lease_id = request.data.get('lease_id')
        billing_month = request.data.get('billing_month')

        if not lease_id or not billing_month:
            return Response(
                {"error": "Cần truyền lease_id và billing_month (YYYY-MM-01)"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            lease = Lease.objects.get(pk=lease_id, status="active")
        except Lease.DoesNotExist:
            return Response(
                {"error": "Hợp đồng không tồn tại hoặc không còn hiệu lực"},
                status=status.HTTP_404_NOT_FOUND
            )

        electricity = UtilityReading.objects.filter(
            room=lease.room, utility_type="electricity", billing_month=billing_month
        ).first()
        water = UtilityReading.objects.filter(
            room=lease.room, utility_type="water", billing_month=billing_month
        ).first()

        electricity_cost = electricity.total_cost if electricity else 0
        water_cost = water.total_cost if water else 0

        total_discount = 0
        active_discounts = Discount.objects.filter(
            lease=lease, is_active=True, start_date__lte=billing_month
        ).filter(
            models.Q(end_date__isnull=True) | models.Q(end_date__gte=billing_month)
        )
        for disc in active_discounts:
            total_discount += disc.calculate_discount(lease.rent_amount)

        invoice, created = MonthlyInvoice.objects.update_or_create(
            lease=lease,
            billing_month=billing_month,
            defaults={
                'rent_amount': lease.rent_amount,
                'electricity_cost': electricity_cost,
                'water_cost': water_cost,
                'discount_amount': total_discount,
            }
        )

        serializer = self.get_serializer(invoice)
        return Response(serializer.data, status=status.HTTP_201_CREATED if created else status.HTTP_200_OK)
