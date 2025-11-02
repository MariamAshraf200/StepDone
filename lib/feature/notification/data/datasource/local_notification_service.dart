import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Number of repeated notifications scheduled per call. Keep in sync with
  // scheduleNotification's occurrences value.
  static const int _repeatedOccurrences = 60;

  // In-app timers for repeating notifications while the app is running.
  final Map<int, Timer> _inAppTimers = {};
  final Map<int, bool> _chainActive = {};

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzResult = await FlutterTimezone.getLocalTimezone();

      // Coerce the returned value to a string and extract a usable IANA ID.
      final s = tzResult.toString();
      String timezone;
      // Try to extract the ID from TimezoneInfo(...) if that's the format.
      final tzInfoMatch = RegExp(r'TimezoneInfo\(\s*([^,\s)]+)').firstMatch(s);
      if (tzInfoMatch != null) {
        timezone = tzInfoMatch.group(1)!;
      } else {
        // Fall back to searching for an 'Area/Location' pattern (e.g. Africa/Cairo)
        final fallbackMatch = RegExp(r'([A-Za-z]+/[A-Za-z_+\-]+)').firstMatch(s);
        // If we can't find a match, use the raw string — tz.getLocation will
        // validate and we'll fall back to UTC in the outer try/catch if invalid.
        timezone = fallbackMatch?.group(1) ?? s;
      }

      // Validate that the timezone exists in the timezone database. If tz.getLocation
      // throws, fall back to UTC.
      try {
        tz.setLocalLocation(tz.getLocation(timezone));
        debugPrint('✅ Timezone set: $timezone');
      } catch (e) {
        debugPrint('⚠️ tz.getLocation failed for "$timezone": $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'task_channel',
      'Task Reminders',
      description: 'Channel for task reminder notifications',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('✅ LocalNotificationService initialized');
  }

  Future<void> requestPermission() async {
    final status = await Permission.notification.request();
    debugPrint('📱 Notification permission: $status');
  }

  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    int occurrences = _repeatedOccurrences,
    int intervalSeconds = 10,
    bool startImmediately = false,
  }) async {
    // Ensure we have permission to show notifications on the device
    await requestPermission();

    final startTime = startImmediately ? DateTime.now() : time;
    // Convert to a TZDateTime in the local timezone and ensure it's in the future.
    tz.TZDateTime tzStart;
    try {
      tzStart = tz.TZDateTime.from(startTime, tz.local);
    } catch (_) {
      tzStart = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1));
    }

    final tzNow = tz.TZDateTime.now(tz.local);
    if (tzStart.isBefore(tzNow) || tzStart.isAtSameMomentAs(tzNow)) {
      tzStart = tzNow.add(const Duration(seconds: 1));
    }

    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      // Schedule repeated notifications by enqueuing multiple future notifications.
      // This is intended for testing/demo purposes. Use small intervalSeconds for quick tests.
      for (var i = 0; i < occurrences; i++) {
        var scheduled = tzStart.add(Duration(seconds: i * intervalSeconds));
        final tzNowIter = tz.TZDateTime.now(tz.local);
        // Ensure scheduled is strictly in the future (plugin requires future dates)
        if (scheduled.isBefore(tzNowIter.add(const Duration(seconds: 1)))) {
          scheduled = tzNowIter.add(Duration(seconds: 1 + i * intervalSeconds));
        }
        await _plugin.zonedSchedule(
          id + i,
          title,
          body,
          scheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        // If this is a large batch, yield frequently (every iteration) to keep
        // the UI responsive. For smaller batches, yield occasionally.
        if (occurrences > 20) {
          await Future.delayed(const Duration(milliseconds: 10));
        } else if (i % 5 == 0) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      return true;
    } catch (e) {
      debugPrint('⚠️ Exact scheduling failed, fallback to enexact batch scheduling: $e');
      // Fallback: try scheduling with inexact mode
      try {
        const notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        );
        for (var i = 0; i < occurrences; i++) {
          final scheduled = tzStart.add(Duration(seconds: i * intervalSeconds));
          await _plugin.zonedSchedule(
            id + i,
            title,
            body,
            scheduled,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexact,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          if (occurrences > 20) {
            await Future.delayed(const Duration(milliseconds: 10));
          } else if (i % 5 == 0) {
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
        return false;
      } catch (e2) {
        debugPrint('⚠️ Batch scheduling also failed: $e2');
        return false;
      }
    }
  }

  Future<void> showNow(int id, String title, String body) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails('task_channel', 'Task Reminders'),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancel(int id) async {
    // Stop any in-app repeater first
    stopInAppRepeater(id);

    // Cancel the full batch scheduled by scheduleNotification (id..id+_repeatedOccurrences-1)
    try {
      for (var i = 0; i < _repeatedOccurrences; i++) {
        await _plugin.cancel(id + i);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to cancel some notifications for id $id: $e');
      // Try best-effort single cancel as a fallback
      await _plugin.cancel(id);
    }
  }

  /// Start an in-app repeating notification for [id]. The timer will run only
  /// while the app process is alive. Use [stopInAppRepeater] to cancel.
  void startInAppRepeater({
    required int id,
    required String title,
    required String body,
    required int intervalSeconds,
    bool immediate = true,
  }) {
    // Use chain repeater implementation for robustness
    startChainRepeater(
      id: id,
      title: title,
      body: body,
      intervalSeconds: intervalSeconds,
      immediate: immediate,
    );
  }

  /// Chain-based repeater: shows a notification, waits [intervalSeconds], then
  /// shows the next, repeating while the app is alive and [stopChainRepeater]
  /// hasn't been called for this id. This avoids scheduling huge batches up
  /// front and keeps only looped async work in Dart.
  void startChainRepeater({
    required int id,
    required String title,
    required String body,
    required int intervalSeconds,
    bool immediate = true,
  }) {
    // Stop any previous chain for this id
    stopChainRepeater(id);

    _chainActive[id] = true;

    Future<void>(() async {
      try {
        if (immediate && (_chainActive[id] ?? false)) {
          await showNow(id, title, body);
        }

        while (_chainActive[id] == true) {
          // Wait interval
          await Future.delayed(Duration(seconds: intervalSeconds));
          if (_chainActive[id] != true) break;
          try {
            await showNow(id, title, body);
          } catch (e) {
            debugPrint('⚠️ Chain repeater showNow failed for id $id: $e');
          }
        }
      } catch (err) {
        debugPrint('⚠️ Chain repeater loop error for id $id: $err');
      } finally {
        _chainActive.remove(id);
      }
    });
  }

  /// Stop a chain-based repeater.
  void stopChainRepeater(int id) {
    _chainActive[id] = false;
    _chainActive.remove(id);
  }

  void stopInAppRepeater(int id) {
    final timer = _inAppTimers.remove(id);
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
    // Also stop chain repeaters for completeness
    stopChainRepeater(id);
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
