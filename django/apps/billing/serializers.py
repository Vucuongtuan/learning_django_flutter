from rest_framework import serializers
from .models import Discount, MonthlyInvoice


class DiscountSerializer(serializers.ModelSerializer):
    lease_display = serializers.CharField(source='lease.__str__', read_only=True)
    discount_type_display = serializers.CharField(source='get_discount_type_display', read_only=True)

    class Meta:
        model = Discount
        fields = [
            'id', 'lease', 'lease_display', 'discount_type', 'discount_type_display',
            'value', 'reason', 'start_date', 'end_date', 'is_active'
        ]


class MonthlyInvoiceSerializer(serializers.ModelSerializer):
    lease_display = serializers.CharField(source='lease.__str__', read_only=True)

    class Meta:
        model = MonthlyInvoice
        fields = [
            'id', 'lease', 'lease_display', 'billing_month',
            'rent_amount', 'electricity_cost', 'water_cost',
            'discount_amount', 'total_amount', 'is_paid', 'paid_date', 'note'
        ]
        read_only_fields = ['total_amount']
