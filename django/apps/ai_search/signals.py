from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.rooms.models import Room
from .tasks import generate_room_embedding_task

@receiver(post_save, sender=Room)
def update_room_embedding_signal(sender, instance, **kwargs):
    """Mỗi khi có Room mới hoặc cập nhật, gửi task cho Celery xử lý ngầm."""
    # .delay() gửi task vào hàng đợi Redis ngay lập tức
    generate_room_embedding_task.delay(instance.id)
