from django.contrib import admin
from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('tenant_name', 'room', 'status', 'expected_move_in_date', 'deposit_amount')
    list_filter = ('status', 'room')
