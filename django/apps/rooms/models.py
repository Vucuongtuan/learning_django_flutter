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
    description = models.TextField(blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="available")
    thumbnail_url = models.URLField(max_length=500, blank=True, null=True, help_text="Ảnh chính của phòng")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.get_status_display()})"


class RoomImage(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name="images")
    image_url = models.URLField(max_length=500)
    caption = models.CharField(max_length=200, blank=True, help_text="Mô tả ảnh (ví dụ: Nhà bếp, Ban công)")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Ảnh của phòng {self.room.name}"
