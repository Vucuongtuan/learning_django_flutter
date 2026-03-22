from django.db import models
from django.core.exceptions import ValidationError

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
    """Gallery ảnh cho từng phòng"""
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name="images")
    image_url = models.URLField(max_length=500)
    caption = models.CharField(max_length=200, blank=True, help_text="Mô tả ảnh (ví dụ: Nhà bếp, Ban công)")
    
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Ảnh của phòng {self.room.name}"

class Tenant(models.Model):
    GENDER_CHOICES = [("male","Nam"), ("female","Nữ"), ("other","Khác")]
    
    full_name = models.CharField(max_length=100)
    phone = models.CharField(max_length=15, unique=True)
    email = models.EmailField(blank=True)
    date_of_birth = models.DateField()
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES)
    
    identity_number = models.CharField(max_length=50, unique=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.full_name} ({self.phone})"

class IdentityDocument(models.Model):
    DOC_TYPES = [
        ("cccd", "Căn cước công dân"),
        ("birth_cert", "Giấy khai sinh"),
        ("passport", "Hộ chiếu"),
    ]

    tenant = models.ForeignKey(Tenant, on_delete=models.CASCADE, related_name="documents")
    doc_type = models.CharField(max_length=20, choices=DOC_TYPES, default="cccd")
    
    front_image_url = models.URLField(max_length=500)
    back_image_url = models.URLField(max_length=500, null=True, blank=True) # Trẻ em ko cần mặt sau
    
    issue_date = models.DateField(null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        """Logic kiểm tra dữ liệu trước khi lưu"""
        if self.doc_type == "cccd" and not self.back_image_url:
            raise ValidationError({"back_image_url": "CCCD bắt buộc phải có ảnh mặt sau!"})
        
    def __str__(self):
        return f"{self.get_doc_type_display()} của {self.tenant.full_name}"

class Lease(models.Model):
    STATUS_CHOICES = [
        ("active", "Đang hiệu lực"),
        ("ended", "Đã kết thúc"),
        ("cancelled", "Đã hủy"),
    ]

    tenant = models.ForeignKey(Tenant, on_delete=models.PROTECT, related_name="leases")
    room = models.ForeignKey(Room, on_delete=models.PROTECT, related_name="leases")
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
    """Những người ở cùng phòng (Vợ, con, bạn...)"""
    ROLE_CHOICES = [
        ("owner", "Chủ hộ"),
        ("member", "Thành viên ở cùng"),
    ]
    lease = models.ForeignKey(Lease, on_delete=models.CASCADE, related_name="members")
    tenant = models.ForeignKey(Tenant, on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="member")

    def __str__(self):
        return f"{self.tenant.full_name} (Trong {self.lease})"

class Booking(models.Model):
    """Luồng xử lý khi khách gọi điện đặt cọc giữ chỗ"""
    STATUS_CHOICES = [
        ("pending", "Chờ xử lý"),
        ("confirmed", "Đã xác nhận cọc"),
        ("cancelled", "Đã hủy"),
        ("completed", "Đã nhận phòng"),
    ]

    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name="bookings")
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

class Notification(models.Model):
    """Thông báo cho chủ trọ"""
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
