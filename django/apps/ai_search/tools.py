from apps.rooms.models import Room
from apps.billing.models import MonthlyInvoice
from apps.notifications.models import Notification
from datetime import datetime

def get_invoice_info(room_name, month, year=None):
    """Lấy thông tin hóa đơn của một phòng trong một tháng cụ thể."""
    if not year:
        year = datetime.now().year
    
    try:
        room = Room.objects.get(name__icontains=room_name)
        invoice = MonthlyInvoice.objects.filter(
            lease__room=room, 
            billing_month__month=month,
            billing_month__year=year
        ).first()
        
        if invoice:
            return {
                "tenant_name": invoice.lease.tenant.full_name,
                "amount": int(invoice.total_amount),
                "is_paid": invoice.is_paid,
                "room_name": room.name,
                "month": month
            }
        return {"error": f"Không tìm thấy hóa đơn tháng {month} cho phòng {room_name}"}
    except Room.DoesNotExist:
        return {"error": f"Không tìm thấy phòng nào có tên {room_name}"}

def send_custom_notification(room_name, message):
    """Gửi một thông báo tùy chỉnh đến khách thuê của phòng đó."""
    try:
        room = Room.objects.get(name__icontains=room_name)
        lease = room.leases.filter(status="active").first()
        
        if lease and lease.tenant.user:
            Notification.objects.create(
                recipient=lease.tenant.user,
                title="Thông báo từ quản lý",
                message=message,
                level="info"
            )
            return {"status": "success", "message": f"Đã gửi tin nhắn đến {lease.tenant.full_name}"}
        return {"error": "Phòng này hiện không có khách ở hoặc khách chưa có tài khoản app"}
    except Room.DoesNotExist:
        return {"error": f"Không tìm thấy phòng {room_name}"}

# Danh sách các hàm AI có thể gọi
AI_TOOLS = {
    "get_invoice_info": get_invoice_info,
    "send_custom_notification": send_custom_notification
}
