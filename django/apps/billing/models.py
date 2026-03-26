from django.db import models


class Discount(models.Model):
    DISCOUNT_TYPES = [
        ("percentage", "Giảm theo %"),
        ("fixed", "Giảm số tiền cố định"),
    ]

    lease = models.ForeignKey("leases.Lease", on_delete=models.CASCADE, related_name="discounts")
    discount_type = models.CharField(max_length=20, choices=DISCOUNT_TYPES)
    value = models.DecimalField(max_digits=10, decimal_places=2, help_text="VD: 10 = 10% hoặc 200000 = 200k VNĐ")
    reason = models.CharField(max_length=200, help_text="Lý do giảm giá (sinh viên, hoàn cảnh khó khăn...)")
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True, help_text="Để trống = vô thời hạn")
    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def calculate_discount(self, rent_amount):
        if not self.is_active:
            return 0
        if self.discount_type == "percentage":
            return rent_amount * self.value / 100
        return self.value

    def __str__(self):
        label = f"{self.value}%" if self.discount_type == "percentage" else f"{self.value} VNĐ"
        return f"Giảm {label} — {self.reason} ({self.lease})"


class MonthlyInvoice(models.Model):
    lease = models.ForeignKey("leases.Lease", on_delete=models.CASCADE, related_name="invoices")
    billing_month = models.DateField(help_text="Tháng tính (ngày 1 của tháng)")
    rent_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    electricity_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    water_cost = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    discount_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    is_paid = models.BooleanField(default=False)
    paid_date = models.DateField(null=True, blank=True)
    note = models.TextField(blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-billing_month']
        unique_together = ['lease', 'billing_month']

    def calculate_total(self):
        self.total_amount = self.rent_amount + self.electricity_cost + self.water_cost - self.discount_amount
        return self.total_amount

    def save(self, *args, **kwargs):
        self.calculate_total()
        super().save(*args, **kwargs)

    def __str__(self):
        status = "✅ Đã TT" if self.is_paid else "❌ Chưa TT"
        return f"Hóa đơn {self.billing_month.strftime('%m/%Y')} — {self.lease} — {status}"
