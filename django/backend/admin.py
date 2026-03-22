from django.contrib import admin
from .models import Room, RoomImage, Tenant, IdentityDocument, Lease, LeaseMember

class RoomImageInline(admin.TabularInline):
    model = RoomImage
    extra = 1

class IdentityDocumentInline(admin.TabularInline):
    model = IdentityDocument
    extra = 1

class LeaseMemberInline(admin.TabularInline):
    model = LeaseMember
    extra = 1

@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ('name', 'status', 'price', 'capacity')
    inlines = [RoomImageInline]

@admin.register(Tenant)
class TenantAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'phone', 'identity_number')
    inlines = [IdentityDocumentInline]

@admin.register(Lease)
class LeaseAdmin(admin.ModelAdmin):
    list_display = ('tenant', 'room', 'status', 'move_in_date')
    inlines = [LeaseMemberInline]
