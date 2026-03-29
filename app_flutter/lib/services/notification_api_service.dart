import 'package:app_flutter/models/app_notification.dart';
import 'package:app_flutter/services/api_client.dart';

class NotificationApiService {
  final ApiClient _api = ApiClient();

  Future<List<AppNotification>> fetchNotifications() async {
    final data = await _api.get('/notifications/');
    return _api.parseList(data, AppNotification.fromJson);
  }

  Future<void> markAsRead(int id) async {
    await _api.patch('/notifications/$id/', body: {'is_read': true});
  }

  Future<void> markAllAsRead() async {
    await _api.post('/notifications/mark_all_read/');
  }

  Future<int> fetchUnreadCount() async {
    final notifications = await fetchNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> registerFcmToken(String fcmToken) async {
    await _api.post('/notifications/register_device/', body: {
      'token': fcmToken,
      'type': 'android',
    });
  }
}
