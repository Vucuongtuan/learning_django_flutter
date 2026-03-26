from django.contrib import admin
from .models import UtilityPricing, UtilityReading


@admin.register(UtilityPricing)
class UtilityPricingAdmin(admin.ModelAdmin):
    list_display = ('utility_type', 'price_per_unit', 'effective_date')
    list_filter = ('utility_type',)


@admin.register(UtilityReading)
class UtilityReadingAdmin(admin.ModelAdmin):
    list_display = ('room', 'utility_type', 'billing_month', 'previous_reading', 'current_reading', 'get_usage', 'get_total_cost')
    list_filter = ('utility_type', 'room', 'billing_month')

    @admin.display(description="Tiêu thụ")
    def get_usage(self, obj):
        return obj.usage

    @admin.display(description="Thành tiền")
    def get_total_cost(self, obj):
        return f"{obj.total_cost:,.0f} VNĐ"
