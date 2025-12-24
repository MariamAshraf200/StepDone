import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_scheduler.dart';
import 'timezone_helper.dart';

class LocalNotificationService {
  // Core Plugin + Stream (kept public API same as before)
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> streamController =
      StreamController.broadcast();

  // Internal scheduler (initialized in init)
  static late final NotificationScheduler _scheduler;

  // -------------------------------------------------------------
  // INIT
  // -------------------------------------------------------------
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTap,
    );

    // create scheduler after plugin and stream exist
    _scheduler = NotificationScheduler(_plugin, streamController);

    // initialize timezone using helper
    await TimezoneHelper.initLocalTimeZone();
  }

  // Stream handler
  static void _onTap(NotificationResponse response) {
    streamController.add(response);
  }

  // -------------------------------------------------------------
  //  ONE-TIME SCHEDULE
  // -------------------------------------------------------------
  static Future<bool> scheduleOneTime({
    required dynamic task,
    required DateTime dateTime,
  }) async {
    return await _scheduler.scheduleOneTime(task: task, dateTime: dateTime);
  }

  // -------------------------------------------------------------
  //  REPEATING NOTIFICATIONS
  // -------------------------------------------------------------
  static Future<bool> scheduleRepeat({
    required dynamic task,
    required DateTime start,
    bool daily = false,
    int? intervalHours,
  }) async {
    return await _scheduler.scheduleRepeat(
      task: task,
      start: start,
      daily: daily,
      intervalHours: intervalHours,
    );
  }

  // -------------------------------------------------------------
  // CANCEL
  // -------------------------------------------------------------
  static Future<void> cancel(int id) => _scheduler.cancel(id);

  static Future<void> cancelTask(String taskId) async {
    await _scheduler.cancelTask(taskId);
  }

  // -------------------------------------------------------------
  // COMPATIBILITY – OLD SCHEDULERS
  // -------------------------------------------------------------
  static Future<List<int>> scheduleTextRepeatNotification({
    required String idBaseString,
    required String title,
    required DateTime firstDateTime,
    required String body,
    required Duration repeatInterval,
  }) async {
    return await _scheduler.scheduleTextRepeatNotification(
      idBaseString: idBaseString,
      title: title,
      firstDateTime: firstDateTime,
      body: body,
      repeatInterval: repeatInterval,
    );
  }

  static Future<List<int>> scheduleTextRepeat({
    required String idBaseString,
    required String title,
    required DateTime firstDateTime,
    required String body,
    required Duration repeatInterval,
  }) async {
    return await _scheduler.scheduleTextRepeat(
      idBaseString: idBaseString,
      title: title,
      firstDateTime: firstDateTime,
      body: body,
      repeatInterval: repeatInterval,
    );
  }

  // -------------------------------------------------------------
  // Compatibility wrappers expected by older call sites
  // -------------------------------------------------------------
  /// Backwards-compatible cancel method used by older helpers.
  static Future<void> cancelNotification(int id) async {
    await cancel(id);
  }

  /// Backwards-compatible one-time schedule helper that mirrors earlier
  /// API shape used across the codebase.
  static Future<bool?> notifyForTaskScheduled(dynamic task, DateTime scheduledDateTime) async {
    try {
      final ok = await scheduleOneTime(task: task, dateTime: scheduledDateTime);
      return ok;
    } catch (_) {
      return null;
    }
  }
}
