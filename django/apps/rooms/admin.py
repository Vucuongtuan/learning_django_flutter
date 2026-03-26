from django.contrib import admin
from .models import Room, RoomImage


class RoomImageInline(admin.TabularInline):
    model = RoomImage
    extra = 1


@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ('name', 'status', 'price', 'capacity')
    list_filter = ('status',)
    search_fields = ('name',)
    inlines = [RoomImageInline]
