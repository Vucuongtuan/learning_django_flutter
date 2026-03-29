import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_flutter/services/notification_api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FcmService.instance.showLocalNotification(
    title: message.notification?.title,
    body: message.notification?.body,
    payload: message.data['route'],
  );
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationApiService _notificationApi = NotificationApiService();

  Timer? _pollingTimer;
  bool _initialized = false;

  bool get _isFcmPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  bool get _isDesktopPolling =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _setupLocalNotifications();

    if (_isFcmPlatform) {
      await _setupFcm();
    } else if (kIsWeb) {
      await _setupWebPush();
    }

    if (_isDesktopPolling) {
      _startPolling();
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Mở thông báo');

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'the_ledger_high',
          'Thông báo quan trọng',
          description: 'Kênh thông báo hóa đơn, thanh toán, nhắc nợ',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          showBadge: true,
          enableLights: true,
        ),
      );
    }
  }

  Future<void> _setupFcm() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        payload: message.data['route'],
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleFcmMessageOpened);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleFcmMessageOpened(initialMessage);
    }

    try {
      final token = await messaging.getToken();
      if (token != null) {
        await _notificationApi.registerFcmToken(token);
      }
      messaging.onTokenRefresh.listen((newToken) {
        _notificationApi.registerFcmToken(newToken);
      });
    } catch (_) {}
  }

  Future<void> _setupWebPush() async {
    if (!kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken(
          vapidKey: null,
        );
        if (token != null) {
          await _notificationApi.registerFcmToken(token);
        }
      }
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showLocalNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          payload: message.data['route'],
        );
      });
    } catch (_) {}
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _pollNewNotifications();
    });
  }

  Future<void> _pollNewNotifications() async {
    try {
      final notifications = await _notificationApi.fetchNotifications();
      final unread = notifications.where((n) => !n.isRead).toList();

      for (final notif in unread) {
        await showLocalNotification(
          title: notif.typeLabel,
          body: notif.message,
          id: notif.id,
        );
        await _notificationApi.markAsRead(notif.id);
      }
    } catch (_) {}
  }

  Future<void> showLocalNotification({
    String? title,
    String? body,
    String? payload,
    int? id,
  }) async {
    if (title == null && body == null) return;

    const androidDetails = AndroidNotificationDetails(
      'the_ledger_high',
      'Thông báo quan trọng',
      channelDescription: 'Kênh thông báo hóa đơn, thanh toán, nhắc nợ',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.message,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    await _localNotifications.show(
      id ?? title.hashCode ^ body.hashCode,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleFcmMessageOpened(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null) {
      _navigateToRoute(route);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _navigateToRoute(payload);
    }
  }

  void _navigateToRoute(String route) {}

  void dispose() {
    _pollingTimer?.cancel();
  }
}
