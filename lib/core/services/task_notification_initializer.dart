import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../feature/notification/data/datasource/local_notification_service.dart';
import '../../../injection_imports.dart';

/// Handles task-based notifications at app startup.
/// Called once in `main.dart` before the app runs.
class TaskNotificationInitializer {
  static Future<void> run() async {
    try {
      // ✅ 1. Initialize local notifications
      final notificationService = sl<LocalNotificationService>();
      await notificationService.init();

      // ✅ 2. Request permission (Android 13+)
      final permissionStatus = await Permission.notification.request();
      if (!permissionStatus.isGranted) {
        debugPrint('❌ Notification permission denied.');
        return;
      }
      debugPrint('✅ Notification permission granted.');

      // ✅ 3. Load all tasks
      final getAllTasks = sl<GetAllTasksUseCase>();
      final List<TaskDetails> allTasks = await getAllTasks();

      debugPrint('📋 Found ${allTasks.length} tasks');

      // ✅ 4. Filter eligible tasks
      final now = DateTime.now();
      final List<TaskDetails> notifiableTasks = allTasks.where((t) {
        if (!t.hasNotification || t.notifyAt == null) return false;

        final notifyAt = t.notifyAt!;
        final endTime = t.endTimeDateTime ?? notifyAt.add(const Duration(hours: 1));

        // Eligible if the task is upcoming or currently active
        final isUpcomingOrCurrent =
            notifyAt.isBefore(now.add(const Duration(minutes: 5))) &&
                endTime.isAfter(now);

        return isUpcomingOrCurrent;
      }).toList();

      if (notifiableTasks.isEmpty) {
        debugPrint('ℹ️ No eligible tasks for notification.');
        return;
      }

      // ✅ 5. Sort by nearest notifyAt
      notifiableTasks.sort((a, b) => a.notifyAt!.compareTo(b.notifyAt!));

      // ✅ 6. Schedule repeating notifications for every eligible task
      const int repeatIntervalSeconds = 10;

      for (final task in notifiableTasks) {
        debugPrint('🔔 Preparing notification for: ${task.title} → notifyAt=${task.notifyAt}, end=${task.endTimeDateTime}');

        // Cancel any previously scheduled reminders for this task to avoid duplicates
        try {
          await notificationService.cancel(task.id.hashCode);
        } catch (_) {}

        // Decide start time: if notifyAt is in the future use it, otherwise start immediately
        final DateTime startTime = task.notifyAt != null && task.notifyAt!.isAfter(now)
            ? task.notifyAt!
            : DateTime.now().add(const Duration(seconds: 1));

        // If the start time is in the future, schedule a delayed callback to start the in-app repeater then.
        if (startTime.isAfter(DateTime.now())) {
          final delay = startTime.difference(DateTime.now());
          Future.delayed(delay, () {
            try {
              notificationService.startInAppRepeater(
                id: task.id.hashCode,
                title: task.title.isNotEmpty ? task.title : 'Task Reminder',
                body: task.description.isNotEmpty ? task.description : 'You have an upcoming task!',
                intervalSeconds: repeatIntervalSeconds,
                immediate: true,
              );
              debugPrint('🔁 In-app repeater started for "${task.title}" at $startTime');
            } catch (e) {
              debugPrint('⚠️ Failed to start in-app repeater for ${task.title}: $e');
            }
          });
        } else {
          // Start immediately
          notificationService.startInAppRepeater(
            id: task.id.hashCode,
            title: task.title.isNotEmpty ? task.title : 'Task Reminder',
            body: task.description.isNotEmpty ? task.description : 'You have an upcoming task!',
            intervalSeconds: repeatIntervalSeconds,
            immediate: true,
          );
          debugPrint('🔁 In-app repeater started for "${task.title}" every ${repeatIntervalSeconds}s');
        }
      }
    } catch (e, st) {
      debugPrint('⚠️ TaskNotificationInitializer error: $e\n$st');
    }
  }
}
