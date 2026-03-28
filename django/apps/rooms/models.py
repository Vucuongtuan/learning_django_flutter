from django.db import models


class Room(models.Model):
    STATUS_CHOICES = [
        ("available", "Available / Trống"),
        ("booked", "Booked / Đã đặt chỗ"),
        ("occupied", "Occupied / Đã cho thuê"),
        ("maintenance", "Maintenance / Bảo trì"),
    ]

    name = models.CharField(max_length=50, unique=True)
    price = models.PositiveIntegerField(default=0)
    capacity = models.PositiveIntegerField(default=1)
...
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._original_price = self.price

    class Meta:
        ordering = ['name']

    def save(self, *args, **kwargs):
        is_price_changed = self.pk and self.price != self._original_price
        super().save(*args, **kwargs)

        if is_price_changed:
            from apps.notifications.models import Notification
            from apps.leases.models import Lease
            
            # Tìm tất cả các khách đang thuê phòng này (Active Lease)
            active_leases = Lease.objects.filter(room=self, status="active")
            for lease in active_leases:
                if lease.tenant.user:
                    Notification.objects.create(
                        recipient=lease.tenant.user,
                        title="Thông báo thay đổi giá thuê",
                        message=f"Giá thuê phòng {self.name} đã được cập nhật từ {self._original_price:,} VNĐ thành {self.price:,} VNĐ.",
                        level="warning"
                    )
            self._original_price = self.price

    def __str__(self):
...        return f"{self.name} ({self.get_status_display()})"


class RoomImage(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name="images")
    image_url = models.URLField(max_length=500)
    caption = models.CharField(max_length=200, blank=True, help_text="Mô tả ảnh (ví dụ: Nhà bếp, Ban công)")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Ảnh của phòng {self.room.name}"
