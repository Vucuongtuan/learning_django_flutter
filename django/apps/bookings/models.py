from django.db import models

from apps.notifications.models import Notification


class Booking(models.Model):
    STATUS_CHOICES = [
        ("pending", "Chờ xử lý"),
        ("confirmed", "Đã xác nhận cọc"),
        ("cancelled", "Đã hủy"),
        ("completed", "Đã nhận phòng"),
    ]

    room = models.ForeignKey("rooms.Room", on_delete=models.CASCADE, related_name="bookings")
    tenant_name = models.CharField(max_length=100, help_text="Tên khách gọi điện")
    tenant_phone = models.CharField(max_length=15, help_text="Số điện thoại khách")
    expected_move_in_date = models.DateField(help_text="Ngày dự kiến dọn vào")
    deposit_amount = models.PositiveIntegerField(default=0, help_text="Số tiền cọc giữ chỗ")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")
    note = models.TextField(blank=True, help_text="Ghi chú thêm (ví dụ: khách đòi sơn lại tường)")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Đặt chỗ: {self.tenant_name} - {self.room.name}"

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)

        if self.status == "confirmed" and self.room.status == "available":
            self.room.status = "booked"
            self.room.save(update_fields=['status'])

            if is_new:
                Notification.objects.create(
                    title="Có khách mới đặt cọc",
                    message=f"Phòng {self.room.name} đã được {self.tenant_name} đặt cọc {self.deposit_amount} VNĐ.",
                    level="success"
                )
