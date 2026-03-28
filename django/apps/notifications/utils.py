import os
import firebase_admin
from firebase_admin import messaging, credentials
from django.conf import settings
from .models import FCMDevice

# Khởi tạo Firebase Admin SDK (Chỉ một lần duy nhất khi khởi động ứng dụng)
# Bạn cần để file serviceAccountKey.json vào thư mục config/ hoặc ROOT của dự án
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
    
    # Lấy tất cả các thiết bị đang hoạt động của người dùng này
    devices = FCMDevice.objects.filter(user=user, is_active=True)
    tokens = list(devices.values_list('registration_id', flat=True))

    if not tokens:
        return 0

    # Tạo tin nhắn thông báo (Notification)
    notification = messaging.Notification(
        title=title,
        body=body
    )

    # Nếu chỉ có 1 token, gửi tin nhắn đơn
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
        # Gửi tin nhắn hàng loạt cho nhiều thiết bị của cùng 1 user
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
