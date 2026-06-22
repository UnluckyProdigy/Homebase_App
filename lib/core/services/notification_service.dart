import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _lowStockChannelId = 'low_stock_alerts';
  static const _expirationChannelId = 'expiration_alerts';

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<void> showLowStockNotification({
    required int id,
    required String itemName,
    required int quantity,
    required int threshold,
    bool isMustHave = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _lowStockChannelId,
      'Low Stock Alerts',
      channelDescription: 'Notifications when inventory items are running low',
      importance: isMustHave ? Importance.high : Importance.defaultImportance,
      priority: isMustHave ? Priority.high : Priority.defaultPriority,
    );

    final details = NotificationDetails(android: androidDetails);

    final title = quantity == 0 ? '$itemName is out of stock!' : 'Low stock: $itemName';
    final body = quantity == 0
        ? 'You\'re out of $itemName. Time to restock!'
        : 'Only $quantity left (threshold: $threshold)';

    await _plugin.show(id, title, body, details);
  }

  static Future<void> showExpirationNotification({
    required int id,
    required String itemName,
    required bool isExpired,
    required int daysLeft,
    bool isMustHave = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _expirationChannelId,
      'Expiration Alerts',
      channelDescription: 'Notifications when items are expiring soon',
      importance: isExpired ? Importance.high : Importance.defaultImportance,
      priority: isExpired ? Priority.high : Priority.defaultPriority,
    );

    final details = NotificationDetails(android: androidDetails);

    final title = isExpired ? '$itemName has expired!' : '$itemName expiring soon';
    final body = isExpired
        ? '$itemName has passed its expiration date'
        : '$itemName expires in $daysLeft day${daysLeft == 1 ? '' : 's'}';

    await _plugin.show(id + 10000, title, body, details);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
