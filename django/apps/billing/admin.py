from django.contrib import admin
from .models import Discount, MonthlyInvoice


@admin.register(Discount)
class DiscountAdmin(admin.ModelAdmin):
    list_display = ('lease', 'discount_type', 'value', 'reason', 'is_active', 'start_date', 'end_date')
    list_filter = ('discount_type', 'is_active')


@admin.register(MonthlyInvoice)
class MonthlyInvoiceAdmin(admin.ModelAdmin):
    list_display = ('lease', 'billing_month', 'rent_amount', 'electricity_cost', 'water_cost', 'discount_amount', 'total_amount', 'is_paid')
    list_filter = ('is_paid', 'billing_month')
    readonly_fields = ('total_amount',)
