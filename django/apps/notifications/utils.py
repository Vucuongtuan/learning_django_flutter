import os
import firebase_admin
from firebase_admin import messaging, credentials
from django.conf import settings
from .models import FCMDevice

FIREBASE_CRED_PATH = os.path.join(settings.BASE_DIR, 'config', 'serviceAccountKey.json')

def initialize_firebase():
    if not firebase_admin._apps:
        if os.path.exists(FIREBASE_CRED_PATH):
            cred = credentials.Certificate(FIREBASE_CRED_PATH)
            firebase_admin.initialize_app(cred)
        else:
            print("⚠️ CẢNH BÁO: File serviceAccountKey.json không tồn tại. Push Notifications sẽ bị bỏ qua.")

def send_push_notification(user, title, body, data=None):
    """
    Gửi thông báo Push thực tế qua Firebase Cloud Messaging (FCM)
    - user: Đối tượng người dùng nhận thông báo
    - title: Tiêu đề hiện trên Banner điện thoại
    - body: Nội dung hiện dưới tiêu đề
    - data: Payload (Dữ liệu ẩn để Flutter xử lý logic như mở màn hình nào)
    """
    initialize_firebase()
    
    devices = FCMDevice.objects.filter(user=user, is_active=True)
    tokens = list(devices.values_list('registration_id', flat=True))

    if not tokens:
        return 0

    notification = messaging.Notification(
        title=title,
        body=body
    )

    if len(tokens) == 1:
        message = messaging.Message(
            notification=notification,
            token=tokens[0],
            data=data or {}
        )
        try:
            messaging.send(message)
            return 1
        except Exception as e:
            print(f"Lỗi gửi thông báo cho user {user.username}: {e}")
            return 0
    else:
        message = messaging.MulticastMessage(
            notification=notification,
            tokens=tokens,
            data=data or {}
        )
        try:
            response = messaging.send_multicast(message)
            return response.success_count
        except Exception as e:
            print(f"Lỗi gửi thông báo hàng loạt cho user {user.username}: {e}")
            return 0

def send_bulk_push_notification(title, body, data=None):
    """
    Gửi thông báo Push cho TOÀN BỘ thiết bị có trong hệ thống (Global Push)
    """
    initialize_firebase()
    
    devices = FCMDevice.objects.filter(is_active=True)
    tokens = list(devices.values_list('registration_id', flat=True))

    if not tokens:
        return 0

    notification = messaging.Notification(
        title=title,
        body=body
    )

    success_count = 0
    for i in range(0, len(tokens), 500):
        batch_tokens = tokens[i:i + 500]
        message = messaging.MulticastMessage(
            notification=notification,
            tokens=batch_tokens,
            data=data or {}
        )
        try:
            response = messaging.send_multicast(message)
            success_count += response.success_count
        except Exception as e:
            print(f"Lỗi gửi Push hàng loạt tại batch {i}: {e}")
            
    return success_count
