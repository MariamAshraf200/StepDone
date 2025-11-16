import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../taskHome/domain/entity/taskEntity.dart';

class LocalNotificationService {
  // Plugin
  static final _plugin = FlutterLocalNotificationsPlugin();

  // Stream: notification tap
  static final StreamController<NotificationResponse> streamController =
  StreamController.broadcast();

  // Channels
  static const _basicChannelId = 'basic_channel';
  static const _scheduledChannelId = 'scheduled_channel';
  static const _repeatChannelId = 'repeat_channel';

  // Hash string → int
  static int _idFromString(String value) =>
      value.hashCode & 0x7fffffff;

  // ---------------------------------------------------------
  // INIT
  // ---------------------------------------------------------
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTap,
    );

    // TimeZone
    tz.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName.identifier));
  }

  static void _onTap(NotificationResponse response) {
    streamController.add(response);
  }

  // ---------------------------------------------------------
  // SAFE SHOW
  // ---------------------------------------------------------
  static Future<void> _safeShow({
    required int id,
    required String title,
    required String body,
    required NotificationDetails details,
    String? payload,
  }) async {
    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } on PlatformException catch (e) {
      if (e.code.contains('sound')) {
        final fallback = NotificationDetails(
          android: AndroidNotificationDetails(
            _basicChannelId,
            'Basic Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        );
        await _plugin.show(id, title, body, fallback, payload: payload);
      } else {
        rethrow;
      }
    }
  }

  // ---------------------------------------------------------
  // IMMEDIATE NOTIFICATION
  // ---------------------------------------------------------
  static Future<void> notifyForTask(TaskDetails task) async {
    if (!task.notification) return;

    final id = _idFromString(task.id);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _basicChannelId,
        'Basic Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _safeShow(
      id: id,
      title: task.title,
      body: task.description.isNotEmpty ? task.description : '',
      details: details,
      payload: task.id,
    );
  }

  // ---------------------------------------------------------
  // SCHEDULE SPECIFIC DATE
  // ---------------------------------------------------------
  static Future<bool> notifyForTaskScheduled(
      TaskDetails task,
      DateTime scheduledDateTime,
      ) async {
    if (!task.notification) return false;

    final id = _idFromString(task.id);
    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _scheduledChannelId,
        'Scheduled Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    try {
      await _plugin.zonedSchedule(
        id,
        task.title,
        task.description.isNotEmpty ? task.description : '',
        tzDateTime,
        details,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      await _plugin.zonedSchedule(
        id,
        task.title,
        task.description,
        tzDateTime,
        details,
        payload: task.id,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return false;
    }
  }

  // ---------------------------------------------------------
  // REPEAT DAILY or EVERY X DAYS
  // ---------------------------------------------------------
  static Future<List<int>> scheduleTextRepeatNotification({
    required String idBaseString,
    String title = 'Reminder',
    required String text,
    required DateTime firstDateTime,
    int daysInterval = 1,
    int occurrences = 60,
    String? payload,
  }) async {
    final baseId = _idFromString(idBaseString);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _repeatChannelId,
        'Repeat Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final firstTZ = tz.TZDateTime.from(firstDateTime, tz.local);
    final ids = <int>[];

    // -------------------------------------------------------------
    // 🔹 DAILY REPEAT
    // -------------------------------------------------------------
    if (daysInterval == 1) {
      await _plugin.zonedSchedule(
        baseId,
        title,
        text,
        firstTZ,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // ⭐ مهم
      );
      return [baseId];
    }

    // -------------------------------------------------------------
    // 🔹 EVERY X DAYS — MANUALLY GENERATE FUTURE OCCURRENCES
    // -------------------------------------------------------------
    for (int i = 0; i < occurrences; i++) {
      final id = baseId + i;
      final date = firstTZ.add(Duration(days: daysInterval * i));

      // تجاهل المواعيد التي مرّ وقتها
      if (date.isBefore(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        id,
        title,
        text,
        date,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      ids.add(id);
    }

    return ids;
  }

  // ---------------------------------------------------------
  // CANCEL
  // ---------------------------------------------------------
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
