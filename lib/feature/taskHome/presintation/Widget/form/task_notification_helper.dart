import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapperapp/injection_imports.dart';
import '../../../../Notification/data/local_notification_service.dart';

/// A clean helper class that manages scheduling, sending, and cancelling
/// notifications for TaskDetails objects.
class TaskNotificationHelper {
  TaskNotificationHelper._(); // Prevent instantiation

  /// Schedule or show an immediate notification for a task.
  ///
  /// Logic:
  /// - If `notificationDate` or `notificationTime` is set → schedule for that moment.
  /// - If not → show immediately.
  ///
  /// Returns:
  /// - `true`: exact scheduled alarm.
  /// - `false`: inexact schedule (fallback mode).
  /// - `null`: immediate notification.
  static Future<bool?> scheduleOrNotifyForTask(TaskDetails task) async {
    try {
      final scheduledDateTime = _parseScheduledDateTime(task);

      // If a future date is valid → schedule
      if (scheduledDateTime != null && scheduledDateTime.isAfter(DateTime.now())) {
        try {
          return await LocalNotificationService.notifyForTaskScheduled(task, scheduledDateTime);
        } on PlatformException catch (e) {
          if (e.code == 'exact_alarms_not_permitted') {
            debugPrint('⚠️ Exact alarms not permitted: ${e.message}');
            return false;
          }
          debugPrint('⚠️ Scheduling error: ${e.code} - ${e.message}');
          await LocalNotificationService.notifyForTask(task);
          return null;
        }
      }

      // Otherwise show immediately
      await LocalNotificationService.notifyForTask(task);
      return null;
    } catch (e, st) {
      debugPrint('❌ scheduleOrNotifyForTask failed: $e\n$st');
      return null;
    }
  }

  /// Parse the task’s date and time fields safely into a DateTime object.
  static DateTime? _parseScheduledDateTime(TaskDetails task) {
    try {
      final dateSource = task.notificationDate.isNotEmpty ? task.notificationDate : task.date;
      final timeSource = task.notificationTime.isNotEmpty ? task.notificationTime : task.time;

      if (dateSource.isEmpty) return null;

      final parsedDate = DateFormatUtil.parseDate(dateSource);
      final parsedTime = (timeSource.isNotEmpty)
          ? TimeFormatUtil.tryParse(timeSource)
          : const TimeOfDay(hour: 9, minute: 0);

      return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, parsedTime!.hour, parsedTime.minute);
    } catch (e) {
      debugPrint('⚠️ Failed to parse date/time for task: $e');
      return null;
    }
  }

  /// Cancel any scheduled notification for a task using its hashed id.
  static Future<void> cancelForTask(TaskDetails task) async {
    final notifyId = task.id.hashCode & 0x7fffffff;
    try {
      await LocalNotificationService.cancelNotification(notifyId);
      debugPrint('🟢 Notification $notifyId cancelled successfully.');
    } catch (e, st) {
      debugPrint('❌ Failed to cancel notification $notifyId: $e\n$st');
    }
  }
}
