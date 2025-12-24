import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationScheduler {
  final FlutterLocalNotificationsPlugin plugin;
  final StreamController<NotificationResponse> streamController;

  // Channel IDs
  static const String scheduledChannelId = 'scheduled_channel';
  static const String repeatChannelId = 'repeat_channel';

  NotificationScheduler(this.plugin, this.streamController);

  int _asId(String value) => value.hashCode & 0x7fffffff;

  NotificationDetails _scheduledDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        scheduledChannelId,
        'Scheduled Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  NotificationDetails _repeatDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        repeatChannelId,
        'Repeating Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  String _safeBody(String? desc) => (desc ?? '').isNotEmpty ? desc! : '';

  Future<bool> scheduleOneTime({
    required dynamic task,
    required DateTime dateTime,
  }) async {
    final id = _asId(task.id);
    final tzDate = tz.TZDateTime.from(dateTime, tz.local);
    final details = _scheduledDetails();

    try {
      await plugin.zonedSchedule(
        id,
        task.title,
        _safeBody(task.description),
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      try {
        await plugin.zonedSchedule(
          id,
          task.title,
          task.description,
          tzDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {}
      return false;
    }
  }

  Future<bool> scheduleRepeat({
    required dynamic task,
    required DateTime start,
    bool daily = false,
    int? intervalHours,
  }) async {
    final id = _asId(task.id);
    final details = _repeatDetails();

    if (intervalHours == null || intervalHours == 24) {
      return _scheduleNativeDaily(id, task, details);
    }

    if (intervalHours == 1) {
      return _scheduleNativeHourly(id, task, details);
    }

    return _scheduleCustomNHours(task, start, intervalHours, details);
  }

  Future<bool> _scheduleNativeDaily(
      int id, dynamic task, NotificationDetails details) async {
    try {
      await plugin.periodicallyShow(
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

  Future<bool> _scheduleNativeHourly(
      int id, dynamic task, NotificationDetails details) async {
    try {
      await plugin.periodicallyShow(
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

  Future<bool> _scheduleCustomNHours(
      dynamic task,
      DateTime start,
      int? interval,
      NotificationDetails details) async {
    const allowed = {1, 3, 6, 9, 12};
    if (interval == null || !allowed.contains(interval)) return false;

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

        await plugin.zonedSchedule(
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

  Future<void> cancel(int id) => plugin.cancel(id);

  Future<void> cancelTask(String taskId) async {
    final baseId = _asId(taskId);
    await plugin.cancel(baseId);

    for (int i = 0; i < 8; i++) {
      await plugin.cancel(_asId('${taskId}_repeat_$i'));
    }
  }

  Future<List<int>> scheduleTextRepeatNotification({
    required String idBaseString,
    required String title,
    required DateTime firstDateTime,
    required String body,
    required Duration repeatInterval,
  }) async {
    return await scheduleTextRepeat(
      idBaseString: idBaseString,
      title: title,
      firstDateTime: firstDateTime,
      body: body,
      repeatInterval: repeatInterval,
    );
  }

  Future<List<int>> scheduleTextRepeat({
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
        await plugin.zonedSchedule(
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
          await plugin.zonedSchedule(
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

    final id = _asId(idBaseString);
    ids.add(id);

    try {
      await plugin.zonedSchedule(
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

  /// Backwards-compatible cancel method used by older helpers.
  Future<void> cancelNotification(int id) async {
    await cancel(id);
  }

  /// Backwards-compatible one-time schedule helper that mirrors earlier
  /// API shape used across the codebase.
  Future<bool?> notifyForTaskScheduled(dynamic task, DateTime scheduledDateTime) async {
    try {
      final ok = await scheduleOneTime(task: task, dateTime: scheduledDateTime);
      return ok;
    } catch (_) {
      return null;
    }
  }
}
