from django.db import models
from django.core.exceptions import ValidationError


class Lease(models.Model):
    STATUS_CHOICES = [
        ("active", "Đang hiệu lực"),
        ("ended", "Đã kết thúc"),
        ("cancelled", "Đã hủy"),
    ]

    tenant = models.ForeignKey("tenants.Tenant", on_delete=models.PROTECT, related_name="leases")
    room = models.ForeignKey("rooms.Room", on_delete=models.PROTECT, related_name="leases")
    move_in_date = models.DateField()
    move_out_date = models.DateField(null=True, blank=True)
    rent_amount = models.PositiveIntegerField()
    deposit_amount = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="active")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.tenant.full_name} -> {self.room.name}"

    def save(self, *args, **kwargs):
        if self.status == "active" and self.room.status == "maintenance":
            raise ValidationError("Phòng đang bảo trì, không thể tạo hợp đồng mới!")

        super().save(*args, **kwargs)
        self.update_room_status()

    def update_room_status(self):
        if self.room.status == "maintenance":
            return

        has_active = Lease.objects.filter(room=self.room, status="active").exists()
        new_status = "occupied" if has_active else "available"

        if self.room.status != new_status:
            self.room.status = new_status
            self.room.save(update_fields=['status'])


class LeaseMember(models.Model):
    ROLE_CHOICES = [
        ("owner", "Chủ hộ"),
        ("member", "Thành viên ở cùng"),
    ]
    lease = models.ForeignKey(Lease, on_delete=models.CASCADE, related_name="members")
    tenant = models.ForeignKey("tenants.Tenant", on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="member")

    def __str__(self):
        return f"{self.tenant.full_name} (Trong {self.lease})"
