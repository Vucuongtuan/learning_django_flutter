from rest_framework import viewsets, permissions
from django.db.models import Q
from .models import Notification, FCMDevice
from .serializers import NotificationSerializer, FCMDeviceSerializer
from .utils import send_push_notification, send_bulk_push_notification


class NotificationViewSet(viewsets.ModelViewSet):
    """
    API quản lý thông báo (Notifications).
    - Chủ trọ: Có thể tạo thông báo cá nhân hoặc toàn bộ.
    - Người thuê: Chỉ xem được thông báo dành cho mình.
    """
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    ordering = ['-created_at']

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return super().get_queryset()
        
        return Notification.objects.filter(
            Q(recipient=user) | Q(is_global=True)
        )

    def perform_create(self, serializer):
        instance = serializer.save()
        
        if instance.is_global:
            send_bulk_push_notification(
                title=f"📢 {instance.title}",
                body=instance.message
            )
        elif instance.recipient:
            send_push_notification(
                user=instance.recipient,
                title=instance.title,
                body=instance.message
            )


class FCMDeviceViewSet(viewsets.ModelViewSet):
    """
    API dành cho Flutter đăng ký Token thiết bị (FCM Token).
    - GET: Xem danh sách thiết bị của mình.
    - POST: Đăng ký thiết bị mới.
    """
    queryset = FCMDevice.objects.all()
    serializer_class = FCMDeviceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return FCMDevice.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        registration_id = self.request.data.get('registration_id')
        FCMDevice.objects.filter(registration_id=registration_id).delete()
        serializer.save(user=self.request.user)
