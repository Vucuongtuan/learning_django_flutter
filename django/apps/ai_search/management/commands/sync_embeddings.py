from django.core.management.base import BaseCommand
from apps.rooms.models import Room
from apps.ai_search.tasks import generate_room_embedding_task

class Command(BaseCommand):
    help = 'Tạo vector embedding cho tất cả các phòng hiện có trong database'

    def handle(self, *args, **options):
        rooms = Room.objects.all()
        count = rooms.count()
        self.stdout.write(f"Đang bắt đầu đồng bộ {count} phòng...")

        for room in rooms:
            # Gửi task vào Celery để xử lý ngầm
            generate_room_embedding_task.delay(room.id)
            self.stdout.write(self.style.SUCCESS(f" - Đã gửi yêu cầu tạo vector cho phòng: {room.name}"))

        self.stdout.write(self.style.SUCCESS(f"Thành công! {count} phòng đã được đưa vào hàng đợi xử lý AI."))
