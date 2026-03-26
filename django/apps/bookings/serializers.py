from rest_framework import serializers
from .models import Booking


class BookingSerializer(serializers.ModelSerializer):
    room_name = serializers.CharField(source='room.name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Booking
        fields = [
            'id', 'room', 'room_name', 'tenant_name', 'tenant_phone',
            'expected_move_in_date', 'deposit_amount', 'status',
            'status_display', 'note', 'created_at'
        ]
