from rest_framework import serializers
from .models import Room, RoomImage


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
