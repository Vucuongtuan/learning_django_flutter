from django.db import models
from pgvector.django import VectorField
from apps.rooms.models import Room

class RoomEmbedding(models.Model):
    """Lưu trữ vector embedding cho từng phòng để tìm kiếm ngữ nghĩa."""
    room = models.OneToOneField(Room, on_delete=models.CASCADE, related_name='embedding')
    # text_to_embed: Nội dung tổng hợp dùng để tạo vector (VD: Tên phòng + Giá + Tiện nghi)
    content = models.TextField()
    # vector: Dãy số vector đại diện cho content (Gemini 'embedding-001' dùng 768 chiều)
    embedding = VectorField(dimensions=768, null=True, blank=True)
    
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Embedding cho {self.room.name}"

    class Meta:
        verbose_name = "Room Embedding"
