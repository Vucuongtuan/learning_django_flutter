from django.contrib import admin
from .models import Lease, LeaseMember


class LeaseMemberInline(admin.TabularInline):
    model = LeaseMember
    extra = 1


@admin.register(Lease)
class LeaseAdmin(admin.ModelAdmin):
    list_display = ('tenant', 'room', 'status', 'move_in_date', 'rent_amount')
    list_filter = ('status',)
    inlines = [LeaseMemberInline]
