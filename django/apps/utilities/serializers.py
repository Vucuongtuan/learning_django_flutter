from rest_framework import serializers
from .models import UtilityPricing, UtilityReading


class UtilityPricingSerializer(serializers.ModelSerializer):
    utility_type_display = serializers.CharField(source='get_utility_type_display', read_only=True)

    class Meta:
        model = UtilityPricing
        fields = ['id', 'utility_type', 'utility_type_display', 'price_per_unit', 'effective_date', 'note']


class UtilityReadingSerializer(serializers.ModelSerializer):
    room_name = serializers.CharField(source='room.name', read_only=True)
    utility_type_display = serializers.CharField(source='get_utility_type_display', read_only=True)
    usage = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)
    total_cost = serializers.DecimalField(max_digits=12, decimal_places=2, read_only=True)

    class Meta:
        model = UtilityReading
        fields = [
            'id', 'room', 'room_name', 'utility_type', 'utility_type_display',
            'billing_month', 'previous_reading', 'current_reading',
            'unit_price', 'usage', 'total_cost', 'created_at'
        ]
