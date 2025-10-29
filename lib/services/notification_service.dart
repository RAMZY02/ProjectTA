import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const String _downloadChannelId = 'download_channel';
  static const String _downloadChannelName = 'Download Notifications';
  static const String _progressChannelId = 'download_progress_channel';
  static const String _progressChannelName = 'Download Progress';

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Buat notification channels untuk Android
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    // Channel untuk notifikasi biasa (high importance)
    const AndroidNotificationChannel downloadChannel = AndroidNotificationChannel(
      _downloadChannelId,
      _downloadChannelName,
      description: 'Notifications for download completion',
      importance: Importance.high,
      playSound: true,
    );

    // Channel untuk progress notification (low importance)
    const AndroidNotificationChannel progressChannel = AndroidNotificationChannel(
      _progressChannelId,
      _progressChannelName,
      description: 'Notifications for download progress',
      importance: Importance.low,
      playSound: false,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(downloadChannel);
      await androidPlugin.createNotificationChannel(progressChannel);
    }
  }

  static Future<void> showDownloadNotification({
    required String title,
    required String body,
    int? progress,
    bool isProgress = false,
    int notificationId = 0,
  }) async {

    // Generate unique ID jika tidak disediakan
    final int id = notificationId == 0
        ? DateTime.now().millisecondsSinceEpoch.remainder(100000)
        : notificationId;

    try {
      if (isProgress && progress != null) {
        // Notifikasi dengan progress bar
        final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _progressChannelId,
          _progressChannelName,
          channelDescription: 'Notifications for download progress',
          importance: Importance.low,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          indeterminate: progress == 0,
          onlyAlertOnce: true,
          ongoing: true,
          autoCancel: false,
        );

        final NotificationDetails details = NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            threadIdentifier: 'download-progress',
          ),
        );

        await _notifications.show(id, title, body, details);
      } else {
        // Notifikasi biasa
        const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _downloadChannelId,
          _downloadChannelName,
          channelDescription: 'Notifications for download completion',
          importance: Importance.high,
          playSound: true,
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _notifications.show(id, title, body, details);
      }
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    int notificationId = 0,
  }) async {
    final int id = notificationId == 0
        ? DateTime.now().millisecondsSinceEpoch.remainder(100000)
        : notificationId;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      _downloadChannelId,
      _downloadChannelName,
      channelDescription: 'Notifications for download completion',
      importance: Importance.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  static Future<void> cancelProgressNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  // Method untuk testing
  static Future<void> testNotification() async {
    await showSimpleNotification(
      title: 'Test Notification',
      body: 'Notification service is working!',
    );
  }
}