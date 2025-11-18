
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static final StreamController<NotificationResponse> streamController =
  StreamController.broadcast();

  static const _basicChannelId = 'basic_channel';
  static const _scheduledChannelId = 'scheduled_channel';
  static const _repeatChannelId = 'repeat_channel';

  static int _idFromString(String value) =>
      value.hashCode & 0x7fffffff;

  // INIT
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTap,
    );

    tz.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName.identifier));
  }

  static void _onTap(NotificationResponse response) {
    streamController.add(response);
  }

  // Show immediately
  static Future<void> notifyNow(int id, String title, String body) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _basicChannelId,
        'Basic Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(id, title, body, details);
  }

  // One-time schedule
  static Future<bool> notifyForTaskScheduled(
      task,
      DateTime scheduledDateTime,
      ) async {
    final id = _idFromString(task.id);
    final tzDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

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
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        task.title,
        task.description,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return false;
    }
  }

  // Daily repeat
  static Future<List<int>> scheduleDaily({
    required String idBaseString,
    required String title,
    required String body,
    required DateTime firstDateTime,
  }) async {
    final id = _idFromString(idBaseString);
    final tzDate = tz.TZDateTime.from(firstDateTime, tz.local);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _repeatChannelId,
        'Daily Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    return [id];
  }

  // Every X days (AlarmManager)
  static Future<List<int>> scheduleEveryXDays({
    required String idBaseString,
    required String title,
    required String body,
    required DateTime firstDateTime,
    required int days,
  }) async {
    final id = _idFromString(idBaseString);

    await AndroidAlarmManager.cancel(id);

    await AndroidAlarmManager.periodic(
      Duration(days: days),
      id,
          () => notifyNow(id, title, body),
      startAt: firstDateTime,
      wakeup: true,
      rescheduleOnReboot: true,
      exact: true,
    );

    return [id];
  }

  static Future<List<int>> scheduleTextRepeatNotification({
    required String idBaseString,
    required String title,
    required String text,
    required DateTime firstDateTime,
    int daysInterval = 1,
  }) async {
    // لو يوميًا → استخدم daily schedule
    if (daysInterval == 1) {
      return await scheduleDaily(
        idBaseString: idBaseString,
        title: title,
        body: text,
        firstDateTime: firstDateTime,
      );
    }

    // لو كل X يوم → استخدم AlarmManager
    return await scheduleEveryXDays(
      idBaseString: idBaseString,
      title: title,
      body: text,
      firstDateTime: firstDateTime,
      days: daysInterval,
    );
  }


  // Cancel
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    await AndroidAlarmManager.cancel(id);
  }
}
