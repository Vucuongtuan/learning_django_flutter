from django.db import models
from django.core.exceptions import ValidationError


class UtilityPricing(models.Model):
    UTILITY_TYPES = [
        ("electricity", "Điện"),
        ("water", "Nước"),
    ]

    utility_type = models.CharField(max_length=20, choices=UTILITY_TYPES)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2, help_text="Đơn giá / kWh hoặc / m³")
    effective_date = models.DateField(help_text="Ngày bắt đầu áp dụng đơn giá này")
    note = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-effective_date']

    def __str__(self):
        return f"{self.get_utility_type_display()} — {self.price_per_unit} VNĐ (từ {self.effective_date})"


class UtilityReading(models.Model):
    UTILITY_TYPES = [
        ("electricity", "Điện"),
        ("water", "Nước"),
    ]

    room = models.ForeignKey("rooms.Room", on_delete=models.CASCADE, related_name="utility_readings")
    utility_type = models.CharField(max_length=20, choices=UTILITY_TYPES)
    billing_month = models.DateField(help_text="Tháng tính (chọn ngày 1 của tháng)")
    previous_reading = models.DecimalField(max_digits=10, decimal_places=2, help_text="Chỉ số cũ")
    current_reading = models.DecimalField(max_digits=10, decimal_places=2, help_text="Chỉ số mới")
    unit_price = models.DecimalField(max_digits=10, decimal_places=2, help_text="Đơn giá tại thời điểm ghi")

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-billing_month']
        unique_together = ['room', 'utility_type', 'billing_month']

    @property
    def usage(self):
        return self.current_reading - self.previous_reading

    @property
    def total_cost(self):
        return self.usage * self.unit_price

    def clean(self):
        if self.current_reading < self.previous_reading:
            raise ValidationError({"current_reading": "Chỉ số mới phải lớn hơn hoặc bằng chỉ số cũ!"})

    def __str__(self):
        return f"{self.room.name} — {self.get_utility_type_display()} tháng {self.billing_month.strftime('%m/%Y')}"
