import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _hasPermission = false;

  NotificationService._init();

  Future<void> init() async {
    try {
      // Initialize timezone data safely
      if (!_isTimeZoneInitialized()) {
        tz.initializeTimeZones();
      }

      const android = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: android,
        iOS: iOS,
      );

      final initialized = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      _isInitialized = initialized ?? false;

      if (_isInitialized) {
        await requestPermission();
      }

      debugPrint('NotificationService initialized: $_isInitialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
    }
  }

  // Check if timezone is already initialized
  bool _isTimeZoneInitialized() {
    try {
      tz.local;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Handle notification tap response
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap here if needed
  }

  Future<void> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        final granted = await androidImpl?.requestNotificationsPermission();
        _hasPermission = granted ?? false;

        // Also request exact alarm permission for Android 12+
        if (Platform.isAndroid) {
          await androidImpl?.requestExactAlarmsPermission();
        }
      } else if (Platform.isIOS) {
        final iosImpl = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        final granted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        _hasPermission = granted ?? false;
      }

      debugPrint('Notification permission granted: $_hasPermission');
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      _hasPermission = false;
    }
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'timetable_channel_id',
        'Timetable Notifications',
        channelDescription: 'Class schedule and timetable notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/launcher_icon',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      ),
    );
  }

  Future<bool> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    try {
      // Check if service is properly initialized
      if (!_isInitialized) {
        debugPrint('NotificationService not initialized');
        return false;
      }

      if (!_hasPermission) {
        debugPrint('No notification permission');
        return false;
      }

      // Validate input parameters
      if (title.isEmpty || body.isEmpty) {
        debugPrint('Invalid notification content');
        return false;
      }

      // Validate and convert DateTime to TZDateTime
      tz.TZDateTime scheduled;
      try {
        scheduled = tz.TZDateTime.from(dateTime, tz.local);
      } catch (e) {
        debugPrint('Error converting DateTime to TZDateTime: $e');
        return false;
      }

      // Skip past notifications with a small buffer (1 minute)
      final now = tz.TZDateTime.now(tz.local);
      if (scheduled.isBefore(now.add(const Duration(minutes: 1)))) {
        debugPrint('Skipping past notification for: $title');
        return false;
      }

      // Don't schedule too far in the future (more than 30 days)
      if (scheduled.isAfter(now.add(const Duration(days: 30)))) {
        debugPrint('Skipping notification too far in future: $title');
        return false;
      }

      // Schedule the notification
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // This makes it recurring weekly
        payload: payload,
        // uiLocalNotificationDateInterpretation:
        // UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('Scheduled notification $id: $title at $scheduled');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification $id: $e');
      return false;
    }
  }

  Future<bool> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    try {
      // Check if service is properly initialized
      if (!_isInitialized) {
        debugPrint('NotificationService not initialized');
        return false;
      }

      if (!_hasPermission) {
        debugPrint('No notification permission');
        return false;
      }

      // Validate input parameters
      if (title.isEmpty || body.isEmpty) {
        debugPrint('Invalid notification content');
        return false;
      }

      // Validate and convert DateTime to TZDateTime
      tz.TZDateTime scheduled;
      try {
        scheduled = tz.TZDateTime.from(dateTime, tz.local);
      } catch (e) {
        debugPrint('Error converting DateTime to TZDateTime: $e');
        return false;
      }

      // Skip past notifications
      final now = tz.TZDateTime.now(tz.local);
      if (scheduled.isBefore(now.add(const Duration(minutes: 1)))) {
        debugPrint('Skipping past notification for: $title');
        return false;
      }

      // Schedule the notification (one-time only)
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        // uiLocalNotificationDateInterpretation:
        // UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime
      );

      debugPrint('Scheduled one-time notification $id: $title at $scheduled');
      return true;
    } catch (e) {
      debugPrint('Error scheduling one-time notification $id: $e');
      return false;
    }
  }

  Future<bool> cancelAll() async {
    try {
      if (!_isInitialized) {
        debugPrint('NotificationService not initialized');
        return false;
      }

      await _plugin.cancelAll();
      debugPrint('All notifications cancelled');
      return true;
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
      return false;
    }
  }

  Future<bool> cancel(int id) async {
    try {
      if (!_isInitialized) {
        debugPrint('NotificationService not initialized');
        return false;
      }

      await _plugin.cancel(id);
      debugPrint('Notification $id cancelled');
      return true;
    } catch (e) {
      debugPrint('Error cancelling notification $id: $e');
      return false;
    }
  }

  // Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      if (!_isInitialized) {
        return [];
      }
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  // Check if notifications are available
  Future<bool> isAvailable() async {
    try {
      return _isInitialized && (Platform.isAndroid || Platform.isIOS);
    } catch (e) {
      return false;
    }
  }

  // Check if we have notification permission
  Future<bool> hasPermission() async {
    try {
      if (!_isInitialized) {
        return false;
      }

      if (Platform.isAndroid) {
        final androidImpl = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final permitted = await androidImpl?.areNotificationsEnabled();
        return permitted ?? false;
      } else if (Platform.isIOS) {
        // For iOS, we assume permission if initialization was successful
        return _hasPermission;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  // Get initialization status
  bool get isInitialized => _isInitialized;

  // Test notification
  Future<bool> showTestNotification() async {
    try {
      const title = 'Test Notification';
      const body = 'This is a test notification from your timetable app.';

      await _plugin.show(
        0,
        title,
        body,
        _details(),
        payload: 'test_notification',
      );

      return true;
    } catch (e) {
      debugPrint('Error showing test notification: $e');
      return false;
    }
  }
}