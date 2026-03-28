from rest_framework import viewsets, permissions
from django.db.models import Q
from .models import Notification
from .serializers import NotificationSerializer


class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]
    ordering = ['-created_at']

    def get_queryset(self):
        user = self.request.user
        # Admin/Landlord thấy tất cả thông báo
        if user.is_staff:
            return super().get_queryset()
        
        # Người thuê thấy thông báo gửi riêng cho họ HOẶC thông báo chung cho tất cả
        return Notification.objects.filter(
            Q(recipient=user) | Q(is_global=True)
        )

    def perform_create(self, serializer):
        # Mặc định người tạo (chủ trọ) là người gửi
        # Logic này có thể được mở rộng nếu cần lưu lại người gửi
        serializer.save()
