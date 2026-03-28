from django.db import models
from django.core.exceptions import ValidationError
from django.contrib.auth.models import User


class Tenant(models.Model):
    GENDER_CHOICES = [("male", "Nam"), ("female", "Nữ"), ("other", "Khác")]

    user = models.OneToOneField(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name="tenant_profile"
    )
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
    back_image_url = models.URLField(max_length=500, null=True, blank=True)

    issue_date = models.DateField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        if self.doc_type == "cccd" and not self.back_image_url:
            raise ValidationError({"back_image_url": "CCCD bắt buộc phải có ảnh mặt sau!"})

    def __str__(self):
        return f"{self.get_doc_type_display()} của {self.tenant.full_name}"
