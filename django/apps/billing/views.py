from rest_framework import viewsets, filters, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Discount, MonthlyInvoice
from .serializers import DiscountSerializer, MonthlyInvoiceSerializer
from apps.leases.models import Lease
from apps.utilities.models import UtilityReading
from apps.tenants.permissions import IsTenantOwner


class DiscountViewSet(viewsets.ModelViewSet):
    queryset = Discount.objects.all()
    serializer_class = DiscountSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['lease', 'is_active', 'discount_type']

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy', 'bulk_apply']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['post'])
    def bulk_apply(self, request):
        scope = request.data.get('scope', 'all')
        ids = request.data.get('ids', [])
        discount_type = request.data.get('discount_type')
        value = request.data.get('value')
        reason = request.data.get('reason', 'Khuyến mãi dịp lễ')
        start_date = request.data.get('start_date', timezone.now().date())
        end_date = request.data.get('end_date')

        if not discount_type or value is None:
            return Response({"error": "Thiếu thông tin discount_type hoặc giá trị giảm"}, status=status.HTTP_400_BAD_REQUEST)

        active_leases = Lease.objects.filter(status="active")
        
        if scope == 'rooms' and ids:
            active_leases = active_leases.filter(room_id__in=ids)
        elif scope == 'leases' and ids:
            active_leases = active_leases.filter(id__in=ids)

        created_count = 0
        for lease in active_leases:
            Discount.objects.create(
                lease=lease,
                discount_type=discount_type,
                value=value,
                reason=reason,
                start_date=start_date,
                end_date=end_date
            )
            
            if lease.tenant.user:
                label = f"{value}%" if discount_type == "percentage" else f"{value:,} VNĐ"
                Notification.objects.create(
                    recipient=lease.tenant.user,
                    title=f"🎁 Quà tặng: {reason}",
                    message=f"Chúc mừng bạn! Bạn được giảm {label} tiền thuê phòng {lease.room.name} từ ngày {start_date}. Chúc bạn một kỳ nghỉ vui vẻ!",
                    level="success"
                )
            created_count += 1

        return Response({
            "status": f"Đã áp dụng giảm giá cho {created_count} hợp đồng",
            "created_count": created_count
        }, status=status.HTTP_201_CREATED)


from django.utils import timezone
from apps.notifications.models import Notification


class MonthlyInvoiceViewSet(viewsets.ModelViewSet):
    queryset = MonthlyInvoice.objects.all()
    serializer_class = MonthlyInvoiceSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['lease', 'is_paid', 'billing_month']
    ordering = ['-billing_month']

    def get_permissions(self):
        if self.action in ['generate', 'mark_as_paid']:
            return [permissions.IsAdminUser()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        if hasattr(user, 'tenant_profile'):
            return MonthlyInvoice.objects.filter(lease__tenant=user.tenant_profile)
        from apps.notifications.utils import send_push_notification


        class MonthlyInvoiceViewSet(viewsets.ModelViewSet):
        ...
            @action(detail=True, methods=['post'])
            def mark_as_paid(self, request, pk=None):
                invoice = self.get_object()
                if invoice.is_paid:
                    return Response({"error": "Hóa đơn này đã được thanh toán rồi"}, status=status.HTTP_400_BAD_REQUEST)

                invoice.is_paid = True
                invoice.paid_date = timezone.now().date()
                invoice.save()

                tenant_user = invoice.lease.tenant.user
                if tenant_user:
                    title = "Thanh toán thành công"
                    message = f"Hóa đơn tháng {invoice.billing_month.strftime('%m/%Y')} cho phòng {invoice.lease.room.name} đã được thanh toán thành công. Cảm ơn bạn!"

                    Notification.objects.create(recipient=tenant_user, title=title, message=message, level="success")

                    send_push_notification(tenant_user, title, message)

                return Response({"status": "Hóa đơn đã được xác nhận thanh toán", "paid_date": invoice.paid_date})


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
