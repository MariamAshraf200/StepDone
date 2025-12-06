import 'package:flutter/material.dart';
import '../../../../../core/util/date_and_time/date_format_util.dart';
import '../../../../../core/util/date_and_time/time_format_util.dart';
import '../../../../Notification/data/local_notification_service.dart';
import '../../../domain/entity/taskEntity.dart';

/// One-time ONLY notification helper for tasks.
class TaskNotificationHelper {
  TaskNotificationHelper._();

  static Future<bool?> scheduleOrNotifyForTask(TaskDetails task) async {
    try {
      final scheduled = _parseTaskDate(task);

      // Scheduled once
      if (scheduled != null && scheduled.isAfter(DateTime.now())) {
        return await LocalNotificationService.notifyForTaskScheduled(task, scheduled);
      }

    } catch (e) {
      debugPrint("❌ Error: $e");
      return null;
    }
  }

  static DateTime? _parseTaskDate(TaskDetails task) {
    try {
      final dateStr = task.notificationDate.isNotEmpty
          ? task.notificationDate
          : task.date;

      final timeStr = task.notificationTime.isNotEmpty
          ? task.notificationTime
          : task.time;

      if (dateStr.isEmpty) return null;

      final d = DateFormatUtil.parseDate(dateStr);
      final t = timeStr.isNotEmpty
          ? TimeFormatUtil.tryParse(timeStr)
          : const TimeOfDay(hour: 9, minute: 0);

      return DateTime(d.year, d.month, d.day, t!.hour, t.minute);

    } catch (_) {
      return null;
    }
  }

  static Future<void> cancelForTask(TaskDetails task) async {
    final id = task.id.hashCode & 0x7fffffff;
    await LocalNotificationService.cancelNotification(id);
  }
}
