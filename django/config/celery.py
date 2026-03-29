import os
from celery import Celery

# Thiết lập Django settings mặc định cho Celery
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

app = Celery('config')

# Đọc cấu hình từ settings.py (prefix 'CELERY_')
app.config_from_object('django.conf:settings', namespace='CELERY')

# Tự động tìm tasks trong tất cả app của Django
app.autodiscover_tasks()

@app.task(bind=True)
def debug_task(self):
    print(f'Request: {self.request!r}')
