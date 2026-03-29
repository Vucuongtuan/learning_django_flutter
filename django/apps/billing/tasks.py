from celery import shared_task
from datetime import date, timedelta
from django.db import models
from apps.leases.models import Lease
from apps.notifications.models import Notification
from apps.utilities.models import UtilityReading
from .models import MonthlyInvoice, Discount

@shared_task
def check_and_auto_close_monthly_invoice():
    """
    Tự động chốt hóa đơn vào ngày kỷ niệm dọn vào của khách.
    Bao gồm: Gom tiền phòng + Điện + Nước + Giảm giá -> Tạo PDF -> Thông báo.
    """
    today = date.today()
    active_leases = Lease.objects.filter(status="active")
    
    count = 0
    for lease in active_leases:
        # Nếu hôm nay là ngày kỷ niệm dọn vào
        if lease.move_in_date.day == today.day:
            billing_month = today.replace(day=1) # VD: 2024-03-01
            
            # 1. Lấy chỉ số điện nước gần nhất
            electricity = UtilityReading.objects.filter(
                room=lease.room, utility_type="electricity", billing_month=billing_month
            ).first()
            water = UtilityReading.objects.filter(
                room=lease.room, utility_type="water", billing_month=billing_month
            ).first()
            
            elec_cost = electricity.total_cost if electricity else 0
            water_cost = water.total_cost if water else 0
            
            # 2. Tính toán giảm giá
            total_discount = 0
            active_discounts = Discount.objects.filter(
                lease=lease, is_active=True, start_date__lte=today
            ).filter(
                models.Q(end_date__isnull=True) | models.Q(end_date__gte=today)
            )
            for d in active_discounts:
                total_discount += d.calculate_discount(lease.rent_amount)
                
            # 3. Tạo Hóa đơn
            invoice, created = MonthlyInvoice.objects.update_or_create(
                lease=lease,
                billing_month=billing_month,
                defaults={
                    'rent_amount': lease.rent_amount,
                    'electricity_cost': elec_cost,
                    'water_cost': water_cost,
                    'discount_amount': total_discount,
                }
            )
            
            # 4. Gửi thông báo có Hóa đơn mới (FE sẽ gọi API lấy file PDF)
            if lease.tenant.user:
                Notification.objects.create(
                    recipient=lease.tenant.user,
                    title=f"💰 Hóa đơn tháng {billing_month.strftime('%m/%Y')}",
                    message=(
                        f"Phòng {lease.room.name} đã được chốt hóa đơn tháng. "
                        f"Tổng cộng: {int(invoice.total_amount):,} VNĐ. "
                        f"Bạn có thể xem chi tiết hóa đơn PDF trong mục Hóa đơn trên App."
                    ),
                    level="success"
                )
                count += 1
                
    return f"Đã tự động chốt {count} hóa đơn."
