from django.contrib import admin
from .models import RoomEmbedding

@admin.register(RoomEmbedding)
class RoomEmbeddingAdmin(admin.ModelAdmin):
    list_display = ('room', 'content', 'updated_at')
    search_fields = ('room__name', 'content')
    readonly_fields = ('room', 'content', 'embedding', 'updated_at')

    def has_add_permission(self, request):
        return False  # Chỉ cho phép tạo tự động qua Signals
