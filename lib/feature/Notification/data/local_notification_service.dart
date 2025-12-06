import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class LocalNotificationService {
  // -------------------------------------------------------------
  // Core Plugin + Stream
  // -------------------------------------------------------------
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse> streamController =
  StreamController.broadcast();

  // -------------------------------------------------------------
  // Channels
  // -------------------------------------------------------------
  static const String _scheduledChannelId = 'scheduled_channel';
  static const String _repeatChannelId = 'repeat_channel';

  // -------------------------------------------------------------
  // Utility – Build stable positive integer from unique string
  // -------------------------------------------------------------
  static int _asId(String value) => value.hashCode & 0x7fffffff;

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

    await _initTimeZone();
  }

  // Timezone Init (cleaned & simplified)
  static Future<void> _initTimeZone() async {
    tz.initializeTimeZones();

    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();

      final String zoneName = _extractTzName(tzResult);
      tz.setLocalLocation(tz.getLocation(zoneName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static String _extractTzName(dynamic tzResult) {
    if (tzResult is String) return tzResult;

    try {
      return tzResult.identifier ??
          tzResult.name ??
          tzResult.value ??
          tzResult.timezone ??
          tzResult.tz ??
          tzResult.toString();
    } catch (_) {
      return 'UTC';
    }
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
    final id = _asId(task.id);
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    final details = _scheduledDetails();

    try {
      await _plugin.zonedSchedule(
        id,
        task.title,
        _safeBody(task.description),
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

  static NotificationDetails _scheduledDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _scheduledChannelId,
        'Scheduled Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  static String _safeBody(String desc) =>
      desc.isNotEmpty ? desc : '';

  // -------------------------------------------------------------
  //  REPEATING NOTIFICATIONS (Daily, Hourly, Every-N Hours)
  // -------------------------------------------------------------
  static Future<bool> scheduleRepeat({
    required dynamic task,
    required DateTime start,
    bool daily = false,
    int? intervalHours,
  }) async {
    final id = _asId(task.id);
    final details = _repeatDetails();

    // ---------- PLATFORM SIMPLE DAILY ----------
    if (intervalHours == null || intervalHours == 24) {
      return _scheduleNativeDaily(id, task, details);
    }

    // ---------- PLATFORM SIMPLE HOURLY ----------
    if (intervalHours == 1) {
      return _scheduleNativeHourly(id, task, details);
    }

    // ---------- CUSTOM EVERY N HOURS ----------
    return _scheduleCustomNHours(task, start, intervalHours, details);
  }

  static NotificationDetails _repeatDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _repeatChannelId,
        'Repeating Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  static Future<bool> _scheduleNativeDaily(
      int id,
      dynamic task,
      NotificationDetails details,
      ) async {
    try {
      await _plugin.periodicallyShow(
        id,
        task.title,
        _safeBody(task.description),
        RepeatInterval.daily,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _scheduleNativeHourly(
      int id,
      dynamic task,
      NotificationDetails details,
      ) async {
    try {
      await _plugin.periodicallyShow(
        id,
        task.title,
        _safeBody(task.description),
        RepeatInterval.hourly,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _scheduleCustomNHours(
      dynamic task,
      DateTime start,
      int interval,
      NotificationDetails details,
      ) async {
    const allowed = {1, 3, 6, 9, 12};
    if (!allowed.contains(interval)) return false;

    final now = tz.TZDateTime.now(tz.local);
    final base = tz.TZDateTime.from(start, tz.local);

    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      base.hour,
      base.minute,
      base.second,
    );

    if (next.isBefore(now)) next = next.add(const Duration(days: 1));

    final steps = 24 ~/ interval;

    try {
      for (int i = 0; i < steps; i++) {
        final offset = Duration(hours: interval * i);
        final scheduled = next.add(offset);
        final id = _asId('${task.id}_repeat_$i');

        await _plugin.zonedSchedule(
          id,
          task.title,
          _safeBody(task.description),
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------
  // CANCEL
  // -------------------------------------------------------------
  static Future<void> cancel(int id) => _plugin.cancel(id);

  static Future<void> cancelTask(String taskId) async {
    final baseId = _asId(taskId);
    await _plugin.cancel(baseId);

    for (int i = 0; i < 8; i++) {
      await _plugin.cancel(_asId('${taskId}_repeat_$i'));
    }
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
     // Backwards-compatible alias for older code that expected the
     // `scheduleTextRepeatNotification` name. Delegates to the
     // internal `scheduleTextRepeat` implementation.
     return await scheduleTextRepeat(
       idBaseString: idBaseString,
       title: title,
       firstDateTime: firstDateTime,
       body: body,
       repeatInterval: repeatInterval,
     );
   }

   // -------------------------------------------------------------
   // COMPATIBILITY – OLD SCHEDULERS
   // -------------------------------------------------------------
   static Future<List<int>> scheduleTextRepeat({
    required String idBaseString,
    required String title,
    required DateTime firstDateTime,
    required String body,
    required Duration repeatInterval,
  }) async {
    final ids = <int>[];
    final details = _repeatDetails();
    final now = tz.TZDateTime.now(tz.local);
    final start = tz.TZDateTime.from(firstDateTime, tz.local);

    // --- Daily ---
    if (repeatInterval.inHours == 24) {
      var first = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      );

      if (first.isBefore(now)) first = first.add(const Duration(days: 1));

      final id = _asId(idBaseString);
      ids.add(id);

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          first,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (_) {}

      return ids;
    }

    // --- Every N Hours ---
    const allowed = {1, 3, 6, 9, 12};
    if (allowed.contains(repeatInterval.inHours)) {
      final step = repeatInterval.inHours;
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      );

      if (next.isBefore(now)) next = next.add(const Duration(days: 1));

      final count = 24 ~/ step;

      for (int i = 0; i < count; i++) {
        final scheduled = next.add(Duration(hours: i * step));
        final id = _asId('${idBaseString}_repeat_$i');
        ids.add(id);

        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            scheduled,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        } catch (_) {}
      }

      return ids;
    }

    // --- Default (One-time) ---
    final id = _asId(idBaseString);
    ids.add(id);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(firstDateTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}

    return ids;
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
