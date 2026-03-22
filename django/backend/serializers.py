from rest_framework import serializers
from .models import Room, RoomImage, Booking, Notification

class RoomImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomImage
        fields = ['id', 'image_url', 'caption']

class RoomSerializer(serializers.ModelSerializer):
    images = RoomImageSerializer(many=True, read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = Room
        fields = [
            'id', 'name', 'price', 'capacity', 'description', 
            'status', 'status_display', 'thumbnail_url', 'images'
        ]

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

class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'message', 'level', 'is_read', 'created_at']
