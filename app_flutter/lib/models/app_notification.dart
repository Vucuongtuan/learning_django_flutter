class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String get typeLabel {
    switch (type) {
      case 'invoice_created':
        return 'Hóa đơn mới';
      case 'payment_success':
        return 'Thanh toán';
      case 'price_change':
        return 'Thay đổi giá';
      case 'reminder':
        return 'Nhắc nhở';
      default:
        return 'Thông báo';
    }
  }
}
