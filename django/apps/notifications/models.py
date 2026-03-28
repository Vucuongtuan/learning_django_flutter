from django.db import models
from django.contrib.auth.models import User


class Notification(models.Model):
    LEVEL_CHOICES = [
        ("info", "Thông tin"),
        ("warning", "Cảnh báo"),
        ("success", "Thành công"),
        ("danger", "Quan trọng"),
    ]

    recipient = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name="notifications", 
        null=True, 
        blank=True,
        help_text="Để trống nếu muốn gửi thông báo cho tất cả người dùng"
    )
    is_global = models.BooleanField(default=False, help_text="Đánh dấu nếu đây là thông báo chung")
    title = models.CharField(max_length=200)
    message = models.TextField()
    level = models.CharField(max_length=10, choices=LEVEL_CHOICES, default="info")
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class FCMDevice(models.Model):
    DEVICE_TYPES = [('android', 'Android'), ('ios', 'iOS'), ('web', 'Web')]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="fcm_devices")
    registration_id = models.CharField(max_length=255, unique=True, help_text="FCM Token từ Flutter")
    device_type = models.CharField(max_length=10, choices=DEVICE_TYPES, default='android')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} - {self.device_type} ({self.registration_id[:10]}...)"
