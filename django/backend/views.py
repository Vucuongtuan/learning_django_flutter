from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Room, Booking, Notification
from .serializers import RoomSerializer, BookingSerializer, NotificationSerializer

class RoomViewSet(viewsets.ModelViewSet):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status']
    search_fields = ['name']
    ordering_fields = ['price', 'name']

class BookingViewSet(viewsets.ModelViewSet):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'room']
    ordering = ['-created_at']

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    ordering = ['-created_at']

    def get_queryset(self):
        return super().get_queryset()
