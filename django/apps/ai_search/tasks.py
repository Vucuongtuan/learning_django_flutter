from celery import shared_task
from .utils import get_embedding
from .models import RoomEmbedding
from apps.rooms.models import Room

@shared_task(bind=True, autoretry_for=(Exception,), retry_kwargs={'max_retries': 5, 'countdown': 60})
def generate_room_embedding_task(self, room_id):
    """Tác vụ ngầm để lấy embedding từ AI và cập nhật vào DB."""
    try:
        room = Room.objects.get(pk=room_id)
        
        # Gom nội dung để AI hiểu phòng này là gì
        content = f"Phòng {room.name}, giá {room.price} VNĐ, sức chứa {room.capacity} người. Trạng thái: {room.get_status_display()}."
        
        # Lấy vector từ AI (Sẽ retry nếu lỗi mạng/API)
        vector = get_embedding(content)
        
        if vector:
            # Cập nhật hoặc tạo mới embedding trong DB
            RoomEmbedding.objects.update_or_create(
                room=room,
                defaults={
                    'content': content,
                    'embedding': vector
                }
            )
            return f"Đã cập nhật embedding cho phòng {room.name}"
        else:
            raise Exception("Không lấy được vector từ AI")
            
    except Room.DoesNotExist:
        return f"Phòng ID {room_id} không tồn tại"
