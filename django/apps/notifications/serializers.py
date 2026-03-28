from rest_framework import serializers
from .models import Notification, FCMDevice


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'recipient', 'is_global', 'title', 'message', 'level', 'is_read', 'created_at']


class FCMDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = FCMDevice
        fields = ['id', 'registration_id', 'device_type', 'is_active', 'created_at']
        read_only_fields = ['user', 'created_at']
