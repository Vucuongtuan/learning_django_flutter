from django.db import models


class Notification(models.Model):
    LEVEL_CHOICES = [
        ("info", "Thông tin"),
        ("warning", "Cảnh báo"),
        ("success", "Thành công"),
        ("danger", "Quan trọng"),
    ]

    title = models.CharField(max_length=200)
    message = models.TextField()
    level = models.CharField(max_length=10, choices=LEVEL_CHOICES, default="info")
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title
