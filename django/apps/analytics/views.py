from datetime import date, timedelta
from django.db.models import Sum, Count, Q
from django.db.models.functions import TruncMonth
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from apps.rooms.models import Room
from apps.billing.models import MonthlyInvoice
from apps.utilities.models import UtilityReading


class DashboardView(APIView):
    """
    API Dashboard Tổng quan cho Chủ trọ.
    - Trả về các chỉ số chính (KPIs) của khu trọ.
    """
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        today = date.today()
        first_day_current_month = today.replace(day=1)

        # 1. Thống kê Phòng (Rooms)
        rooms_stats = Room.objects.aggregate(
            total=Count('id'),
            occupied=Count('id', filter=Q(status='occupied')),
            available=Count('id', filter=Q(status='available')),
            maintenance=Count('id', filter=Q(status='maintenance'))
        )

        # 2. Doanh thu Tháng này (Current Month)
        # Tính toán cả tiền đã thu (is_paid=True) và tiền dự kiến (toàn bộ hóa đơn tháng này)
        current_month_invoices = MonthlyInvoice.objects.filter(billing_month=first_day_current_month)
        
        revenue_stats = current_month_invoices.aggregate(
            received=Sum('total_amount', filter=Q(is_paid=True)),
            pending=Sum('total_amount', filter=Q(is_paid=False)),
            total=Sum('total_amount')
        )

        # 3. Biểu đồ Doanh thu (6 tháng gần nhất)
        six_months_ago = today - timedelta(days=180)
        revenue_history = (
            MonthlyInvoice.objects.filter(billing_month__gte=six_months_ago, is_paid=True)
            .annotate(month=TruncMonth('billing_month'))
            .values('month')
            .annotate(amount=Sum('total_amount'))
            .order_by('month')
        )

        # 4. Thống kê Điện/Nước tiêu thụ (6 tháng gần nhất)
        utility_history = (
            UtilityReading.objects.filter(billing_month__gte=six_months_ago)
            .annotate(month=TruncMonth('billing_month'))
            .values('month', 'utility_type')
            .annotate(usage=Sum('current_reading') - Sum('previous_reading')) # Tính toán đơn giản mức tiêu thụ
            .order_by('month')
        )

        return Response({
            "overview": {
                "rooms": rooms_stats,
                "revenue_this_month": {
                    "received": revenue_stats['received'] or 0,
                    "pending": revenue_stats['pending'] or 0,
                    "total": revenue_stats['total'] or 0
                }
            },
            "charts": {
                "revenue": list(revenue_history),
                "utilities": list(utility_history)
            }
        })
